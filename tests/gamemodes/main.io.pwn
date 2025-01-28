#include "a_samp"
#include "PawnPlus"

#include "discord-connector"
#include "samp-chatbot.inc"

main(){}

public OnPlayerSpawn (playerid)
{
  new Float:x, Float:y, Float:z;
  GetPlayerPos(playerid, x, y, z);
  SetPlayerPos(playerid, x, y, z + 5.0);

  return 1;
}
