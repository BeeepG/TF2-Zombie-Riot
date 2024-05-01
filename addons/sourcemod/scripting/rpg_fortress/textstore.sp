#pragma semicolon 1
#pragma newdecls required

static const char RarityName[][] = 
{
	"Common",
	"Uncommon",
	"Rare",
	"Legendary",
	"Mythic",
	"Bob's Possession"
};

enum struct StoreEnum
{
	char Tag[16];
	char Key[64];
	
	char Model[PLATFORM_MAX_PATH];
	char Intro[64];
	char Idle[64];
	float Pos[3];
	float Ang[3];
	float Scale;
	char Enter[64];
	char Talk[64];
	char Leave[64];	
	int ParticleRef;
	char Particle[64];
	char ParticleParent[64];
	int ForceBodyGroup;
	
	char Wear1[PLATFORM_MAX_PATH];
	char Wear2[PLATFORM_MAX_PATH];
	char Wear3[PLATFORM_MAX_PATH];
	
	int EntRef;
	
	void SetupEnum(KeyValues kv)
	{
		kv.GetString("tag", this.Tag, 16);
		kv.GetString("key", this.Key, 64);
		
		kv.GetString("model", this.Model, PLATFORM_MAX_PATH);
		if(this.Model[0])
		{
			this.Scale = kv.GetFloat("scale", 1.0);
			
			kv.GetString("anim_enter", this.Intro, 64);
			kv.GetString("anim_idle", this.Idle, 64);
			
			kv.GetVector("pos", this.Pos);
			kv.GetVector("ang", this.Ang);
			
			kv.GetString("wear1", this.Wear1, PLATFORM_MAX_PATH);
			if(this.Wear1[0])
				PrecacheModel(this.Wear1);
			
			kv.GetString("wear2", this.Wear2, PLATFORM_MAX_PATH);
			if(this.Wear2[0])
				PrecacheModel(this.Wear2);
			
			kv.GetString("wear3", this.Wear3, PLATFORM_MAX_PATH);
			if(this.Wear3[0])
				PrecacheModel(this.Wear3);
		}
		
		kv.GetString("sound_enter", this.Enter, 64);
		if(this.Enter[0])
			PrecacheScriptSound(this.Enter);
		
		kv.GetString("sound_buy", this.Talk, 64);
		if(this.Talk[0])
			PrecacheScriptSound(this.Talk);
		
		kv.GetString("sound_leave", this.Leave, 64);
		if(this.Leave[0])
			PrecacheScriptSound(this.Leave);

		this.ForceBodyGroup = kv.GetNum("force_bodygroup", 0);

		kv.GetString("particle", this.Particle, 64);
		
		kv.GetString("particle_parent", this.ParticleParent, 64);
	}
	
	void PlayEnter(int client)
	{
		if(this.Enter[0])
		{
			int entity = client;
			if(this.EntRef != INVALID_ENT_REFERENCE)
				entity = EntRefToEntIndex(this.EntRef);
			
			EmitGameSoundToClient(client, this.Enter, entity);
		}
	}
	
	void PlayBuy(int client)
	{
		if(this.Talk[0])
		{
			int entity = client;
			if(this.EntRef != INVALID_ENT_REFERENCE)
				entity = EntRefToEntIndex(this.EntRef);
			
			EmitGameSoundToClient(client, this.Talk, entity);
		}
	}
	
	void PlayLeave(int client)
	{
		if(this.Leave[0])
		{
			int entity = client;
			if(this.EntRef != INVALID_ENT_REFERENCE)
				entity = EntRefToEntIndex(this.EntRef);
			
			EmitGameSoundToClient(client, this.Leave, entity);
		}
	}
	
	void Despawn()
	{
		if(this.EntRef != INVALID_ENT_REFERENCE)
		{

			int particle = EntRefToEntIndex(this.ParticleRef);
			if(IsValidEntity(particle))
				RemoveEntity(particle);

			int entity = EntRefToEntIndex(this.EntRef);
			if(IsValidEntity(entity))
				RemoveEntity(entity);
			
			this.EntRef = INVALID_ENT_REFERENCE;
		}
	}
	
	void Spawn()
	{
		if(this.EntRef == INVALID_ENT_REFERENCE && this.Model[0])
		{
			int entity = CreateEntityByName("prop_dynamic_override");
			if(IsValidEntity(entity))
			{
				DispatchKeyValue(entity, "targetname", "rpg_fortress");
				DispatchKeyValue(entity, "model", this.Model);
				
				TeleportEntity(entity, this.Pos, this.Ang, NULL_VECTOR);
				
				DispatchSpawn(entity);
				SetEntityCollisionGroup(entity, 2);
				
				if(this.Wear1[0])
					GivePropAttachment(entity, this.Wear1);
				
				if(this.Wear2[0])
					GivePropAttachment(entity, this.Wear2);
				
				if(this.Wear3[0])
					GivePropAttachment(entity, this.Wear3);
				
				SetEntPropFloat(entity, Prop_Send, "m_flModelScale", this.Scale);
				
				SetVariantString(this.Idle);
				AcceptEntityInput(entity, "SetDefaultAnimation", entity, entity);
				
				if(this.Intro[0])
				{
					SetVariantString(this.Intro);
					AcceptEntityInput(entity, "SetAnimation", entity, entity);
				}
				if(this.ForceBodyGroup > 0)
				{
					SetVariantInt(this.ForceBodyGroup);
					AcceptEntityInput(entity, "SetBodyGroup");
				}

				this.EntRef = EntIndexToEntRef(entity);

				if(this.Particle[0])
				{
					float flPos[3]; // original
					float flAng[3]; // original
					CClotBody npc = view_as<CClotBody>(entity);
		
					npc.GetAttachment(this.ParticleParent, flPos, flAng);

					this.ParticleRef = EntIndexToEntRef(ParticleEffectAt_Parent(flPos, this.Particle, entity, "", {0.0,0.0,15.0}));
				}
			}
		}
	}
}

enum struct BackpackEnum
{
	int Owner;
	int Item;
	int Amount;
	int Weight;
}

enum struct SpellEnum
{
	bool Active;
	int Owner;
	char Name[64];
	char Display[64];
	Function Func;
	float Cooldown;
	int Store;
}

enum struct MarketEnum
{
	char SteamID[64];
	int Amount;
	int Price;
	bool NowEmpty;
}

enum
{
	MENU_SPELLS = 0,
	MENU_BACKPACK = 1,
	MENU_QUESTBOOK = 2,
	MENU_TRANSFORM = 3,
	MENU_BUILDING = 4
}

static KeyValues HashKey;
static KeyValues MarketKv;
static ArrayList Backpack;
static ArrayList SpellList;
static StringMap StoreList;
static char InStore[MAXTF2PLAYERS][32];
static char InStoreTag[MAXTF2PLAYERS][16];
static int ItemIndex[MAXENTITIES];
static int ItemCount[MAXENTITIES];
static int ItemOwner[MAXENTITIES];
static float ItemLifetime[MAXENTITIES];
static bool InMenu[MAXTF2PLAYERS];
static int MenuType[MAXTF2PLAYERS];
static float RefreshAt[MAXTF2PLAYERS];
static bool ChatListen[MAXTF2PLAYERS];
static int MarketItem[MAXTF2PLAYERS];
static int MarketCount[MAXTF2PLAYERS];
static int MarketSell[MAXTF2PLAYERS];
static int SkillRand[MAXTF2PLAYERS];

static void SaveMarket(int client)
{
	TextStore_ClientSave(client);

	static char buffer[PLATFORM_MAX_PATH];
	RPG_BuildPath(buffer, sizeof(buffer), "stores_savedata");
	MarketKv.Rewind();
	MarketKv.ExportToFile(buffer);
}

