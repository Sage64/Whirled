
// GM Object
// by sage [ https://github.com/Sage64/Whirled ]
// Part of GMBody.as


package gamemaker
{

import flash.display.*;
import flash.events.*;
import flash.filters.*;
import flash.geom.*;
import flash.text.*;

import com.threerings.text.*;
import com.whirled.*;

public class GMObject extends GMFunctions
{
	public var parent;
	public var name = "GMObject";
	public var x = 0;
	public var y = 0;
	public var width = 0;
	public var height = 0;
	public var visible = true;
	
	public var object_index = -1;
	
	public static var timescale = 1;
	public static var timescale_delta = 1;
	
	public static var current_time = 0;
	
	public static var _createx;
	public static var _createy;
	
	public var body;
	public var id = this;
	public var exists = true;
	
	public var persistent = false;
	
	public var xstart;
	public var ystart;
	public var depth = 0;
	
	public var alarm = new Array( 12 );
	
	//public var sprite_index;
	public var sprite_current = null;
	//public var sprite_width = 0;
	//public var sprite_height = 0;
	//public var sprite_xoffset = 0;
	//public var sprite_yoffset = 0;
	public var image_number = 1;
	public var image_index = 0;
	public var image_speed = 1;
	public var image_xscale = 1;
	public var image_yscale = 1;
	public var image_angle = 0;
	public var image_blend = 0xFFFFFF;
	public var image_alpha = 1;
	
	// Movement
	public var direction = 0;
	public var speed = 0;
	public var hspeed = 0;
	public var vspeed = 0;
	public var gravity = 0;
	public var gravity_direction = 270;
	
	
	public function GMObject()
	{
		this.x = _createx;
		this.y = _createy;
		this.xstart = x;
		this.ystart = y;
		
		GM.debugTracker = "GMObject";
		this.body = GMControl.body;
		
		
	}
	
	public function Cleanup() {}
	
	public function Create() {} // called after being instance_create'd after construction
	
	public function GMStep()
	{
		if ( true )
		GMMovement();
		
		GMAlarms();
		
		Step();
		
		GMAnimate();
	}
	
	public function GMAnimate()
	{
		if ( true )
		{
			if ( image_index < image_number )
			{
				image_index += ( image_speed );
				if ( image_index >= image_number )
					OnAnimationEnd();
				return;
			}
			image_index += ( image_speed );
			return;
		}
		image_index += ( image_speed ); 
	}
	
	// override to disable
	public function GMMovement()
	{
		if ( gravity != 0 )
		{
			hspeed += dcos( gravity_direction ) * ( gravity );
			vspeed -= dsin( gravity_direction) * ( gravity );
		}
		if ( hspeed != 0 )
			x += ( hspeed );
		if ( vspeed != 0 )
			y += ( vspeed );
	}
	
	public function GMAlarms()
	{
		for ( var i = 0; i < 12; ++i )
		{
			if ( alarm[i] > 0 )
			{
				--alarm[i];
				if ( alarm[i] == 0 )
				{
					this["Alarm_" + i]();
					alarm[i] = -1;
				}
			}
		}
	}
	
	public function Alarm_0() {}
	public function Alarm_1() {}
	public function Alarm_2() {}
	public function Alarm_3() {}
	public function Alarm_4() {}
	public function Alarm_5() {}
	public function Alarm_6() {}
	public function Alarm_7() {}
	public function Alarm_8() {}
	public function Alarm_9() {}
	public function Alarm_10() {}
	public function Alarm_11() {}
	
	public function Step() {}
	
	public function GMDraw()
	{
		Draw();
	}
	
	public function Draw()
	{
		draw_self();
	}
	
	public function DrawEnd()
	{
		// unused currently
	}
	
	public function OnAnimationEnd() {}
	
	
	// yyInstance
	{
		// Set the "current" sprite for this object;
		public function sprite_set( sprite_ref )
		{
			if ( sprite_ref == -1 )
				sprite_ref = null;
			if ( sprite_ref == sprite_current )
			{
				return;
			}
			if ( sprite_current )
			{
				sprite_current = null;
				image_number = 0;
			}
			if ( sprite_ref )
			{
				sprite_current = sprite_ref;
				image_number = sprite_ref.count;
			}
		}
		
		public function set sprite_index( _ref )
		{
			// sprite_current = _ref;
			sprite_set( _ref );
		}
		
		public function get sprite_index()
		{
			if ( sprite_current == null )
				return -1;
			return sprite_current;
		}
		
		
		public function get sprite_width()
		{
			return ( sprite_current ) ? ( sprite_current.width * image_xscale ) : 0;
		}
		
		public function get sprite_height()
		{
			return ( sprite_current ) ? ( sprite_current.height * image_yscale ) : 0;
		}
		
		
		public function get sprite_xoffset()
		{
			return ( sprite_current ) ? ( sprite_current.x * image_xscale ) : 0;
		}
		
		public function get sprite_yoffset()
		{
			return ( sprite_current ) ? ( sprite_current.y * image_yscale ) : 0;
		}
	}
	
	
	
	
	
	// View
	
	public static function camera_get_view_x( _camera = null )
	{
		if ( _camera )
			return _camera.x;
		return GM.view_x; //0 - ( GM.view_width / 2 );
	}
	
	public static function camera_get_view_y( _camera = null )
	{
		if ( _camera )
			return _camera.y;
		return GM.view_y; //0 - ( GM.view_height / 2  );
	}
	
	public static function camera_get_view_width( _camera = null )
	{
		if ( _camera )
			return _camera.width;
		return ( GM.view_width );
	}
	
	public static function camera_get_view_height( _camera = null )
	{
		if ( _camera )
			return _camera.height;
		return ( GM.view_height );
	}
	
	public static function camera_set_view_pos( _camera, _x, _y )
	{
		if ( _camera )
		{
			return;
		}
		
		GM.view_x = _x;
		GM.view_y = _y;
	}
	
	// Surf
	
	public static function surface_set_target( _surf )
	{
		GM.internalrenderstack.push( GM.internalrendertarget );
		GM.InternalSetDrawTarget( _surf );
	}
	
	public static function surface_reset_target()
	{
		var target = ( GM.internalrenderstack.length > 0 ) ? GM.internalrenderstack.pop() : GM.container;
		GM.InternalSetDrawTarget( target );
	}
	
	public function array_create( len, val = 0 )
	{
		var array = new Array( len );
		if ( val != null )
		{
			for ( var i = 0; i < len; ++i )
				array[i] = val;
		}
		return array;
	}
	
	public static function is_array( val )
	{
		return ( val && ( val is Array ) );
	}
	
	public static function script_execute( scr, arg )
	{
		var i = 0;
		switch ( arg.length )
		{
			case 1:
				return scr( arg[i++] );
			case 2:
				return scr( arg[i++], arg[i++] );		
			case 3:
				return scr( arg[i++], arg[i++], arg[i++] );		
			case 4:
				return scr( arg[i++], arg[i++], arg[i++], arg[i++] );		
			case 5:
				return scr( arg[i++], arg[i++], arg[i++], arg[i++], arg[i++] );		
			case 6:
				return scr( arg[i++], arg[i++], arg[i++], arg[i++], arg[i++], arg[i++] );		
			case 7:
				return scr( arg[i++], arg[i++], arg[i++], arg[i++], arg[i++], arg[i++], arg[i++] );		
			case 8:
				return scr( arg[i++], arg[i++], arg[i++], arg[i++], arg[i++], arg[i++], arg[i++], arg[i++] );		
			case 9:
				return scr( arg[i++], arg[i++], arg[i++], arg[i++], arg[i++], arg[i++], arg[i++], arg[i++], arg[i++] );		
			case 10:
				return scr( arg[i++], arg[i++], arg[i++], arg[i++], arg[i++], arg[i++], arg[i++], arg[i++], arg[i++], arg[i++] );		
		}
		return scr();
	}
	
	public static function variable_instance_exists( inst, varname )
	{
		try
		{
			var val = inst[varname];
			if ( val != null )
				return true;
		}
		catch(e)
		{
			return false;
		}
	}
	
	public static function variable_instance_get( inst, varname )
	{
		try
		{
			return inst[varname];
		}
		catch(e){}
		return null;
	}
	
	public static function variable_instance_set( inst, varname, val )
	{
		try
		{
			inst[varname] = val;
		}
		catch(e) {}
	}
	
	
	
	// Sprite
	
	// Retrieve a sprite asset
	// OLD. assets are now added to "global", eg: global.sprite_name
	public static function sprite_get( sprite_name )
	{
		return GM.InternalSpriteGet( sprite_name );
	}
	
	// Draw
	
	
	// Sound
	
	public static function audio_play_sound( _sound, _priority = 0, _loop = false, _gain = 1, _offset = 0, _pitch = 1 )
	{
		return GM.InternalAudioPlay( _sound, _priority, _loop, _gain, _offset, _pitch );
	}
	
	public static function audio_stop_sound( _sound )
	{
		return GM.InternalAudioStop( _sound );
	}
}


} // package
