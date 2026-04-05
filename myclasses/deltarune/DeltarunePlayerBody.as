
// Deltarune player
// 
// 

package deltarune
{

import gamemaker.*;

import flash.display.*;
import flash.events.*;
import flash.text.*;
import flash.ui.*;
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
	public static const INPUT_DOWN = 0;
	public static const INPUT_RIGHT = 1;
	public static const INPUT_UP = 2;
	public static const INPUT_LEFT = 3;
	
	public static const FLAG_AUTORUN = 11;
	
	public var menu_object;
	
	public var char;
	
	public var swordmode = false;
	public var swordfacing = 0;
	
	public var heroname = "Hero";
	public var herocolor = 0xFFFFFF;
	
	public var partylist = [];    // All remote members of the party
	
	public var followtarget = null;  // Who I am following
	public var followtargethistory = []; // movement history of the party member im following
	public var followtargetdelay = 20;
	
	public var keyboardInputPanel;
	public var keyboardMoveX;
	public var keyboardMoveY;
	public var keyboardMovedX;
	public var keyboardMovedY;
	public var keyboardMoveTime = 0;
	
	public function DeltarunePlayerBody()
	{
		super();
		use_delta = false;
		
		global.input_pressed = new Array( 10 );
		global.input_held = new Array( 10 );
		
		mymemories["character"] = AddMemory( "deltarune.character", 0, SetCharacter );
		
		myactions["keyboardmode"] = AddAction( "[Open Keyboard Input]", Action_OpenKeyboardControl );
		
		InitMenu();
		
		myactions["chapter_switch"] = AddAction_ToggleMemory( "[Chapter]", "deltarune.chapter", [ 1, 4 ]  );
		myactions["chapter_switch"].hidden = false;
		myactions["toggle_darkzone"] = AddAction_ToggleMemory( "[Dark World]", "deltarune.forcedarkzone", [ false, true ] );
		myactions["toggle_darkzone"].hidden = false;
		
		mymemories["autorun"] = AddMemory( "deltarune.autorun", 0, SetAutorun );
		myactions["autorun_toggle"] = AddAction_ToggleMemory( "[Autorun]", "deltarune.autorun" );
		
		if ( false )
		{
			myactions["deltarune.battlemode"] = AddAction( "[Open Battle Box]", Action_OpenBattleBox );
			myactions["deltarune.battlemode"].hidden = true;
		}
		
		mymemories["swordfacing"] = AddMemory( "deltarune.swordfacing", 1 );
		
	}
	
	public function InitMenu()
	{
		myactions["deltarune.menu_light"] = AddAction( "[LW Menu]", Action_OpenMenu, 0 );
		myactions["deltarune.menu_dark"] = AddAction( "[DW Menu]", Action_OpenMenu, 1 );
	}
	
	override public function OnStateChanged()
	{
		super.OnStateChanged();
		
		if ( !curState )
			return;
	}
	
	public function GetLeader()
	{
		
	}
	
	override public function OnUpdateLook()
	{
		super.OnUpdateLook();
		if ( !GMControl.isControl )
			swordfacing = GetMemory( "deltarune.swordfacing" );
		
		var facing = ( Math.round( ( ( 360 + 90 ) - direction ) / 90 ) ) % 4;
		if ( speed == 0 )
		{
			global.input_held[INPUT_DOWN] = 0;
			global.input_held[INPUT_RIGHT] = 0;
			global.input_held[INPUT_UP] = 0;
			global.input_held[INPUT_LEFT] = 0;
		}
		else
		{
			switch( facing )
			{
				case 0:
					global.input_held[INPUT_DOWN] = 1;
					break;
				case 1:
					global.input_held[INPUT_RIGHT] = 1;
					break;
				case 2:
					global.input_held[INPUT_UP] = 1;
					break;
				case 3:
					global.input_held[INPUT_LEFT] = 1;
					break;
			}
		}
		global.facing = facing;
		
		if ( true )
		{
			if ( ( hDir < -0.001 ) && ( swordfacing > 0 ) )
			{
				swordfacing = -1;
				SetMemory( "deltarune.swordfacing", swordfacing );
			}
			else if ( ( hDir > 0.001 ) && ( swordfacing < 0 ) )
			{
				swordfacing = 1;
				SetMemory( "deltarune.swordfacing", swordfacing );
			}
		}
		else
			swordfacing = GetMemory( "deltarune.swordfacing" );
	}
	
	override public function Step()
	{
		super.Step();
		
		// Keyboard Input Step
		if ( !GMControl.isControl )
			return;
		if ( window_has_focus() ) //( keyboardInputPanel && ( keyboardInputPanel.HasFocus() ) )
		{
			var entity = GMControl.GetEntity( ctrl.getMyEntityId() );
			if ( entity && entity.GetPosition() )
			{
				
			}
			else
				return;
			if ( keyboardMoveX == null )
			{
				StartKeyboard();
			}
			var press_l = ( keyboard_check( Keyboard.LEFT ) || keyboard_check( Keyboard.A ) );
			var press_r = ( keyboard_check( Keyboard.RIGHT ) || keyboard_check( Keyboard.D ) );
			var press_u = ( keyboard_check( Keyboard.UP ) || keyboard_check( Keyboard.W ) );
			var press_d = ( keyboard_check( Keyboard.DOWN ) || keyboard_check( Keyboard.S ) );
			
			
			var xmove = ( press_r - press_l );
			var ymove = ( press_u - press_d );
			
			if ( xmove == 0 && ymove == 0 )
			{
				
			}
			else
			{
				var bounds = ctrl.getRoomBounds();
				var ts = timescale_delta;
				
				var _spd = ( moveSpeedReal / 30 );
				keyboardMoveX += ( _spd * xmove * ts );
				keyboardMoveY += ( _spd * ymove * ts );
				
				keyboardMoveX = clamp( keyboardMoveX, entity.x - ( _spd * 15 ), entity.x +  ( _spd * 15 ) );
				keyboardMoveY = clamp( keyboardMoveY, entity.z - ( _spd * 15 ), entity.z +  ( _spd * 15 ) );
				
				keyboardMoveX = clamp( keyboardMoveX, 0, 0 + bounds[0] );
				keyboardMoveY = clamp( keyboardMoveY, 0, 0 + bounds[1] );
			}
			
			var dis = point_distance( keyboardMovedX, keyboardMovedY, keyboardMoveX, keyboardMoveY );
			var _move = false;
			if ( dis > 0 )
			{
				if ( ( getTimer() - keyboardMoveTime ) > ( 1000 * ( 1 / 7.5 ) ) ) 
				{
					_move = true;
					keyboardMoveTime = getTimer();
				}
			}
			else
				keyboardMoveTime = getTimer();
			
			if ( _move )
			{
				var dir = point_direction( keyboardMovedX, keyboardMovedY, keyboardMoveX, keyboardMoveY );
				keyboardMovedX = keyboardMoveX;
				keyboardMovedY = keyboardMoveY;
				MoveTo( keyboardMoveX, entity.y, keyboardMoveY, dir + 90 );
				// MoveTo_Speed( ( moveSpeedReal / 30 ) * 2, keyboardMoveX, entity.y, keyboardMoveY, dir + 90 );
			}
		}
		else
			keyboardMoveX = null;
	}
	
	override public function OnMoveStart()
	{
		if ( !movePathStartReal )
			return;
		var entity = GMControl.entity;
		if ( !entity )
			return;
		
	}
	
	override public function OnMoveStop()
	{
		
	}
	
	public function PetStep()
	{
		if ( followtarget == null )
		{
			
		}
	}
	
	// 
	
	override public function Draw()
	{
		super.Draw();
		if ( window_has_focus() )
		{
			//var entity = GMControl.entity;
			var entity = GMControl.GetEntity( ctrl.getMyEntityId() );
			if ( entity ) //keyboardInputPanel && keyboardInputPanel.HasFocus() )
			{
				var xx = ( keyboardMoveX - entity.x ) / GMControl.scale;
				var yy = ( -( keyboardMoveY - entity.z ) ) / GMControl.scale;
				if ( isNaN( xx ) || isNaN( yy ) )
				{
					
				}
				else
				{ 
					draw_set_color( c_white );
					var ww = 20 / GMControl.scale;
					var hh = 12 / GMControl.scale;
					draw_set_color( c_white );
					draw_set_alpha( 0.5 );
					draw_rectangle( xx - ( ww / 2), yy - ( hh / 2 ), xx + ( ww / 2 ), yy + ( hh / 2 ) );
					draw_set_color( c_black );
					draw_rectangle( xx - ( ww / 3 ), yy - ( hh / 3 ), xx + ( ww / 3 ), yy + ( hh / 3 ) );
					draw_set_alpha( 1 );
				}
			}
		}
	}
	
	public function StartKeyboard()
	{
		keyboardMoveX = null;
		var entity = GMControl.GetEntity( ctrl.getMyEntityId() );
		if ( !entity )
			return;
		entity.GetPosition();
		keyboardMoveX = entity.x; //entity.destination[0];
		keyboardMoveY = entity.z; //entity.destination[2];
		keyboardMovedX = keyboardMoveX;
		keyboardMovedY = keyboardMoveY;
	}
	
	//
	public function Action_SetCharacter( data = null )
	{
		SetMemory( "deltarune.character", data );
	}
	
	public function SetCharacter( data = null )
	{
		if ( this.char == data )
			return;
		this.char = data;
		OnStateChanged();
	}
	
	// 
	
	public function Action_ToggleAutorun( data = null )
	{
		SetMemory( "deltarune.autorun", ( global.flag[FLAG_AUTORUN] == 1 ) ? 0 : 1 );
	}
	
	public function SetAutorun( data = 0 )
	{
		if ( data )
			global.flag[FLAG_AUTORUN] = 1;
		else
			global.flag[FLAG_AUTORUN] = 0;
		GMControl.Log( "deltarune flag[" + FLAG_AUTORUN + "] = " + global.flag[FLAG_AUTORUN] );
	}
	
	public function Action_OpenKeyboardControl( data = null )
	{
		if ( GMControl.isControl )
		{
			StartKeyboard();
			var size_w = 250;
			var size_h = 200;
			GMControl.DoPopup( null, size_w, size_h, null );
		}
	}
	
	public function Action_OpenBattleBox( data = null )
	{
		
	}
	
	public function Action_OpenMenu( data = null )
	{
		if ( !GMControl.isControl )
			return;
		if ( instance_exists( menu_object ) )
		{
			instance_destroy( menu_object );
			ctrl.clearPopup();
			// return;
		}
		
		if ( data == null )
			data = global.darkzone;
		
		if ( data == 1 )
		{
			menu_object = instance_create_depth( 0, 0, 0, obj_dwmenu );
		}
		else
		{
			menu_object = instance_create_depth( 0, 0, 0, obj_lwmenu );
		}
		
		if ( menu_object.surf == GMControl.popup_surface )
		{
			var res = GMControl.DoPopup( GMControl.popup_surface, menu_object.menuw, menu_object.menuh, menu_object );
		}
	}
	
}
} // Package


