
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
	public static const INPUT_DOWN = 0;
	public static const INPUT_RIGHT = 1;
	public static const INPUT_UP = 2;
	public static const INPUT_LEFT = 3;
	
	public static const FLAG_AUTORUN = 11;
	
	public var chara;
	
	public var menu_object;
	
	public var swordmode = false;
	public var heroname = "Hero";
	public var herocolor = 0xFFFFFF;
	
	public var partylist = [];    // All remote members of the party
	
	public var followtarget = null;  // Who I am following
	public var followtargethistory = []; // movement history of the party member im following
	public var followtargetdelay = 20;
	
	public var keyboardInputPanel;
	
	public function DeltarunePlayerBody()
	{
		super();
		use_delta = false;
		
		global.input_pressed = new Array( 10 );
		global.input_held = new Array( 10 );
		
		InitMenu();
		
		myactions["keyboardmode"] = AddAction( "[Open Keyboard Control]", Action_OpenKeyboardControl );
		
		mymemories["autorun"] = AddMemory( "deltarune.autorun", 0, SetAutorun );
		myactions["autorun_toggle"] = AddAction_ToggleMemory( "[Toggle Autorun]", "deltarune.autorun" );
		
		// myactions["battlemode"] = AddAction( "[Open Battle Box]", Action_OpenBattleBox );
		// myactions["battlemode"].hidden = true;
		
		if ( false )
		{
			ctrl.registerCustomConfig( GetKeyboardPopup );
			myactions["devpanel"].hidden = false;
		}
	}
	
	public function InitMenu()
	{
		myactions["deltarune.menu"] = AddAction( "[Open Menu]", Action_OpenMenu );
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
		global.facing = ( Math.round( ( ( 360 + 90 ) - direction ) / 90 ) ) % 4;
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
	
	//
	
	public function GetKeyboardPopup()
	{
		if ( !keyboardInputPanel )
			keyboardInputPanel = new KeyboardControlPopup();
		return keyboardInputPanel;
	}
	
	public function Action_OpenKeyboardControl( data = null )
	{
		if ( !keyboardInputPanel )
			keyboardInputPanel = new KeyboardControlPopup();
		GMControl.DoPopup( keyboardInputPanel, keyboardInputPanel.size_w, keyboardInputPanel.size_h );
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
			return;
		}
		menu_object = instance_create( 0, 0, obj_darkmenu );
		if ( menu_object.surf == GMControl.popup_surface )
		{
			var res = GMControl.DoPopup( null, 640, 420 );
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

class KeyboardControlPopup extends Sprite
{
	
	public var s;
	public var g;
	
	var size_w = 200;
	var size_h = 128;
	
	public function KeyboardControlPopup()
	{
		addEventListener( Event.UNLOAD, Cleanup );
		name = "Input Handler";
		s = this;
		g = s.graphics;
		
		g.clear();
		g.beginFill( 0 );
		g.drawRect( 0, 0, size_w, size_h );
		g.endFill();
		
		s.addEventListener( KeyboardEvent.KEY_DOWN, OnKeyDown );
		GM.media.stage.focus = s;
	}
	
	public function Cleanup( ... ignored )
	{
		s.removeEventListener( KeyboardEvent.KEY_DOWN, OnKeyDown );
	}
	
	public function OnKeyDown( ev )
	{
		GM.Log( "key down" );
	}
	
	public function OnKeyUp( ev )
	{
		GM.Log( "key up" );
	}
}

class obj_darkmenu extends DeltaruneObject
{
	public var surf;
	
	public var menuw = 640;
	public var menuh = 420;
	
	public function obj_darkmenu()
	{
		super();
		
		width = menuw;
		height = menuh;
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
		if ( !GM.overlay.visible )
		{
			GM.Log( "popup not visible" );
			return;
		}
		surface_set_target( GM.overlay );
		
		DrawMenu();
		
		surface_reset_target();
	}
	
	public function DrawMenu()
	{
		var x1 = 0;
		var y1 = 0;
		var x2 = menuw;
		var y2 = menuh;
		
		
		scr_darkbox( x1, y1, x2, y2 );
	}
}