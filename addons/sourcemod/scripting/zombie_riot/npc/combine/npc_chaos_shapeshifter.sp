#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav"
};

static const char g_HurtSounds[][] = {
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav"
};

static const char g_IdleAlertedSounds[][] = {
	"npc/combine_soldier/vo/prison_soldier_bunker1.wav",
	"npc/combine_soldier/vo/prison_soldier_bunker2.wav",
	"npc/combine_soldier/vo/prison_soldier_bunker3.wav"
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav"
};

static const char g_MeleeHitSounds[][] = {
	"weapons/cleaver_hit_02.wav",
	"weapons/cleaver_hit_03.wav",
	"weapons/cleaver_hit_05.wav",
	"weapons/cleaver_hit_06.wav",
	"weapons/cleaver_hit_07.wav",
};

static const char g_RangeAttackSounds[][] = {
	"weapons/rpg/rocketfire1.wav",
};

static const char g_MageAttackSounds[][] = {
	"ambient/cp_harbor/furnace_1_shot_05.wav",
};

void WF_Shapeshifter_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Shapeshifter");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_chaos_shapeshifter");
	strcopy(data.Icon, sizeof(data.Icon), "scout_bat");
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
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_RangeAttackSounds);
	PrecacheSoundArray(g_MageAttackSounds);
	PrecacheModel("models/player/scout.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return WF_Shapeshifter(vecPos, vecAng, ally);
}