import gamemaker.*;
import deltarune.*;
import deltarune.objects.*;
import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.ui.*;
import flash.utils.*;

class obj_menu extends DeltaruneObject
{
	public var surf = GMControl.popup_surface;
	public var menuscale = 2;
	public var menux = 0;
	public var menuy = 0;
	public var menuw = 640;
	public var menuh = 470;
	public var menuedge = 3;
	
	public function obj_menu()
	{
		super();
		global.menuno = 0;
	}
}


class obj_lwmenu extends obj_menu
{
	
	public function obj_lwmenu()
	{
		super();
	}
	
	override public function Create()
	{
		super.Create();
		
	}
	
	override public function Draw()
	{
		if ( true )
		{
			surface_set_target( GMControl.popup_surface );
			DrawMenu();
			surface_reset_target();
		}
	}
	
	public function DrawMenu()
	{
		var x1, y1, x2, y2;
		var xx = menux;
		var yy = menuy;
		var moveyy = yy;
		if ( false )
			moveyy += 135;
		
		// draw backgrounds
		if ( global.menuno != 4 )
		{
			x1 = xx + 16;
			y1 = moveyy + 16;
			x2 = x1 + 70;
			y2 = y1 + 54;
			draw_set_color( c_white );
			draw_rectangle( x1 * menuscale, y1 * menuscale, x2 * menuscale, y2 * menuscale, false );
			draw_set_color( c_black );
			draw_rectangle( ( x1 + menuedge ) * menuscale, ( y1 + menuedge ) * menuscale, ( x2 - menuedge ) * menuscale, ( y2 - menuedge ) * menuscale, false );
			y1 = yy + 74;
			y2 = x1 + 131
			draw_set_color( c_white );
			draw_rectangle( x1 * menuscale, y1 * menuscale, x2 * menuscale, y2 * menuscale, false );
			draw_set_color( c_black );
			draw_rectangle( ( x1 + menuedge ) * menuscale, ( y1 + menuedge ) * menuscale, ( x2 - menuedge ) * menuscale, ( y2 - menuedge ) * menuscale, false );
		}
		
	}
}

class obj_dwmenu extends obj_menu
{
	
	public function obj_dwmenu()
	{
		super();
		
	}
	
	override public function Cleanup()
	{
		GM.Log( "Remove surf" );
		surf = null;
	}
	
	public function SetSize( _w = null, _h = null )
	{
		if ( _w != null )
			width = _w;
		if ( _h != null )
			height = _h;
	}
	
	override public function Draw()
	{
		if ( true )
		{
			surface_set_target( GMControl.popup_surface );
			DrawMenu();
			surface_reset_target();
		}
	}
	
	public function DrawMenu()
	{
		var x1 = menux;
		var y1 = menuy;
		var x2 = menux + menuw;
		var y2 = menuy + menuh;
		
		
		scr_darkbox( x1, y1, x2, y2 );
	}
}