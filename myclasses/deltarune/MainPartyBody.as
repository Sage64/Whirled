
package deltarune
{

import gamemaker.*;

import deltarune.*;
import deltarune.objects.*;

import flash.display.*;
import flash.events.*;
import flash.utils.*;

import com.threerings.util.*
import com.whirled.*

// Now handles multiple characters
// 

public class MainPartyBody extends DeltarunePlayerBody
{
	public var kris;
	public var herokris;
	public var susie;
	public var herosusie;
	public var ralsei;
	public var heroralsei;
	public var noelle;
	public var heronoelle;
	
	public var unhappy = 0;
	public var ralsei_butler = 0;
	public var churchoutfit = 0;
	
	public function MainPartyBody()
	{
		super();
		
		char = "kris";
		
		// 
		mystates["default"] = LWState( "Default" );
		mystates["church"] = LWState( "Church" );
		mystates["darkzone"] = DWState( "Dark" );
		//
		mystates["battle"] = BattleState( "Battle - Idle" );
		mystates["battle_attack"] = BattleState( "Battle - Attack Ready" );
		mystates["battle_act"] = BattleState( "Battle - Act Ready" );
		mystates["battle_item"] = BattleState( "Battle - Item Ready" );
		mystates["battle_defend"] = BattleState( "Battle - Defend" );
		// 
		mystates["board"] = DWState( "Board" );
			
		myactions["toggle_unhappy"] = AddAction_ToggleMemory( "[Unhappy]", "deltarune.unhappy" );
		myactions["toggle_unhappy"].hidden = true;
		
		
		mystates["kris_sit"] = CharState( "kris", "Kris - spr_kris_sit", false, global.spr_kris_sit, 0 );
		mystates["kris_sit_wind"] = CharState( "kris", "Kris - spr_kris_sit_wind", false, global.spr_kris_sit_wind, 0.1 );
		
		// mymemories["ralsei_butler"] = AddMemory( "deltarune.ralsei.butler", 0, OnStateChanged );
		// myactions["toggle_ralsei_butler"] = AddAction_ToggleMemory( "Ralsei - [Toggle Butler]", "deltarune.ralsei.butler" );
		
		mystates["ralsei_butler"] = CharState( "ralsei", "Ralsei - butler", true );
		
		
		// 
	}
	
	override public function InitActions_Characters()
	{
		super.InitActions_Characters();
		myactions["char_krs"] = AddAction( "[Switch to Kris]", Action_SetCharacter, "kris" );
		myactions["char_sus"] = AddAction( "[Switch to Susie]", Action_SetCharacter, "susie" );
		myactions["char_ral"] = AddAction( "[Switch to Ralsei]", Action_SetCharacter, "ralsei" );
		//myactions["char_nol"] = AddAction( "[Switch to Noelle]", Action_SetCharacter, "noelle" );
	}
	
	public function CharState( charname, statename, darkzone = 0, sprite = null, image_speed = 0 )
	{
		var State = ( ( darkzone ) ? DWState : LWState )( statename );
		State.char = charname;
		State.sprite = sprite;
		State.image_speed = image_speed;
		return State; 
	}
	
	override public function Step()
	{
		super.Step();
	}
	
	override public function OnStateChanged()
	{
		unhappy = mymemories["unhappy"].value;
		ralsei_butler = ( curState == mystates["ralsei_butler"] ); //mymemories["ralsei_butler"].value;
		boardmode = ( curState == mystates["board"] ); //mymemories["board"].value;
		churchoutfit = ( curState == mystates["church"] );// mymemories["churchoutfit"].value;
		
		super.OnStateChanged();
		
		if ( !curState )
		{}
		else if ( curState.battle )
		{
			
		}
		else
		{
			leader.fun = 0;
			if ( curState.sprite != null )
			{
				var target = leader;
				switch ( curState.char )
				{
					case "kris":
						target = kris;
						break;
					case "susie":
						target = susie;
						break;
					case "ralsei":
						target = ralsei;
						break;
					case "noelle":
						target = noelle;
						break;
				}
				if ( instance_exists( target ) )
				{
					target.fun = 1;
					target.sprite_index = curState.sprite;
					target.image_speed = curState.image_speed;
				}
			}
			UpdateSprites();
			if ( instance_exists( leader ) )
			{
				x = leader.x;
				y = leader.y;
				SetMoveSpeed( leader.bwspeed );
			}
		}
	}
	
	override public function GetLeader()
	{
		darkmode = 0;
		textsound = global.snd_text;
		
		// instance_destroy( kris );
		// instance_destroy( susie );
		// instance_destroy( ralsei );
		// instance_destroy( noelle );
		for ( var i = 0; i < 4; ++i )
			global.char[i] = 0;
		
		char = GetMemory( "deltarune.character" );
		
		switch( char )
		{
			case "noelle":
			case "nol":
				if ( !instance_exists( noelle ) )
				{
					noelle = instance_create( x, y, obj_mainchara );
					noelle.herocolor = 0x13D26F;
				}
				global.char[0] = 4;
				leader = noelle;
				textsound = global.snd_txtnol;
				break;
			case "ralsei":
			case "ral":
				if ( !instance_exists( ralsei ) )
				{
					ralsei = instance_create( x, y, obj_mainchara );
					ralsei.herocolor = 0x13D26F;
				}
				darkmode = 1;
				global.char[0] = 3;
				leader = ralsei;
				textsound = global.snd_txtral;
				break;
			case "susie":
			case "sus":
				if ( !instance_exists( susie ) )
				{
					susie = instance_create( x, y, obj_mainchara );
					susie.herocolor = 0xF22D81;
				}
				global.char[0] = 2;
				leader = susie;
				textsound = global.snd_txtsus;
				break;
			case "kris":
			case "krs":
			default:
				if ( !instance_exists( kris ) )
				{
					kris = instance_create( x, y, obj_mainchara );
					kris.herocolor = 0x8DEDFE;
				}
				global.char[0] = 1;
				leader = kris;
				break;
		}
		if ( instance_exists( leader ) )
			return leader;
		return super.GetLeader();
	}
	
	override public function OnUpdateLook()
	{
		var _offx = 0;
		var _offy = 0;
		
		super.OnUpdateLook();
		if ( instance_exists( leader ) )
		{
			leader.facing = global.facing;
			leader.swordfacing = swordfacing;
			leader.press_d = global.input_held[0];
			leader.press_r = global.input_held[1];
			leader.press_u = global.input_held[2];
			leader.press_l = global.input_held[3];
			
			// _offy -= sprite_get_height( leader.dsprite ) * leader.image_yscale / 2;
		}
		
		_offy -= 24 * image_yscale;
		SetViewOffset( _offx, _offy );
	}
	
	override public function OnRegisterState( state )
	{
		if ( super.OnRegisterState( state ) )
			return true;
		switch( state.char )
		{
			case null:
				break;
			case "kris":
				if ( !instance_exists( kris ) )
					return true;
				break;
			case "susie":
				if ( !instance_exists( susie ) )
					return true;
				break;
			case "ralsei":
				if ( !instance_exists( ralsei ) )
					return true;
				break;
		}
	}
	
	override public function UpdateSprites( ... ignored )
	{
		x = 0;
		y = 0;
		characterH = 24;
		image_xscale = ( global.darkzone ) ? 2 : 1;
		image_yscale = image_xscale;
		
		if ( instance_exists( noelle ) )
			Apply_Ralsei( noelle );
		if ( instance_exists( ralsei ) )
			Apply_Ralsei( ralsei );
		if ( instance_exists( susie ) )
			Apply_Susie( susie );
		if ( instance_exists( kris ) )
			Apply_Kris( kris );
		OnUpdateLook();
		
		if ( nametag )
		{
			nametag.SetBaseColor( 0xFFFFFF ); 
			nametag.SetBaseOutline( 0x000000 );
		}
		
		if ( instance_exists( leader ) )
		{
			x = leader.x;
			y = leader.y;
			characterH = 0;
			
			if ( true )
			{
				if ( leader.fun == 1 )
					characterH = ( ( sprite_get_height( leader.sprite_index ) + sprite_get_yoffset( leader.sprite_index ) ) * leader.image_yscale );
				else
					characterH = ( sprite_get_height( leader.dsprite ) - sprite_get_yoffset( leader.dsprite ) ) * leader.image_yscale;
				if ( boardmode )
					nametag.SetBaseColor( leader.herocolor );
			}
			else if ( leader == kris )
			{
				if ( leader.fun == 1 )
					characterH = ( ( sprite_get_height( leader.sprite_index ) + sprite_get_yoffset( leader.sprite_index ) ) * leader.image_yscale );
				else
					characterH = ( sprite_get_height( global.spr_krisd ) ) * leader.image_yscale;
			}
			else if ( leader == susie )
				characterH = ( sprite_get_height( global.spr_susied ) ) * leader.image_yscale;
			else if ( leader == ralsei )
				characterH = ( sprite_get_height( global.spr_ralseid ) ) * leader.image_yscale;
			else
				characterH = ( sprite_get_height( leader.dsprite ) ) * leader.image_yscale;
		}
	}
	
	public function ResetParty()
	{
		
	}
	
	public function Apply_Chara( inst )
	{
		inst.image_xscale = image_xscale;
		inst.image_yscale = image_yscale;
		
		inst.darkmode = ( global.darkzone );
		inst.boardmode = ( global.darkzone && boardmode );
	}
	
	public function Apply_Kris( inst )
	{
		Apply_Chara( inst );
		
		if ( global.darkzone )
		{
			if ( inst.boardmode )
			{
				inst.dsprite = global.spr_board_kris_walk_down;
				inst.rsprite = global.spr_board_kris_walk_right;
				inst.usprite = global.spr_board_kris_walk_up;
				inst.lsprite = global.spr_board_kris_walk_left;
			}
			else
			{
				inst.dsprite = global.spr_krisd_dark;
				inst.rsprite = global.spr_krisr_dark;
				inst.usprite = global.spr_krisu_dark;
				inst.lsprite = global.spr_krisl_dark;
			}
		}
		else
		{
			if ( churchoutfit )
			{
				inst.dsprite = global.spr_kris_walk_down_church;
				inst.rsprite = global.spr_kris_walk_right_church;
				inst.usprite = global.spr_krisu;
				inst.lsprite = global.spr_kris_walk_left_church;
			}
			else
			{
				inst.dsprite = global.spr_krisd;
				inst.rsprite = global.spr_krisr;
				inst.usprite = global.spr_krisu;
				inst.lsprite = global.spr_krisl;
			}
		}
		inst.GetFacingSprite();
		if ( boardmode )
		{
			inst.offset_x = sprite_get_width( inst.dsprite ) / 2;
			inst.offset_y = ( sprite_get_height( inst.dsprite ) - sprite_get_yoffset( inst.dsprite ) );
		}
		else if ( inst.fun == 1 )
		{
			inst.offset_x = ( sprite_get_width( inst.sprite_index ) / 2 );
			inst.offset_y = ( sprite_get_height( inst.sprite_index ) - sprite_get_yoffset( inst.sprite_index ) );
		}
		else
		{
			inst.offset_x = ( sprite_get_width( global.spr_krisd ) / 2 );
			inst.offset_y = ( sprite_get_height( inst.dsprite ) - sprite_get_yoffset( inst.dsprite ) );
		}
		
		inst.feet_y = 1;
	}
	
	public function Apply_Susie( inst )
	{
		Apply_Chara( inst );
		
		if ( global.darkzone )
		{
			if ( inst.boardmode )
			{
				inst.dsprite = global.spr_board_susie_walk_down;
				inst.rsprite = global.spr_board_susie_walk_right;
				inst.usprite = global.spr_board_susie_walk_up;
				inst.lsprite = global.spr_board_susie_walk_left;
			}
			else
			{
				inst.dsprite = ( global.chapter > 1 ) ? global.spr_susie_walk_down_dw : global.spr_susied_dark;
				inst.rsprite = ( global.chapter > 1 ) ? global.spr_susie_walk_right_dw : global.spr_susier_dark;
				inst.usprite = ( global.chapter > 1 ) ? global.spr_susie_walk_up_dw : global.spr_susieu_dark;
				inst.lsprite = ( global.chapter > 1 ) ? global.spr_susie_walk_left_dw : global.spr_susiel_dark;
			}
		}
		else
		{
			if ( churchoutfit )
			{
				inst.dsprite = ( unhappy ) ? global.spr_susie_walk_down_church_neutral : global.spr_susie_walk_down_church;
				inst.rsprite = ( unhappy ) ? global.spr_susie_walk_right_church_neutral : global.spr_susie_walk_right_church;
				inst.usprite = global.spr_susie_walk_up_church;
				inst.lsprite = ( unhappy ) ? global.spr_susie_walk_left_church_neutral : global.spr_susie_walk_left_church;
			}
			else
			{
				inst.dsprite = ( global.chapter > 1 ) ? global.spr_susie_walk_down_lw : global.spr_susied;
				inst.rsprite = ( global.chapter > 1 ) ? global.spr_susie_walk_right_lw : global.spr_susier;
				inst.usprite = ( global.chapter > 1 ) ? global.spr_susie_walk_up_lw : global.spr_susieu;
				inst.lsprite = ( global.chapter > 1 ) ? global.spr_susie_walk_left_lw : global.spr_susiel;
			}
		}
		
		inst.GetFacingSprite();
		if ( boardmode )
			inst.offset_x = sprite_get_width( inst.dsprite ) / 2;
		else
			inst.offset_x = ( sprite_get_width( global.spr_susied ) / 2 );
		inst.offset_y = ( sprite_get_height( inst.dsprite ) - sprite_get_yoffset( inst.dsprite ) );
		inst.feet_y = ( !inst.boardmode && global.chapter > 1 && global.darkzone ) ? 0 : 1;
		
	}
	
	public function Apply_Ralsei( inst )
	{
		Apply_Chara( inst );
		
		if ( inst.boardmode )
		{
			inst.dsprite = global.spr_board_ralsei_walk_down;
			inst.rsprite = global.spr_board_ralsei_walk_right;
			inst.usprite = global.spr_board_ralsei_walk_up;
			inst.lsprite = global.spr_board_ralsei_walk_left;
		}
		else if ( ralsei_butler )
		{
			inst.dsprite = global.spr_cutscene_20_ralsei_walk_down_butler;
			inst.rsprite = global.spr_cutscene_20_ralsei_walk_right_butler;
			inst.usprite = global.spr_cutscene_20_ralsei_walk_up_butler;
			inst.lsprite = global.spr_cutscene_20_ralsei_walk_left_butler;
		}
		else
		{
			inst.dsprite = ( global.chapter > 1 ) ? global.spr_ralsei_walk_down : global.spr_ralseid;
			inst.rsprite = ( global.chapter > 1 ) ? global.spr_ralsei_walk_right : global.spr_ralseir;
			inst.usprite = ( global.chapter > 1 ) ? global.spr_ralsei_walk_up : global.spr_ralseiu;
			inst.lsprite = ( global.chapter > 1 ) ? global.spr_ralsei_walk_left : global.spr_ralseil;
		}
		inst.GetFacingSprite();
		
		if ( inst.boardmode )
			inst.offset_x = sprite_get_width( inst.dsprite ) / 2;
		else
			inst.offset_x = ( sprite_get_width( inst.dsprite ) / 2 );
		inst.offset_y = ( sprite_get_height( inst.dsprite ) - sprite_get_yoffset( inst.dsprite ) );
		inst.feet_y = ( global.chapter > 1 ) ? 2 : 1;
	}
	
	public function Apply_Noelle( inst )
	{
		
	}
	
}

}

import gamemaker.*;
import deltarune.*;
import deltarune.objects.*;

import flash.display.*;
import flash.events.*;
import flash.text.*;
import flash.utils.*;

import com.threerings.util.*
import com.whirled.*

import gamemaker.*;
import deltarune.*;
import deltarune.objects.*;

class obj_caterpillarchara extends DeltaruneObject
{
	public var dsprite = global.spr_susied;
	public var rsprite = global.spr_susier;
	public var usprite = global.spr_susieu;
	public var lsprite = global.spr_susiel;
	
	public var followtarget = null;
	
	public var followdelay = 12;
	public var followhistory = [];
	
	public function obj_caterpillarchara()
	{
		super();
		image_speed = 0;
	}
	
	override public function Create()
	{
		
	}
	
	override public function Step()
	{
		
	}
	
	
	
	 
}