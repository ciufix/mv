/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <cstrike>  
#include <fun>
#include <engine>
#include <hamsandwich>
#include <fakemeta_util>

#define PLUGIN "VIP System"
#define VERSION "0.Ox" 
#define AUTHOR "Hades Ownage"

#define	PREFIX		"!g[MV.INDUNGI.RO]!n"
#define	START_HOUR	21 
#define	END_HOUR	10

#define	REQUIRED_ROUNDS	3

#define	TASKID_CHECKER	82371
#define	TASKID_MESSAGE	82121

new CountRounds = 0, g_sCurrentMap [ 32 ], bool: HappyHours = false;
new HP = 100, Allowmap = 1
new gold[33], silver[33]
new Limit[33]

// Advanced bullet damage � Sn!ff3r
new g_hudmsg1, g_hudmsg2;

// Parachute � KRoT@L/JTP10181 & Fixed sector
new para_ent [ 33 ];
new test
new kill[33]
native set_leader(id)
native delete_leader()
new lastCT, lastT
// Warmup
native is_warmup_enable ( );

public plugin_init ( ) {
	//new NAME_LICENTIAT[20];
   //	get_user_ip(0, NAME_LICENTIAT, charsmax(NAME_LICENTIAT), 1);

   	//if(equal(NAME_LICENTIAT, "89.44.246.211")) {
	register_plugin ( PLUGIN, VERSION, AUTHOR );
	
	RegisterHam ( Ham_Spawn, "player", "Player_Spawn", 1 );
	
	register_message ( get_user_msgid ( "ScoreAttrib" ), "hookMessageScoreAttrib" );
	
	register_event ( "HLTV", "hookNewRound", "a", "1=0", "2=0" );
	register_logevent("clearleader", 2, "1=Round_End");
	register_event ( "DeathMsg", "hookDeathMsg", "a" );
	fChecker ( )
	set_task ( 60.0, "fChecker", TASKID_CHECKER, _, _, "b" );
	set_task ( 600.0, "fMessage", TASKID_MESSAGE, _, _, "b" );

	register_clcmd ( "say /rd", "fResetDeaths" );
	register_clcmd ( "say_team /rd", "fResetDeaths" );
	register_clcmd ( "say", "handleSay" )
	register_concmd("amx_givemoney", "givemoney")
	
	// Advanced bullet damage � Sn!ff3r
	
	register_event ( "Damage", "hookOnDamage", "b", "2!0", "3=0", "4!0" );	
	
	g_hudmsg1 = CreateHudSyncObj ( );
	g_hudmsg2 = CreateHudSyncObj ( );
	citeste();
	//}
	
}

public handleSay(id)
{
	if(!gold[id])
		return 0;

	new args[64],comanda[18]
	
	read_args(args, charsmax(args))
	remove_quotes(args)
	new arg1[9];
	new arg2[32];
	
	strbreak(args, arg1, charsmax(arg1), arg2, charsmax(arg2));
	formatex(comanda, charsmax(comanda), "/give")

	if (equal(arg1,comanda, strlen(comanda)+1))
		donate(id, arg2);

	return 0;
	
}
public donate(id, arg[])
{
	new to[32], count[10], player[32], player2[32];
	strbreak(arg, to, charsmax(to), count, charsmax(count));
	
	if (!to[0])
	{
		chat_color(id, "^x04Jucatorul care la-ti scris nu este pe server");
		return 1;
	}

	new reciever = cmd_target(id, to, (CMDTARGET_ALLOW_SELF));
	new nr = str_to_num(count)

	if (!reciever)
	{
		chat_color(id, "^x04Jucatorul care la-ti scris nu este pe server");
		return 1;
	}

	else if (cs_get_user_money(id) < nr )
	{
		chat_color(id, "^x04Nu ai suficienti bani");
		return 1;
	}

	else if (cs_get_user_money(reciever) >= 16000 )
	{
		chat_color(id, "^x04Jucatorul care la-ti scris are nr. maxim de bani");
		return 1;
	}
	get_user_name(id, player, charsmax(player))
	get_user_name(reciever, player2, charsmax(player2))
	if(cs_get_user_money(reciever)+nr > 16000)
	{
		chat_color(id, "^x04Jucatorul %s va trece limita de bani, mai poate primi %d$",player2, (16000-cs_get_user_money(reciever)));
		return 1;
	}
	chat_color(0, "^x04%s ^x01i-a dat lui ^x04%s ^x03%d^x04$",player,player2,nr);
	cs_set_user_money(id, cs_get_user_money(id)-nr)
	cs_set_user_money(reciever, cs_get_user_money(reciever)+nr)
	return 0;
}
public givemoney(id) {
	if(get_user_flags ( id ) & read_flags ( "abcdefghijklmnopqrst" ))
	{
		new target_name[32]
		new Amount[10]
		
		read_argv(1, target_name, 31)
		read_argv(2, Amount, 9)
		
		if(equal(target_name, "") || equal(Amount, ""))
		{
			console_print(id, "amx_givemoney <Nume> <Suma>")
			return 1
		}
		
		new Money = str_to_num(Amount)
		
		if(Money <= 0)
		{
			console_print(id, "Trebuie sa scrii o suma mai mare decat 0 !")
			return 1
		}
		
		new iPlayer = cmd_target(id, target_name, 8)
		
		if(!iPlayer)
		{
			console_print(id, "Jucatorul %s nu a fost gasit !", target_name)
			return 1
		}

		cs_set_user_money(iPlayer, cs_get_user_money(iPlayer)+Money)

		return 1
	}
	else
	{
		console_print(id, "Nu ai acces la aceasta comanda !")
		return 1
	}
	return 1
}  
public plugin_natives ( )
	register_native ( "is_happy_hours", "is_happy_hours", 1 );

