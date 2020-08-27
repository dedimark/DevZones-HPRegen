#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>
#include <multicolors>
#include <devzones>
#include <warden>

#pragma semicolon 1
#pragma newdecls required

ConVar ConVar_Regen_HP, ConVar_Regen_Timer, ConVar_Regen_Maxhp;

Handle Handle_HPRegenC_T[MAXPLAYERS + 1];

public Plugin myinfo = 
{
	name = "SM DEV ZONES - HP Regen",
	author = "ByDexter",
	description = "",
	version = "1.0",
	url = "https://steamcommunity.com/id/ByDexterTR/"
};

public void OnPluginStart()
{
	ConVar_Regen_HP = CreateConVar("sm_hpregen", "5", "Bölgede bulunan oyunculara kaç can verilsin");
	ConVar_Regen_Timer = CreateConVar("sm_timeregen", "1.0", "Bölgede bulunan oyunculara kaç saniyede can verilsin");
	ConVar_Regen_Maxhp = CreateConVar("sm_maxhp", "100", "Bölgede bulunan oyunculara kaç versin");
	AutoExecConfig(true, "DevZones-HpRegen", "ByDexter");
}

public void OnClientDisconnect(int client)
{
	if (Handle_HPRegenC_T[client] != INVALID_HANDLE)
	{
		KillTimer(Handle_HPRegenC_T[client]);
		Handle_HPRegenC_T[client] = INVALID_HANDLE;
	}
}

public void Zone_OnClientEntry(int client, const char[] zone)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) ||!IsPlayerAlive(client)) 
		return;
		
	if(StrContains(zone, "hpregen", false) == 0)
	{
		Handle_HPRegenC_T[client] = CreateTimer(ConVar_Regen_Timer.FloatValue, Timer_Regen, client, TIMER_REPEAT);
	}
}

public void Zone_OnClientLeave(int client, const char[] zone)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) ||!IsPlayerAlive(client)) 
		return;
		
	if(StrContains(zone, "hpregen", false) == 0)
	{
		if (Handle_HPRegenC_T[client] != INVALID_HANDLE)
		{
			KillTimer(Handle_HPRegenC_T[client]);
			Handle_HPRegenC_T[client] = INVALID_HANDLE;
		}
		if (GetClientHealth(client) > ConVar_Regen_Maxhp.IntValue)
		{
			SetEntityHealth(client, ConVar_Regen_Maxhp.IntValue);
		}
	}
}

public Action Timer_Regen(Handle timer, any client)
{
	if (GetClientHealth(client) > ConVar_Regen_Maxhp.IntValue)
	{
		SetEntityHealth(client, ConVar_Regen_Maxhp.IntValue);
		return Plugin_Stop;
	}
	int HP = GetClientHealth(client);
	SetEntityHealth(client, HP + ConVar_Regen_HP.IntValue);
	return Plugin_Continue;
}