static void HashCheck()
{
	for(int i; ; i++)
	{
		KeyValues kv = TextStore_GetItemKv(i);
		if(kv)
		{
			if(kv != HashKey)
			{
				delete Backpack;
				Backpack = new ArrayList(sizeof(BackpackEnum));

				delete SpellList;
				SpellList = new ArrayList(sizeof(SpellEnum));
				
				Garden_ResetAll();
				Store_Reset();
				RPG_PluginEnd();
				Tinker_ResetAll();

				for(int client = 1; client <= MaxClients; client++)
				{
					if(IsClientInGame(client))
						CancelClientMenu(client);
				}

				SPrintToChatAll("The store was reloaded, items and areas were also reloaded!");

				HashKey = kv;
				
				Zones_ResetAll();
			}
			break;
		}
	}
}

void TextStore_PluginStart()
{
	CreateTimer(2.0, TextStore_ItemTimer, _, TIMER_REPEAT);
	RegConsoleCmd("rpg_help", TextStore_HelpCommand, _, FCVAR_HIDDEN);
	RegAdminCmd("rpg_givemeall", TextStore_GiveMeAllCommand, ADMFLAG_ROOT);
}

static Action TextStore_HelpCommand(int client, int args)
{
	ReplyToCommand(client, "[SM] Use /inv <item name> to search for an item");
	if(client)
		FakeClientCommandEx(client, "sm_store");
	
	return Plugin_Handled;
}

static Action TextStore_GiveMeAllCommand(int client, int args)
{
	if(client)
	{
		int count;
		int length = TextStore_GetItems();
		for(int i; i < length; i++)
		{
			TextStore_GetInv(client, i, count);
			if(count < 1)
				TextStore_SetInv(client, i, 1);
		}
	}
	return Plugin_Handled;
}

void TextStore_ConfigSetup()
{
	char buffer[PLATFORM_MAX_PATH];
	RPG_BuildPath(buffer, sizeof(buffer), "stores");
	KeyValues kv = new KeyValues("Stores");
	kv.ImportFromFile(buffer);
	
	delete StoreList;
	StoreList = new StringMap();

	StoreEnum store;
	store.EntRef = INVALID_ENT_REFERENCE;

	kv.GotoFirstSubKey();
	do
	{
		kv.GetSectionName(buffer, sizeof(buffer));
		store.SetupEnum(kv);
		StoreList.SetArray(buffer, store, sizeof(store));
	}
	while(kv.GotoNextKey());

	delete kv;
	
	delete MarketKv;
	RPG_BuildPath(buffer, sizeof(buffer), "stores_savedata");
	MarketKv = new KeyValues("MarketData");
	MarketKv.ImportFromFile(buffer);
	
	RequestFrame(TextStore_ConfigSetupFrame);
}

static void TextStore_ConfigSetupFrame()
{
	HashCheck();
	for(int client = 1; client <= MaxClients; client++)
	{
		InStore[client][0] = 0;
		if(IsClientInGame(client) && TextStore_GetClientLoad(client))
			LoadItems(client);
	}
}

public ItemResult TextStore_Item(int client, bool equipped, KeyValues item, int index, const char[] name, int &count, bool auto)
{
	if(auto)
		return Item_None;
	
	if(!equipped && !CvarRPGInfiniteLevelAndAmmo.BoolValue)
	{
		int level = item.GetNum("level");
		if(level > Level[client])
		{
			SPrintToChat(client, "You must be Level %d to use this.", level);
			return Item_None;
		}
	}

	HashCheck();

	static char buffer[64];
	item.GetString("type", buffer, sizeof(buffer));
	/*
	if(!StrContains(buffer, "ammo", false))
	{
		int type = item.GetNum("ammo");

		int ammo = GetAmmo(client, type) + item.GetNum("amount");
		SetAmmo(client, type, ammo);
		CurrentAmmo[client][type] = ammo;
		return Item_Used;
	}
	*/
	if(!StrContains(buffer, "custom", false))
	{
		ItemResult result = Item_None;
		item.GetString("func", buffer, sizeof(buffer), "Ammo_HealingSpell");
		if(buffer[0])
		{
			Function func = GetFunctionByName(null, buffer);
			if(func != INVALID_FUNCTION)
			{
				Call_StartFunction(null, func);
				Call_PushCell(client);
				Call_Finish(result);
			}
		}
		return result;
	}

	if(equipped)
		return Item_Off;
	
	if(!StrContains(buffer, "healing", false) || !StrContains(buffer, "spell", false))
	{
		static SpellEnum spell;
		int length = SpellList.Length;
		for(int i; i < length; i++)
		{
			SpellList.GetArray(i, spell);
			if(spell.Owner == client && spell.Store == index)
				return Item_On;
		}

		spell.Owner = client;
		spell.Store = index;
		spell.Active = false;
		strcopy(spell.Name, 64, name);
		
		item.GetString("func", buffer, sizeof(buffer), "Ammo_HealingSpell");
		spell.Func = GetFunctionByName(null, buffer);

		SpellList.PushArray(spell);
	}
	else if(!Store_EquipItem(client, item, index, name))
	{
		return Item_None;
	}
	return Item_On;
}

void TextStore_ClientDisconnect(int client)
{
	for(int i = SpellList.Length - 1; i >= 0; i--)
	{
		static SpellEnum spell;
		SpellList.GetArray(i, spell);
		if(spell.Owner == client)
			SpellList.Erase(i);
	}
}

void TextStore_GiveAll(int client)
{
	int length = SpellList.Length;
	for(int i; i < length; i++)
	{
		static SpellEnum spell;
		SpellList.GetArray(i, spell);
		if(spell.Owner == client)
		{
			if(TextStore_GetInv(client, spell.Store))
			{
				spell.Active = true;
				spell.Cooldown = 0.0;
				strcopy(spell.Display, sizeof(spell.Display), spell.Name);
				SpellList.SetArray(i, spell);
			}
			else
			{
				SpellList.Erase(i--);
				length--;
			}
		}
	}
}

public void TextStore_OnDescItem(int client, int item, char[] desc)
{
	KeyValues kv = TextStore_GetItemKv(item);
	if(kv)
	{
		static char buffer[256];
		kv.GetString("plugin", buffer, sizeof(buffer));
		if(StrEqual(buffer, "rpg_fortress"))
		{
			if(item < 0)
			{
				Tinker_DescItem(client, item, desc);
			}
			else
			{
				static int attrib[16];
				static float value[16];
				static char buffers[32][16];

				kv.GetString("attributes", buffer, sizeof(buffer));
				int count = ExplodeString(buffer, ";", buffers, sizeof(buffers), sizeof(buffers[])) / 2;
				for(int i; i < count; i++)
				{
					attrib[i] = StringToInt(buffers[i*2]);
					if(!attrib[i])
					{
						count = i;
						break;
					}
					
					value[i] = StringToFloat(buffers[i*2+1]);
				}
				
			//	Ammo_DescItem(kv, desc);
				Mining_DescItem(kv, desc, attrib, value, count);
				Fishing_DescItem(kv, desc, attrib, value, count);
				Stats_DescItem(desc, attrib, value, count);
				
				int archetype = kv.GetNum("archetype");
				kv.GetString("classname", buffer, sizeof(buffer));
				Config_CreateDescription(ItemArchetype[archetype], buffer, attrib, value, count, desc, 512);
				
				int level = kv.GetNum("level");
				if(level > 0)
				{
					Format(buffer, sizeof(buffer), "Level %d", level);
				}
				else
				{
					strcopy(buffer, sizeof(buffer), "Any Level");
				}
				
				int rarity = kv.GetNum("rarity");
				if(rarity >= 0 && rarity < sizeof(RarityName))
				{
					Format(desc, 512, "%s\n%s\n%s", RarityName[rarity], buffer, desc);
				}
				else
				{
					Format(desc, 512, "%s\n%s", buffer, desc);
				}
			}
		}
	}
}

