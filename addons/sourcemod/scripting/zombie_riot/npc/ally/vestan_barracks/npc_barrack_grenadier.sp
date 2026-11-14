#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/scout_sf12_badmagic03.mp3",
	"vo/scout_sf12_badmagic04.mp3",
	"vo/scout_sf12_badmagic05.mp3",
};

static const char g_IdleSounds[][] =
{
	"vo/taunts/soldier_taunts01.mp3",
	"vo/taunts/soldier_taunts09.mp3",
	"vo/taunts/soldier_taunts14.mp3",
};

static const char g_RangedAttackSounds[][] =
{
	"weapons/cleaver_throw.wav",
};

static const char g_IdleAlert[][] =
{
	"vo/taunts/soldier_taunts02.mp3",
	"vo/taunts/soldier_taunts03.mp3",
	"vo/taunts/soldier_taunts04.mp3",
	"vo/taunts/soldier_taunts05.mp3",
	"vo/taunts/soldier_taunts06.mp3",
	"vo/taunts/soldier_taunts07.mp3",
	"vo/taunts/soldier_taunts08.mp3",
};

void Barrack_Vestan_Grenadier_Precache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_IdleAlert);
	PrecacheModel("models/player/soldier.mdl");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Vestan Grenadier");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_grenadier");
	data.IconCustom = false;
	
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return Barrack_Vestan_Grenadier(client, vecPos, vecAng);
}

methodmap Barrack_Vestan_Grenadier < BarrackBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	public void PlayIdleAlertSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlert[GetRandomInt(0, sizeof(g_IdleAlert) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}
	public void PlayNPCDeath()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}

	public Barrack_Vestan_Grenadier(int client, float vecPos[3], float vecAng[3])
	{
		Barrack_Vestan_Grenadier npc = view_as<Barrack_Vestan_Grenadier>(BarrackBody(client, vecPos, vecAng, "140", "models/player/soldier.mdl", STEPTYPE_NORMAL,_,_,"models/pickups/pickup_powerup_precision.mdl"));
		
		i_NpcWeight[npc.index] = 1;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = Barrack_Vestan_Grenadier_NPCDeath;
		func_NPCThink[npc.index] = Barrack_Vestan_Grenadier_ClotThink;
		npc.m_flSpeed = 125.0;

		npc.m_flNextRangedAttack = 0.0;
		npc.m_flRangedSpecialDelay = 0.0;

		
		KillFeed_SetKillIcon(npc.index, "frontier_kill");
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/zombie_riot/weapons/custom_weaponry_1_57.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
        SetVariantInt(65536);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/soldier/beard/beard.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/fall17_attack_packs/fall17_attack_packs.mdl");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/soldier/sum23_stealth_bomber_style1/sum23_stealth_bomber_style1.mdl");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
        npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/all_class/sum24_brand_loyalist/sum24_brand_loyalist_soldier.mdl");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

public void Barrack_Vestan_Grenadier_ClotThink(int iNPC)
{
	Barrack_Vestan_Grenadier npc = view_as<Barrack_Vestan_Grenadier>(iNPC);
	float GameTime = GetGameTime(iNPC);
	
	GrantEntityArmor(iNPC, true, 0.5, 0.66, 0);
	
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		int client = BarrackBody_ThinkTarget(npc.index, true, GameTime);
		int PrimaryThreatIndex = npc.m_iTarget;

		if(PrimaryThreatIndex > 0)
		{
			npc.PlayIdleAlertSound();
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			if(flDistanceToTarget < 100000.0)
			{
				int Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					if((npc.m_flNextRangedAttack < GameTime))
					{
						static float flMyPos[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flMyPos);
						static float hullcheckmaxs[3];
						static float hullcheckmins[3];

						//Defaults:
						//hullcheckmaxs = view_as<float>( { 24.0, 24.0, 72.0 } );
						//hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );

						hullcheckmaxs = view_as<float>( { 35.0, 35.0, 500.0 } ); //check if above is free
						hullcheckmins = view_as<float>( { -35.0, -35.0, 17.0 } );

						if(!IsSpaceOccupiedWorldOnly(flMyPos, hullcheckmins, hullcheckmaxs, npc.index))
						{
							float RocketDamage = 675.0;
							float RocketSpeed = 900.0;
							float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
							float VecStart[3]; WorldSpaceCenter(npc.index, VecStart );
							float vecDest[3];
							vecDest = vecTarget;
							vecDest[0] += GetRandomFloat(-100.0, 100.0);
							vecDest[1] += GetRandomFloat(-100.0, 100.0);
							vecDest[2] += GetRandomFloat(-100.0, 100.0);

							float SpeedReturn[3];
							npc.AddGesture("ACT_MP_PASSTIME_THROW_END",false);

							int RocketGet = npc.FireRocket(vecDest, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), RocketDamage, 1), RocketSpeed, "models/weapons/w_grenade.mdl",1.25, _, _,GetClientOfUserId(npc.OwnerUserId));	
							SetEntityGravity(RocketGet, 1.0); 	
							ArcToLocationViaSpeedProjectile(RocketGet, vecDest, SpeedReturn, 1.25, 1.0);
							Better_Gravity_Rocket(RocketGet, 55.0);
							TeleportEntity(RocketGet, NULL_VECTOR, NULL_VECTOR, SpeedReturn);
						}
						else
						{
							npc.AddGesture("ACT_MP_THROW", false);
							float speed = 800.0;
							float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
							npc.FireRocket(vPredictedPos, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), 455.0, 1), speed+100.0, "models/weapons/w_grenade.mdl",1.25, _, _,GetClientOfUserId(npc.OwnerUserId));	
						}
						
						npc.PlayRangedSound();
						npc.FaceTowards(vecTarget, 250000.0);
						npc.m_flNextRangedAttack = GameTime + (2.0 * npc.BonusFireRate);		
					}
					else
					{
						npc.m_flSpeed = 100.0;
					}
				}
			}
		}
		else
		{
			npc.PlayIdleSound();
		}

		BarrackBody_ThinkMove(npc.index, 125.0, "ACT_MP_COMPETITIVE_WINNERSTATE", "ACT_MP_RUN_PASSTIME", 85000.0,_, true);
	}
}

void Barrack_Vestan_Grenadier_NPCDeath(int entity)
{
	Barrack_Vestan_Grenadier npc = view_as<Barrack_Vestan_Grenadier>(entity);
	BarrackBody_NPCDeath(npc.index);
	npc.PlayNPCDeath();
}
