
package deltarune
{

import gamemaker.*;

import flash.display.*;
import flash.events.*;
import flash.utils.*;

import com.threerings.util.*
import com.whirled.*

// Now handles multiple characters
// 

public class MainPartyBody extends DeltarunePlayerBody
{
	public var inst;
	
	public var kris;
	public var susie;
	public var ralsei;
	public var noelle;
	
	public var leader;
	
	public var unhappy = 0;
	public var ralsei_butler = 0;
	public var boardmode = 0;
	public var churchoutfit = 0;
	
	public function MainPartyBody()
	{
		super();
		
		char = "kris";
		
		if ( true )
		{
			mystates["default"] = LWState( "Default" );
			mystates["board"] = DWState( "Board" );
			mystates["church"] = LWState( "Church" );
			
			myactions["char_krs"] = AddAction( "[Switch to Kris]", Action_SetCharacter, "kris" );
			myactions["char_sus"] = AddAction( "[Switch to Susie]", Action_SetCharacter, "susie" );
			myactions["char_ral"] = AddAction( "[Switch to Ralsei]", Action_SetCharacter, "ralsei" );
			//myactions["char_nol"] = AddAction( "[Switch to Noelle]", SetCharacter, "noelle" );
			
		}
		else
		{
			//mystates["kris"] = LWState( "Kris" );
			//mystates["susie"] = LWState( "Susie" );
			//mystates["ralsei"] = DWState( "Ralsei" );
		}
		
		myactions["toggle_unhappy"] = AddAction_ToggleMemory( "[Unhappy]", "deltarune.unhappy" );
		myactions["toggle_unhappy"].hidden = true;
		
		// ch1
		
		// ch2
		
		mymemories["ralsei_butler"] = AddMemory( "deltarune.ralsei.butler", 0, OnStateChanged );
		myactions["toggle_ralsei_butler"] = AddAction_ToggleMemory( "[Ralsei Butler]", "deltarune.ralsei.butler" );
		
		// ch3
		
		// myactions["toggle_board"] = AddAction_ToggleMemory( "[Board]", "deltarune.board" );
		
		// ch4
		
		mymemories["churchoutfit"] = AddMemory( "deltarune.churchoutfit", 0, OnStateChanged );
		// myactions["toggle_churchoutfit"] = AddAction_ToggleMemory( "[Church]", "deltarune.churchoutfit" );
		
		mystates["kris_sit"] = LWState( "Kris - spr_kris_sit", global.spr_kris_sit );
		mystates["kris_sit"].char = "kris";
		mystates["kris_sit_wind"] = LWState( "Kris - spr_kris_sit_wind", global.spr_kris_sit_wind );
		mystates["kris_sit_wind"].char = "kris";
		
		// 
	}
	
	override public function Step()
	{
		super.Step();
	}
	
	override public function OnStateChanged()
	{
		unhappy = mymemories["unhappy"].value;
		ralsei_butler = mymemories["ralsei_butler"].value;
		boardmode = ( curState == mystates["board"] ); //mymemories["board"].value;
		churchoutfit = ( curState == mystates["church"] );// mymemories["churchoutfit"].value;
		
		super.OnStateChanged();
		
		x = originX;
		y = originY;
		
		GetLeader();
		
		leader.fun = 0;
		
		switch ( curState )
		{
			case null:
				break;
			case mystates["kris"]:
				break;
			case mystates["kris_sit"]:
			case mystates["kris_sit_wind"]:
				if ( !instance_exists( kris ) )
					break;
				kris.fun = 1;
				kris.sprite_index = curState.sprite;
				kris.image_speed = 0.1;
				break;
			case mystates["susie"]:
				break;
			case mystates["ralsei"]:
				break;
			}
		
		UpdateSprites();
		
		if ( instance_exists( leader ) )
		{
			x = leader.x;
			y = leader.y;
			SetMoveSpeed( leader.bwspeed );
		}
	}
	
	override public function GetLeader()
	{
		textsound = global.snd_text;
		
		instance_destroy( kris );
		instance_destroy( susie );
		instance_destroy( ralsei );
		instance_destroy( noelle );
		
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
				leader = kris;
				break;
		}
		
		return leader;
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
	
	public function UpdateSprites( ... ignored )
	{
		x = 0;
		y = 0;
		characterH = 24;
		image_xscale = ( global.darkzone ) ? 2 : 1;
		image_yscale = image_xscale;
		
		
		
		if ( instance_exists( noelle ) )
		{
			Apply_Ralsei( noelle );
		}
		
		if ( instance_exists( ralsei ) )
		{
			Apply_Ralsei( ralsei );
		}
		
		if ( instance_exists( susie ) )
		{
			Apply_Susie( susie );
		}
		
		if ( instance_exists( kris ) )
		{
			Apply_Kris( kris );
		}
		
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


class obj_mainchara extends DeltaruneObject
{
	public var darkmode = 0;
	public var boardmode = 0;
	
	public var herocolor;
	
	// Input
	public var press_l = 0;
	public var press_r = 0;
	public var press_d = 0;
	public var press_u = 0;
	public var nopress = 0;
	public var pressdir = -1;
	public var fun = 0;
	
	// Movement
	public var px = 0;
	public var py = 0;
	public var walk = 0;
	public var walkbuffer = 0;
	public var walktimer = 0;
	public var bwspeed = 3;
	public var wspeed = 3;
	public var runheld = false;
	public var run = 0;
	public var autorun = 0;
	public var runtimer = 0;
	public var runmove = 0;
	public var canrun = true;
	public var runcounter = 0;
	
	// Appearance
	public var offset_x = 0;
	public var offset_y = 0;
	public var feet_y = 0;
	
	public var mywidth;
	public var myheight;
	public var facing = 0;
	public var dsprite = -1;
	public var rsprite = -1;
	public var usprite = -1;
	public var lsprite = -1;
	public var climbing = 0;
	public var climbsprite = -1;
	
	// Battle
	public var battlemode = 0;
	
	// Board
	public var swordmode = 0;
	public var swordfacing = 1;
	
	public function obj_mainchara()
	{
		super();
		
		image_speed = 0;
		
		darkmode = global.darkzone ? 1 : 0;
		
		dsprite = global.spr_krisd;
		rsprite = global.spr_krisr;
		usprite = global.spr_krisu;
		lsprite = global.spr_krisl;
		
		if ( darkmode )
		{
			image_xscale = 2;
			image_yscale = 2;
			dsprite = global.spr_krisd_dark;
			rsprite = global.spr_krisr_dark;
			usprite = global.spr_krisu_dark;
			lsprite = global.spr_krisl_dark;
		}
		
		sprite_set( dsprite );
	}
	
	override public function Step()
	{
		super.Step();
		if ( fun == 0 )
			PlayerControl();
		else
			runtimer = 0;
		if ( fun == 0 )
			AnimateWalk();
		GetFacingSprite();
		
		if ( false && GMControl.debug )
		{
			image_angle = point_direction( x, y, mouse_x, mouse_y );
		}
	}
	
	override public function Draw()
	{
		if ( body )
		{
			body.x = this.x;
			body.y = this.y;
		}
		
		var _xscale = image_xscale;
		var _yscale = image_yscale;
		var _offx = offset_x;
		var _offy = offset_y - feet_y;
		if ( fun == 1 )
		{
			if ( swordfacing < 0 )
				_xscale *= -1;
			switch ( sprite_index )
			{
				case global.spr_kris_sit:
					_offx -= 3;
					_offy -= 7;
					break;
			}
		}
		
		// _xscale = mouse_x / 24;
		
		//if ( _xscale < 0 )
		//	_offx += sprite_get_width( sprite_index );
		
		var x = this.x - ( _offx * _xscale );
		var y = this.y - ( ( _offy ) * _yscale );
		
		draw_sprite_ext( sprite_current, image_index, x, y, _xscale, _yscale, image_angle, image_blend, image_alpha );
		
		if ( battlemode == 1 )
		{
			
		}
	}
	
	// Simulate how the player animates
	// based on current movement
	public function PlayerControl()
	{
		//
		TestSpeed();
		// 
		if ( run )
			runtimer += timescale;
		else
			runtimer = 0;
		px = 0;
		py = 0;
		pressdir = -1;
		if ( press_r )
			px = wspeed;
		if ( press_l )
			px = -wspeed;
		if ( press_d )
			py = wspeed;
		if ( press_u )
			py = -wspeed;
		// 
		nopress = 0;
		//
		runmove = 0;
		if ( ( run  == 1) && ( px != 0 || py != 0 ) )
		{
			runmove = 1;
			runtimer += timescale;
			runcounter += timescale;
		}
		else
			runtimer = 0;
	}
	
	// Adjust move speed based on various factors
	public function TestSpeed()
	{
		if ( boardmode )
		{
			wspeed = 4;
			run = 0;
		}
		else
		{
			run = global.flag[DeltarunePlayerBody.FLAG_AUTORUN];
			if ( false )
				run = !run;
			if ( autorun > 0 )
			{
				run = 1;
				if ( autorun == 1 )
				{
					runtimer = 200;
				}
				else if ( autorun == 2 )
				{
					runtimer = 50;
				}
			}
			if ( !canrun )
				run = 0;
			if ( run == 1 )
			{
				if ( darkmode )
				{
					bwspeed = 4;
					if ( runtimer > 60 )
						wspeed = bwspeed + 5;
					else if ( runtimer > 10 )
						wspeed = bwspeed + 4;
					else
						wspeed = bwspeed + 2;
				}
				else
				{
					bwspeed = 3;
					if ( runtimer > 60 )
						wspeed = bwspeed + 3;
					else if ( runtimer > 10 )
						wspeed = bwspeed + 2;
					else
						wspeed = bwspeed + 1;
				}
			}
			else
				wspeed = bwspeed;
		}
		if ( body )
			body.SetMoveSpeed( wspeed );
	}
	
	// Animate walking frames
	public function AnimateWalk()
	{
		walk = 0;
		if ( nopress == 0 )
		{
			if ( px != 0 || py != 0 )
				walk = 1;
		}
		if ( walk == 1 )
			walkbuffer = 6;
		if ( walkbuffer > 3 )
		{
			walktimer += ( runmove ? 3 : 1.5 ) * timescale;
			walktimer = walktimer % 40;
			image_index = Math.floor( walktimer / 10 );
		}
		if ( walkbuffer <= 0 )
		{
			if ( walktimer < 10 )
				walktimer = 9.5;
			if ( walktimer >= 10 && walktimer < 20 )
				walktimer = 19.5;
			if ( walktimer >= 20 && walktimer < 30 )
				walktimer = 29.5;
			if ( walktimer >= 30 )
				walktimer = 39.5
			image_index = 0;
		}
		walkbuffer -= 0.75 * timescale;
	}
	
	// Get facing sprite
	public function GetFacingSprite()
	{
		if ( fun != 0 )
			return;
		if ( climbing )
		{
			sprite_set( climbsprite );
		}
		else
		{
			switch ( facing )
			{
				case 0:
					sprite_set( dsprite );
					break;
				case 1:
					sprite_set( rsprite );
					break;
				case 2:
					sprite_set( usprite );
					break;
				case 3:
					sprite_set( lsprite );
					break;
			}
		}
	}
}

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