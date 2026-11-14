#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/pyro_painsharp01.mp3",
	"vo/pyro_painsharp02.mp3",
	"vo/pyro_painsharp03.mp3",
	"vo/pyro_painsharp04.mp3",
	"vo/pyro_painsharp05.mp3"
};

static const char g_IdleSounds[][] =
{
	"vo/pyro_jeers01.mp3",	
	"vo/pyro_jeers02.mp3",
};

static const char g_RangedAttackSounds[][] =
{
	"weapons/shotgun/shotgun_fire6.wav",
	"weapons/shotgun/shotgun_fire7.wav",
};

static const char g_IdleAlert[][] =
{
	"vo/pyro_negativevocalization01.mp3",
    "vo/pyro_negativevocalization02.mp3",
};

void Barrack_Vestan_Breacher_Precache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_IdleAlert);
	PrecacheModel("models/player/soldier.mdl");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Vestan Breacher");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_breacher");
	data.IconCustom = false;
	
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return Barrack_Vestan_Breacher(client, vecPos, vecAng);
}

methodmap Barrack_Vestan_Breacher < BarrackBody
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

	public Barrack_Vestan_Breacher(int client, float vecPos[3], float vecAng[3])
	{
		Barrack_Vestan_Breacher npc = view_as<Barrack_Vestan_Breacher>(BarrackBody(client, vecPos, vecAng, "150", "models/player/pyro.mdl", STEPTYPE_NORMAL,_,_,"models/pickups/pickup_powerup_precision.mdl"));
		
		i_NpcWeight[npc.index] = 1;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		SetVariantInt(5);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = Barrack_Vestan_Breacher_NPCDeath;
		func_NPCThink[npc.index] = Barrack_Vestan_Breacher_ClotThink;
		npc.m_flSpeed = 125.0;

		npc.m_flNextRangedAttack = 0.0;
		npc.m_flRangedSpecialDelay = 0.0;

		
		KillFeed_SetKillIcon(npc.index, "frontier_kill");
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_frontierjustice/c_frontierjustice.mdl");
		SetVariantString("0.8");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/pyro/dec22_partizan/dec22_partizan.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/pyro/sum19_spawn_camper_jacket/sum19_spawn_camper_jacket.mdl");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable4 = npc.EquipItem("head", "models/player/items/pyro/winter_pyro_mask.mdl");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 3);
        NpcColourCosmetic_ViaPaint(npc.m_iWearable4, 8289918);
		
		return npc;
	}
}

public void Barrack_Vestan_Breacher_ClotThink(int iNPC)
{
	Barrack_Vestan_Breacher npc = view_as<Barrack_Vestan_Breacher>(iNPC);
	float GameTime = GetGameTime(iNPC);
	
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
						npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY", false);
						npc.m_iTarget = Enemy_I_See;
						npc.PlayRangedSound();
						npc.FaceTowards(vecTarget, 250000.0);
						Handle swingTrace;
						if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex, { 9999.0, 9999.0, 9999.0 }))
						{
							int target = TR_GetEntityIndex(swingTrace);	
								
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							float origin[3], angles[3];
							view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
							ShootLaser(npc.m_iWearable1, "bullet_tracer02_red", origin, vecHit, false );
							
							npc.m_flNextRangedAttack = GameTime + (1.25 * npc.BonusFireRate);
							
							SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), 200.0, 1), DMG_BULLET, -1, _, vecHit);
						} 		
						delete swingTrace;				
					}
					else
					{
						npc.m_flSpeed = 125.0;
					}
				}
			}
		}
		else
		{
			npc.PlayIdleSound();
		}

		BarrackBody_ThinkMove(npc.index, 125.0, "ACT_MP_COMPETITIVE_WINNERSTATE", "ACT_MP_RUN_SECONDARY", 85000.0,_, true);
	}
}

void Barrack_Vestan_Breacher_NPCDeath(int entity)
{
	Barrack_Vestan_Breacher npc = view_as<Barrack_Vestan_Breacher>(entity);
	BarrackBody_NPCDeath(npc.index);
	npc.PlayNPCDeath();
}
