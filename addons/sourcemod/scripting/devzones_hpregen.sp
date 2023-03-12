#include <sourcemod>
#include <devzones>

#pragma semicolon 1
#pragma newdecls required

ConVar RegenHp, RegenTime, RegenMaxHp;

public Plugin myinfo = 
{
	name = "SM DEV ZONES - HP Regen", 
	author = "ByDexter", 
	description = "", 
	version = "1.1", 
	url = "https://steamcommunity.com/id/ByDexterTR/"
};

public void OnPluginStart()
{
	RegenHp = CreateConVar("sm_hpregen_hp", "5", "Bölgede bulunan oyunculara kaç CAN verilsin?\nHow many HP should be given to players in the zone?");
	RegenTime = CreateConVar("sm_hpregen_time", "1.0", "Bölgede bulunan oyunculara kaç saniyede CAN verilsin?\nHow many seconds should HP be given to players in the zone?");
	RegenMaxHp = CreateConVar("sm_hpregen_maxhp", "100", "Bölgedeki insanların maksimum CAN ne olacak?\nWhat HP will the people in the zone have the maximum?");
	AutoExecConfig(true, "DevZones-HpRegen", "ByDexter");
}

public void Zone_OnClientEntry(int client, const char[] zone)
{
	if (IsValidClient(client) && StrContains(zone, "hpregen", false) != -1 && GetClientHealth(client) < RegenMaxHp.IntValue)
	{
		CreateTimer(RegenTime.FloatValue, Timer_RegenHP, client, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action Timer_RegenHP(Handle timer, any client)
{
	if (!IsValidClient(client))
	{
		return Plugin_Stop;
	}
	if (GetClientHealth(client) > RegenMaxHp.IntValue)
	{
		SetEntityHealth(client, RegenMaxHp.IntValue);
		return Plugin_Stop;
	}
	SetEntityHealth(client, GetClientHealth(client) + RegenHp.IntValue);
	return Plugin_Continue;
}

bool IsValidClient(int client, bool nobots = true)
{
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
	{
		return false;
	}
	return IsClientInGame(client);
} 