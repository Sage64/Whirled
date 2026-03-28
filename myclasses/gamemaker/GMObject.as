
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
	// public var parent;
	// public var name = "GMObject";
	// public var x = 0;
	// public var y = 0;
	// public var width = 0;
	// public var height = 0;
	
	public static const global = GM.global;
	
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
	
	// Text constants
	public static const fa_left = 0;
	public static const fa_center = 1;
	public static const fa_right = 2;
	public static const fa_top = 0;
	public static const fa_middle = 1;
	public static const fa_bottom = 2;
	
	
	// Draw constants
	public static const bm_add = BlendMode.ADD;
	public static const bm_normal = BlendMode.NORMAL;
	
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
		if ( gravity != 0 )
		{
			hspeed += dcos( gravity_direction ) * ( gravity * timescale );
			vspeed -= dsin( gravity_direction) * ( gravity * timescale );
		}
		
		if ( hspeed != 0 )
			x += ( hspeed * timescale );
		if ( vspeed != 0 )
			y += ( vspeed * timescale );
		
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
	
	public function DrawEnd()
	{
		// unused currently
	}
	
	public function OnAnimationEnd() {}
	
	/*
		GM Functions
	*/
	
	
	// Function_Graphics
	
	
	// Function_Instance
	
	public function instance_destroy( _inst = null )
	{
		if ( _inst == null )
			_inst = this;
		return GM.InternalInstanceDestroy( _inst );
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
			sprite_current = null;
			image_number = 0;
		}
		
		if ( sprite_ref )
		{
			sprite_current = sprite_ref;
			image_number = sprite_ref.count;
		}
	}
	
	// Function_Layer
	
	public static function instance_create( _x, _y, _obj, _basis = null )
	{
		var inst = GM.AddInstance( _x, _y, _obj, _basis );
		inst.Create();
		return inst;
	}
	
	public static function instance_create_depth( _x = 0, _y = 0, _depth = 0, _obj = -1, _basis = null )
	{
		var inst = GM.AddInstance( _x, _y, _obj, _basis );
		inst.depth = _depth;
		inst.Create();
		return inst;
	}
	
	public static function instance_create_layer( _x = 0, _y = 0, _layer = 0, _obj = -1, _basis = null )
	{
		var inst = GM.AddInstance( _x, _y, _obj, _basis );
		inst.Create();
		return inst;
	}
	
	
	// Function_Maths
	
	public static function point_direction( _x1, _y1, _x2, _y2 )
	{
		var xx = _x2 - _x1;
		var yy = _y2 - _y1;
		return Math.floor( ( Math.round( Math.atan2( yy, xx ) / ( 2 * Math.PI / 360 ) ) + 360) % 360 );
	}
	
	public static function point_distance( _x1, _y1, _x2, _y2 )
	{
		var dx = _x2 - _x1;
		var dy = _y2 - _y1;
		return Math.sqrt( ( dx*dx ) + ( dy*dy ) );
	}
	
	
	// Function_Sprite
	
	public static function sprite_get_width( _spr )
	{
		if ( _spr != null )
			return _spr.width;
		return 0;
	}
	
	public static function sprite_get_height( _spr )
	{
		if ( _spr != null )
			return _spr.height;
		return 0;
	}
	
	public static function sprite_get_number( _spr )
	{
		if ( _spr != null )
			return _spr.count;
		return 0;
	}
	
	public static function sprite_get_xoffset( _spr )
	{
		if ( _spr != null )
			return _spr.x;
		return 0;
	}
	
	public static function sprite_get_yoffset( _spr )
	{
		if ( _spr != null )
			return _spr.y;
		return 0;
	}
	
	public static function sprite_create_from_surface( _surf, _x, _y, _w, _h, _removeback = false, _smooth = false, _xoff = 0, _yoff = 0 )
	{
		return;
		var spr = {};
		//var _spr = new GMSprite();
		_spr.width = _w;
		_spr.height = _h;
		_spr.x = _xoff;
		_spr.y = _yoff;
		
	}
	
	// Function_Texture
	
	public function draw_self()
	{
		var _inst = this;
		var spr = _inst.sprite_current;
		if ( spr == null )
			return;
		var _subimg = ( Math.floor( _inst.image_index ) % spr.count );
		if ( _subimg < 0 )
			_subimg += spr.count;
		spr.Draw( _subimg, _inst.x, _inst.y, _inst.image_xscale, _inst.image_yscale, _inst.image_angle, _inst.image_blend, _inst.image_alpha );
	}
	
	public function draw_sprite( _spr, _subimg, _x, _y )
	{
		var _inst = this;
		var spr = _spr;
		if ( spr == null )
			return;
		var _subimg = ( _subimg % spr.count );
		if ( _subimg < 0 )
			_subimg += spr.count;
		spr.DrawSimple( _subimg, _x, _y, GM.g_GlobalAlpha );
	}
	
	public function draw_sprite_ext( _spr, _subimg, _x, _y, _xscale = 1, _yscale = 1, _ang = 0, _col = 0xFFFFFF, _alpha = null )
	{
		var _inst = this;
		var spr = _spr;
		if ( spr == null )
			return;
		var _subimg = ( _subimg % spr.count );
		if ( _subimg < 0 )
			_subimg += spr.count;
		
		if ( _alpha == null )
			_alpha = GM.g_GlobalAlpha;
		spr.Draw( _subimg, _x, _y, _xscale, _yscale, _ang, _col, _alpha );
	}
	
	public function draw_sprite_pos( _spr, _subimg, _x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4, _alpha = null )
	{
		// return GM.InternalSpriteDrawPos( _spr, _subimg, _x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4, _alpha );
		var _inst = this;
		var spr = _spr;
		if ( spr == null )
			return;
		var _subimg = ( _inst.image_index % spr.count );
		if ( _subimg < 0 )
			_subimg += spr.count;
		spr.DrawSimplePos( _subimg, _x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4, _alpha );
	}
	
	public function draw_sprite_part_ext( _spr, _subimg, _left, _top, _width, _height, _x, _y, _xscale = 1, _yscale = 1, _col = 0xFFFFFF, _alpha = null )
	{
		if ( _alpha == null )
			_alpha = GM.g_GlobalAlpha;
	}
	
	
	// yyInstance
	
	public function set sprite_index( _ref )
	{
		// sprite_current = _ref;
		sprite_set( _ref );
	}
	
	public function get sprite_index()
	{
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
	
	// yyIOManager
	
	public function get mouse_x()
	{
		var _xx = mouseX;
		
		return _xx;
	}
	
	public function get mouse_y()
	{
		var _yy = mouseY;
		
		return _yy;
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
		GM.InternalSetDrawTarget( _surf );
	}
	
	public static function surface_reset_target()
	{
		GM.InternalSetDrawTarget( GM.container );
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
	
	public function is_array( val )
	{
		return ( val && ( val.constructor == Array ) );
	}
	
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
	
	public static function sign( val )
	{
		if ( val == 0 )
			return 0;
		else
			return ( val > 0 ) ? 1 : -1;
	}
	
	public static function sqr( val )
	{
		return val * val;
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
	// OLD. assets are now added to "global", eg: global.sprite_name
	public static function sprite_get( sprite_name )
	{
		return GM.InternalSpriteGet( sprite_name );
	}
	
	// Draw
	
	public static function gpu_set_blendmode( _bm )
	{
		GM.internalblendmode = _bm;
	}
	
	public static function gpu_set_fog( on, col = c_white, _start = 0, _end = 0 )
	{
		if ( on )
			GM.internalfog = col;
		else
			GM.internalfog = null;
	}
	
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
	
	public function draw_clear_alpha( col, a )
	{
		GM.internalrendertarget.graphics.clear();
		if ( a > 0 )
		{
			
		}
	}
	
	public static function draw_set_alpha( alpha )
	{
		GM.g_GlobalAlpha = alpha;
		//return GM.InternalSetAlpha( alpha );
	}
	
	public static function draw_get_alpha()
	{
		return GM.g_GlobalAlpha;
	}
	
	public static function draw_set_color( col )
	{
		GM.internaldrawcolor = col;
		//return GM.InternalSetColor( col );
	}
	
	public static function draw_get_color()
	{
		return GM.internaldrawcolor;
	}
	
	public static function draw_line_width( x1, y1, x2, y2, w = 1, a = null )
	{
		return GM.InternalDrawLine( x1, y1, x2, y2, w, a );
	}
	
	public static function draw_rectangle( x1, y1, x2, y2, outline = false )
	{
		return GM.InternalDrawRectangle( x1, y1, x2, y2, outline );
	}
	
	// Text
	
	public static function draw_set_font( _fnt )
	{
		GM.internaldrawfont = _fnt;
	}
	
	public static function draw_set_halign( _h = fa_left )
	{
		GM.internaldrawhalign = _h;
	}
	public static function draw_set_valign( _v = fa_top )
	{
		GM.internaldrawvalign = _v;
	}
	
	public function draw_text_transformed( _x, _y, _text, _xscale = 1, _yscale = 1, _angle = 0 )
	{
		GM.InternalTextDraw( _x, _y, _text, _xscale, _yscale, _angle );
		return;
	}
	
	
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



