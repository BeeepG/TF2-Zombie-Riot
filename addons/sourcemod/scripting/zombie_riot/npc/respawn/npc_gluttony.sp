#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/heavy_paincrticialdeath01.mp3",
	"vo/heavy_paincrticialdeath02.mp3",
	"vo/heavy_paincrticialdeath03.mp3",
};

static const char g_SoldierScreamSounds[][] = {
	"vo/soldier_paincrticialdeath01.mp3",
	"vo/soldier_paincrticialdeath02.mp3",
	"vo/soldier_paincrticialdeath03.mp3"
};

static const char g_HurtSounds[][] = {
	"vo/heavy_painsharp01.mp3",
	"vo/heavy_painsharp02.mp3",
	"vo/heavy_painsharp03.mp3",
	"vo/heavy_painsharp04.mp3",
	"vo/heavy_painsharp05.mp3",
};


static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/heavy_taunts16.mp3",
	"vo/taunts/heavy_taunts18.mp3",
	"vo/taunts/heavy_taunts19.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"vo/heavy_meleeing01.mp3",
	"vo/heavy_meleeing02.mp3",
	"vo/heavy_meleeing03.mp3",
	"vo/heavy_meleeing04.mp3",
	"vo/heavy_meleeing05.mp3",
	"vo/heavy_meleeing06.mp3",
	"vo/heavy_meleeing07.mp3",
	"vo/heavy_meleeing08.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/cbar_hitbod1.wav",
	"weapons/cbar_hitbod2.wav",
	"weapons/cbar_hitbod3.wav",
};


void Gluttony_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	PrecacheModel("models/player/heavy.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Gluttony");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_gluttony");
	strcopy(data.Icon, sizeof(data.Icon), "heavy_heal_intertius_1");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Interitus;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Gluttony(vecPos, vecAng, team);
}