public is_happy_hours ( ) return HappyHours;	

public fResetDeaths ( id ) {
	if(get_user_flags ( id ) & read_flags ( "abcdefghijklmnopqrst" ))
	{
		cs_set_user_deaths ( id, 0 );
		chat_color ( id, "!g[MV DEATHS]!n Ti-ai resetat decesele!" );
	}
	else
	{
		if(gold[id] == 1 && Limit[id] < 3)
		{
			Limit [ id ]++;
			cs_set_user_deaths ( id, 0 );
			chat_color ( id, "!g[MV DEATHS]!n Ti-ai resetat decesele, ti le mai poti reseta de %d ori!",(3-Limit[id]));
		}
		else if(gold[id] == 1 && Limit[id] >= 3)
			chat_color ( id, "!g[MV DEATHS]!n Ai folosit nr maxim de /rd!" );
	}
}

public fChecker ( ) {
	
	new Hour;
	time ( Hour, _, _ );
	
	if ( Hour >= START_HOUR || Hour < END_HOUR ) {

		HappyHours = true;
		chat_color ( 0, "!gHappyHours este in desfasurare!" )
		
		if ( equali ( g_sCurrentMap, "de_dust" ) == -1 )
			server_cmd ( "changelevel de_dust2" );
		else {
			
			set_cvar_num ( "mp_timelimit", 0 );
			
			static id;
			for ( id = 1; id <= get_maxplayers ( ); id++ )
				if ( is_user_connected ( id ) )
					gold[id] = true;
			
		}
	}
	
	else {
		
		if ( Hour >= END_HOUR && HappyHours ) {
			
			HappyHours = false;
			server_cmd ( "changelevel de_inferno" );
			
		}
		
		
	}
	
}
public citeste()
{
	get_mapname( g_sCurrentMap, charsmax ( g_sCurrentMap ) );
	strtolower( g_sCurrentMap );
	new szDatadir[ 64 ],g_szFile[128];
	get_localinfo( "amxx_configsdir", szDatadir, charsmax( szDatadir ) );
	
	formatex( szDatadir, charsmax( szDatadir ), "%s", szDatadir );
	
	if( !dir_exists( szDatadir ) )
		mkdir( szDatadir );
	
	formatex( g_szFile, charsmax( g_szFile ), "%s/hp_maps.ini", szDatadir );
	
	if( !file_exists( g_szFile ) ) {
		write_file( g_szFile, "// ^"Nume mapa^" ^"hp^" ^"acces meniu/grenade^"", -1 );
		write_file( g_szFile, "// ^"de_dust2^" ^"100^" ^"1^"", -1 );
	}
	
	new Data[ 256 ], mapa[ 32 ], mapa2[32], hpmapa[16], arme[16];
	new iFile = fopen( g_szFile, "rt" );
	
	while( !feof( iFile ) ) {
		fgets( iFile, Data, charsmax( Data ) );
		
		parse( Data, mapa, charsmax(mapa), hpmapa, charsmax(hpmapa), arme, charsmax(arme) );
		
		replace_all(mapa, charsmax(mapa), " ", "")
		replace_all(g_sCurrentMap, charsmax(g_sCurrentMap), " ", "")
		if(equali(mapa, g_sCurrentMap)) {
			HP = str_to_num(hpmapa)
			Allowmap = str_to_num(arme)
			break;
		}
	}
	
	fclose( iFile );

	formatex( g_szFile, charsmax( g_szFile ), "%s/knife_maps.ini", szDatadir );
	
	if( !file_exists( g_szFile ) ) {
		write_file( g_szFile, "// Nume mapa", -1 );
		write_file( g_szFile, "// de_dust2", -1 );
	}
	
	new sData[ 256 ];
	new iFile2 = fopen( g_szFile, "rt" );
	
	while( !feof( iFile2 ) ) {
		fgets( iFile2, sData, charsmax( sData ) );
		
		parse( sData, mapa2, charsmax(mapa2));

		if( equal( mapa2, g_sCurrentMap ) ) {
			set_cvar_num("wup_mode",2);
			test = 1
			break;
		}
	}
	
	fclose( iFile2 );
}
public fMessage ( ) chat_color ( 0, "%s In intervalul !g21:00 - 10:00!n singura mapa jucata este !gde_dust2, !giar toti jucatorii au !gGold VIP.", PREFIX );

