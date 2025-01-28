#include "a_samp" // include stdlib

#include "fixes" // include samp-fixes

#include "discord-connector" // include discord-connector
#include "samp-chatbot.inc" // include samp-chatbot

main(){}

public OnPlayerSpawn (playerid)
{
  new Float:x, Float:y, Float:z;
  GetPlayerPos playerid, x, y, z;
  SetPlayerPos playerid, x, y, z + 5.0; // fixed spawn

  return 1;
}