methodmap Gluttony < CClotBody
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
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}

	public void PlayEatingSound()
	{
		EmitSoundToAll(g_EatingSounds[GetRandomInt(0, sizeof(g_EatingSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		EmitSoundToAll(g_EatingSounds[GetRandomInt(0, sizeof(g_EatingSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}

	public void PlaySoldierScream() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);

	}
	property float m_flAbilityDuration
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	
	
	public Gluttony(float vecPos[3], float vecAng[3], int ally)
	{
		Gluttony npc = view_as<Gluttony>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.5", "10000", ally, false, true));
		
		i_NpcWeight[npc.index] = 2;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PASSTIME");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		npc.Anger = false;

		func_NPCDeath[npc.index] = view_as<Function>(Gluttony_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Gluttony_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Gluttony_ClotThink);
		
		
		npc.StartPathing();
		npc.m_flSpeed = 250.0;
		
		ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);	
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		

		npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/heavy/big_jaw.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/heavy/hwn_heavy_misc1.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/all_class/dec18_bread_heads/dec18_bread_heads_heavy.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/heavy/dec24_battle_balaclava_style1/dec24_battle_balaclava_style1.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/all_class/hwn2025_face_lift/hwn2025_face_lift_heavy.mdl");
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/heavy/sum26_tzar_athlete_style2/sum26_tzar_athlete_style2.mdl");
		
		SetEntityRenderColor(npc.index, 100, 150, 150, 255);
		SetEntityRenderColor(npc.m_iWearable3, 125, 0, 0, 255);
		SetEntityRenderColor(npc.m_iWearable5, 125, 0, 0, 255);
		SetEntityRenderColor(npc.m_iWearable6, 100, 150, 150, 255);

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);


		float Vec[3], Ang[3]={0.0,0.0,0.0};
		npc.GetAttachment("effect_hand_r", Vec, Ang);
		npc.m_iWearable7 = npc.EquipItemSeperate("models/player/soldier.mdl",_,1,1.001,_,true);
		/*
		Ang = view_as<float>( { 0.0, -90.0, -90.0 } );
		Vec[0] += 37.5;
		Vec[2] += 51.2;
		*/
		TeleportEntity(npc.m_iWearable7, Vec, Ang, NULL_VECTOR);
		SetEntityRenderColor(npc.m_iWearable7, 125, 125, 125, 255);
		SetVariantString("0.5");
		AcceptEntityInput(npc.m_iWearable7, "SetModelScale");

		return npc;
	}
}

public void Gluttony_ClotThink(int iNPC)
{
	Gluttony npc = view_as<Gluttony>(iNPC);
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
	
	if(npc.Anger)
	{
		switch(npc.m_iState)
		{
			case 0:
			{
				npc.StopPathing();				
				npc.m_bisWalking = false;
				npc.AddActivityViaSequence("taunt04");
				npc.SetCycle(0.05);
				npc.SetPlaybackRate(2.0);
				npc.PlayEatingSound();
				IncreaseEntityDamageTakenBy(npc.index, 0.15, 2.0);
				npc.m_flAttackHappens = 0.0;
				npc.m_flSpeed = 0.0;
				npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 2.0;
				npc.m_flAbilityDuration = gameTime + 1.00;
				npc.m_iState=1;
				npc.PlaySoldierScream();
			}	
			case 1:
			{
				if(npc.m_flAbilityDuration < gameTime)
				{
					if(IsValidEntity(npc.m_iWearable7))
						RemoveEntity(npc.m_iWearable7);
					float flMaxhealth = float(ReturnEntityMaxHealth(npc.index));
					flMaxhealth *= 1.25;
					SetEntProp(npc.index, Prop_Data, "m_iHealth", RoundToNearest(flMaxhealth));
					DesertYadeamDoHealEffect(npc.index, 250.0);

					npc.m_iState=2;
				}
			}
		}
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
		GluttonySelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action Gluttony_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Gluttony npc = view_as<Gluttony>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	int maxhealth = ReturnEntityMaxHealth(npc.index);
	int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	float ratio = float(health) / float(maxhealth);
	if(ratio<0.5 || (float(health)-damage)<(maxhealth*0.5))
	{
		if(!npc.Anger)
		{
			damage=0.0;
			npc.Anger = true;
		}
	}
	
	return Plugin_Changed;
}


public void Gluttony_NPCDeath(int entity)
{
	Gluttony npc = view_as<Gluttony>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
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

void GluttonySelfDefense(Gluttony npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1))//Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{		
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(!NpcStats_IsEnemySilenced(npc.index) && !IsValidEnemy(npc.index, target))	// Killed target, spawn 3 copies
				{
					npc.Anger = false;
					float Vec[3], Ang[3]={0.0,0.0,0.0};
					npc.GetAttachment("effect_hand_r", Vec, Ang);
					npc.m_iWearable7 = npc.EquipItemSeperate("models/player/soldier.mdl",_,1,1.001,_,true);
					/*
					Ang = view_as<float>( { 0.0, -90.0, -90.0 } );
					Vec[0] += 37.5;
					Vec[2] += 51.2;
					*/
					TeleportEntity(npc.m_iWearable7, Vec, Ang, NULL_VECTOR);
					SetEntityRenderColor(npc.m_iWearable7, 125, 125, 125, 255);
					SetVariantString("0.5");
					AcceptEntityInput(npc.m_iWearable7, "SetModelScale");
				}
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 100.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 1.5;
					if(!npc.Anger)
						damageDealt *= 1.5;

					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_GRENADE",_,_,_,1.5);
						
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 1.0;
			}
		}
	}
}

void GluttonyAllyHealInternal(int entity, int victim)
{
	int flHealth = GetEntProp(victim, Prop_Data, "m_iHealth");
	int flMaxHealth = ReturnEntityMaxHealth(victim);

	if(b_thisNpcIsABoss[victim] || b_thisNpcIsARaid[victim])
	{
		//bosses and raids need much more overheal to get this insanely strong buff!
		flMaxHealth = RoundToCeil(float(flMaxHealth) * 1.5);
	}
	else
	{
		flMaxHealth = RoundToCeil(float(flMaxHealth) * 1.15);
	}
	//silence disables this superbuff accuring.
	if(!NpcStats_IsEnemySilenced(entity) && !NpcStats_IsEnemySilenced(victim))
	{
		if(flHealth > flMaxHealth)
		{
			//super power!
			ApplyStatusEffect(entity, victim, "War Cry", 999999.0);	
			ApplyStatusEffect(entity, victim, "Defensive Backup", 999999.0);	
		}
	}
}