public client_putinserver ( id ) {
	if(test == 1)
		set_cvar_num("wup_mode",2);

	if ( HappyHours )
	{
		gold[id] = 1;
		return 1;
	}
	new name[32]
	get_user_name(id, name, charsmax(name))
	new szDatadir[ 64 ],g_szFile[128];
	get_localinfo( "amxx_configsdir", szDatadir, charsmax( szDatadir ) );
	
	formatex( szDatadir, charsmax( szDatadir ), "%s", szDatadir );
	
	if( !dir_exists( szDatadir ) )
		mkdir( szDatadir );
	
	formatex( g_szFile, charsmax( g_szFile ), "%s/vips.ini", szDatadir );
	
	if( !file_exists( g_szFile ) ) {
		write_file( g_szFile, "// ^"nume^" ^"flah vip^"", -1 );
		write_file( g_szFile, "// ^"zorken^" ^"bst^"", -1 );
	}
	
	new sData[ 256 ], nume[32], flags[32];
	new iFile = fopen( g_szFile, "rt" );
	
	while( !feof( iFile ) ) {
		fgets( iFile, sData, charsmax( sData ) );
		
		if( !sData[ 0 ] || sData[ 0 ] == ';' || sData[ 0 ] == ' ' || ( sData[ 0 ] == '/' && sData[ 1 ] == '/' ) )
			continue;
		
		parse( sData, nume, charsmax(nume), flags, charsmax(flags));
		
		if( equal( name, nume ) ) {
			if(equal(flags, "bst"))
				gold[id] = 1
			else if(equal(flags, "bt"))
				silver[id] = 1
			break;
		}
	}
	fclose( iFile );
	if ( gold[id] )
	{
		chat_color ( 0, "%s !gPlayer!n *VIP*!t Gold %s!n has connected on this server.", PREFIX, get_name ( id ) );
	}
	else if ( silver[id] )
	{
		chat_color ( 0, "%s !gPlayer!n *VIP*!t Silver %s!n has connected on this server.", PREFIX, get_name ( id ) );
	}
	return 0
}

public Player_Spawn ( id ) {
	
	if ( !is_user_connected ( id ) || !is_user_alive ( id ) )
		return 1;
	
	parachute_reset ( id );
	
	if ( gold[id] || silver[id] ) {
		
		fm_set_user_armor ( id, 100 );
		
		if(gold[id]) {
			
			fm_set_user_health ( id, HP );
			
			
			if ( CountRounds >= REQUIRED_ROUNDS && Allowmap )
			{
				ShowGoldMenu ( id );
				fm_give_item ( id, "weapon_flashbang" );
				fm_give_item ( id, "weapon_hegrenade" );
				fm_give_item ( id, "weapon_flashbang" );
			}
		}
		
		else{
			if ( CountRounds >= REQUIRED_ROUNDS && Allowmap )
			{
				ShowSilverMenu ( id );
				fm_give_item ( id, "weapon_flashbang" );
				fm_give_item ( id, "weapon_hegrenade" );
				fm_give_item ( id, "weapon_flashbang" );
			}
		}
	}
	
	return 1;
	
}

