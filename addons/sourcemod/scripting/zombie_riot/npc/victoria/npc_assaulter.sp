#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/sniper_paincrticialdeath01.mp3",
	"vo/sniper_paincrticialdeath02.mp3",
	"vo/sniper_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/sniper_painsharp01.mp3",
	"vo/sniper_painsharp02.mp3",
	"vo/sniper_painsharp03.mp3",
	"vo/sniper_painsharp04.mp3",
};


static const char g_IdleAlertedSounds[][] = {
	"vo/sniper_battlecry01.mp3",
	"vo/sniper_battlecry02.mp3",
	"vo/sniper_battlecry03.mp3",
	"vo/sniper_battlecry04.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/smg_shoot.wav",
};


void VictoriaAssulter_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	PrecacheModel("models/player/sniper.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Assulter");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_assaulter");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_assaulter");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return VictoriaAssulter(client, vecPos, vecAng, ally);
}

methodmap VictoriaAssulter < CClotBody
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

	public VictoriaAssulter(int client, float vecPos[3], float vecAng[3], int ally)
	{
		VictoriaAssulter npc = view_as<VictoriaAssulter>(CClotBody(vecPos, vecAng, "models/player/sniper.mdl", "1.0", "7000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		func_NPCDeath[npc.index] = VictoriaAssulter_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = VictoriaAssulter_OnTakeDamage;
		func_NPCThink[npc.index] = VictoriaAssulter_ClotThink;
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 250.0;
		npc.m_iOverlordComboAttack = 2;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_pro_smg/c_pro_smg.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/sniper/sum23_preventative_measure/sum23_preventative_measure.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/sniper/sum24_aimframe/sum24_aimframe.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		return npc;
	}
}

public void VictoriaAssulter_ClotThink(int iNPC)
{
	VictoriaAssulter npc = view_as<VictoriaAssulter>(iNPC);
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

	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );

		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else 
		{
			NPC_SetGoalEntity(npc.index, npc.m_iTarget);
		}
		VictoriaAssulterSelfDefense(npc,GetGameTime(npc.index)); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action VictoriaAssulter_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictoriaAssulter npc = view_as<VictoriaAssulter>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	return Plugin_Changed;
	}

	public void VictoriaAssulter_NPCDeath(int entity)
	{
	VictoriaAssulter npc = view_as<VictoriaAssulter>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		

	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}

void VictoriaAssulterSelfDefense(VictoriaAssulter npc, float gameTime)
{
	int target;
	//some Ranged units will behave differently.
	//not this one.
	target = npc.m_iTarget;
	if(!IsValidEnemy(npc.index,target))
	{
		if(npc.m_iChanged_WalkCycle != 4)
		{
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 4;
			npc.SetActivity("ACT_MP_RUN_SECONDARY");
			npc.m_flSpeed = 250.0;
			npc.StartPathing();
		}
		return;
	}
	float vecTarget[3]; WorldSpaceCenter(target, vecTarget);

	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
	if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0))
	{
		int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
		if(IsValidEnemy(npc.index, Enemy_I_See))
		{
			if(npc.m_iChanged_WalkCycle != 5)
			{
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 5;
				npc.SetActivity("ACT_MP_STAND_SECONDARY");
				npc.m_flSpeed = 0.0;
				npc.StopPathing();
			}	
			if(gameTime > npc.m_flNextMeleeAttack)
			{
				if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0))
				{	
					npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY", false);
					npc.PlayMeleeSound();
					npc.FaceTowards(vecTarget, 20000.0);
					Handle swingTrace;
					if(npc.DoSwingTrace(swingTrace, target, { 9999.0, 9999.0, 9999.0 }))
					{
						target = TR_GetEntityIndex(swingTrace);	
							
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						float origin[3], angles[3];
						view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
						ShootLaser(npc.m_iWearable1, "bullet_tracer02_blue_crit", origin, vecHit, false );
						if(npc.m_iOverlordComboAttack <= 0)
						{
							npc.m_iOverlordComboAttack = 2;
							float Cooldown = 0.3;
							if(NpcStats_VictorianCallToArms(npc.index))
							{
								Cooldown *= 0.5;
							}
							npc.m_flNextMeleeAttack = GetGameTime(npc.index) + Cooldown;
						}
						else
						{
							npc.m_iOverlordComboAttack --;
							float ShorterFire = 0.1;
							if(NpcStats_VictorianCallToArms(npc.index))
							{
								ShorterFire *= 0.5;
							}
							npc.m_flNextMeleeAttack = GetGameTime(npc.index) + ShorterFire;
						}

						if(IsValidEnemy(npc.index, target))
						{
							float damageDealt = 10.0;
							if(ShouldNpcDealBonusDamage(target))
								damageDealt *= 3.0;


							SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
						}
					}
					delete swingTrace;
				}
			}
		}
		else
		{
			if(npc.m_iChanged_WalkCycle != 4)
			{
				npc.m_bisWalking = true;
				npc.m_iChanged_WalkCycle = 4;
				npc.SetActivity("ACT_MP_RUN_PRIMARY");
				npc.m_flSpeed = 250.0;
				npc.StartPathing();
			}
		}
	}
	else
	{
		if(npc.m_iChanged_WalkCycle != 4)
		{
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 4;
			npc.SetActivity("ACT_MP_RUN_PRIMARY");
			npc.m_flSpeed = 250.0;
			npc.StartPathing();
		}
	}
}