#include amxmodx
#include fakemeta

#define AUTHOR "x"
#define VERSION "1.0.0"
#define PLUGIN_NAME "x"

#define NUMAR_DE_BOTI 2

new g_Query[256];
new botz;

public plugin_init()
{
    register_plugin(PLUGIN_NAME, VERSION, AUTHOR);
    set_task( 5.0, "TaskManageBots", .flags="b" );
    botz = 0;
}

new g_Bot[33], g_BotsCount;

public TaskManageBots(){
    static PlayersNum; PlayersNum  = get_playersnum( 1 );
    if( PlayersNum < get_maxplayers() - 1 && g_BotsCount < 2 )
    {
        CreateBot();
    }
    else if(PlayersNum > get_maxplayers() - 1 && g_BotsCount )
    {
        RemoveBot();
    }
}
new const g_Names[][]=
{
	"DNS: Mv.Indungi.Ro",
	"IP: 89.44.246.4:27015"
};

public client_disconnect(i)
{
   if( g_Bot[ i ] ) {
      g_Bot[ i ] = 0, g_BotsCount -- ; botz -= 1;
   }
}

RemoveBot(){
   static i;
   for( i = 1; i <= get_maxplayers(); i++ ) {
      if(g_Bot[ i ]) 
      {
        server_cmd( "kick #%d", get_user_userid( i ) );
        botz -= 1;
        break;
      }}}

CreateBot(){
   static Bot;
   formatex( g_Query, 255, "%s", g_Names[botz] );
   botz += 1;
   Bot = engfunc( EngFunc_CreateFakeClient, g_Query );
   if( Bot > 0 &&pev_valid(Bot)) {
      dllfunc(MetaFunc_CallGameEntity,"player",Bot);
      set_pev(Bot,pev_flags,FL_FAKECLIENT);
      set_pev(Bot, pev_model, "");
      set_pev(Bot, pev_viewmodel2, "");
      set_pev(Bot, pev_modelindex, 0);
      set_pev(Bot, pev_renderfx, kRenderFxNone);
      set_pev(Bot, pev_rendermode, kRenderTransAlpha);
      set_pev(Bot, pev_renderamt, 0.0);
      set_pdata_int(Bot,114,0);
      message_begin(MSG_ALL,get_user_msgid("TeamInfo"));
      write_byte(Bot);
      write_string("UNASSIGNED");
      message_end();
      g_Bot[Bot]=1;
      g_BotsCount++;
   }
}