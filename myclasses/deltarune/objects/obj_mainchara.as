package deltarune.objects
{

import gamemaker.*;

import deltarune.*;
import deltarune.objects.*;

public class obj_mainchara extends DeltaruneObject
{
	public var darkmode = 0;
	public var boardmode = 0;
	
	public var myself = 0;
	
	public var heroinst;
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
	
	override public function Cleanup()
	{
		super.Cleanup();
		if ( instance_exists( heroinst ) )
		{
			instance_destroy( heroinst );
		}
	}
	
	override public function Step()
	{
		super.Step();
		if ( global.interact == 0 )
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



}