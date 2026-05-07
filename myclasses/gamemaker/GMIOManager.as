// IOManager
package gamemaker
{

import gamemaker.*;
import flash.display.*;
import flash.errors.*;
import flash.events.*;
import flash.text.*;
import flash.ui.*;
import flash.utils.*;

public class GMIOManager
{
	public static const MAX_KEYS = 256;
	public static const MAX_BUTTONS = 5;
	
	public static const StartStep = IO_StartStep;
	
	public static var updated = false;
	
	public static var KeyDown = new Array( 256 );
	public static var KeyPressed = new Array( 256 );
	public static var KeyReleased = new Array( 256 );
	
	public function GMIOManager()
	{
		Init();
	}
	
	public static function Init()
	{
		trace( "GMIOManager Init" );
		var _targets = [ GM.container, GM.media.stage ];
		for each ( var target in _targets )
		{
			InitInputListeners( target );
		}
	}
	
	public static function InitInputListeners( target )
	{
		GM.debugTracker = "GMControl.InitInputListeners";
		GM.Log( "Adding input listeners to " + target );
		var _events = [
			[ KeyboardEvent.KEY_DOWN, GMKeyboardDown ],
			[ KeyboardEvent.KEY_UP, GMKeyboardUp ],
			[ MouseEvent.MOUSE_DOWN, GMMouseDown ],
			[ MouseEvent.MOUSE_UP, GMMouseUp ],
			[ "releaseOutside", GMMouseUp ],
			[ MouseEvent.RIGHT_MOUSE_DOWN, GMMouseDown ],
			[ MouseEvent.RIGHT_MOUSE_UP, GMMouseUp ],
			[ MouseEvent.MIDDLE_MOUSE_DOWN, GMMouseDown ],
			[ MouseEvent.MIDDLE_MOUSE_UP, GMMouseUp ],
			[ MouseEvent.MOUSE_WHEEL, GMMouseWheel ]
		];
		for each ( var event in _events )
		{
			try
			{
				GM.AddEventListener( target, event[0], event[1] );
			}
			catch(e)
			{
				GM.Warn( "Security violation adding event listener" );
			}
		}
	}
	
	public static function IsPriorityKey( keycode )
	{
		if ( true ) // is whirled
		{
			if ( keycode == 115 ) // F4 - See through players
				return true;
			if ( keycode == 116 ) // F5 - See through furniture
				return true;
		}
		if ( keycode == 122 ) // F11
			return true;
		return false;
	}
	
	public static function GMKeyboardDown( ev )
	{
		var keycode = ev.keyCode;
		if ( IsPriorityKey( keycode ) )
			return true;
		else
			ev.preventDefault();
		OnKeyDown( keycode );
		return false;
	}
	
	public static function OnKeyDown( keycode )
	{
		if ( !GM.g_KeyDown[keycode] )
		{
			GM.g_KeyPressed[keycode] = true;
			GM.g_KeyDown[keycode] = true;
			updated = true;
			//trace( "key " + keycode + " down" );
		}
	}
	
	public static function GMKeyboardUp( ev )
	{
		var keycode = ev.keyCode;
		// var charcode = ev.charCode;
		if ( IsPriorityKey( keycode ) )
			return;
		ev.preventDefault();
		OnKeyUp( keycode );
		return false;
	}
	
	public static function OnKeyUp( keycode )
	{
		if ( GM.g_KeyDown[keycode] )
		{
			GM.g_KeyDown[keycode] = false;
			GM.g_KeyUp[keycode] = true;
			updated = true;
			//trace( "key " + keycode + " up" );
		}
	}
	
	public static function GMMouseDown( ev )
	{
		var focus = ev.target;
		if ( ev.target == GM.media.stage )
			focus = GM.container;
		GM.media.stage.focus = focus; // GM.container;
		//trace( GM.media.stage.focus );
		var keycode = 1; // MOUSE_LEFT
		switch ( ev.type )
		{
			case MouseEvent.MOUSE_DOWN:
				break;
			case MouseEvent.RIGHT_MOUSE_DOWN:
				keycode = 2;
				break;
			case MouseEvent.MIDDLE_MOUSE_DOWN:
				keycode = 4;
				break;
		}
		ev.preventDefault();
		OnKeyDown( keycode );
		return false;
	}
	
	public static function GMMouseUp( ev )
	{
		var keycode = 1; // MOUSE_LEFT
		switch ( ev.type )
		{
			case MouseEvent.MOUSE_UP:
				break;
			case MouseEvent.RIGHT_MOUSE_UP:
				keycode = 2;
				break;
			case MouseEvent.MIDDLE_MOUSE_UP:
				keycode = 4;
				break;
			case "releaseOutside":
				OnKeyUp( 1 );
				OnKeyUp( 2 );
				OnKeyUp( 4 );
				return false;
		}
		ev.preventDefault();
		OnKeyUp( keycode );
		return false;
	}
	
	public static function GMMouseWheel( ev )
	{
		if ( !ev )
			return;
		var keycode = 0;
		if ( ev.delta > 0 )
			keycode = 10;
		else if ( ev.delta < 0 )
			keycode = 11;
		
		if ( keycode != 0 )
		{
			OnKeyDown( keycode );
			OnKeyUp( keycode );
		}
	}
	
	public static function IO_Clear()
	{
		//trace( "IO_Clear()" );
		for ( var i = 0; i < MAX_KEYS; ++i )
		{
			// GM.g_KeyDown[i] = false;
			// GM.g_KeyPressed[i] = false;
			// GM.g_KeyUp[i] = false;
			KeyDown[i] = false;
			KeyPressed[i] = false;
			KeyReleased[i] = false;
		}
		updated = false;
	}
	
	public static function IO_StartStep()
	{
		if ( updated )
			updated = false;
		else
			return;
		
		var pressed, down, released;
		KeyDown.length = 0;
		KeyDown.length = MAX_KEYS;
		KeyPressed.length = 0;
		KeyPressed.length = MAX_KEYS;
		KeyReleased.length = 0;
		KeyReleased.length = MAX_KEYS;
		
		
		for ( var i = 0; i < MAX_KEYS; ++i )
		{
			var key = i;
			KeyDown[key] = false;
			// 
			KeyDown[key] |= GM.g_KeyDown[i];
			if ( GM.g_KeyPressed[i] )
			{
				KeyPressed[key] = true;
				updated = true;
			}
			else
				KeyPressed[key] = false;
			// 
			if ( GM.g_KeyUp[i] )
			{
				KeyReleased[key] = true;
				updated = true;
			}
			else
				KeyReleased[key] = false;
			
			GM.g_KeyPressed[i] = false;
			GM.g_KeyUp[i] = false;
		}
	}
}


}
