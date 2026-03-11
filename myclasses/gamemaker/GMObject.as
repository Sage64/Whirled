
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

import com.threerings.text.TextFieldUtil;
import com.whirled.*;

public class GMObject extends Sprite
{
	public static const global = GMControl.global;
	
	public static var current_time = 0;
	
	public static var _createx;
	public static var _createy;
	
	public var body;
	public var id = this;
	public var exists = true;
	
	public var xstart;
	public var ystart;
	public var depth = 0;
	
	public var alarm = new Array( 12 );
	
	public var sprite_index = null; // use sprite_current instead for sprite ref
	public var sprite_current = null;
	public var image_number = 1;
	public var image_index = 0;
	public var image_speed = 1;
	public var image_xscale = 1;
	public var image_yscale = 1;
	public var image_angle = 0;
	public var image_blend = 0xFFFFFF;
	public var image_alpha = 1;
	
	// Movement
	public var hspeed = 0;
	public var vspeed = 0;
	public var gravity = 0;
	
	// Color consants
	public static const c_white = 0xFFFFFF;
	public static const c_black = 0x000000;
	//
	public static const c_aqua = c_white;
	public static const c_blue = 0x0000FF;
	public static const c_lime = 0x00FF00;
	public static const c_ltgray = 0xCCCCCC;
	public static const c_purple = 0x800080;
	public static const c_red = 0xFF0000;
	public static const c_yellow = 0xFFFF00;
	
	// Function constants
	public static const string = String;
	
	//
	public static const fa_left = 0;
	public static const fa_center = 1;
	public static const fa_right = 2;
	public static const fa_top = 0;
	public static const fa_middle = 1;
	public static const fa_bottom = 2;
	
	
	public function GMObject()
	{
		this.x = _createx;
		this.y = _createy;
		xstart = x;
		ystart = y;
		
		GMControl.debugTracker = "GMObject";
		this.body = GMControl.body;
	}
	
	public function Cleanup() {}
	
	public function Create() {} // called after being instance_create'd after construction
	
	public function GMStep()
	{
		if ( gravity != 0 )
		{
			vspeed += gravity;
		}
		
		if ( vspeed != 0 )
		{
			y += vspeed;
		}
		
		Step();
		
		if ( image_speed != 0 && ( image_number > 1 ) )
		{
			image_index += ( image_speed );
			if ( image_index >= image_number )
			{
				OnAnimationEnd();
			}
			image_index = ( image_index % image_number );
		}
		
	}
	
	public function Step() {}
	
	public function GMDraw()
	{
		Draw();
	}
	
	public function Draw()
	{
		draw_self();
	}
	
	public function OnAnimationEnd() {}
	
	/*
		GM Functions
	*/
	
	public function script_execute( scr, arg )
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
	
	// Misc. constants
	public static const pi = Math.PI;
	
	// Misc. functions, sorted alphabetically
	
	public static const abs = Math.abs;
	public static const arccos = Math.acos;
	public static const arcsin = Math.asin;
	public static const ceil = Math.ceil;
	public static const clamp = gml.clamp;
	public static const cos = Math.cos;
	public static const dcos = gml.dcos;
	public static const dsin = gml.dsin;
	public static const floor = Math.floor;
	public static const lengthdir_x = gml.lengthdir_x;
	public static const lengthdir_y = gml.lengthdir_y;
	public static const lerp = gml.lerp;
	public static const min = Math.min;
	public static const max = Math.max;
	public static const power = Math.pow;
	public static const round = Math.round;
	public static const sin = Math.sin;
	public static const sqrt = Math.sqrt;
	
	public static function irandom( val )
	{
		return Math.round( Math.random() * val );
	}
	
	public static function is_string( val )
	{
		return ( typeof val == "String" );
	}
	
	public static function random( val )
	{
		return Math.random() * val;
	}
	
	public static function random_range( a, b )
	{
		return gml.lerp( a, b, Math.random() );
	}
	
	public static function sqr( val )
	{
		return val * val;
	}
	
	// Instance
	
	public static function instance_create( _x, _y, _obj )
	{
		return GMControl.InternalInstanceCreate( _x, _y, _obj );
	}
	
	public function instance_destroy( _inst = null )
	{
		if ( _inst == null )
			_inst = this;
		return GMControl.InternalInstanceDestroy( _inst );
	}
	
