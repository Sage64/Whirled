
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
	public var churchoutfit = 0;
	
	
	public function MainPartyBody()
	{
		super();
		
		mystates["kris"] = LWState( "Kris" );
		mystates["susie"] = LWState( "Susie" );
		mystates["ralsei"] = DWState( "Ralsei" );
		
		myactions["chapter_switch"] = AddAction_ToggleMemory( "[Chapter]", "deltarune.chapter", [ 1, 4 ]  );
		myactions["toggle_darkzone"] = AddAction_ToggleMemory( "[Dark World]", "deltarune.forcedarkzone", [ false, true ] );
		
		
		mymemories["ralsei_butler"] = AddMemory( "deltarune.ralsei.butler", 0, UpdateSprites );
		myactions["toggle_ralsei_butler"] = AddAction_ToggleMemory( "[Ralsei Butler]", "deltarune.ralsei.butler" );
		
		mymemories["churchoutfit"] = AddMemory( "deltarune.churchoutfit", 0, UpdateSprites );
		myactions["toggle_churchoutfit"] = AddAction_ToggleMemory( "[Church]", "deltarune.churchoutfit" );
		
	}
	
	override public function OnStateChanged()
	{
		super.OnStateChanged();
		x = originX;
		y = originY;
		
		switch ( curState )
		{
			case mystates["kris"]:
				instance_destroy( susie );
				instance_destroy( ralsei );
				instance_destroy( noelle );
				if ( !instance_exists( kris ) )
				{
					kris = instance_create( x, y, obj_mainchara );
					leader = kris;
				}
				break;
			case mystates["susie"]:
				instance_destroy( kris );
				instance_destroy( ralsei );
				instance_destroy( noelle );
				if ( !instance_exists( susie ) )
				{
					susie = instance_create( x, y, obj_mainchara );
					leader = susie;
				}
				break;
			case mystates["ralsei"]:
				instance_destroy( kris );
				instance_destroy( susie );
				instance_destroy( noelle );
				if ( !instance_exists( ralsei ) )
				{
					ralsei = instance_create( x, y, obj_mainchara );
					leader = ralsei;
				}
				break;
		}
		
		UpdateSprites();
		
		if ( instance_exists( leader ) )
		{
			x = leader.x;
			y = leader.y;
			
			textsound = global.snd_text;
			if ( leader == null )
			{}
			else if ( leader == susie )
				textsound = global.snd_txtsus;
			else if ( leader == ralsei )
				textsound = global.snd_txtral;
		}
	}
	
	override public function OnUpdateLook()
	{
		var _offx = 0;
		var _offy = 0;
		
		super.OnUpdateLook();
		if ( instance_exists( leader ) )
		{
			leader.facing = global.facing;
			leader.press_d = global.input_held[0];
			leader.press_r = global.input_held[1];
			leader.press_u = global.input_held[2];
			leader.press_l = global.input_held[3];
			
			// _offy -= sprite_get_height( leader.dsprite ) * leader.image_yscale / 2;
		}
		
		_offy -= 48 * image_yscale;
		SetViewOffset( _offx, _offy );
	}
	
	override public function UpdateSprites( ... ignored )
	{
		unhappy = 0;
		ralsei_butler = mymemories["ralsei_butler"].value;
		churchoutfit = mymemories["churchoutfit"].value;
		
		x = 0;
		y = 0;
		characterH = 24;
		image_xscale = ( global.darkzone ) ? 2 : 1;
		image_yscale = image_xscale;
		
		super.UpdateSprites();
		if ( instance_exists( kris ) )
		{
			Apply_Kris( kris );
		}
		if ( instance_exists( susie ) )
		{
			Apply_Susie( susie );
		}
		if ( instance_exists( ralsei ) )
		{
			Apply_Ralsei( ralsei );
		}
		if ( instance_exists( noelle ) )
		{
			Apply_Ralsei( noelle );
		}
		
		OnUpdateLook();
		
		if ( instance_exists( leader ) )
		{
			x = leader.x;
			y = leader.y;
			characterH = 0;
			if ( leader == kris )
				characterH = ( sprite_get_height( global.spr_krisd ) ) * leader.image_yscale;
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
	
	public function Apply_Kris( inst )
	{
		inst.image_xscale = image_xscale;
		inst.image_yscale = image_yscale;
		if ( global.darkzone )
		{
			inst.dsprite = global.spr_krisd_dark;
			inst.rsprite = global.spr_krisr_dark;
			inst.usprite = global.spr_krisu_dark;
			inst.lsprite = global.spr_krisl_dark;
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
		inst.offset_x = ( sprite_get_width( global.spr_krisd ) / 2 );
		inst.offset_y = ( sprite_get_height( inst.dsprite ) - sprite_get_yoffset( inst.dsprite ) );
		inst.feet_y = 1;
	}
	
	public function Apply_Susie( inst )
	{
		inst.image_xscale = image_xscale;
		inst.image_yscale = image_yscale;
		
		if ( global.darkzone )
		{
			inst.dsprite = ( global.chapter > 1 ) ? global.spr_susie_walk_down_dw : global.spr_susied_dark;
			inst.rsprite = ( global.chapter > 1 ) ? global.spr_susie_walk_right_dw : global.spr_susier_dark;
			inst.usprite = ( global.chapter > 1 ) ? global.spr_susie_walk_up_dw : global.spr_susieu_dark;
			inst.lsprite = ( global.chapter > 1 ) ? global.spr_susie_walk_left_dw : global.spr_susiel_dark;
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
		inst.offset_x = ( sprite_get_width( global.spr_susied ) / 2 );
		inst.offset_y = ( sprite_get_height( inst.dsprite ) - sprite_get_yoffset( inst.dsprite ) );
		inst.feet_y = ( global.chapter > 1 && global.darkzone ) ? 0 : 1;
	}
	
	public function Apply_Ralsei( inst )
	{
		inst.image_xscale = image_xscale;
		inst.image_yscale = image_yscale;
		if ( ralsei_butler )
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
		
		if ( GMControl.debug )
		{
			image_angle = point_direction( x, y, mouse_x, mouse_y );
		}
	}
	
	override public function Draw()
	{
		var x = this.x - ( offset_x * image_xscale );
		var y = this.y - ( ( offset_y - feet_y ) * image_yscale );
		
		draw_sprite_ext( sprite_current, image_index, x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha );
		
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
				if ( runtimer > 60 )
					wspeed = bwspeed + 5;
				else if ( runtimer > 10 )
					wspeed = bwspeed + 4;
				else
					wspeed = bwspeed + 2;
			}
			else
			{
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