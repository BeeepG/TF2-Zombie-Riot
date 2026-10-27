#pragma semicolon 1
#pragma newdecls required

static const char g_IdleAlertedSounds[][] = {
	")vo/medic_cartstaycloseoffense01.mp3",
	")vo/medic_cartstaycloseoffense02.mp3",
	")vo/medic_cartstaycloseoffense03.mp3",
};

static const char g_DeathSounds[][] = {
	"vo/medic_sf13_magic_reac01.mp3",
	"vo/medic_sf13_magic_reac02.mp3",
	"vo/medic_sf13_magic_reac03.mp3",
	"vo/medic_sf13_magic_reac04.mp3",
	"vo/medic_sf13_magic_reac05.mp3",
	"vo/medic_sf13_magic_reac06.mp3",
	"vo/medic_sf13_magic_reac07.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/axe_hit_flesh1.wav",
	"weapons/axe_hit_flesh2.wav",
	"weapons/axe_hit_flesh3.wav",
};

static const char g_PassiveSound[] = "mvm/giant_scout/giant_scout_loop.wav";
static const char g_MeleeAttackSounds[] = "weapons/knife_swing.wav";

void Vestan_Paramedic_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Paramedic");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_paramedic");
	strcopy(data.Icon, sizeof(data.Icon), "medic"); 
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Vesta;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_DefaultMedic_HurtSounds);
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSound(g_MeleeAttackSounds);
	PrecacheSound(g_PassiveSound);
	PrecacheModel("models/player/medic.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return Vestan_Paramedic(vecPos, vecAng, ally);
}

methodmap Vestan_Paramedic < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_DefaultMedic_HurtSounds[GetRandomInt(0, sizeof(g_DefaultMedic_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds, this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayPassiveSound()
	{
		EmitSoundToAll(g_PassiveSound[GetRandomInt(0, sizeof(g_PassiveSound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 125);
	}
	public void StopPassiveSound()
	{
		StopSound(this.index, SNDCHAN_STATIC, g_PassiveSound[GetRandomInt(0, sizeof(g_PassiveSound) - 1)]);
		StopSound(this.index, SNDCHAN_STATIC, g_PassiveSound[GetRandomInt(0, sizeof(g_PassiveSound) - 1)]);
	}
	
	public Vestan_Paramedic(float vecPos[3], float vecAng[3], int ally)
	{
		Vestan_Paramedic npc = view_as<Vestan_Paramedic>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "1000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_KART_IDLE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = 0;
		
		func_NPCDeath[npc.index] = Vestan_Paramedic_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Vestan_Paramedic_OnTakeDamage;
		func_NPCThink[npc.index] = Vestan_Paramedic_ClotThink;
		
		//IDLE
		KillFeed_SetKillIcon(npc.index, "batsaber");
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_flAttackHappens_bullshit = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_flNextRangedAttack = GetGameTime() + GetRandomFloat(5.0, 45.0);
		npc.m_flSpeed = 225.0;
		npc.StartPathing();
		
		npc.PlayPassiveSound();

		npc.Anger = false;
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/fall17_vitals_vest/fall17_vitals_vest.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/medic_mask/medic_mask.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/sum24_brand_loyalist/sum24_brand_loyalist_medic.mdl");
		
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable5 = npc.EquipItemSeperate("models/workshop/player/items/medic/taunt_the_mannbulance/taunt_the_mannbulance.mdl");
		SetVariantString("1.1");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);

		return npc;
	}
}

static void Vestan_Paramedic_ClotThink(int iNPC)
{
	Vestan_Paramedic npc = view_as<Vestan_Paramedic>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}

	if(!npc.Anger)
	{
		if(npc.m_flNextRangedAttackHappening < GetGameTime())
		{
			npc.m_flNextRangedAttackHappening = GetGameTime() + 2.5;
			DesertYadeamDoHealEffect(npc.index, 300.0);
			npc.AddGesture("ACT_MP_GESTURE_VC_FINGERPOINT_PRIMARY");
		}
		if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
		{
			npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.5;
			ExpidonsaGroupHeal(npc.index, 300.0, 99, (75.0 * fl_Extra_Damage[npc.index]) , 1.0, false,Expidonsa_DontHealSameIndex);
		}
	}

	if(npc.m_flNextRangedAttack < GetGameTime(npc.index) && !npc.Anger)
	{
		npc.Anger = true;
		if(IsValidEntity(npc.m_iWearable5))
			RemoveEntity(npc.m_iWearable5);
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/w_models/w_bonesaw.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		npc.m_flSpeed = 300.0;
		npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		int health = ReturnEntityMaxHealth(npc.index) * 2;

		float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
		float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);

		int entity = NPC_CreateByName("npc_ambulance", -1, pos, ang, GetTeam(npc.index), "EX");
		if(entity > MaxClients)
		{
			if(GetTeam(npc.index) != TFTeam_Red)
				Zombies_Currently_Still_Ongoing++;
			
			SetEntProp(entity, Prop_Data, "m_iHealth", health);
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
			
			fl_Extra_MeleeArmor[entity] = fl_Extra_MeleeArmor[npc.index];
			fl_Extra_RangedArmor[entity] = fl_Extra_RangedArmor[npc.index];
			fl_Extra_Damage[entity] = fl_Extra_Damage[npc.index];
			view_as<CClotBody>(entity).m_iBleedType = BLEEDTYPE_METAL;
		}

		npc.StopPassiveSound();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		if(npc.Anger)
		{
			Vestan_ParamedicSelfDefense(npc,GetGameTime(npc.index), flDistanceToTarget); 
		}
		
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static Action Vestan_Paramedic_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Vestan_Paramedic npc = view_as<Vestan_Paramedic>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void Vestan_Paramedic_NPCDeath(int entity)
{
	Vestan_Paramedic npc = view_as<Vestan_Paramedic>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();	
	ExpidonsaRemoveEffects(entity);

	npc.StopPassiveSound();
	
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}

static void Vestan_ParamedicSelfDefense(Vestan_Paramedic npc, float gameTime, float distance)
{
	if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
	{
		if(npc.m_flNextMeleeAttack < gameTime)
		{
			if(!npc.m_flAttackHappenswillhappen)
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
				npc.PlayMeleeSound();
				npc.m_flAttackHappens = gameTime+0.25;
				npc.m_flAttackHappens_bullshit = gameTime+0.39;
				npc.m_flAttackHappenswillhappen = true;
			}
			if(npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen)
			{
				Handle swingTrace;
				float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
				npc.FaceTowards(vecTarget, 20000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(IsValidEnemy(npc.index, target))
					{
						float damageDealt = 40.0;
						if(ShouldNpcDealBonusDamage(target))
							damageDealt*=2.0;
						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
						npc.PlayMeleeHitSound();
					} 
				}
				delete swingTrace;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
				npc.m_flAttackHappenswillhappen = false;
			}
			else if(npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen)
			{
				npc.m_flAttackHappenswillhappen = false;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}
	}
}