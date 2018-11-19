#pragma semicolon 1
#include <sourcemod> 
#include <sdktools> 
#include <morecolors> 
#include <tf2_stocks> 
#include <basecomm> 

#define FIELD_COMMAND    "Command" 
#define FIELD_TIME        "Timer" 
#define RED 				2
#define BLU 				3

Handle ARRAY_Commands;
Handle h_cvarEnable;
Handle ff_acikmi;

public Plugin myinfo = 
{
	name = "TF2 Turkiye",
	author = "Kerem",
	description = "",
	version = SOURCEMOD_VERSION,
	url = "https://tf2turkiye.com"
};	

public void OnPluginStart() 
{ 
    h_cvarEnable = CreateConVar("sm_chatacikmi", "1", "(1 - acik, 0 - kapali)", 0, true, 0.0, true, 1.0);
    ff_acikmi = CreateConVar("sm_ffacikmi", "0", "(1 - acik, 0 - kapali)", 0, true, 0.0, true, 1.0);
    ARRAY_Commands = CreateArray(100); 
    HookEvent("teamplay_round_win", Event_RoundWin, EventHookMode_Post); 
    HookEvent("player_death", Event_PlayerDeath);
    HookEvent("round_start", GameStart);
    RegAdminCmd("sm_sayac", CMD_StartCountDown, ADMFLAG_GENERIC, "Sayac baslatma.");
    RegAdminCmd("sm_saklambaciptal", saklambac_iptal, ADMFLAG_GENERIC, "SaklambacIptal.");

    for (new i = 1; i <= MaxClients; i++)
    { 
        if (IsClientInGame(i) && (TF2_GetClientTeam(i) != TFTeam_Blue))
        {
            SetClientListeningFlags(i, VOICE_MUTED);
        }
    }
    
} 
public Action:GameStart(Handle:Event, const String:Name[], bool:Broadcast)
{
    for (new i = 1; i <= MaxClients; i++)
    { 
        if (IsClientInGame(i) && (TF2_GetClientTeam(i) != TFTeam_Blue))
        {
            SetClientListeningFlags(i, VOICE_MUTED);
        }
    }
}
public Action:Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
    if(GetConVarBool(h_cvarEnable) == 0 || GetConVarBool(ff_acikmi) == 1)
	{
        new count, client;
        for (new i = 1; i <= MaxClients; i++)
        { 
            if (IsClientInGame(i) && IsPlayerAlive(i) && (TF2_GetClientTeam(i) == TFTeam_Red))
            {
                client = i;
                count++;
                char yeni[32];
                // IntToString(count,yeni,32);
                // PrintToChatAll(yeni);
            }
        }
        if (count == 1)
        {
            // ForcePlayerSuicide(client);
            if(GetConVarBool(h_cvarEnable) == 0)
                PrintCenterTextAll("SAKLAMBAC OYUNUNU %N KAZANDI!", client);
            if(GetConVarBool(ff_acikmi) == 1)
                PrintCenterTextAll("DOST ATESI OYUNUNU %N KAZANDI!", client);

            CPrintToChatAll("{dimgray}[ {darkgray}SM {dimgray}] {gray}Koruma oyununu %N kazandığı için {blue}Gardiyan {gray}takımına aktarıldı.", client);
            ChangeClientTeam(client, 3);
            ServerCommand("sm_chatacikmi 1");
            ServerCommand("sm_ffacikmi 0");
        }
    }
}   
public Action OnClientSayCommand(int client, const char[] command, const char[] args)
{	
	if(GetConVarBool(h_cvarEnable) == 0)
	{
		if (client != 0)
		{
			CPrintToChat(client, "{dimgray}[ {darkgray}SM {dimgray}] {gray}Yer söyleme veya ipucu vermeyi engelleyebilmek için yetkili saklambaç oyununu sonlandırana veya el bitimine kadar chat kullanımı kapalıdır.");
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public void OnMapStart() 
{ 
    CreateTimer(1.0, TMR_Tick, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE); 
} 

public Action:Event_RoundWin(Handle:event, const String:name[], bool:dontBroadcast) 
{
    if(GetConVarBool(h_cvarEnable) == 0)
	{
        ServerCommand("sm_chatacikmi 1");
        ServerCommand("sm_god @all 0");
        CPrintToChatAll("{dimgray}[ {darkgray}SM {dimgray}] {gray}Chat tekrar kullanıma açıldı.");
    }
    if(GetConVarBool(ff_acikmi) == 1)
	{
        ServerCommand("ff_acikmi 0");
        ServerCommand("mp_friendlyfire 0");
        ServerCommand("sm_god @all 0");
        CPrintToChatAll("{dimgray}[ {darkgray}SM {dimgray}] {gray}Dost ateşi kapatıldı.");
    }
}

public int PanelHandler1(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		PrintToConsole(param1, "You selected item: %d", param2);
	}
	else if (action == MenuAction_Cancel)
	{
		PrintToServer("Client %d's menu was cancelled.  Reason: %d", param1, param2);
	}
}

public Action CMD_StartCountDown(int client, int args) 
{ 
    if (args < 1) 
    { 
        CPrintToChat(client, "Kullanım : sm_sayac [saniye] {komut}"); 
        return Plugin_Handled; 
    } 
     
    char strTime[10]; 
    char strCommand[90]; 
    char strTotal[100]; 

     
    GetCmdArg(1, strTime, sizeof(strTime)); 
    GetCmdArg(2, strCommand, sizeof(strCommand)); 
    Format(strTotal, sizeof(strTotal), "%s¢%s", strTime, strCommand); 
     
    PushArrayString(ARRAY_Commands, strTotal); 
    // PrintToChatAll("Komut: %s",strCommand);

    if(StrEqual("saklambac",strCommand,true))
    {
        Panel panel = new Panel();
        // panel.SetTitle("         Saklambaç Oyunu Kurallari");
        panel.DrawItem("[-]  - - -    Saklambaç Kurallari   - - -  [-]", ITEMDRAW_RAWLINE);
        panel.DrawItem("Mahkumlar yasak yerler hariç haritanin", ITEMDRAW_RAWLINE);
        panel.DrawItem("herhangi bir yerine saklanir ve sona", ITEMDRAW_RAWLINE);
        panel.DrawItem("kalan mahkum gardiyanlarin takimina", ITEMDRAW_RAWLINE);
        panel.DrawItem("koruma olarak girmeye hak kazanir.", ITEMDRAW_RAWLINE);
        panel.DrawItem("[-]  - - - - -   Infaz Sebepleri   - - - - -  [-]", ITEMDRAW_RAWLINE);
        panel.DrawItem("Silah odasina, hücrelerde saklanmak,", ITEMDRAW_RAWLINE);
        panel.DrawItem("uçurumlarda donmak yasak.", ITEMDRAW_RAWLINE);
        panel.DrawItem("[-]  - - - - -    Ban Sebepleri    - - - - -  [-]", ITEMDRAW_RAWLINE);
        panel.DrawItem("Yer söylemek veya ipucu dahi vermek", ITEMDRAW_RAWLINE);
        panel.DrawItem("4 saat ban sebebidir.", ITEMDRAW_RAWLINE);
        panel.DrawItem("Anladim...");
    
        panel.Send(client, PanelHandler1, 30);
        delete panel;

        ServerCommand("sm_god @blue 1");
    }
    
    if(StrEqual("dostatesi",strCommand,true))
    {
        Panel panel = new Panel();
        // panel.SetTitle("         Dost Atesi Oyunu Kurallari");
        panel.DrawItem("[-]  - - -    Dost Atesi Kurallari   - - -  [-]", ITEMDRAW_RAWLINE);
        panel.DrawItem("Mahkumlar esit saglikla arenanin", ITEMDRAW_RAWLINE);
        panel.DrawItem("icerisinde kendi aralarinda dovusur", ITEMDRAW_RAWLINE);
        panel.DrawItem("ve sona kalan mahkum gardiyanlarin", ITEMDRAW_RAWLINE);
        panel.DrawItem("takimina koruma olarak girmeye", ITEMDRAW_RAWLINE);
        panel.DrawItem("hak kazanir.", ITEMDRAW_RAWLINE);
        panel.DrawItem("[-]  - - - - -   Infaz Sebepleri   - - - - -  [-]", ITEMDRAW_RAWLINE);
        panel.DrawItem("Merdivende durmak, arenadan", ITEMDRAW_RAWLINE);
        panel.DrawItem("disari cikmak ve stock harici silah.", ITEMDRAW_RAWLINE);
        panel.DrawItem("kullanmak infaz sebebidir.", ITEMDRAW_RAWLINE);
        panel.DrawItem("Anladim...");
    
        panel.Send(client, PanelHandler1, 30);
        delete panel;

        ServerCommand("sm_setclass @red scout");
        ServerCommand("sm_gi @red 0 3 50 8 0 0 tf_weapon_bat 1");
        ServerCommand("sm_teleport @red -845 -706 -27");
        ServerCommand("sm_teleport @blue -1118 -142 166");
        ServerCommand("sm_hp @red 125");
        ServerCommand("sm_god @blue 1");
    }

    
     
    return Plugin_Handled; 
} 

public Action TMR_Tick(Handle tmr) 
{ 
    char strTotal[100]; 
    char tmrCmd[2][90]; 


     
    for (int i = 0; i <= GetArraySize(ARRAY_Commands); i++) 
    { 
        GetArrayString(ARRAY_Commands, i, strTotal, sizeof(strTotal)); 
        ExplodeString(strTotal, "¢", tmrCmd, sizeof tmrCmd, sizeof tmrCmd[]); 
         
        int timer = StringToInt(tmrCmd[0]); 

        // PrintToChatAll("%s",tmrCmd[1]);

        if(timer>0) {
            if(StrEqual("saklambac",tmrCmd[1],true)) {
                PrintCenterTextAll("Mahkumlarin dondurulmasina son %i saniye!", timer); 
            }
            if(StrEqual("dostatesi",tmrCmd[1],true)) {
                PrintCenterTextAll("Dost atesinin acilmasina son %i saniye!", timer); 
            }
        }
            
         
        timer--; 
        if (timer == -1) 
        { 
            if (strlen(tmrCmd[1]) > 2) {
                if(StrEqual("saklambac",tmrCmd[1],true)) {
                    ServerCommand("sm_freeze @red 720;sm_chatacikmi 0");
                    PrintCenterTextAll("SAKLAMBAC BASLADI!!"); 
                    CPrintToChatAll("{dimgray}[ {darkgray}SM {dimgray}] {gray}Yer söyleme veya ipucu vermeyi engelleyebilmek için yetkili saklambaç oyununu sonlandırana veya el bitimine kadar chat kullanımı kapalıdır.");
                }
                if(StrEqual("dostatesi",tmrCmd[1],true)) {          
                    ServerCommand("mp_friendlyfire 1;sm_ffacikmi 1");
                    PrintCenterTextAll("DOST ATESI BASLADI!!"); 
                    CPrintToChatAll("{dimgray}[ {fullred}DIKKAT {dimgray}] {gray}Dost ateşi başladı!");
                }
                
            }
                
            RemoveFromArray(ARRAY_Commands, i); 
        } 
        else 
        { 
            Format(strTotal, sizeof(strTotal), "%i¢%s", timer, tmrCmd[1]); 
            SetArrayString(ARRAY_Commands, i, strTotal); 
        } 
    } 
} 

public Action saklambac_iptal(int client, int args)
{
    ServerCommand("sm_chatacikmi 1");
    ServerCommand("sm_ffacikmi 0");
    ServerCommand("mp_friendlyfire 0");
    ServerCommand("sm_slay @all");
    ServerCommand("sm_god @all");
    ServerCommand("sm plugins reload timer");
    PrintCenterTextAll("Koruma oyunu iptal edildi.");
    CPrintToChatAll("{dimgray}[ {darkgray}SM {dimgray}] {gray}Koruma oyunu iptal edildi.");
    
}
