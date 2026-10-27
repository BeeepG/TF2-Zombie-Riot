#pragma semicolon 1
#pragma newdecls required


#define Vesta_Ambulance "models/workshop/player/items/medic/taunt_the_mannbulance/taunt_the_mannbulance.mdl"

static const char g_DeathSounds[][] = {
	")physics/metal/metal_canister_impact_hard1.wav",
	")physics/metal/metal_canister_impact_hard2.wav",
	")physics/metal/metal_canister_impact_hard3.wav",
};

static const char g_HurtSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};

void Vesta_Ambulance_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Vestan Ambulance");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ambulance");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.Flags = -1;
	data.Category = Type_Vesta;
	data.Func = ClotSummon;
	NPC_Add(data);
	PrecacheModel(Vesta_Ambulance);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Vestan_Ambulance(vecPos, vecAng, team);
}
methodmap Vestan_Ambulance < CClotBody
{
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}

	public Vestan_Ambulance(float vecPos[3], float vecAng[3], int ally)
	{
		Vestan_Ambulance npc = view_as<Vestan_Ambulance>(CClotBody(vecPos, vecAng, Vesta_Ambulance, "1.1", "5000", ally, .NpcTypeLogic = 1));
		
		i_NpcWeight[npc.index] = 999;
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 1.0;

		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		npc.m_bDissapearOnDeath = true;
		Is_a_Medic[npc.index] = true;
		f_ExtraOffsetNpcHudAbove[npc.index] = 500.0;
		i_NpcIsABuilding[npc.index] = true;

		func_NPCDeath[npc.index] = view_as<Function>(Vestan_Ambulance_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Vestan_Ambulance_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Vestan_Ambulance_ClotThink);

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		//IDLE
		npc.m_iState = 0;
		npc.m_flSpeed = 0.0;

		//counts as a static npc, means it wont count towards NPC limit.
		AddNpcToAliveList(npc.index, 1);

		return npc;
	}
}

public void Vestan_Ambulance_ClotThink(int iNPC)
{
	Vestan_Ambulance npc = view_as<Vestan_Ambulance>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	//Need to check this often sadly.
	if(!IsValidAlly(npc.index, GetClosestAlly(npc.index)))
	{
		//there is no more valid ally, suicide.
		SmiteNpcToDeath(npc.index);
		return;
	}
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	if(npc.m_iState == 0)
	{
		npc.m_iState = 1;
		SetEntityRenderMode(npc.index, RENDER_NORMAL);
		SetEntityRenderColor(npc.index, 255, 255, 255, 255);
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.5;
	
	ExpidonsaGroupHeal(npc.index, 300.0, 99, (100.0 * fl_Extra_Damage[npc.index]) , 1.0, false,Expidonsa_DontHealSameIndex);
	DesertYadeamDoHealEffect(npc.index, 300.0);
	npc.m_flNextRangedSpecialAttack = 0.0;
}

public Action Vestan_Ambulance_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Vestan_Ambulance npc = view_as<Vestan_Ambulance>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Vestan_Ambulance_NPCDeath(int entity)
{
	Vestan_Ambulance npc = view_as<Vestan_Ambulance>(entity);
	npc.PlayDeathSound();	
	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	makeexplosion(-1, pos, 0, 0);
}