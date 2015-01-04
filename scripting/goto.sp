#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION  "0x01"

public Plugin:myinfo = {
    name = "Teleport yourself to a player, or teleport them to you.",
    author = "Chdata",
    description = "Hexy.",
    version = PLUGIN_VERSION,
    url = "http://steamcommunity.com/groups/tf2data"
};
 
//Plugin-Start
public OnPluginStart()
{
    RegAdminCmd("sm_goto",      Command_Goto,  ADMFLAG_SLAY, "Go to a player");
    RegAdminCmd("sm_teleto",    Command_Goto,  ADMFLAG_SLAY, "Go to a player");
    RegAdminCmd("sm_bring",     Command_Bring, ADMFLAG_SLAY, "Teleport a player to you");

    LoadTranslations("common.phrases");
}

public Action:Command_Goto(iClient, iArgc)
{
    if (!iClient)
    {
        ReplyToCommand(iClient, "[SM] Console cannot be teleported.");
        return Plugin_Handled;
    }

    if (iArgc < 1)
    {
        ReplyToCommand(iClient, "[SM] Usage: sm_goto <name>");
        return Plugin_Handled;
    }

    /*if (!IsPlayerAlive(iClient))
    {
        ReplyToCommand(iClient, "[SM] Only living players can use this command.");
        return Plugin_Handled;
    }*/

    decl String:szTarget[32];
    GetCmdArg(1, szTarget, sizeof(szTarget));

    if (StrEqual(szTarget, "@me"))
    {
        ReplyToCommand(iClient, "[SM] Cannot teleport self to self.");
        return Plugin_Handled;
    }

    new iTarget = FindTarget(iClient, szTarget);

    if (iTarget != -1)
    {
        if (IsPlayerAlive(iTarget))
        {
            TeleMeToYou(iClient, iTarget);
        }
        else
        {
            ReplyToCommand(iClient, "[SM] You can only teleport to living players.");
        }
    }

    return Plugin_Handled;
}

public Action:Command_Bring(iClient, iArgc)
{
    if (!iClient)
    {
        ReplyToCommand(iClient, "[SM] Console cannot teleport players to itself.");
        return Plugin_Handled;
    }

    if (iArgc < 1)
    {
        ReplyToCommand(iClient, "[SM] Usage: sm_bring <name>");
        return Plugin_Handled;
    }

    if (!IsPlayerAlive(iClient))
    {
        ReplyToCommand(iClient, "[SM] Only living players can use this command.");
        return Plugin_Handled;
    }

    decl String:szTarget[32];
    GetCmdArg(1, szTarget, sizeof(szTarget));

    if (StrEqual(szTarget, "@me"))
    {
        ReplyToCommand(iClient, "[SM] Cannot teleport self to self.");
        return Plugin_Handled;
    }

    new iTarget = FindTarget(iClient, szTarget);

    if (iTarget != -1)
    {
        if (IsPlayerAlive(iTarget))
        {
            TeleMeToYou(iTarget, iClient);
        }
        else
        {
            ReplyToCommand(iClient, "[SM] Only living players can be teleported to you.");
        }
    }

    return Plugin_Handled;
}

stock TeleMeToYou(iMe, iYou)
{
    decl Float:vPos[3];
    GetEntPropVector(iYou, Prop_Send, "m_vecOrigin", vPos);

    if (GetEntProp(iYou, Prop_Send, "m_bDucked"))
    {
        decl Float:vCollisionVec[3];
        vCollisionVec[0] = 24.0;
        vCollisionVec[1] = 24.0;
        vCollisionVec[2] = 62.0;
        SetEntPropVector(iMe, Prop_Send, "m_vecMaxs", vCollisionVec);
        SetEntProp(iMe, Prop_Send, "m_bDucked", 1);
        SetEntityFlags(iMe, GetEntityFlags(iMe)|FL_DUCKING);
    }
    
    TeleportEntity(iMe, vPos, NULL_VECTOR, NULL_VECTOR);
}