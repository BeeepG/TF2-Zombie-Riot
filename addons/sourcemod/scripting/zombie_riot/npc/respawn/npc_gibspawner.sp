#pragma semicolon 1
#pragma newdecls required


void GibSpawner_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Gib");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_gibspawner");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = true;
	data.Flags = -1;
	data.Category = Type_Hidden; 
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return GibSpawner(vecPos, vecAng, team);
}
methodmap GibSpawner < CClotBody
{
	property int m_iTalkWaveAt
	{
		public get()							{ return i_BleedType[this.index]; }
		public set(int TempValueForProperty) 	{ i_BleedType[this.index] = TempValueForProperty; }
	}
	property int m_iRandomTalkNumber
	{
		public get()							{ return i_StepNoiseType[this.index]; }
		public set(int TempValueForProperty) 	{ i_StepNoiseType[this.index] = TempValueForProperty; }
	}
	public GibSpawner(float vecPos[3], float vecAng[3], int ally)
	{
		GibSpawner npc = view_as<GibSpawner>(CClotBody(vecPos, vecAng, "models/player/soldier.mdl", "1.0", "100000000", ally));

		i_NpcWeight[npc.index] = 999;

		b_StaticNPC[npc.index] = true;
		AddNpcToAliveList(npc.index, 1);
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		GiveNpcOutLineLastOrBoss(npc.index, false);
		b_thisNpcHasAnOutline[npc.index] = false;
		npc.m_bCamo = true;
		b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; 
		b_NpcIsInvulnerable[npc.index] = true;
		b_ThisEntityIgnored[npc.index] = true;
        b_NoKillFeed[npc.index] = true;

        func_NPCDeath[npc.index] = INVALID_FUNCTION;
		func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
		func_NPCThink[npc.index] = GIBSPAWNER_ClotThink;

        npc.m_iBleedType = BLEEDTYPE_NORMAL;

        SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 255, 255, 1);
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 1.0);
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 1.0);
		if(IsValidEntity(npc.m_iTeamGlow))
			RemoveEntity(npc.m_iTeamGlow);
			
		b_NpcForcepowerupspawn[npc.index] = 0;
		i_RaidGrantExtra[npc.index] = 0;
		b_DoGibThisNpc[npc.index] = true;

		
		return npc;
	}
}

static void GIBSPAWNER_ClotThink(int iNPC)
{
	Invisible_TRIGGER npc = view_as<Invisible_TRIGGER>(iNPC);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	if(npc.m_flNextThinkTime > gameTime)
		return;
	npc.m_flNextThinkTime = gameTime + 0.1;
    SmiteNpcToDeath(npc.index);
    SmiteNpcToDeath(npc.index);
    SmiteNpcToDeath(npc.index);
    SmiteNpcToDeath(npc.index);
    SmiteNpcToDeath(npc.index);
    SmiteNpcToDeath(npc.index); //fuckin die!!! I NEEED YOUR JUCIY FLESH GRAAHHHH!!!
}