public Action TextStore_OnClientLoad(int client, char file[PLATFORM_MAX_PATH])
{
	RequestFrame(TextStore_LoadFrame, GetClientUserId(client));
	return Plugin_Continue;
}

static void TextStore_LoadFrame(int userid)
{
	int client = GetClientOfUserId(userid);
	if(client)
	{
		if(TextStore_GetClientLoad(client))
		{
			HashCheck();
			LoadItems(client);
		}
		else
		{
			RequestFrame(TextStore_LoadFrame, userid);
		}
	}
}

static void LoadItems(int client)
{
/*
	int length = TextStore_GetItems();
	for(int i; i < length; i++)
	{
		static char buffer[64];
		TextStore_GetItemName(i, buffer, sizeof(buffer));
		if(StrEqual(buffer, ITEM_XP, false))
		{
			TextStore_GetInv(client, i, XP[client]);
			ItemXP = i;
		}
	}
*/
	Traffic_LoadItems(client);
}

bool TextStore_IsValidName(const char[] name)
{
	int length = TextStore_GetItems();
	for(int i; i < length; i++)
	{
		static char buffer[64];
		TextStore_GetItemName(i, buffer, sizeof(buffer));
		if(StrEqual(buffer, name, false))
			return true;
	}

	return false;
}

int TextStore_GetItemCount(int client, const char[] name)
{
	if(StrEqual(name, ITEM_CASH, false))
		return TextStore_Cash(client);
	
	int amount = -1;
	
	int length = TextStore_GetItems();
	for(int i; i < length; i++)
	{
		static char buffer[64];
		TextStore_GetItemName(i, buffer, sizeof(buffer));
		if(StrEqual(buffer, name, false))
		{
			TextStore_GetInv(client, i, amount);
			break;
		}
	}

	return amount;
}

void TextStore_AddItemCount(int client, const char[] name, int amount)
{
	if(StrEqual(name, ITEM_CASH, false))
	{
		TextStore_Cash(client, amount);
		if(amount > 0)
			SPrintToChat(client, "You gained %d credits", amount);
	}
	else if(StrEqual(name, ITEM_XP, false))
	{
		Stats_GiveXP(client, amount);
		if(amount > 0)
			SPrintToChat(client, "You gained %d XP", amount);
	}
	else
	{
		int length = TextStore_GetItems();
		for(int i; i < length; i++)
		{
			static char buffer[64];
			TextStore_GetItemName(i, buffer, sizeof(buffer));
			if(StrEqual(buffer, name, false))
			{
				TextStore_GetInv(client, i, length);
				TextStore_SetInv(client, i, length + amount, amount >= length ? 0 : -1);
				if(amount == 1)
				{
					SPrintToChat(client, "You gained %s", name);
				}
				else if(amount > 1)
				{
					SPrintToChat(client, "You gained %s x%d", name, amount);
				}
				return;
			}
		}

		LogError("Could not find item '%s'", name);
	}

	Quests_MarkBookDirty(client);
}

void TextStore_ZoneEnter(int client, const char[] name)
{
	static StoreEnum store;
	if(StoreList.GetArray(name, store, sizeof(store)))
	{
		if(store.EntRef == INVALID_ENT_REFERENCE)
		{
			store.Spawn();
			StoreList.SetArray(name, store, sizeof(store));
		}

		if(store.Key[0] && TextStore_GetItemCount(client, store.Key) < 1)
		{
			SPrintToChat(client, "You require \"%s\" to use this shop", store.Key);
		}
		else
		{
			store.PlayEnter(client);
			strcopy(InStore[client], sizeof(InStore[]), name);
			strcopy(InStoreTag[client], sizeof(InStoreTag[]), store.Tag);

			if(StrEqual(store.Tag, "market", false) && GetClientAuthId(client, AuthId_Steam3, store.Enter, sizeof(store.Enter)))
			{
				MarketKv.Rewind();
				if(MarketKv.JumpToKey("Payout") && MarketKv.JumpToKey(store.Enter))
				{
					if(MarketKv.GotoFirstSubKey())
					{
						do
						{
							int cash = MarketKv.GetNum("cash");
							MarketKv.GetSectionName(store.Enter, sizeof(store.Enter));
							SPrintToChat(client, "%d of your %s were sold for %d credits", MarketKv.GetNum("amount"), store.Enter, cash);
							TextStore_Cash(client, cash);
						}
						while(MarketKv.GotoNextKey());

						MarketKv.GoBack();
					}

					MarketKv.DeleteThis();
					SaveMarket(client);
				}
			}
			
			FakeClientCommand(client, "sm_buy");
		}
	}
}

void TextStore_ZoneLeave(int client, const char[] name)
{
	if(InStore[client][0] && StrEqual(name, InStore[client]))
	{
		InStore[client][0] = 0;
		if(!InMenu[client])
			CancelClientMenu(client);
	}
}

void TextStore_ZoneAllLeave(const char[] name)
{
	static StoreEnum store;
	if(StoreList.GetArray(name, store, sizeof(store)))
	{
		store.Despawn();
		StoreList.SetArray(name, store, sizeof(store));
	}
}

public Action TextStore_OnSellItem(int client, int item, int cash, int &count, int &sell)
{
	if(InStore[client][0])
	{
		if(item < 0)
			return Plugin_Continue;
		
		KeyValues kv = TextStore_GetItemKv(item);
		if(!kv || !kv.GetNum("trade", 1))
		{
			SPrintToChat(client, "This item can't be sold in the market!");
		}
		else if(sell > 0)
		{
			MarketItem[client] = item;
			MarketCount[client] = 1;
			MarketSell[client] = sell;
			RequestFrame(TextStore_ShowSellMenu, client);
		}
	}
	else
	{
		SPrintToChat(client, "You must sell this in a shop or market!");
	}
	return Plugin_Handled;
}