methodmap WF_Shapeshifter < CClotBody
{
	property int m_iBulletHit
	{
		public get()							{ return i_OverlordComboAttack[this.index]; }
		public set(int TempValueForProperty) 	{ i_OverlordComboAttack[this.index] = TempValueForProperty; }
	}
	property int m_iMagicHit
	{
		public get()							{ return i_OverlordComboAttack[this.index]; }
		public set(int TempValueForProperty) 	{ i_OverlordComboAttack[this.index] = TempValueForProperty; }
	}
	property int m_iExplosionHit
	{
		public get()							{ return i_OverlordComboAttack[this.index]; }
		public set(int TempValueForProperty) 	{ i_OverlordComboAttack[this.index] = TempValueForProperty; }
	}
	property int m_iMeleeHit
	{
		public get()							{ return i_OverlordComboAttack[this.index]; }
		public set(int TempValueForProperty) 	{ i_OverlordComboAttack[this.index] = TempValueForProperty; }
	}
	
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
	public void PlayRangeSound()
	{
		EmitSoundToAll(g_RangeAttackSounds[GetRandomInt(0, sizeof(g_RangeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMageSound()
	{
		EmitSoundToAll(g_MageAttackSounds[GetRandomInt(0, sizeof(g_MageAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}

	public WF_Shapeshifter(float vecPos[3], float vecAng[3], int ally)
	{
		WF_Shapeshifter npc = view_as<WF_Shapeshifter>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_2_MODEL, "1.15", "100", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_GULN_CORRUPTED_SECOND_WALK");
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE_METRO;

		func_NPCDeath[npc.index] = view_as<Function>(WF_Shapeshifter_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(WF_Shapeshifter_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(WF_Shapeshifter_ClotThink);
		
		//IDLE
		//KillFeed_SetKillIcon(npc.index, "bat");
		npc.m_iState = 9;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 250.0;

		npc.Anger = false;
		npc.m_fbRangedSpecialOn = false;

		npc.m_iBulletHit = 0;
		npc.m_iMagicHit = 0;
		npc.m_iExplosionHit = 0;
		npc.m_iMeleeHit = 0;
		
		float flPos[3], flAng[3];
				
		npc.GetAttachment("eyes", flPos, flAng);
		npc.m_iWearable4 = ParticleEffectAt_Parent(flPos, "unusual_smoking", npc.index, "eyes", {0.0,0.0,0.0});
		npc.m_iWearable5 = ParticleEffectAt_Parent(flPos, "unusual_psychic_eye_white_glow", npc.index, "eyes", {0.0,0.0,-15.0});
		npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "utaunt_2fort_teamc_red_smoke1", npc.index, "m_vecAbsOrigin", {0.0,0.0,10.0});

		ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);		
		ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", 999999.0);
		
		SetEntityRenderColor(npc.index, 150, 150, 150, 175);

		return npc;
	}
}

static void WF_Shapeshifter_ClotThink(int iNPC)
{
	WF_Shapeshifter npc = view_as<WF_Shapeshifter>(iNPC);
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
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		WF_ShapeshifterSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}

	if(npc.m_fbRangedSpecialOn)
	{
		npc.m_iState = 0;
	}
	else if(npc.m_iBulletHit > 5)
	{
		npc.m_iState = 1;
	}
	else if(npc.m_iExplosionHit > 5)
	{
		npc.m_iState = 2;
	}
	else if(npc.m_iMagicHit > 5)
	{
		npc.m_iState = 3;
	}
	else if(npc.m_iMeleeHit > 5)
	{
		npc.m_iState = 4;
	}
	if(!npc.Anger)
	{
		switch(npc.m_iState)
		{
			case 0:
			{
				npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/medic/robo_medic_blighted_beak/robo_medic_blighted_beak.mdl");
				SetVariantString("1.2");
				AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
				SetEntityRenderColor(npc.m_iWearable2, 150, 150, 150, 175);
				npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/sf14_the_battle_bird/sf14_the_battle_bird.mdl");
				SetVariantString("1.1");
				AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
				SetEntityRenderColor(npc.m_iWearable3, 150, 150, 150, 175);
				if(IsValidEntity(npc.m_iWearable6))
				RemoveEntity(npc.m_iWearable6);
				float flPos[3], flAng[3];
				npc.GetAttachment("m_vecAbsOrigin", flPos, flAng);
				npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "utaunt_arcane_yellow_glow", npc.index, "m_vecAbsOrigin", {0.0,0.0,10.0});
				npc.GetAttachment("LHand", flPos, flAng);
				npc.m_iWearable7 = ParticleEffectAt_Parent(flPos, "flaregun_trail_crit_blue", npc.index, "LHand", {0.0,0.0,0.0});
				npc.GetAttachment("RHand", flPos, flAng);
				npc.m_iWearable8 = ParticleEffectAt_Parent(flPos, "flaregun_trail_crit_red", npc.index, "RHand", {0.0,0.0,0.0});
				npc.SetActivity("ACT_CALMATICUS_RUN");
				npc.m_flSpeed = 300.0;
				npc.m_flMeleeArmor = 0.6;
				npc.m_flRangedArmor = 0.5;
				SetEntProp(npc.index, Prop_Data, "m_iHealth", 30000);
				SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", 30000);
				ApplyStatusEffect(npc.index, npc.index, "King's Dying Breath", 999999.0);
				npc.Anger = true;
			}
			case 1:
			{
				npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_trenchgun/c_trenchgun.mdl");
				SetEntityRenderColor(npc.m_iWearable1, 150, 150, 150, 200);
				npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/spy/sum22_night_vision_gawkers/sum22_night_vision_gawkers.mdl");
				SetVariantString("1.25");
				AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
				SetEntityRenderColor(npc.m_iWearable2, 150, 150, 150, 175);
				npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/engineer/sum22_lawnmaker_style2/sum22_lawnmaker_style2.mdl");
				SetVariantString("1.2");
				AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
				SetEntityRenderColor(npc.m_iWearable3, 150, 150, 150, 175);
				if(IsValidEntity(npc.m_iWearable6))
				RemoveEntity(npc.m_iWearable6);
				float flPos[3], flAng[3];
				npc.GetAttachment("m_vecAbsOrigin", flPos, flAng);
				npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "utaunt_aestheticlogo_blue_lines", npc.index, "m_vecAbsOrigin", {0.0,0.0,10.0});
				npc.SetActivity("ACT_CALMATICUS_MINIGUN_WALK");
				npc.m_flMeleeArmor = 1.25;
				npc.m_flRangedArmor = 0.5;
				SetEntProp(npc.index, Prop_Data, "m_iHealth", 35000);
				SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", 35000);
				ApplyStatusEffect(npc.index, npc.index, "Mazeat Command", 999999.0);
				npc.Anger = true;
			}
			case 2:
			{
				npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_caber/c_caber.mdl");
				SetEntityRenderColor(npc.m_iWearable1, 150, 150, 150, 200);
				npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/demo/sum22_head_banger/sum22_head_banger.mdl");
				SetVariantString("1.2");
				AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
				SetEntityRenderColor(npc.m_iWearable2, 150, 150, 150, 175);
				npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/heavy/fall17_heavy_harness/fall17_heavy_harness.mdl");
				SetVariantString("1.2");
				AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
				SetEntityRenderColor(npc.m_iWearable3, 150, 150, 150, 175);
				if(IsValidEntity(npc.m_iWearable6))
				RemoveEntity(npc.m_iWearable6);
				float flPos[3], flAng[3];
				npc.GetAttachment("m_vecAbsOrigin", flPos, flAng);
				npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "utaunt_god_lava_crack3", npc.index, "m_vecAbsOrigin", {0.0,0.0,0.0});
				npc.SetActivity("ACT_SHADOW_RUN");
				npc.m_flSpeed = 320.0;
				npc.m_flMeleeArmor = 1.0;
				npc.m_flRangedArmor = 0.75;
				SetEntProp(npc.index, Prop_Data, "m_iHealth", 40000);
				SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", 40000);
				ApplyStatusEffect(npc.index, npc.index, "Mazeat Command", 999999.0);
				npc.Anger = true;
			}
			case 3:
			{
				npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop_partner/weapons/c_models/c_tw_eagle/c_tw_eagle.mdl");
				SetEntityRenderColor(npc.m_iWearable1, 150, 150, 150, 200);
				SetVariantString("0.7");
				AcceptEntityInput(npc.m_iWearable1 , "SetModelScale");
				npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/sniper/hwn2023_sightseer/hwn2023_sightseer.mdl");
				SetVariantString("1.2");
				AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
				SetEntityRenderColor(npc.m_iWearable2, 150, 150, 150, 200);
				if(IsValidEntity(npc.m_iWearable6))
				RemoveEntity(npc.m_iWearable6);
				float flPos[3], flAng[3];
				npc.GetAttachment("m_vecAbsOrigin", flPos, flAng);
				npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "utaunt_hellswirl_smoke", npc.index, "m_vecAbsOrigin", {0.0,0.0,0.0});
				npc.SetActivity("ACT_GULN_NORMAL_FIRST_WALK");
				npc.m_flSpeed = 270.0;
				npc.m_flMeleeArmor = 0.7;
				npc.m_flRangedArmor = 0.7;
				SetEntProp(npc.index, Prop_Data, "m_iHealth", 40000);
				SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", 40000);
				ApplyStatusEffect(npc.index, npc.index, "Expidonsan War Cry", 999999.0);
				npc.Anger = true;
			}
			case 4:
			{
				npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl");
				SetVariantString("0.8");
				AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
				SetEntityRenderColor(npc.m_iWearable1, 150, 150, 150, 200);
				AcceptEntityInput(npc.m_iWearable1 , "SetModelScale");
				npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/demo/sf14_deadking_pauldrons/sf14_deadking_pauldrons.mdl");
				SetEntityRenderColor(npc.m_iWearable2, 150, 150, 150, 200);
				npc.m_iWearable3 = npc.EquipItem("partyhat", "models/workshop/player/items/demo/sf14_deadking_head/sf14_deadking_head.mdl");
				SetVariantString("1.2");
				AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
				SetEntityRenderColor(npc.m_iWearable3, 150, 150, 150, 200);
				if(IsValidEntity(npc.m_iWearable6))
				RemoveEntity(npc.m_iWearable6);
				float flPos[3], flAng[3];
				npc.GetAttachment("m_vecAbsOrigin", flPos, flAng);
				npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "utaunt_2fort_teamc_red_globe1", npc.index, "m_vecAbsOrigin", {0.0,0.0,0.0});
				npc.SetActivity("ACT_TEUTON_WALK_NEW_XENO");
				npc.m_flSpeed = 270.0;
				npc.m_flMeleeArmor = 0.4;
				npc.m_flRangedArmor = 1.0;
				SetEntProp(npc.index, Prop_Data, "m_iHealth", 50000);
				SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", 50000);
				ApplyStatusEffect(npc.index, npc.index, "Hussar's Warscream", 999999.0);
				npc.Anger = true;
			}
		}
	}

	npc.PlayIdleAlertSound();
}

static Action WF_Shapeshifter_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	WF_Shapeshifter npc = view_as<WF_Shapeshifter>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	if(!npc.Anger)
	{
		if((damagetype & DMG_TRUEDAMAGE))
		{
			npc.m_fbRangedSpecialOn = true;
		}

		if((damagetype & DMG_CLUB))
		{
			npc.m_iMeleeHit++;
		}

		if((damagetype & DMG_BULLET))
		{
			npc.m_iBulletHit++;
		}

		if((damagetype & DMG_BLAST))
		{
			npc.m_iExplosionHit++;
		}
		
		if((damagetype & DMG_PLASMA) || (i_HexCustomDamageTypes[victim] & ZR_DAMAGE_LASER_NO_BLAST) || (damagetype & DMG_SHOCK))
		{
			npc.m_iMagicHit++;
		}
		damage = 1.0;
	}
	

	
	return Plugin_Changed;
}

static void WF_Shapeshifter_NPCDeath(int entity)
{
	WF_Shapeshifter npc = view_as<WF_Shapeshifter>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
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

static void WF_ShapeshifterSelfDefense(WF_Shapeshifter npc, float gameTime, int target, float distance)
{
	switch(npc.m_iState)
	{
		case 0:
		{
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
							float damageDealt = 75.0;
							
							if(ShouldNpcDealBonusDamage(target))
								damageDealt *= 3.0;

							int DamageType = DMG_CLUB;

							int PreviousArmor = 0;
							if(IsValidClient(target))
							{
								PreviousArmor = Armor_Charge[target];
								Armor_Charge[target] = 0;
								if(f_ReceivedTruedamageHit[target] < GetGameTime())
								{
									f_ReceivedTruedamageHit[target] = GetGameTime() + 0.5;
									ClientCommand(target, "playgamesound player/crit_received%d.wav", (GetURandomInt() % 3) + 1);
								}
							}
							else
							{
								CClotBody npcenemy = view_as<CClotBody>(target);
								PreviousArmor = RoundToNearest(npcenemy.m_flArmorCount);
								npcenemy.m_flArmorCount = 0.0;
							}
							
							SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DamageType, -1, _, vecHit);

							if(IsValidClient(target))
							{
								Armor_Charge[target] = PreviousArmor;
							}
							else
							{
								CClotBody npcenemy = view_as<CClotBody>(target);
								npcenemy.m_flArmorCount = float(PreviousArmor);
							}

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
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",_,_,_,1.0);
								
						npc.m_flAttackHappens = gameTime + 0.25;
						npc.m_flDoingAnimation = gameTime + 0.25;
						npc.m_flNextMeleeAttack = gameTime + 0.75;
					}
				}
			}
		}
		case 1:
		{
			if(npc.m_flNextMeleeAttack < gameTime)
			{
				if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0))
				{
					int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					if(IsValidEnemy(npc.index, Enemy_I_See))
					{
						npc.m_iTarget = Enemy_I_See;
						npc.PlayRangeSound();
						float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
						npc.FaceTowards(vecTarget, 20000.0);
						Handle swingTrace;
						if(npc.DoSwingTrace(swingTrace, target, { 9999.0, 9999.0, 9999.0 }))
						{
							target = TR_GetEntityIndex(swingTrace);
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							float origin[3], angles[3];
							view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
							ShootLaser(npc.m_iWearable1, "bullet_tracer02_blue", origin, vecHit, false );
							npc.m_flNextMeleeAttack = gameTime + 0.25;

							if(IsValidEnemy(npc.index, target))
							{
								float damageDealt = 35.0;
								if(ShouldNpcDealBonusDamage(target))
									damageDealt *= 3.0;

								SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
							}
						}
						delete swingTrace;
					}
				}
			}
		}
		case 2:
		{
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
							int DamageType = DMG_CLUB;

							if(!ShouldNpcDealBonusDamage(target))
								SDKHooks_TakeDamage(target, npc.index, npc.index, 75.0, DamageType, -1, _, vecHit);
							else
								SDKHooks_TakeDamage(target, npc.index, npc.index, 400.0, DamageType, -1, _, vecHit);
								
							float startPosition[3];
							GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", startPosition);
							makeexplosion(-1, startPosition, 0, 0);

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
						npc.AddGesture("ACT_SHADOW_ATTACK_1",_,_,_,1.0);
								
						npc.m_flAttackHappens = gameTime + 0.25;
						npc.m_flDoingAnimation = gameTime + 0.25;
						npc.m_flNextMeleeAttack = gameTime + 0.8;
					}
				}
			}
		}
		case 3:
		{
			if(npc.m_flNextMeleeAttack < gameTime)
			{
				if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 25.0))
				{	
					float damageDeal = 100.0;
					float ProjectileSpeed = 600.0;

					npc.PlayMageSound();

					float vPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);

					npc.FireParticleRocket(vPredictedPos, damageDeal , ProjectileSpeed , 150.0 , "scorchshot_trail_crit_blue");
					
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",_,_,_,1.0);
					npc.m_flNextMeleeAttack = gameTime + 1.50;	
				}
				
			}
		}
		case 4:
		{
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
							float damageDealt = 100.0;
							
							if(ShouldNpcDealBonusDamage(target))
								damageDealt *= 3.0;

							int DamageType = DMG_CLUB;
							
							SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DamageType, -1, _, vecHit);

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
						npc.AddGesture("ACT_TEUTON_ATTACK_CADE_NEW_XENO",_,_,_,1.0);
								
						npc.m_flAttackHappens = gameTime + 0.25;
						npc.m_flDoingAnimation = gameTime + 0.25;
						npc.m_flNextMeleeAttack = gameTime + 1.0;
					}
				}
			}
		}
	}
	
}