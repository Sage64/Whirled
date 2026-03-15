
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
	public var press_l = 0;
	public var press_r = 0;
	public var press_d = 0;
	public var press_u = 0;
	public var nopress = 0;
	
	public var fun = 0;
	
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
	
	public var facing = 0;
	public var dsprite = -1;
	public var rsprite = -1;
	public var usprite = -1;
	public var lsprite = -1;
	
	public var bheight;
	
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
		super();
		
		use_delta = false;
		
		bheight = 40;
		
		wspeed = bwspeed;
		SetMoveSpeed( wspeed );
		
		// 
		
		mymemories["autorun"] = AddMemory( "deltarune.autorun", 0, SetAutorun );
		
		myactions["autorun_toggle"] = AddAction_Options( "[Toggle Autorun]", Action_ToggleAutorun, [false, true] );
		
		myactions["battlemode"] = AddAction( "[Open Battle Box]", Action_OpenBattleBox );
		myactions["battlemode"].hidden = true;
	}
	
	override public function OnStateChanged()
	{
		super.OnStateChanged();
		fun = 0;
		if ( !curState )
			return;
		if ( curState.directional == 4 )
		{
			GMControl.debugTracker = "4 sprites";
			dsprite = ( curState.sprite[0] );
			rsprite = ( curState.sprite[1] );
			usprite = ( curState.sprite[2] );
			lsprite = ( curState.sprite[3] );
		}
		else if ( curState.directional == 0 )
			dsprite = curState.sprite;
		canrun = true;
		if ( global.flag[11] == 1 )
			runheld = true;
		else
			runheld = false;
		
		if ( global.darkzone == 1 )
			darkmode = 1
		else
			darkmode = 0;
		
		if ( darkmode )
		{
			image_xscale = 2;
			image_yscale = 2;
			SetScale( bscale / 2 );
			bwspeed = 4;
			wspeed = 4;
			
			nametag.SetBaseColor( namecol_dw );
			nametag.SetBaseOutline( nameout_dw );
			nametag.SetSleepOutline( nameout_dw );
			
			if ( curState.board )
			{
				canrun = false;
				characterH = 18 * 2;
				nametag.SetBaseColor( herocolor );
			}
			else
			{
				characterH = bheight * 2;
			}
		}
		else
		{
			characterH = bheight;
			image_xscale = 1;
			image_yscale = 1;
			SetScale( bscale );
			bwspeed = 3;
			wspeed = 3;
			nametag.SetBaseColor( namecol_lw );
			nametag.SetBaseOutline( nameout_lw );
			nametag.SetSleepOutline( nameout_dw );
		}
		
		SetViewOffset( 0, - ( characterH / 2 ) );
		
		TestSpeed();
	}
	
	override public function OnUpdateLook()
	{
		super.OnUpdateLook();
		
		image_xscale = Math.abs( image_xscale );
		
		if ( speed == 0 )
		{
			press_l = 0;
			press_r = 0;
			press_d = 0;
			press_u = 0;
			nopress = true;
			runtimer = 0;
			nopress = true;
		}
		else
		{
			if ( hDir > 0.25 )
			{
				press_l = false;
				press_r = true;
			}
			else if ( hDir < -0.25 )
			{
				press_l = true;
				press_r = false;
			}
			if ( vDir > 0.25 )
			{
				press_u = false;
				press_d = true;
			}
			else if ( vDir < -0.25 )
			{
				press_u = true;
				press_d = false;
			}
		}
		
		facing = ( Math.round( ( ( 360 + 90 ) - direction ) / 45 ) ) % 8;
		
		// compensate for whirled's rediculous orientation behaviour
		// that heavily leans you towards up/down for some reason
		
		if ( !curState )
		{
		
		}
		else if ( curState.directional == 4 )
		{
			switch ( facing )
			{
				case 1:
				case 2:
				case 3:
					facing = 1;
					sprite_set( rsprite );
					break;
				case 4:
					facing = 2;
					sprite_set( usprite );
					break;
				case 5:
				case 6:
				case 7:
					facing = 3
					sprite_set( lsprite );
					break;
				case 0:
				default:
					facing = 0;
					sprite_set( dsprite );
					break;
			}
		}
		else if ( curState.directional == 0 )
		{
			sprite_set( dsprite );
		}
		
		TestSpeed();
	}
	
	override public function Step()
	{
		super.Step();
		
		GMControl.debugTracker = "DeltarunePlayerBody.Step";
		
		// if ( !( press_u || press_d || press_l || press_r ) )
		// 	nopress = true; 
		
		// 
		
		if ( followtarget != null )
		{
			FollowTarget();
		}
		
		if ( isMoving && ( fun == 0 ) )
		{
			PlayerControl();
		}
		else
			runtimer = 0;
		
		if ( fun == 0 )
		{
			AnimateWalk();
		}
	}
	
	override public function Draw()
	{
		draw_self();
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
		if ( runheld )
			run = 1;
		else
			run = 0;
			
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
		// 
		SetMoveSpeed( wspeed );
	}
	
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
	
	public function PetControl()
	{
		if ( followtarget == null )
		{
			
		}
	}
	
	public function FollowTarget()
	{
		
	}
	
	public function Action_ToggleAutorun( data = null )
	{
		SetMemory( "deltarune.autorun", ( global.flag[11] == 1 ) ? 0 : 1 );
	}
	
	public function SetAutorun( data = 0 )
	{
		if ( data )
			global.flag[11] = 1;
		else
			global.flag[11] = 0;
		GMControl.Log( "deltarune flag[11] = " + global.flag[11] );
		if ( global.flag[11] == 1 )
			runheld = true;
		else
			runheld = false;
	}
	
	public function Action_OpenBattleBox( data = null )
	{
		ctrl.DoPopup(  );
	}
	
	
}
} // Package

import gamemaker.*;

import flash.display.*;
import flash.events.*;
import flash.text.*;
import flash.utils.*;

import com.threerings.util.*
import com.whirled.*
