
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
	public var keyboardMoveX = 0;
	public var keyboardMoveY = 0;
	
	public function DeltarunePlayerBody()
	{
		super();
		use_delta = false;
		
		global.input_pressed = new Array( 10 );
		global.input_held = new Array( 10 );
		
		InitMenu();
		
		myactions["keyboardmode"] = AddAction( "[Open Keyboard Control]", Action_OpenKeyboardControl );
		myactions["keyboardmode"].hidden = true;
		
		mymemories["autorun"] = AddMemory( "deltarune.autorun", 0, SetAutorun );
		myactions["autorun_toggle"] = AddAction_ToggleMemory( "[Autorun]", "deltarune.autorun" );
		
		if ( false )
		{
			myactions["deltarune.battlemode"] = AddAction( "[Open Battle Box]", Action_OpenBattleBox );
			myactions["deltarune.battlemode"].hidden = true;
		}
		
		
		
	}
	
	public function InitMenu()
	{
		myactions["deltarune.menu"] = AddAction( "[Open Menu]", Action_OpenMenu );
		myactions["deltarune.menu"].hidden = true;
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
	
	override public function Step()
	{
		super.Step();
		return;
		// Keyboard Input Step
		if ( keyboardInputPanel && ( keyboardInputPanel.HasFocus() ) )
		{
			var xmove = ( keyboardInputPanel.press_r - keyboardInputPanel.press_l );
			var ymove = ( keyboardInputPanel.press_u - keyboardInputPanel.press_d );
			
			if ( xmove == 0 && ymove == 0 )
			{
			}
			else
			{
				keyboardMoveX += ( body.moveSpeed * xmove );
				keyboardMoveY += ( body.moveSpeed * ymove );
			}
		}
		
		
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
		{
			keyboardInputPanel = new KeyboardControlPopup();
		}
		keyboardInputPanel.Apply();
		return keyboardInputPanel;
	}
	
	public function Action_OpenKeyboardControl( data = null )
	{
		return;
		GetKeyboardPopup();
		GMControl.DoPopup( keyboardInputPanel, keyboardInputPanel.size_w, keyboardInputPanel.size_h );
	}
	
	public function Action_OpenBattleBox( data = null )
	{
		
	}
	
	public function Action_OpenMenu( data = null )
	{
		if ( false && !GMControl.isControl )
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
	
	public var has_listeners = false;
	
	public var press_d = 0;
	public var press_r = 0;
	public var press_u = 0;
	public var press_l = 0;
	
	
	public function KeyboardControlPopup()
	{
		this.focusRect = null;
		
		addEventListener( Event.UNLOAD, Cleanup );
		name = "Input Handler";
		g = graphics;
		g.clear();
		g.beginFill( 0 );
		g.drawRect( 0, 0, size_w, size_h );
		g.endFill();
	}
	
	public function Cleanup( ... ignored )
	{
		this.removeEventListener( Event.UNLOAD, Cleanup );
		this.removeEventListener( KeyboardEvent.KEY_DOWN, OnKeyDown );
		this.removeEventListener( KeyboardEvent.KEY_UP, OnKeyUp  );
		this.removeEventListener( MouseEvent.CLICK, OnClicked );
	}
	
	// Give focus and add listeners
	public function Apply( ... ignored )
	{
		// GMControl.SetKeyboardListener( this );
		if ( !has_listeners )
		{
			has_listeners = true;
			this.addEventListener( KeyboardEvent.KEY_DOWN, OnKeyDown );
			this.addEventListener( KeyboardEvent.KEY_UP, OnKeyUp  );
			this.addEventListener( MouseEvent.CLICK, OnClicked );
		}
		OnClicked();
	}
	
	public function OnKeyDown( ev )
	{
		switch ( ev.keyCode )
		{
			case 37: // LeftArrow
				press_l = 1;
				break;
			case 38: // UpArrow
				press_u = 1;
				break;
			case 39: // RightArrow
				press_r = 1;
				break;
			case 40: // DownArrow
				press_d = 1;
				break;
		}
	}
	
	public function OnKeyUp( ev )
	{
		switch ( ev.keyCode )
		{
			case 37: // LeftArrow
				press_l = 0;
				break;
			case 38: // UpArrow
				press_u = 0;
				break;
			case 39: // RightArrow
				press_r = 0;
				break;
			case 40: // DownArrow
				press_d = 0;
				break;
		}
	}
	
	public function OnClicked( ... ignored )
	{
		GM.Log( "KeyboardControl focused" );
		GM.media.stage.focus = this;
	}
	
	public function HasFocus()
	{
		return ( GM.media.stage.focus == this );
	}
	
}

class obj_darkmenu extends DeltaruneObject
{
	public var surf;
	
	public var menux = 0;
	public var menuy = 0;
	public var menuw = 640;
	public var menuh = 420;
	
	public function obj_darkmenu()
	{
		super();
		
		menux = 0;
		menuy = 0;
		menuw = 600;
		menuh = 180;
		
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
		var x1 = menux;
		var y1 = menuy;
		var x2 = menux + menuw;
		var y2 = menuy + menuh;
		
		
		scr_darkbox( x1, y1, x2, y2 );
	}
}