	public static function instance_exists( _obj )
	{
		if ( !_obj )
			return false;
		if ( _obj == 1 )
			return true;
		if ( _obj )
		{
			return _obj.exists;
		}
		return false;
	}
	
	public static function variable_instance_get( inst, varname )
	{
		return inst[varname];
	}
	
	public static function variable_instance_set( inst, varname, val )
	{
		inst[varname] = val;
	}
	
	// Sprite
	
	// Retrieve a sprite asset
	public static function sprite_get( sprite_name )
	{
		return GMControl.InternalSpriteGet( sprite_name );
	}
	
	// Set the "current" sprite for this object;
	public function sprite_set( sprite_ref )
	{
		if ( sprite_ref == -1 )
			sprite_ref = null;
		if ( sprite_ref == sprite_current )
		{
			// trace( "no change" );
			return;
		}
		
		if ( sprite_current )
		{
			//sprite_current.symbol.visible = false;
			sprite_current = null;
		}
		
		if ( sprite_ref )
		{
			// trace( "sprite = " + sprite_ref.name );
			sprite_current = sprite_ref;
			image_number = sprite_current.count;
		}
	}
	
	public function draw_self()
	{
		return GMControl.InternalSpriteDraw( sprite_current, image_index, x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha  );
	}
	
	public function draw_sprite( _sprite, _image = null, _x = null, _y = null )
	{
		if ( _sprite == sprite_index )
			_sprite = sprite_current;
		return GMControl.InternalSpriteDraw( _sprite, _image, _x, _y, 1, 1, 0, 0xFFFFFF, 1 );
	}
	
	public function draw_sprite_ext( _sprite, _image = null,
	_x = null, _y = null, _xscale = 1, _yscale = 1,
	_rot = 0, _col = 0xFFFFFF, _alpha = 1 )
	{
		if ( _sprite == sprite_index )
			_sprite = sprite_current;
		return GMControl.InternalSpriteDraw( _sprite, _image, _x, _y, _xscale, _yscale, _rot, _col, _alpha  );
	}
	
	public function draw_sprite_pos( sprite, subimg, x1, y1, x2, y2, x3, y3, x4, y4, alpha )
	{
		
	}
	
	
	// Draw
	
	public static function merge_color( cola, colb, amnt )
	{
		if ( amnt > 0 )
		{
			if ( amnt < 1 )
			{
				var r = ( ( cola >> 16 ) & 0xFF );
				var b = ( ( cola >> 8 ) & 0xFF );
				var g = ( ( cola ) & 0xFF );
				r = lerp( r, ( ( colb >> 16 ) & 0xFF ), amnt );
				b = lerp( b, ( ( colb >> 8 ) & 0xFF ), amnt );
				g = lerp( g, ( ( colb ) & 0xFF ), amnt );
				colb = g | ( b << 8 ) | ( r << 16 );
			}
			return colb;
		}
		return cola;
	}
	
	public static function draw_set_alpha( alpha )
	{
		return GMControl.InternalSetAlpha( alpha );
	}
	
	public static function draw_get_alpha()
	{
		return GMControl.drawalpha;
	}
	
	public static function draw_set_color( col )
	{
		return GMControl.InternalSetColor( col );
	}
	
	public static function draw_get_color()
	{
		return GMControl.drawcolor;
	}
	
	public static function draw_line_width( x1, y1, x2, y2, w = 1, a = null )
	{
		return GMControl.InternalDrawLine( x1, y1, x2, y2, w, a );
	}
	
	// Text
	
	public static function draw_set_font( _fnt )
	{
		GMControl.drawfont = _fnt;
	}
	
	public static function draw_set_halign( _h = fa_left )
	{
		GMControl.drawhalign = _h;
	}
	public static function draw_set_valign( _v = fa_top )
	{
		GMControl.drawvalign = _v;
	}
	
	public function draw_text_transformed( _x, _y, _text, _xscale = 1, _yscale = 1, _angle = 0 )
	{
		GMControl.InternalTextDraw( _x, _y, _text, _xscale, _yscale, _angle );
		return;
	}
	
	
	// Sound
	
	public static function audio_play_sound( _sound, _priority = 0, _loop = false, _gain = 1, _offset = 0, _pitch = 1 )
	{
		return GMControl.InternalAudioPlay( _sound, _priority, _loop, _gain, _offset, _pitch );
	}
	
	
}



} // package



