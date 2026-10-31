#pragma semicolon 1
#pragma newdecls required


static const char g_MeleeAttackSounds[][] = {
	"weapons/boxing_gloves_swing1.wav",
	"weapons/boxing_gloves_swing2.wav",
	"weapons/boxing_gloves_swing4.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/cbar_hitbod1.wav",
	"weapons/cbar_hitbod2.wav",
	"weapons/cbar_hitbod3.wav",
};

static const char g_DeathSounds[][] = {
	"vo/heavy_negativevocalization01.mp3",
	"vo/heavy_negativevocalization02.mp3",
	"vo/heavy_negativevocalization03.mp3"
};

static const char g_HurtSounds[][] = {
	"vo/heavy_helpmedefend01.mp3",
	"vo/heavy_helpmedefend02.mp3",
	"vo/heavy_helpmedefend03.mp3"
};


static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/heavy_taunts16.mp3",
	"vo/taunts/heavy_taunts18.mp3",
	"vo/taunts/heavy_taunts19.mp3"
};

void Vestan_Road_Block_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Road Block");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_roadblock");
	strcopy(data.Icon, sizeof(data.Icon), "heavy_steelfist");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Vesta;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return Vestan_Road_Block(vecPos, vecAng, ally);
}

methodmap Vestan_Road_Block < CClotBody
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
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public Vestan_Road_Block(float vecPos[3], float vecAng[3], int ally)
	{
		Vestan_Road_Block npc = view_as<Vestan_Road_Block>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.2", "9000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_CROUCHWALK_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(0);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttackHappening = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;

		func_NPCDeath[npc.index] = view_as<Function>(Vestan_Road_Block_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Vestan_Road_Block_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Vestan_Road_Block_ClotThink);
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 150.0;

		npc.m_flMeleeArmor = 1.00;
		npc.m_flRangedArmor = 0.4;
		
		int skin = 1;

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_fists_of_steel/c_fists_of_steel.mdl");
		SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable1, 100, 100, 150, 255);

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/heavy/robo_heavy_football_helmet/robo_heavy_football_helmet.mdl");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/all_class/bak_batarm/bak_batarm_heavy.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/sum20_spectre_cles_style2/sum20_spectre_cles_style2_heavy.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/heavy/hwn2022_road_rage/hwn2022_road_rage.mdl");
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/heavy/dec24_cossack_camo_style1/dec24_cossack_camo_style1.mdl");


		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

static void Vestan_Road_Block_ClotThink(int iNPC)
{
	Vestan_Road_Block npc = view_as<Vestan_Road_Block>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
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
		Vestan_Road_BlockSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static void Vestan_Road_Block_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Vestan_Road_Block npc = view_as<Vestan_Road_Block>(victim);
		
	if(attacker <= 0)
		return;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
}

static void Vestan_Road_Block_NPCDeath(int entity)
{
	Vestan_Road_Block npc = view_as<Vestan_Road_Block>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();	
	
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

static void Vestan_Road_BlockSelfDefense(Vestan_Road_Block npc, float gameTime, int target, float distance)
{
	if(!npc.m_flNextRangedAttackHappening)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_flNextMeleeAttack = gameTime + 0.25;
				npc.m_flNextRangedAttackHappening = 1.0;
				npc.AddGesture("ACT_MP_GESTURE_VC_FINGERPOINT_PRIMARY");
				if(IsValidEntity(npc.m_iWearable1))
					RemoveEntity(npc.m_iWearable1);
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 1.0;
			}
		}		
		return;
	}
	if(npc.m_flNextMeleeAttack && npc.m_flNextMeleeAttack != 5.0)
	{
		if(npc.m_flNextMeleeAttack < gameTime)
		{
			npc.m_flNextMeleeAttack = 5.0;
			npc.m_flRangedArmor = 1.0;
			npc.m_flDoingAnimation = gameTime + 0.25;
		}
	}
	if(npc.m_flNextMeleeAttack && npc.m_flNextMeleeAttack == 5.0)
	{
		npc.m_flNextMeleeAttack = 0.0;
		npc.SetActivity("ACT_MP_RUN_MELEE");
		npc.m_flSpeed = 300.0;
		return;
	}
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
			{
							
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 60.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 2.0;

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
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 1.25;
			}
		}
	}
}