public ShowGoldMenu ( id ) {
	
	new menu = menu_create ( "Gold VIP", "GoldVIP_Handler" );
	
	if ( get_user_team ( id ) == 2 ) {
		
		menu_additem ( menu, "\wGet\r M4A1\w +\r Deagle", "1", 0 );
		menu_additem ( menu, "\wGet\r AUG\w +\r Deagle", "2", 0 );
		menu_additem ( menu, "\wGet\r Famas\w +\r Deagle", "3", 0 );
		if(CountRounds >= 4)
		{
			menu_additem ( menu, "\wGet\r SG 550\w +\r Deagle", "4", 0 );
			menu_additem ( menu, "\wGet\r AWP\w +\r Deagle", "5", 0 );
		}
		else
		{
			menu_additem ( menu, "\wGet\r SG 550\w +\r Deagle\d[Round 4]", "0", 0 );
			menu_additem ( menu, "\wGet\r AWP\w +\r Deagle\d[Round 4]", "0", 0 );
		}
	}
	
	else if ( get_user_team ( id ) == 1 ) {
		
		menu_additem ( menu, "\wGet\r AK47\w +\r Deagle", "1", 0 );
		menu_additem ( menu, "\wGet\r SG 552\w +\r Deagle", "2", 0 );
		menu_additem ( menu, "\wGet\r Galil\w +\r Deagle", "3", 0 );
		if(CountRounds >= 4)
		{
			menu_additem ( menu, "\wGet\r G3SG1\w +\r Deagle", "4", 0 );
			menu_additem ( menu, "\wGet\r AWP\w +\r Deagle", "5", 0 );
		}
		else
		{
			menu_additem ( menu, "\wGet\r G3SG1\w +\r Deagle\d[Round 4]", "0", 0 );
			menu_additem ( menu, "\wGet\r AWP\w +\r Deagle\d[Round 4]", "0", 0 );
		}
		
	}
	
	menu_setprop ( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display ( id, menu, 0 );
	
	return 1;
	
}

public GoldVIP_Handler ( id, menu, item ) { 
	
	if( item == MENU_EXIT || !is_user_connected ( id ) || !is_user_alive ( id ) ) {
		
		menu_destroy ( menu ); 
		return 1; 
	} 
	
	new data [ 6 ], szName [ 64 ];
	new access, callback;
	menu_item_getinfo ( menu, item, access, data,charsmax ( data ), szName,charsmax ( szName ), callback );
	new key = str_to_num ( data );
	if(key == 0)
		ShowGoldMenu ( id )

	if ( get_user_team ( id ) == 2 ) {
		
		switch ( key ) {
			
			case 1:
			{
				StripHades ( id );
				
				fm_give_item ( id, "weapon_m4a1" );
				fm_give_item ( id, "weapon_deagle" );
				
				cs_set_user_bpammo ( id, CSW_M4A1, 90 );
				cs_set_user_bpammo ( id, CSW_DEAGLE, 30 );
				
				chat_color ( id, "%s Ai primit!g M4A1!n si !gDeagle!n !", PREFIX );
				
			}
			
			case 2:
			{
				StripHades ( id );
				
				fm_give_item ( id, "weapon_aug" );
				fm_give_item ( id, "weapon_deagle" );
				
				cs_set_user_bpammo ( id, CSW_AUG, 90 );
				cs_set_user_bpammo ( id, CSW_DEAGLE, 30 );
				
				chat_color ( id, "%s Ai primit!g AUG!n si !gDeagle!n !", PREFIX );
				
			}
			
			case 3:
			{
				StripHades ( id );
				
				fm_give_item ( id, "weapon_famas" );
				fm_give_item ( id, "weapon_deagle" );
				
				cs_set_user_bpammo ( id, CSW_FAMAS, 90 );
				cs_set_user_bpammo ( id, CSW_DEAGLE, 30 );
				
				chat_color ( id, "%s Ai primit!g Famas!n si !gDeagle!n !", PREFIX );
				
			}
			
			case 4:
			{
				StripHades ( id );
				
				fm_give_item ( id, "weapon_sg550" );
				fm_give_item ( id, "weapon_deagle" );
				
				cs_set_user_bpammo ( id, CSW_SG550, 90 );
				cs_set_user_bpammo ( id, CSW_DEAGLE, 30 );
				
				chat_color ( id, "%s Ai primit!g SG 550!n si !gDeagle!n !", PREFIX );
				
			}
			
			case 5:
			{
				StripHades ( id );
				
				fm_give_item ( id, "weapon_awp" );
				fm_give_item ( id, "weapon_deagle" );
				
				cs_set_user_bpammo ( id, CSW_AWP, 90 );
				cs_set_user_bpammo ( id, CSW_DEAGLE, 30 );
				
				chat_color ( id, "%s Ai primit!g AWP!n si !gDeagle!n !", PREFIX );
				
			}
			
		}
		
	}
	
	else if ( get_user_team ( id ) == 1 ) {
		
		switch ( key ) {
			
			case 1:
			{
				StripHades ( id );
				
				fm_give_item ( id, "weapon_ak47" );
				fm_give_item ( id, "weapon_deagle" );
				
				cs_set_user_bpammo ( id, CSW_AK47, 90 );
				cs_set_user_bpammo ( id, CSW_DEAGLE, 30 );
				
				chat_color ( id, "%s Ai primit!g AK47!n si !gDeagle!n !", PREFIX );
				
			}
			
			case 2:
			{
				StripHades ( id );
				
				fm_give_item ( id, "weapon_sg552" );
				fm_give_item ( id, "weapon_deagle" );
				
				cs_set_user_bpammo ( id, CSW_SG552, 90 );
				cs_set_user_bpammo ( id, CSW_DEAGLE, 30 );
				
				chat_color ( id, "%s Ai primit!g SG552!n si !gDeagle!n !", PREFIX );
				
			}
			
			case 3:
			{
				StripHades ( id );
				
				fm_give_item ( id, "weapon_galil" );
				fm_give_item ( id, "weapon_deagle" );
				
				cs_set_user_bpammo ( id, CSW_GALIL, 90 );
				cs_set_user_bpammo ( id, CSW_DEAGLE, 30 );
				
				chat_color ( id, "%s Ai primit!g Galil!n si !gDeagle!n !", PREFIX );
				
			}
			
			case 4:
			{
				StripHades ( id );
				
				fm_give_item ( id, "weapon_g3sg1" );
				fm_give_item ( id, "weapon_deagle" );
				
				cs_set_user_bpammo ( id, CSW_G3SG1, 90 );
				cs_set_user_bpammo ( id, CSW_DEAGLE, 30 );
				
				chat_color ( id, "%s Ai primit!g G3SG1!n si !gDeagle!n !", PREFIX );
				
			}
			
			case 5:
			{
				StripHades ( id );
				
				fm_give_item ( id, "weapon_awp" );
				fm_give_item ( id, "weapon_deagle" );
				
				cs_set_user_bpammo ( id, CSW_AWP, 90 );
				cs_set_user_bpammo ( id, CSW_DEAGLE, 30 );
				
				chat_color ( id, "%s Ai primit!g AWP!n si !gDeagle!n !", PREFIX );
				
			}
			
		}
		
	}
	
	return 1;
	
}

public ShowSilverMenu ( id ) {
	
	new menu = menu_create ( "Silver VIP", "SilverVIP_Handler" );
	
	if ( get_user_team ( id ) == 2 ) {
		
		menu_additem ( menu, "\wGet\r AUG\w +\r USP", "1", 0 );
		menu_additem ( menu, "\wGet\r Famas\w +\r USP", "2", 0 );
		menu_additem ( menu, "\wGet\r MP5\w +\r USP", "3", 0 );
		if(CountRounds >= 4)
			menu_additem ( menu, "\wGet\r Sig 550\w +\r USP", "4", 0 );
		else
			menu_additem ( menu, "\wGet\r Sig 550\w +\r USP/d[Round 4]", "0", 0 );
		
	}
	
	else if ( get_user_team ( id ) == 1 ) {
		
		menu_additem ( menu, "\wGet\r Sig 552\w +\r USP", "1", 0 );
		menu_additem ( menu, "\wGet\r Galil\w +\r USP", "2", 0 );
		menu_additem ( menu, "\wGet\r UMP45\w +\r USP", "3", 0 );
		if(CountRounds >= 4)
			menu_additem ( menu, "\wGet\r G3SG1\w +\r USP", "4", 0 );
		else
			menu_additem ( menu, "\wGet\r G3SG1\w +\r USP/d[Round 4]", "0", 0 );
		
	}
	
	menu_setprop ( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display ( id, menu, 0 );
	
	return 1;
	
}

public SilverVIP_Handler ( id, menu, item ) { 
	
	if( item == MENU_EXIT || !is_user_connected ( id ) || !is_user_alive ( id ) ) {
		
		menu_destroy ( menu ); 
		return 1; 
	} 
	
	new data [ 6 ], szName [ 64 ];
	new access, callback;
	menu_item_getinfo ( menu, item, access, data,charsmax ( data ), szName,charsmax ( szName ), callback );
	new key = str_to_num ( data );
	if(key == 0)
		ShowSilverMenu ( id )

	if ( get_user_team ( id ) == 2 ) {
		
		switch ( key ) {
			
			case 1:
			{
				StripHades ( id );
				
				fm_give_item ( id, "weapon_aug" );
				fm_give_item ( id, "weapon_usp" );
				
				cs_set_user_bpammo ( id, CSW_AUG, 90 );
				cs_set_user_bpammo ( id, CSW_USP, 90 );
				
				chat_color ( id, "%s Ai primit!g AUG!n si !gUSP!n !", PREFIX );
				
			}
			
			case 2:
			{
				StripHades ( id );
				
				fm_give_item ( id, "weapon_famas" );
				fm_give_item ( id, "weapon_usp" );
				
				cs_set_user_bpammo ( id, CSW_FAMAS, 90 );
				cs_set_user_bpammo ( id, CSW_USP, 90 );
				
				chat_color ( id, "%s Ai primit!g Famas!n si !gUSP!n !", PREFIX );
				
			}
			
			case 3:
			{
				StripHades ( id );
				
				fm_give_item ( id, "weapon_mp5navy" );
				fm_give_item ( id, "weapon_usp" );
				
				cs_set_user_bpammo ( id, CSW_MP5NAVY, 90 );
				cs_set_user_bpammo ( id, CSW_USP, 90 );
				
				chat_color ( id, "%s Ai primit!g MP5!n si !gUSP!n !", PREFIX );
				
			}
			
			case 4:
			{
				StripHades ( id );
				
				fm_give_item ( id, "weapon_sg550" );
				fm_give_item ( id, "weapon_usp" );
				
				cs_set_user_bpammo ( id, CSW_SG550, 90 );
				cs_set_user_bpammo ( id, CSW_USP, 90 );
				
				chat_color ( id, "%s Ai primit!g SG 550!n si !gUSP!n !", PREFIX );
				
			}
			
			
		}
		
	}
	
	else if ( get_user_team ( id ) == 1 ) {
		
		switch ( key ) {
			
			case 1:
			{
				StripHades ( id );
				
				fm_give_item ( id, "weapon_sg552" );
				fm_give_item ( id, "weapon_usp" );
				
				cs_set_user_bpammo ( id, CSW_SG552, 90 );
				cs_set_user_bpammo ( id, CSW_USP, 90 );
				
				chat_color ( id, "%s Ai primit!g SG 552!n si !gUSP!n !", PREFIX );
				
			}
			
			case 2:
			{
				StripHades ( id );
				
				fm_give_item ( id, "weapon_galil" );
				fm_give_item ( id, "weapon_usp" );
				
				cs_set_user_bpammo ( id, CSW_GALIL, 90 );
				cs_set_user_bpammo ( id, CSW_USP, 90 );
				
				chat_color ( id, "%s Ai primit!g Galil!n si !gUSP!n !", PREFIX );
				
			}
			
			case 3:
			{
				StripHades ( id );
				
				fm_give_item ( id, "weapon_ump45" );
				fm_give_item ( id, "weapon_usp" );
				
				cs_set_user_bpammo ( id, CSW_UMP45, 90 );
				cs_set_user_bpammo ( id, CSW_USP, 90 );
				
				chat_color ( id, "%s Ai primit!g UMP45!n si !gUSP!n !", PREFIX );
				
			}
			
			case 4:
			{
				StripHades ( id );
				
				fm_give_item ( id, "weapon_g3sg1" );
				fm_give_item ( id, "weapon_usp" );
				
				cs_set_user_bpammo ( id, CSW_G3SG1, 90 );
				cs_set_user_bpammo ( id, CSW_USP, 90 );
				
				chat_color ( id, "%s Ai primit!g G3SG1!n si !gUSP!n !", PREFIX );
				
			}
			
			
		}
		
	}
	
	return 1;
	
}

public hookDeathMsg ( ) {
	
	new iKiller = read_data(1);
	new iVictim = read_data(2);
	new iHeadShot = read_data(3);
	
	if (gold[iKiller]) {
		if(get_user_health ( iKiller ) < 100)
		{
			if ( iHeadShot && get_user_health ( iKiller ) + 20 < 100 )
				fm_set_user_health ( iKiller, get_user_health ( iKiller ) + 20 );
			else if ( iHeadShot && get_user_health ( iKiller ) + 20 > 100 )
				fm_set_user_health ( iKiller, 100 );
			else {
				if ( get_user_health ( iKiller ) + 10 < 100 )
					fm_set_user_health ( iKiller, get_user_health ( iKiller ) + 10 );
				else
					fm_set_user_health ( iKiller, 100 );	
			
			}
		}
		
		if ( iHeadShot )
			cs_set_user_money ( iKiller, cs_get_user_money ( iKiller ) + 200, 1 );
		else
			cs_set_user_money ( iKiller, cs_get_user_money ( iKiller ) + 100, 1 ); 
	}
	if(iHeadShot && get_user_flags(iKiller)  & read_flags ( "abcdefghijklmnopqrst" ))
	{
		set_user_frags(iKiller,get_user_frags(iKiller)+1)
		kill[iKiller]++
	}
	kill[iKiller]++
	
	parachute_reset ( iVictim );
}

public hookNewRound ( ) {
	
	if ( !is_warmup_enable ( ) )
	{
		CountRounds++;

		if(CountRounds <= 4)
			set_task(10.0, "resetfreq")

		if(CountRounds > 2)
			leader()
	}
	else
		CountRounds = 0

	client_cmd(0, "spk misc/prepareMV.wav")
	
}
public clearleader()
{
	if(is_user_connected(lastT) && silver[lastT])
	{
		silver[lastT] = 0
	}

	if(is_user_connected(lastCT) && silver[lastCT])
	{
		silver[lastCT] = 0
	}

	delete_leader()
}
public leader()
{
	if(get_playersnum(1)-3 < 4)
		return 1;

	new killuriT = -1, killuriCT = -1, winT,winCT, remizaT, remizaCT
	for(new id;id< 32;id++)
	{
		if(is_user_connected(id))
		{
			if(cs_get_user_team(id) == CS_TEAM_T)
			{
				if(killuriT < kill[id])
				{
					if(remizaT)
						remizaT = 0

					killuriT = kill[id]
					winT = id
				}
				else if(killuriT == kill[id] && killuriT > 0)
				{
					remizaT++
					winT = -1
					killuriT = kill[id]
				}
			}
			else if(cs_get_user_team(id) == CS_TEAM_CT)
			{
				if(killuriCT < kill[id])
				{
					if(remizaCT)
						remizaCT = 0

					killuriCT = kill[id]
					winCT = id
				}
				else if(killuriCT == kill[id] && killuriCT > 0)
				{
					remizaCT++
					winCT = -1
					killuriCT = kill[id]
				}
			}
		}
	}
	if(killuriCT > 0 && killuriCT != killuriT && !remizaCT)
	{
		new name[32]
		get_user_name(winCT, name, charsmax(name))
		for(new id;id< 32;id++)
		{
			if(is_user_connected(id) && cs_get_user_team(id) == CS_TEAM_CT)
			{
				chat_color(id, "%s Jucatorul %s este liderul echipei cu %d killuri", PREFIX, name, kill[winCT] );
			}
		}
		if(is_user_connected(lastCT) && lastCT != winCT)
			chat_color(lastCT, "%s Jucatorul %s te-a intrecut, a facut cu %d killuri mai multe ca tine.!", PREFIX,name,(kill[winCT]-kill[lastCT]));

		chat_color(winCT, "%s Felicitari, esti liderul echipei !", PREFIX);
		chat_color(winCT, "%s Ai primit 500$ pentru ca ai facut cele mai multe killuri!", PREFIX);
		cs_set_user_money(winCT, cs_get_user_money(winCT)+500)
		if(!gold[winCT] && !silver[winCT])
		{
			silver[winCT] = 1
			lastCT = winCT
			Player_Spawn ( winCT )
		}
		set_leader(winCT)
	}
	if(killuriT > 0 && killuriT != killuriCT && !remizaT)
	{
		new name[32]
		get_user_name(winT, name, charsmax(name))
		for(new id;id< 32;id++)
		{
			if(is_user_connected(id) && cs_get_user_team(id) == CS_TEAM_T)
			{
				chat_color(id, "%s Jucatorul %s este liderul echipei cu %d killuri", PREFIX, name,kill[winT] );
			}
		}
		if(is_user_connected(lastT) && lastCT != winT)
			chat_color(lastT, "%s Jucatorul %s te-a intrecut, a facut cu %d killuri mai multe ca tine.!", PREFIX,name,(kill[winT]-kill[lastT]));

		chat_color(winT, "%s Felicitari, esti liderul echipei !", PREFIX);
		chat_color(winT, "%s Ai primit 500$ pentru ca ai facut cele mai multe killuri!", PREFIX);
		cs_set_user_money(winT, cs_get_user_money(winT)+500)
		if(!gold[winT] && !silver[winT])
		{
			silver[winT] = 1
			lastT = winT
			Player_Spawn ( winT )
		}
		set_leader(winT)
	}
	if(remizaCT > 1)
	{
		for(new id;id< 32;id++)
		{
			if(is_user_connected(id) && cs_get_user_team(id) == CS_TEAM_CT)
			{
				chat_color(id, "%s %d jucatori au facut aceleasi killuri", PREFIX, remizaCT );
				chat_color(id, "%s Prin urmare este remiza.", PREFIX);
			}
		}
	}
	if(remizaT > 1)
	{
		for(new id;id< 32;id++)
		{
			if(is_user_connected(id) && cs_get_user_team(id) == CS_TEAM_T)
			{
				chat_color(id, "%s %d jucatori au facut aceleasi killuri", PREFIX, remizaT );
				chat_color(id, "%s Prin urmare este remiza.", PREFIX);
			}
		}
	}
	if(killuriT == killuriCT)
	{
		chat_color(0, "%s Nu exista niciun leader pentru ca e remiza.", PREFIX);
	}
	return 0;
}
public resetfreq()
{
	for(new id;id< 32;id++)
	{
		if(is_user_connected(id) && (gold[id]||silver[id]||lastCT == id||lastT == id))
		{
			static ic[64]
			if(CountRounds < 3)
			{
				if(gold[id])
					format(ic, charsmax(ic), "Mai sunt %i runde pana devii un Gold VIP.", (3-CountRounds))
				else if(silver[id])
					format(ic, charsmax(ic), "Mai sunt %i runde pana devii un Silver VIP.", (3-CountRounds))
			}
			else if(CountRounds == 3)
			{
				if(gold[id])
					formatex(ic, charsmax(ic), "Ai devenit un Gold VIP.")
				else if(silver[id])
					formatex(ic, charsmax(ic), "Ai devenit un Silver VIP.")
				else if(lastCT == id||lastT == id)
					formatex(ic, charsmax(ic), "Ai devenit un Leader.")
			}
			else if(CountRounds == 4)
			{
				formatex(ic, charsmax(ic), "New weapons have been unlocked")
			}
			set_hudmessage(255, 0, 0, -1.0, 0.20, 0, 0.5, 12.0, 2.0, 2.0, -1);
			show_hudmessage(id, "%s", ic);
		}
	}
}
public hookMessageScoreAttrib(const MsgId, const MsgType, const MsgDest) {
	
	new id;
	id = get_msg_arg_int(1);
	
	if(gold[id] && !get_msg_arg_int(2))
		set_msg_arg_int(2, ARG_BYTE, (1 << 2 ));

}
public hookOnDamage ( id ) {
	
	static attacker; attacker = get_user_attacker(id)
	static damage; damage = read_data(2)
	
	
	set_hudmessage(255, 0, 0, 0.45, 0.50, 2, 0.1, 4.0, 0.1, 0.1, -1)
	ShowSyncHudMsg(id, g_hudmsg2, "%i^n", damage)		
	
	if(is_user_connected(attacker))
	{
		set_hudmessage(0, 100, 200, -1.0, 0.55, 2, 0.1, 4.0, 0.02, 0.02, -1)
		ShowSyncHudMsg(attacker, g_hudmsg1, "%i^n", damage)				
		
	}
	
}

// Parachute � KRoT@L/JTP10181 & Fixed sector

public client_connect(id)
{
	parachute_reset(id)
}

public client_disconnect(id)
{
	parachute_reset(id)
	gold[id] = 0
	silver[id] = 0
	kill[id] = 0
}


public client_PreThink(id)
{
   if(!is_user_connected ( id ) || !is_user_alive(id) || !(gold[id]||silver[id]) ) return
   
   new Float:fallspeed = 100 * -1.0
   new Float:frame
   new button = get_user_button(id)
   new oldbutton = get_user_oldbutton(id)
   new flags = get_entity_flags(id)
   if(para_ent[id] > 0 && (flags & FL_ONGROUND)) 
   {
      if(fm_get_user_gravity(id) == 0.1) fm_set_user_gravity(id, 1.0)
      {
         if(entity_get_int(para_ent[id],EV_INT_sequence) != 2) 
         {
            entity_set_int(para_ent[id], EV_INT_sequence, 2)
            entity_set_int(para_ent[id], EV_INT_gaitsequence, 1)
            entity_set_float(para_ent[id], EV_FL_frame, 0.0)
            entity_set_float(para_ent[id], EV_FL_fuser1, 0.0)
            entity_set_float(para_ent[id], EV_FL_animtime, 0.0)
            entity_set_float(para_ent[id], EV_FL_framerate, 0.0)
            return
         }
         frame = entity_get_float(para_ent[id],EV_FL_fuser1) + 2.0
         entity_set_float(para_ent[id],EV_FL_fuser1,frame)
         entity_set_float(para_ent[id],EV_FL_frame,frame)
         if(frame > 254.0) 
         {
            remove_entity(para_ent[id])
            para_ent[id] = 0
         }
         else 
         {
            remove_entity(para_ent[id])
            fm_set_user_gravity(id, 1.0)
            para_ent[id] = 0
         }
         return
      }
   }
   if (button & IN_USE) 
   {
      new Float:velocity[3]
      entity_get_vector(id, EV_VEC_velocity, velocity)
      if(velocity[2] < 0.0) 
      {
         if(para_ent[id] <= 0) 
         {
            para_ent[id] = create_entity("info_target")
            if(para_ent[id] > 0) 
            {
               entity_set_string(para_ent[id],EV_SZ_classname,"parachute")
               entity_set_edict(para_ent[id], EV_ENT_aiment, id)
               entity_set_edict(para_ent[id], EV_ENT_owner, id)
               entity_set_int(para_ent[id], EV_INT_movetype, MOVETYPE_FOLLOW)
               entity_set_int(para_ent[id], EV_INT_sequence, 0)
               entity_set_int(para_ent[id], EV_INT_gaitsequence, 1)
               entity_set_float(para_ent[id], EV_FL_frame, 0.0)
               entity_set_float(para_ent[id], EV_FL_fuser1, 0.0)
            }
         }
         if(para_ent[id] > 0) 
         {
            entity_set_int(id, EV_INT_sequence, 3)
            entity_set_int(id, EV_INT_gaitsequence, 1)
            entity_set_float(id, EV_FL_frame, 1.0)
            entity_set_float(id, EV_FL_framerate, 1.0)
            fm_set_user_gravity(id, 0.1)
            velocity[2] = (velocity[2] + 40.0 < fallspeed) ? velocity[2] + 40.0 : fallspeed
            entity_set_vector(id, EV_VEC_velocity, velocity)
            if(entity_get_int(para_ent[id],EV_INT_sequence) == 0) 
            {
               frame = entity_get_float(para_ent[id],EV_FL_fuser1) + 1.0
               entity_set_float(para_ent[id],EV_FL_fuser1,frame)
               entity_set_float(para_ent[id],EV_FL_frame,frame)
               if (frame > 100.0) 
               {
                  entity_set_float(para_ent[id], EV_FL_animtime, 0.0)
                  entity_set_float(para_ent[id], EV_FL_framerate, 0.4)
                  entity_set_int(para_ent[id], EV_INT_sequence, 1)
                  entity_set_int(para_ent[id], EV_INT_gaitsequence, 1)
                  entity_set_float(para_ent[id], EV_FL_frame, 0.0)
                  entity_set_float(para_ent[id], EV_FL_fuser1, 0.0)
               }
            }
         }
      }
      else if(para_ent[id] > 0) 
      {
         remove_entity(para_ent[id])
         fm_set_user_gravity(id, 1.0)
         para_ent[id] = 0
      }
   }
   else if((oldbutton & IN_USE) && para_ent[id] > 0 ) 
   {
      remove_entity(para_ent[id])
      fm_set_user_gravity(id, 1.0)
      para_ent[id] = 0
   }
}


stock parachute_reset(id)
{
	if(para_ent[id] > 0) 
	{
		if (is_valid_ent(para_ent[id])) 
		{
			remove_entity(para_ent[id])
		}
	}
	
	if(is_user_alive(id)) fm_set_user_gravity(id, 1.0)
	para_ent[id] = 0
}


stock bacon_strip_weapon(index, weapon[]) {
	if(!equal(weapon, "weapon_", 7)) 
		return 0
	
	static weaponid 
	weaponid = get_weaponid(weapon)
	
	if(!weaponid) 
		return 0
	
	static weaponent
	weaponent = fm_find_ent_by_owner(-1, weapon, index)
	
	if(!weaponent) 
		return 0
	
	if(get_user_weapon(index) == weaponid) 
		ExecuteHamB(Ham_Weapon_RetireWeapon, weaponent)
	
	if(!ExecuteHamB(Ham_RemovePlayerItem, index, weaponent)) 
		return 0
	
	ExecuteHamB(Ham_Item_Kill, weaponent)
	set_pev(index, pev_weapons, pev(index, pev_weapons) & ~(1<<weaponid))
	
	return 1
}

stock StripHades ( id ) {
	
	new bool: grenade, bool: flashbang, bool: smoke, bool: c4;
	
	if ( user_has_weapon ( id, CSW_HEGRENADE ) )
		grenade = true;
	
	if ( user_has_weapon ( id, CSW_FLASHBANG ) )
		flashbang = true;
	
	if ( user_has_weapon ( id, CSW_SMOKEGRENADE ) )
		smoke = true;
	
	if ( user_has_weapon ( id, CSW_C4 ) )
		c4 = true;
	
	fm_strip_user_weapons ( id );
	fm_give_item ( id, "weapon_knife" );
	
	if ( grenade )
		fm_give_item ( id, "weapon_hegrenade" );
	
	if ( flashbang ) {
		
		fm_give_item ( id, "weapon_flashbang" );
		fm_give_item ( id, "weapon_flashbang" );
	}
	
	if ( smoke )
		fm_give_item ( id, "weapon_smokegrenade" );
	
	if ( c4 )
		fm_give_item ( id, "weapon_c4" );
}

stock chat_color(const id, const input[], any:...)
{
	new count = 1, players[32]
	static msg[320]
	vformat(msg, 190, input, 3)
	replace_all(msg, 190, "!g", "^4")
	replace_all(msg, 190, "!n", "^1")
	replace_all(msg, 190, "!t", "^3")
	replace_all(msg, 190, "!t2", "^0")
	
	if (id)
		players[0] = id;
	else
		get_players(players, count, "ch")
	
	
	for (new i = 0; i < count; i++)
	{
		if (is_user_connected(players[i]))
		{
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
			write_byte(players[i])
			write_string(msg)
			message_end()
		}
	}
}

stock get_name ( id ) { 
	
	new name [ 32 ]; 
	
	get_user_name( id, name, 31 ); 
	
	return name; 
}
