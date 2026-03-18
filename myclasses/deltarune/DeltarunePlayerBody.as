
// Deltarune player
// 
// 

package deltarune
{

import gamemaker.*;

import flash.display.*;
import flash.events.*;
import flash.text.*;
import flash.utils.*;

import com.threerings.util.*
import com.whirled.*

/*
	In the darkworld (darkmode == true) most things are scaled 2x
	and the avatar scale is halved to compensate
	this behaviour is mimicked here to make converting position/movement/etc
	accurately more convenient
*/

public class DeltarunePlayerBody extends DeltaruneBody
{
	public var chara;
	
	public var swordmode = false;
	public var heroname = "Hero";
	public var herocolor = 0xFFFFFF;
	
	public var namecol_lw = 0xFFFFFF;
	public var namecol_dw = 0xFFFFFF;
	public var nameout_lw = 0x000000;
	public var nameout_dw = 0x000000
	
	public var partylist = [];    // All remote members of the party
	
	public var followtarget = null;  // Who I am following
	public var followtargethistory = []; // movement history of the party member im following
	public var followtargetdelay = 20;
	
	public function DeltarunePlayerBody()
	{
		global.obj_mainchara = obj_mainchara;
		
		super();
		use_delta = false;
		
		
		global.input_pressed = new Array( 10 );
		global.input_held = new Array( 10 );
		
		// 
		
		mymemories["autorun"] = AddMemory( "deltarune.autorun", 0, SetAutorun );
		myactions["autorun_toggle"] = AddAction_ToggleMemory( "[Toggle Autorun]", "deltarune.autorun" );
		
		myactions["battlemode"] = AddAction( "[Open Battle Box]", Action_OpenBattleBox );
		myactions["battlemode"].hidden = true;
	}
	
	override public function OnStateChanged()
	{
		super.OnStateChanged();
		
		if ( !curState )
			return;
		
		
	}
	
	override public function OnUpdateLook()
	{
		super.OnUpdateLook();
		
		if ( speed == 0 )
		{
			global.input_held[INPUT_DOWN] = 0;
			global.input_held[INPUT_RIGHT] = 0;
			global.input_held[INPUT_UP] = 0;
			global.input_held[INPUT_LEFT] = 0;
		}
		else
		{
			if ( hDir > 0.25 )
			{
				global.input_held[INPUT_LEFT] = 0;
				global.input_held[INPUT_RIGHT] = 1;
			}
			else if ( hDir < -0.25 )
			{
				global.input_held[INPUT_LEFT] = 1;
				global.input_held[INPUT_RIGHT] = 0;
			}
			if ( vDir > 0.25 )
			{
				global.input_held[INPUT_DOWN] = 0;
				global.input_held[INPUT_UP] = 1;
			}
			else if ( vDir < -0.25 )
			{
				global.input_held[INPUT_DOWN] = 1;
				global.input_held[INPUT_UP] = 0;
			}
		}
		global.facing = ( Math.round( ( ( 360 + 90 ) - direction ) / 45 ) ) % 8;
	}
	
	public function PetStep()
	{
		if ( followtarget == null )
		{
			
		}
	}
	
	// 
	
	public function Action_ToggleAutorun( data = null )
	{
		SetMemory( "deltarune.autorun", ( global.flag[DeltaruneBody.FLAG_AUTORUN] == 1 ) ? 0 : 1 );
	}
	
	public function SetAutorun( data = 0 )
	{
		if ( data )
			global.flag[DeltaruneBody.FLAG_AUTORUN] = 1;
		else
			global.flag[DeltaruneBody.FLAG_AUTORUN] = 0;
		GMControl.Log( "deltarune flag[" + DeltaruneBody.FLAG_AUTORUN + "] = " + global.flag[DeltaruneBody.FLAG_AUTORUN] );
	}
	
	public function Action_OpenBattleBox( data = null )
	{
		// ctrl.DoPopup(  );
	}
	
	
}
} // Package

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
	public var facing = 0;
	public var dsprite = -1;
	public var rsprite = -1;
	public var usprite = -1;
	public var lsprite = -1;
	
	// Battle
	public var battlemode = 0;
	
	public function obj_mainchara()
	{
		super();
		
		image_speed = 0;
		
		darkmode = global.darkzone;
		
		dsprite = global.spr_krisd;
		rsprite = global.spr_krisr;
		usprite = global.spr_krisu;
		lsprite = global.spr_krisl;
		
		sprite_set( dsprite );
		
		offset_x = ( sprite_get_width( dsprite ) / 2 );
		offset_y = ( sprite_get_height( dsprite ) - 1 );
	}
	
	override public function Create()
	{
		
	}
	
	
	override public function Step()
	{
		super.Step();
		GMControl.debugTracker = "DeltarunePlayerBody.Step";
		if ( fun == 0 )
			PlayerControl();
		else
			runtimer = 0;
		if ( fun == 0 )
			AnimateWalk();
	}
	
	override public function Draw()
	{
		var x = this.x - ( offset_x * image_xscale );
		var y = this.y - ( offset_y * image_yscale );
		
		
		
		scr_draw_chaseaura( sprite_current, image_index, x, y );
		
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
		
		// 
		
		px = 0;
		py = 0;
		
		if ( press_r )
		{
			px = wspeed;
		}
		if ( press_l )
		{
			px = -wspeed;
		}
		if ( press_d )
		{
			py = wspeed;
		}
		if ( press_u )
		{
			py = -wspeed;
		}
		
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
		run = global.flag[DeltaruneBody.FLAG_AUTORUN];
		if ( runheld )
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
		if ( body && body.leader == this )
			body.SetMoveSpeed( wspeed );
	}
	
	// 
	
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
	
}