static void TextStore_ShowSellMenu(int client)
{
	if(InStore[client][0])
	{
		KeyValues kv = TextStore_GetItemKv(MarketItem[client]);
		if(kv)
		{
			Menu menu = new Menu(TextStore_SellMenuHandle);

			bool market = StrEqual(InStoreTag[client], "market", false);

			static char buffer[64];
			kv.GetSectionName(buffer, sizeof(buffer));

			if(market)
			{
				menu.SetTitle("Listing %s in market:\n ", buffer);
			}
			else
			{
				menu.SetTitle("Selling %s in store:\n ", buffer);
			}

			if(MarketCount[client] < 1)
				MarketCount[client] = 1;
			
			int amount;
			if(TextStore_GetInv(client, MarketItem[client], amount))
				amount--;
			
			if(MarketCount[client] > amount)
				MarketCount[client] = amount;
			
			if(market)
			{
				amount = kv.GetNum("cost");
				kv.GetString("storetags", buffer, sizeof(buffer));
				if(buffer[0])
				{
					if(MarketSell[client] > amount)
						MarketSell[client] = amount;
				}
				
				amount = kv.GetNum("sell", RoundFloat(amount * 0.75));
				if(MarketSell[client] < amount)
					MarketSell[client] = amount;
			}

			menu.AddItem(buffer, "Add 10");
			menu.AddItem(buffer, "Add 5");
			menu.AddItem(buffer, "Add 1");
			menu.AddItem(buffer, "Remove 1");
			menu.AddItem(buffer, "Remove 5");

			if(market)
			{
				menu.AddItem(buffer, "Remove 10\n \n Enter a number in the chat\nbox to change the sell value\n ");
			}
			else
			{
				menu.AddItem(buffer, "Remove 10\n ");
			}

			if(market)
			{
				Format(buffer, sizeof(buffer), "List %d for %d credits each (%d total)\n ", MarketCount[client], MarketSell[client], MarketCount[client] * MarketSell[client]);
			}
			else
			{
				Format(buffer, sizeof(buffer), "Sell %d for %d credits each (%d total)\n ", MarketCount[client], MarketSell[client], MarketCount[client] * MarketSell[client]);
			}

			menu.AddItem(buffer, buffer, MarketCount[client] > 0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			menu.ExitBackButton = true;
			ChatListen[client] = (menu.Display(client, MENU_TIME_FOREVER) && market);
		}
	}
}

bool TextStore_SayCommand(int client)
{
	if(!ChatListen[client])
		return false;
	
	static char buffer[16];
	GetCmdArgString(buffer, sizeof(buffer));
	ReplaceString(buffer, sizeof(buffer), "\"", "");
	int value = StringToInt(buffer);
	if(value < 1)
	{
		SPrintToChat(client, "You must enter a number with a value more than 0.");
	}
	else if(value >= 100000000)
	{
		MarketSell[client] = 99999999;
		TextStore_ShowSellMenu(client);
	}
	else
	{
		MarketSell[client] = value;
		TextStore_ShowSellMenu(client);
	}
	return true;
}

static int TextStore_SellMenuHandle(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			ChatListen[client] = false;

			if(choice == MenuCancel_ExitBack)
				FakeClientCommandEx(client, "sm_inv");
		}
		case MenuAction_Select:
		{
			ChatListen[client] = false;

			switch(choice)
			{
				case 0:
				{
					MarketCount[client] += 10;
				}
				case 1:
				{
					MarketCount[client] += 5;
				}
				case 2:
				{
					MarketCount[client]++;
				}
				case 3:
				{
					MarketCount[client]--;
				}
				case 4:
				{
					MarketCount[client] -= 5;
				}
				case 5:
				{
					MarketCount[client] -= 10;
				}
				case 6:
				{
					if(InStore[client][0])
					{
						KeyValues kv = TextStore_GetItemKv(MarketItem[client]);
						if(kv)
						{
							int amount;
							TextStore_GetInv(client, MarketItem[client], amount);
							if(amount >= MarketCount[client])
							{
								if(StrEqual(InStoreTag[client], "market", false))
								{
									MarketKv.Rewind();
									MarketKv.JumpToKey("Listing", true);

									static char buffer[64];
									kv.GetSectionName(buffer, sizeof(buffer));
									MarketKv.JumpToKey(buffer, true);

									if(GetClientAuthId(client, AuthId_Steam3, buffer, sizeof(buffer)) && MarketKv.JumpToKey(buffer, true))
									{
										if(MarketKv.GetNum("price") == MarketSell[client])
										{
											amount -= MarketCount[client];
											MarketKv.SetNum("amount", MarketKv.GetNum("amount") + MarketCount[client]);
										}
										else
										{
											int refund = MarketKv.GetNum("amount");
											amount -= MarketCount[client] - refund;
											MarketKv.SetNum("amount", MarketCount[client]);
											MarketKv.SetNum("price", MarketSell[client]);

											if(refund)
												SPrintToChat(client, "%d was returned to you from the market because you changed your sell price.", refund);
										}

										TextStore_SetInv(client, MarketItem[client], amount);
										SaveMarket(client);
									}
								}
								else
								{
									TextStore_SetInv(client, MarketItem[client], amount - MarketCount[client]);
									TextStore_Cash(client, MarketCount[client] * MarketSell[client]);
								}

								ClientCommand(client, "playgamesound mvm/mvm_money_pickup.wav");
							}
						}
					}

					FakeClientCommandEx(client, "sm_inv");
					return 0;
				}
			}

			TextStore_ShowSellMenu(client);
		}
	}
	return 0;
}

public Action TextStore_OnMainMenu(int client, Menu menu)
{
	if(!InStore[client][0])
		menu.RemoveItem(0);
	
	menu.AddItem("rpg_stats",	"Player Stats");
	menu.AddItem("rpg_spawns",	"Spawn Stats");
	menu.AddItem("rpg_party",	"Party");
	menu.AddItem("rpg_help",	"Search");
	menu.AddItem("rpg_character",	"Characters");
	menu.AddItem("rpg_settings",	"Settings");
	return Plugin_Changed;
}

public void TextStore_OnCatalog(int client)
{
	bool market = StrEqual(InStoreTag[client], "market", false);
	if(market)
	{
		MarketKv.Rewind();
		MarketKv.JumpToKey("Listing", true);
	}

	ArrayList list = new ArrayList();
	
	for(int i = TextStore_GetItems() - 1; i >= 0; i--)
	{
		bool block = true;

		static char buffer[128];
		KeyValues kv = TextStore_GetItemKv(i);
		if(kv)
		{
			if(InStore[client][0] && kv.GetNum("level") <= Level[client])
			{
				if(market)
				{
					kv.GetSectionName(buffer, sizeof(buffer));
					if(MarketKv.JumpToKey(buffer))
					{
						if(MarketKv.GotoFirstSubKey())
						{
							do
							{
								if(MarketKv.GetNum("amount"))
								{
									block = false;
									break;
								}
							}
							while(MarketKv.GotoNextKey());

							MarketKv.GoBack();
						}

						MarketKv.GoBack();
					}
				}
				else
				{
					kv.GetString("storetags", buffer, sizeof(buffer));
					if(buffer[0] && StrContains(buffer, InStoreTag[client], false) != -1)
					{
						block = false;
					}
				}
			}
		}
		else
		{
			block = list.FindValue(i) == -1;
		}

		TextStore_SetItemHidden(i, block);
		if(!block)
			list.Push(TextStore_GetItemParent(i));
	}

	delete list;
}

public Action TextStore_OnPriceItem(int client, int item, int &price)
{
	if(price > 0 && !StrEqual(InStoreTag[client], "market", false))
		return Plugin_Continue;
	
	price = 0;

	MarketKv.Rewind();
	MarketKv.JumpToKey("Listing", true);
	
	static char buffer[64];
	TextStore_GetItemName(item, buffer, sizeof(buffer));
	if(MarketKv.JumpToKey(buffer))
	{
		if(MarketKv.GotoFirstSubKey())
		{
			do
			{
				if(MarketKv.GetNum("amount"))
				{
					int sell = MarketKv.GetNum("price");
					if(!price || sell < price)
						price = sell;
				}
			}
			while(MarketKv.GotoNextKey());
		}
	}
	return Plugin_Changed;
}

public Action TextStore_OnBuyItem(int client, int item, int cash, int &count, int &cost)
{
	MarketItem[client] = item;
	MarketCount[client] = 1;
	MarketSell[client] = cost;
	TextStore_OnPriceItem(client, item, MarketSell[client]);
	RequestFrame(TextStore_ShowBuyMenu, client);
	return Plugin_Handled;
}

static void TextStore_ShowBuyMenu(int client)
{
	if(InStore[client][0])
	{
		KeyValues kv = TextStore_GetItemKv(MarketItem[client]);
		if(kv)
		{
			Menu menu = new Menu(TextStore_BuyMenuHandle);

			bool market = StrEqual(InStoreTag[client], "market", false);

			static char buffer[64];
			kv.GetSectionName(buffer, sizeof(buffer));

			if(market)
			{
				menu.SetTitle("Buying %s in market:\n ", buffer);
			}
			else
			{
				menu.SetTitle("Buying %s in store:\n ", buffer);
			}

			if(MarketCount[client] < 1)
				MarketCount[client] = 1;
			
			bool unlist;
			if(market)
			{
				MarketKv.Rewind();
				MarketKv.JumpToKey("Listing", true);

				int amount;
				if(MarketKv.JumpToKey(buffer))
				{
					static char steamid[64];
					if(!GetClientAuthId(client, AuthId_Steam3, steamid, sizeof(steamid)))
						steamid[0] = 0;

					if(MarketKv.GotoFirstSubKey())
					{
						do
						{
							if(MarketKv.GetSectionName(buffer, sizeof(buffer)) && StrEqual(steamid, buffer, false))
							{
								MarketSell[client] = 0;
								amount += MarketKv.GetNum("amount");
								kv.GetSectionName(buffer, sizeof(buffer));
								menu.SetTitle("Unlisting %s from market:\n ", buffer);
								unlist = true;
								break;
							}
							
							if(MarketKv.GetNum("price") <= MarketSell[client])
								amount += MarketKv.GetNum("amount");
						}
						while(MarketKv.GotoNextKey());
					}
				}

				if(MarketCount[client] > amount)
					MarketCount[client] = amount;
			}

			bool noStack = !kv.GetNum("stack", 1);
			if(noStack && MarketCount[client] > 1)
				MarketCount[client] = 1;
			
			if(!unlist)
			{
				int cash = TextStore_Cash(client);
				while((MarketCount[client] * MarketSell[client]) > cash)
				{
					MarketCount[client]--;
				}
			}

			menu.AddItem(buffer, "Add 10", noStack ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem(buffer, "Add 5", noStack ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem(buffer, "Add 1", noStack ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem(buffer, "Remove 1", noStack ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem(buffer, "Remove 5", noStack ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem(buffer, "Remove 10\n ", noStack ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

			if(unlist)
			{
				Format(buffer, sizeof(buffer), "Unlist and return %d\n ", MarketCount[client]);
			}
			else
			{
				Format(buffer, sizeof(buffer), "Buy %d for %d credits each (%d total)\n ", MarketCount[client], MarketSell[client], MarketCount[client] * MarketSell[client]);
			}
			
			menu.AddItem(buffer, buffer, MarketCount[client] > 0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			menu.ExitBackButton = true;
			menu.Display(client, MENU_TIME_FOREVER);
		}
	}
}

static int TextStore_BuyMenuHandle(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			if(choice == MenuCancel_ExitBack)
				FakeClientCommandEx(client, "sm_buy");
		}
		case MenuAction_Select:
		{
			switch(choice)
			{
				case 0:
				{
					MarketCount[client] += 10;
				}
				case 1:
				{
					MarketCount[client] += 5;
				}
				case 2:
				{
					MarketCount[client]++;
				}
				case 3:
				{
					MarketCount[client]--;
				}
				case 4:
				{
					MarketCount[client] -= 5;
				}
				case 5:
				{
					MarketCount[client] -= 10;
				}
				case 6:
				{
					if(InStore[client][0])
					{
						KeyValues kv = TextStore_GetItemKv(MarketItem[client]);
						if(kv)
						{
							int cash = TextStore_Cash(client);
							if(cash >= (MarketCount[client] * MarketSell[client]))
							{
								static char buffer[64];
								if(!StrEqual(InStoreTag[client], "market", false))
								{
									int amount;
									TextStore_GetInv(client, MarketItem[client], amount);
									TextStore_SetInv(client, MarketItem[client], amount + MarketCount[client]);
									TextStore_Cash(client, -(MarketCount[client] * MarketSell[client]));
								}
								else if(MarketSell[client])
								{
									MarketKv.Rewind();
									MarketKv.JumpToKey("Listing", true);

									kv.GetSectionName(buffer, sizeof(buffer));
									MarketKv.JumpToKey(buffer, true);

									if(MarketKv.GotoFirstSubKey())
									{
										static MarketEnum market;
										ArrayList list = new ArrayList(sizeof(MarketEnum));

										do
										{
											market.Price = MarketKv.GetNum("price");
											if(market.Price <= MarketSell[client])
											{
												int amount = MarketKv.GetNum("amount");
												market.Amount = amount;
												if(market.Amount > MarketCount[client])
													market.Amount = MarketCount[client];
												
												MarketCount[client] -= market.Amount;
												MarketKv.SetNum("amount", amount - market.Amount);

												MarketKv.GetSectionName(market.SteamID, sizeof(market.SteamID));
												market.NowEmpty = market.Amount == amount;
												list.PushArray(market);
												
												TextStore_GetInv(client, MarketItem[client], amount);
												TextStore_SetInv(client, MarketItem[client], amount + market.Amount);
												TextStore_Cash(client, -(market.Amount * market.Price));
											}
										}
										while(MarketKv.GotoNextKey());
										
										int length = list.Length;
										for(int i; i < length; i++)
										{
											list.GetArray(i, market);

											MarketKv.Rewind();
											MarketKv.JumpToKey("Payout", true);
											MarketKv.JumpToKey(market.SteamID, true);
											MarketKv.JumpToKey(buffer, true);
											MarketKv.SetNum("cash", MarketKv.GetNum("cash") + (market.Price * market.Amount));
											MarketKv.SetNum("amount", MarketKv.GetNum("amount") +  market.Amount);

											if(market.NowEmpty)
											{
												MarketKv.Rewind();
												MarketKv.JumpToKey("Listing", true);
												MarketKv.JumpToKey(buffer, true);
												MarketKv.DeleteKey(market.SteamID);
											}
										}

										delete list;

										SaveMarket(client);
									}
								}
								else
								{
									MarketKv.Rewind();
									MarketKv.JumpToKey("Listing", true);

									kv.GetSectionName(buffer, sizeof(buffer));
									MarketKv.JumpToKey(buffer, true);

									if(GetClientAuthId(client, AuthId_Steam3, buffer, sizeof(buffer)) && MarketKv.JumpToKey(buffer))
									{
										int amount = MarketKv.GetNum("amount");

										if(MarketCount[client] > amount)
											MarketCount[client] = amount;
										
										MarketKv.SetNum("amount", amount - MarketCount[client]);
										if(MarketCount[client] == amount)
											MarketKv.DeleteThis();
										
										TextStore_GetInv(client, MarketItem[client], amount);
										TextStore_SetInv(client, MarketItem[client], amount + MarketCount[client]);

										SaveMarket(client);
									}
								}

								ClientCommand(client, "playgamesound mvm/mvm_bought_upgrade.wav");
							}
						}
					}

					FakeClientCommandEx(client, "sm_buy");
					return 0;
				}
			}

			TextStore_ShowBuyMenu(client);
		}
	}
	return 0;
}

void TextStore_EntityCreated(int entity)
{
	ItemCount[entity] = 0;
}

stock void TextStore_DropCash(int client, float pos[3], int amount)
{
	DropItem(client, -1, pos, amount);
}

void TextStore_DropNamedItem(int client, const char[] name, float pos[3], int amount)
{
	int length = TextStore_GetItems();
	for(int i; i < length; i++)
	{
		static char buffer[64];
		if(TextStore_GetItemName(i, buffer, sizeof(buffer)) && StrEqual(buffer, name, false))
		{
			DropItem(client, i, pos, amount);
		}
	}
}

static void DropItem(int client, int index, float pos[3], int amount)
{
	float ang[3];
	static char buffer[PLATFORM_MAX_PATH];

	int entity = MaxClients + 1;
	while((entity = FindEntityByClassname(entity, "prop_physics_multiplayer")) != -1)
	{
		if(ItemCount[entity] && ItemIndex[entity] == index && ItemOwner[entity] == client)
		{
			GetEntPropVector(entity, Prop_Data, "m_vecOrigin", ang);
			if(GetVectorDistance(pos, ang, true) < 10000.0) // 100.0
			{
				if(ItemCount[entity] < 50)
				{
					if(ItemIndex[entity] == -1)
					{
						return;
					}
					else
					{
						ItemCount[entity] += amount;
						UpdateItemText(entity, index);
						return;
					}
				}

				amount = ItemCount[entity] - 49;
				ItemCount[entity] = 50;
			}
		}
	}

	KeyValues kv = index == -1 ? null : TextStore_GetItemKv(index);
	if(kv || index == -1)
	{
		if(GetEntityCount() > 1850)
			return;

		if(index == -1)
		{
			strcopy(buffer, sizeof(buffer), "models/items/currencypack_small.mdl");
		}
		else
		{
			kv.GetString("model", buffer, sizeof(buffer), "models/items/currencypack_small.mdl");
		}

		if(buffer[0])
		{
			PrecacheModel(buffer);

			entity = CreateEntityByName("prop_physics_multiplayer");
			if(entity != -1)
			{
				DispatchKeyValue(entity, "model", buffer);
				DispatchKeyValue(entity, "physicsmode", "2");
				DispatchKeyValue(entity, "massScale", "1.0");
				DispatchKeyValue(entity, "spawnflags", "6");
				DispatchKeyValue(entity, "targetname", "rpg_item");

				ang[1] = index == -1 ? -1.0 : kv.GetFloat("modelscale", -1.0);
				if(ang[1] > 0.0)
					DispatchKeyValueFloat(entity, "modelscale", ang[1]);

				if(index != -1)
				{
					ang[0] = GetRandomFloat(0.0, 360.0);
					ang[2] = GetRandomFloat(0.0, 360.0);
				}

				ang[1] = GetRandomFloat(0.0, 360.0);

				static float vel[3];
				vel[0] = GetRandomFloat(-160.0, 160.0);
				vel[1] = GetRandomFloat(-160.0, 160.0);
				vel[2] = GetRandomFloat(0.0, 160.0);

				pos[2] += 20.0;
				TeleportEntity(entity, pos, NULL_VECTOR, vel, true);

				DispatchSpawn(entity);
			//	SetEntityCollisionGroup(entity, 2);
			//	b_Is_Player_Projectile[entity] = true;

				int color[4] = {255, 255, 255, 255};
				if(index != -1)
				{
					kv.GetColor4("color", color);
					SetEntityRenderColor(entity, color[0], color[1], color[2], color[3]);

					for(int i; i < sizeof(color); i++)
					{
						color[i] = 128 + color[i] / 2;
					}
				}

				ItemIndex[entity] = index;
				ItemCount[entity] = amount;
				ItemOwner[entity] = client;
				ItemLifetime[entity] = GetGameTime() + 30.0;

				if(index == -1)
				{
					strcopy(buffer, sizeof(buffer), ITEM_CASH);
				}
				else
				{
					TextStore_GetItemName(index, buffer, sizeof(buffer));
				}
				
				if(amount != 1)
					Format(buffer, sizeof(buffer), "%s x%d", buffer, amount);
				
				CreateTimer(2.5, Timer_DisableMotion, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
				
				int rarity;
				
				if(index != -1)
				{
					rarity = kv.GetNum("rarity", 0);
				}
				else
				{
					rarity = 3;
				}
				
				int color_Text[4];
		
				color_Text[0] = RenderColors_RPG[rarity][0];
				color_Text[1] = RenderColors_RPG[rarity][1];
				color_Text[2] = RenderColors_RPG[rarity][2];
				color_Text[3] = RenderColors_RPG[rarity][3];

				int text = SpawnFormattedWorldText(buffer, {0.0, 0.0, 30.0}, amount == 1 ? 5 : 6, color_Text, entity,_,true);
				ItemOwner[text] = client;
				i_TextEntity[text][0] = entity;
				i_TextEntity[entity][0] = EntIndexToEntRef(text);
				
				SDKHook(text, SDKHook_SetTransmit, DroppedTextSetTransmit);
				SDKHook(entity, SDKHook_SetTransmit, DroppedItemSetTransmit);
			
			}
		}
	}
}

bool Textstore_CanSeeItem(int entity, int client)
{
	return (ItemOwner[entity] == client);// || Party_IsClientMember(ItemOwner[entity], client) || ItemLifetime[entity] < (GetGameTime() + 15.0));
}

static Action DroppedTextSetTransmit(int entity, int client)
{
	if(Textstore_CanSeeItem(i_TextEntity[entity][0], client))
		return Plugin_Continue;
	
	return Plugin_Handled;
}

static Action DroppedItemSetTransmit(int entity, int client)
{
	if(Textstore_CanSeeItem(entity, client))
		return Plugin_Continue;
	
	return Plugin_Handled;
}

static void UpdateItemText(int entity, int index)
{
	ItemLifetime[entity] = GetGameTime() + 30.0;
	
	int text = EntRefToEntIndex(i_TextEntity[entity][0]);
	if(IsValidEntity(text))
	{
		static char buffer[64];			
		if(index == -1)
		{
			strcopy(buffer, sizeof(buffer), ITEM_CASH);
		}
		else
		{
			TextStore_GetItemName(index, buffer, sizeof(buffer));
		}
		
		Format(buffer, sizeof(buffer), "%s x%d", buffer, ItemCount[entity]);

		DispatchKeyValue(text, "message", buffer);
	}
}

static int GetBackpackSize(int client)
{
	int amount;

	static BackpackEnum pack;
	int length = Backpack.Length;
	for(int i; i < length; i++)
	{
		Backpack.GetArray(i, pack);
		if(pack.Owner == client)
			amount += pack.Amount * pack.Weight;
	}

	return amount;
}

void TextStore_DepositBackpack(int client, bool death, bool message = false)
{
	float pos[3];
	int amount;
	int cash;

	if(death)
		GetClientAbsOrigin(client, pos);
	
	for(int i = Backpack.Length - 1; i >= 0; i--)
	{
		static BackpackEnum pack;
		Backpack.GetArray(i, pack);
		if(pack.Owner == client)
		{
			if(pack.Item == -1)
			{
				if(death)
				{
					DropItem(client, pack.Item, pos, pack.Amount);
					cash = pack.Amount;
				}
				else
				{
					cash = 1;
					TextStore_Cash(client, pack.Amount);
				}
			}
			else
			{
				cash = 1;
				TextStore_GetInv(client, pack.Item, amount);
				TextStore_SetInv(client, pack.Item, pack.Amount + amount);
			}

			Backpack.Erase(i);
		}
	}

	if(death)
	{
		if(cash)
			SPrintToChat(client, "You have dropped %d credits", cash);
	}
	else if(message && cash)
	{
		SPrintToChat(client, "You backpack was deposited");
	}

	Quests_MarkBookDirty(client);
}

bool TextStore_Interact(int client, int entity, bool reload)
{
	if(ItemCount[entity])
	{
		if(reload)
		{
			KeyValues kv = ItemIndex[entity] == -1 ? null : TextStore_GetItemKv(ItemIndex[entity]);
			if(ItemIndex[entity] == -1 || kv)
			{
				int itemWeight = ItemIndex[entity] == -1 ? 1 : kv.GetNum("weight", 1);
				int weight = -1;
				int strength;
				if(ItemIndex[entity] != -1)
				{
					weight = GetBackpackSize(client) - 2;

					int i;
					while(TF2_GetItem(client, strength, i))
					{
						weight += 1;
					}

					strength = Stats_BaseCarry(client);
				}

				if((weight + itemWeight) > strength)
				{
					ClientCommand(client, "playgamesound items/medshotno1.wav");
					ShowGameText(client, "ico_notify_highfive", 0, "You can't carry any more items (%d / %d)", weight, strength);

					if(Level[client] < 6)
					{
						SPrintToChat(client, "TIP: Head over to a shop to deposit your backpack");
					}
					else if(Level[client] == 10)
					{
						SPrintToChat(client, "TIP: You can carry 10 more items for each elite level up");
					}
					else if(Level[client] < 30)
					{
						SPrintToChat(client, "TIP: Switch to your backpack to drop items you don't need");
					}
				}
				else
				{
					ClientCommand(client, "playgamesound items/gift_pickup.wav");
					
					int amount = strength - weight;
					if(ItemIndex[entity] == -1 || amount > ItemCount[entity])
						amount = ItemCount[entity];
					
					bool found;
					static BackpackEnum pack;
					int length = Backpack.Length;
					for(int i; i < length; i++)
					{
						Backpack.GetArray(i, pack);
						if(pack.Owner == client && pack.Item == ItemIndex[entity])
						{
							pack.Amount += amount;
							Backpack.SetArray(i, pack);

							found = true;
							break;
						}
					}

					if(!found)
					{
						pack.Owner = client;
						pack.Item = ItemIndex[entity];
						pack.Amount = amount;

						if(ItemIndex[entity] == -1)
						{
							pack.Weight = 0;
						}
						else
						{
							pack.Weight = itemWeight;
						}
						
						Backpack.PushArray(pack);
					}
					
					if(amount == ItemCount[entity])
					{
						int text = EntRefToEntIndex(i_TextEntity[entity][0]);
						if(text != INVALID_ENT_REFERENCE)
							RemoveEntity(text);
						
						i_TextEntity[entity][0] = INVALID_ENT_REFERENCE;
						ItemCount[entity] = 0;
						RemoveEntity(entity);
					}
					else
					{
						ItemCount[entity] -= amount;
						UpdateItemText(entity, ItemIndex[entity]);
					}

					if(InMenu[client] && MenuType[client] == MENU_BACKPACK)
						ShowMenu(client);
				}
			}
			else
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				ShowGameText(client, "ico_notify_highfive", 0, "Ghost Item???? Please Report This");
			}
			return true;
		}
		else if(Level[client] < 8)
		{
			SPrintToChat(client, "TIP: Press RELOAD (R) to pick up an item");
			return true;
		}
	}
	return false;
}

static Action TextStore_ItemTimer(Handle timer)
{
	float gameTime = GetGameTime();

	int entity = MaxClients + 1;
	while((entity = FindEntityByClassname(entity, "prop_physics_multiplayer")) != -1)
	{
		if(ItemCount[entity] && ItemLifetime[entity] < gameTime)
		{
			int text = EntRefToEntIndex(i_TextEntity[entity][0]);
			if(text != INVALID_ENT_REFERENCE)
				RemoveEntity(text);
			
			i_TextEntity[entity][0] = INVALID_ENT_REFERENCE;
			ItemCount[entity] = 0;
			RemoveEntity(entity);
		}
	}

	return Plugin_Continue;
}

void TextStore_PlayerRunCmd(int client)
{
	if((InMenu[client] || GetClientMenu(client) == MenuSource_None))
	{
		if(!IsPlayerAlive(client))
		{
			if(!Saves_HasCharacter(client))
				Saves_MainMenu(client);
			
			return;
		}

		if(Actor_InChatMenu(client, false))
		{
			Actor_ReopenMenu(client);
			return;
		}
		
		if(InMenu[client])
		{
			switch(MenuType[client])
			{
				case MENU_SPELLS:
				{
					float gameTime = GetGameTime();
					if(RefreshAt[client] < gameTime)
					{
						gameTime += 1.0;
						if(RefreshAt[client] < gameTime)
						{
							RefreshAt[client] = gameTime;
						}
						else
						{
							RefreshAt[client] += 1.0;
						}
					}
				}
				case MENU_QUESTBOOK:
				{
					if(!Quests_BookMenuDirty(client))
						return;
				}
				default:
				{
					if(!RefreshAt[client])
						return;
					
					RefreshAt[client] = 0.0;
				}
			}
		}
		
		ShowMenu(client);
	}
}

static void ShowMenu(int client, int page = 0)
{
	if(!SpellList || Dungeon_MenuOverride(client))
	{
		InMenu[client] = false;
		return;
	}
	
	switch(MenuType[client])
	{
		case MENU_SPELLS:
		{
			Menu menu = new Menu(TextStore_SpellMenu);

			menu.SetTitle("RPG Fortress\n \nSkills:");

			static const int MaxSkills = 5;

			int amount;
			float gameTime = GetGameTime();
			int length = SpellList.Length;
			for(int i; i < length; i++)
			{
				static SpellEnum spell;
				SpellList.GetArray(i, spell);
				if(spell.Active && spell.Owner == client)
				{
					static char index[12];
					IntToString(spell.Store, index, sizeof(index));

					int cooldown = RoundToCeil(spell.Cooldown - gameTime);
					if(!spell.Display[0] || cooldown > 999)
					{
						if(amount < MaxSkills)
						{
							amount++;
							menu.AddItem(index, spell.Display, ITEMDRAW_DISABLED);
						}
						continue;
					}

					if(cooldown > 0)
						Format(spell.Display, sizeof(spell.Display), "%s [%ds]", spell.Display, cooldown);
					
					if(++amount > MaxSkills)
					{
						menu.InsertItem((SkillRand[client] + i) % amount, index, spell.Display);
					}
					else
					{
						menu.AddItem(index, spell.Display);
					}
				}
			}

			for(; amount < MaxSkills; amount++)
			{
				menu.AddItem("0", "");
			}

			for(; amount > MaxSkills; amount--)
			{
				menu.RemoveItem(amount);
			}

			menu.AddItem("-3", "Main Menu", ITEMDRAW_SPACER);
			bool CanTransform = true;
			if(f_TransformationDelay[client] > GetGameTime())
				CanTransform = false;

			static Race race;
			static Form form;
			if(Races_GetRaceByIndex(RaceIndex[client], race))
			{
				if(i_TransformationSelected[client] > 0 && i_TransformationSelected[client] <= race.Forms.Length)
				{
					race.Forms.GetArray(i_TransformationSelected[client] - 1, form);
				}
				else
				{
					CanTransform = false;
					form.Default();
				}	
			}
			
			Format(form.Name, sizeof(form.Name), "%s [M%.1f/%.1f]", form.Name, Stats_GetFormMastery(client, form.Name), form.Mastery);
			menu.AddItem("-1", form.Name, CanTransform ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
			menu.AddItem("-2", "Transform Settings");
			menu.AddItem("-3", "Main Menu");

			menu.Pagination = 0;
			menu.ExitButton = true;
			InMenu[client] = menu.Display(client, MENU_TIME_FOREVER);
		}
		case MENU_TRANSFORM:
		{
			Menu menu = new Menu(TextStore_TransformMenu);

			menu.SetTitle("RPG Fortress\n \nTransform Settings:");
			
			Race race;
			if(Races_GetRaceByIndex(RaceIndex[client], race) && race.Forms)
			{
				char data[16], buffer[64];

				Form form;
				int length = race.Forms.Length;
				for(int i; i < length; i++)
				{
					race.Forms.GetArray(i, form);
					IntToString(i, data, sizeof(data));
					FormatEx(buffer, sizeof(buffer), "%s | Mastery [%.1f/%.1f]", form.Name, Stats_GetFormMastery(client, form.Name), form.Mastery);
					menu.AddItem(data, buffer, i_TransformationSelected[client] == (i + 1) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
				}
			}
			
			if(!menu.ItemCount)
				menu.AddItem("0", "None", ITEMDRAW_DISABLED);

			menu.Pagination = 0;
			menu.ExitButton = true;
			InMenu[client] = menu.Display(client, MENU_TIME_FOREVER);
		}
		case MENU_BACKPACK:
		{
			Menu menu = new Menu(TextStore_BackpackMenu);

			int amount;
			bool found;
			int length = Backpack.Length;
			for(int i; i < length; i++)
			{
				static BackpackEnum pack;
				Backpack.GetArray(i, pack);
				if(pack.Owner == client)
				{
					static char index[16], name[64];
					IntToString(pack.Item, index, sizeof(index));

					if(pack.Item == -1)
					{
						strcopy(name, sizeof(name), ITEM_CASH);
					}
					else
					{
						TextStore_GetItemName(pack.Item, name, sizeof(name));
					}
					
					if(pack.Amount != 1)
						Format(name, sizeof(name), "%s x%d", name, pack.Amount);
					
					if(pack.Item == -1)
					{
						if(amount)
						{
							menu.InsertItem(0, index, name);
						}
						else
						{
							menu.AddItem(index, name);
						}
					}
					else
					{
						menu.AddItem(index, name);
						amount += pack.Amount * pack.Weight;
					}

					found = true;
				}
			}

			if(!found)
				menu.AddItem(NULL_STRING, "Empty", ITEMDRAW_DISABLED);

			amount -= 2;
			
			int i;
			while(TF2_GetItem(client, length, i))
			{
				amount += 1;
			}

			menu.SetTitle("RPG Fortress\n \nBackpack (%d / %d):", amount, Stats_BaseCarry(client));

			menu.ExitButton = true;
			InMenu[client] = menu.DisplayAt(client, page / 7 * 7, MENU_TIME_FOREVER);
		}
		case MENU_QUESTBOOK:
		{
			InMenu[client] = Quests_BookMenu(client);
		}
		case MENU_BUILDING:
		{
			/*if(Plots_ShowMenu(client))
			{
				InMenu[client] = true;
			}
			else*/
			{
				MenuType[client] = MENU_SPELLS;
				InMenu[client] = false;
			}
		}
		default:
		{
			InMenu[client] = false;
		}
	}
}

/*
static int TextStore_WeaponSort(int elem1, int elem2, const int[] array, Handle hndl)
{
	if(!StoreWeapon[elem1][0])
		return 1;
	
	for(int i; i < 8; i++)
	{
		if(StoreWeapon[elem1][i] > StoreWeapon[elem2][i])
			return 1;
		
		if(StoreWeapon[elem1][i] < StoreWeapon[elem2][i])
			return -1;
	}
	
	return elem1 > elem2 ? 1 : -1;
}
*/

void TextStore_UnmarkInMenu(int client)
{
	InMenu[client] = false;
}

static int TextStore_BackpackMenu(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			InMenu[client] = false;

			if(choice == MenuCancel_Exit)
				TextStore_Inspect(client);
		}
		case MenuAction_Select:
		{
			if(IsPlayerAlive(client))
			{
				char num[16];
				menu.GetItem(choice, num, sizeof(num));

				int index = StringToInt(num);

				int length = Backpack.Length;
				for(int i; i < length; i++)
				{
					static BackpackEnum pack;
					Backpack.GetArray(i, pack);
					if(pack.Owner == client && pack.Item == index)
					{
						float pos[3];
						GetClientEyePosition(client, pos);
						if(pack.Item == -1)
						{
							length = pack.Amount % 1000;
							if(!length)
								length = 1000;
							
							DropItem(client, index, pos, length);
							pack.Amount -= length;
						}
						else
						{
							DropItem(client, index, pos, 1);
							pack.Amount--;
						}

						if(pack.Amount)
						{
							Backpack.SetArray(i, pack);
						}
						else
						{
							Backpack.Erase(i);
						}
						break;
					}
				}
			}

			ShowMenu(client, choice);
		}
	}
	return 0;
}

static int TextStore_SpellMenu(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			InMenu[client] = false;

			if(choice == MenuCancel_Exit)
				TextStore_Inspect(client);
		}
		case MenuAction_Select:
		{
			if(IsPlayerAlive(client))
			{
				char num[16];
				menu.GetItem(choice, num, sizeof(num));

				int index = StringToInt(num);
				switch(index)
				{
					case -1:
					{
						// Transform player into the selected state!
						TransformButton(client);
					}
					case -2:
					{
						MenuType[client] = MENU_TRANSFORM;
						RefreshAt[client] = 1.0;
						InMenu[client] = false;
						return 0;
					}
					case -3:
					{
						FakeClientCommandEx(client, "sm_store");
						return 0;
					}
					default:
					{
						int length = SpellList.Length;
						for(int i; i < length; i++)
						{
							static SpellEnum spell;
							SpellList.GetArray(i, spell);
							if(spell.Owner == client && spell.Store == index)
							{
								if(spell.Func && spell.Cooldown < GetGameTime())
								{
									float cooldownSet;
									Call_StartFunction(null, spell.Func);
									Call_PushCell(client);
									Call_PushCell(index);
									Call_PushStringEx(spell.Display, sizeof(spell.Display), SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
									Call_Finish(cooldownSet);

									SkillRand[client] = GetURandomInt();

									//CC difficulty, increacing ability cooldowns by 40%.
									if(b_DungeonContracts_LongerCooldown[client])
									{
										float calc = cooldownSet - GetGameTime();
										calc *= 1.4;	
										cooldownSet = calc + GetGameTime();
									}
									
									spell.Cooldown = cooldownSet;
									SpellList.SetArray(i, spell);
								}
								break;
							}
						}
					}
				}
			}

			ShowMenu(client);
		}
	}
	return 0;
}

static int TextStore_TransformMenu(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			InMenu[client] = false;

			if(choice == MenuCancel_Exit)
				TextStore_Inspect(client);
		}
		case MenuAction_Select:
		{
			char num[16];
			menu.GetItem(choice, num, sizeof(num));
			
			i_TransformationSelected[client] = StringToInt(num) + 1;

			ShowMenu(client);
		}
	}
	return 0;
}

stock void TextStore_Inspect(int client)
{
	switch(MenuType[client])
	{
		case MENU_SPELLS:
		{
			MenuType[client] = MENU_BACKPACK;
			RefreshAt[client] = 1.0;
		}
		case MENU_BACKPACK:
		{
			MenuType[client] = MENU_QUESTBOOK;
			RefreshAt[client] = 1.0;
		}
		case MENU_QUESTBOOK, MENU_TRANSFORM, MENU_BUILDING:
		{
			MenuType[client] = MENU_SPELLS;
			RefreshAt[client] = 1.0;
		}
	}
}

void ReApplyTransformation(int client)
{
	if(i_TransformationLevel[client] <= 0)
	{
		return;
	}
	Race race;
	if(Races_GetRaceByIndex(RaceIndex[client], race) && race.Forms)
	{
		Form form;
		race.Forms.GetArray(i_TransformationLevel[client] - 1, form);
		
		if(form.Func_FormActivate != INVALID_FUNCTION)
		{
			Call_StartFunction(null, form.Func_FormActivate);
			Call_PushCell(client);
			Call_Finish();
		}
		Store_ApplyAttribs(client);
	}
}
static void TransformButton(int client)
{
	if(f_TransformationDelay[client] > GetGameTime())
	{
		return;
	}
	Race race;
	if(Races_GetRaceByIndex(RaceIndex[client], race) && race.Forms)
	{
		if(i_TransformationSelected[client] > 0 && i_TransformationSelected[client] <= race.Forms.Length)
		{
			if(i_TransformationSelected[client] == i_TransformationLevel[client])
			{
				De_TransformClient(client);
				return;
			}
			i_TransformationLevel[client] = i_TransformationSelected[client];
			Form form;
			race.Forms.GetArray(i_TransformationLevel[client] - 1, form);
			
			if(form.Func_FormActivate != INVALID_FUNCTION)
			{
				Call_StartFunction(null, form.Func_FormActivate);
				Call_PushCell(client);
				Call_Finish();
			}
			Store_ApplyAttribs(client);
		}
	}
}

void De_TransformClient(int client)
{
	if(i_TransformationLevel[client] <= 0)
	{
		return;
	}
	Race race;
	if(Races_GetRaceByIndex(RaceIndex[client], race) && race.Forms)
	{
		Form form;
		race.Forms.GetArray(i_TransformationLevel[client] - 1, form);
		i_TransformationLevel[client] = 0;
		f_TransformationDelay[client] = GetGameTime() + 5.0;
		if(form.Func_FormDeactivate != INVALID_FUNCTION)
		{
			Call_StartFunction(null, form.Func_FormDeactivate);
			Call_PushCell(client);
			Call_Finish();
		}
		Store_ApplyAttribs(client);
	}
}