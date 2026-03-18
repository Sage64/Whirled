


package deltarune
{

import gamemaker.*;
import deltarune.objects.*;

public class DeltaruneObject extends GMObject
{    
	
	
	public function DeltaruneObject()
	{
		super();
		
	}
	
	
	// Delayed script
	
	public function scr_script_delayed( ...argument )
	{
		var argument_count = argument.length;
		var __scriptdelay = instance_create(0, 0, obj_script_delayed);
		__scriptdelay.script = argument[0];
		__scriptdelay.alarm[0] = argument[1];
		__scriptdelay.target = id;
		for (var __i = 0; __i < (argument_count - 2); __i++)
			__scriptdelay.script_arg[__i] = argument[__i + 2];
		__scriptdelay.arg_count = argument_count - 2;
		return __scriptdelay;
	}
	
	public function scr_var_delay(arg0, arg1, arg2)
	{
		scr_script_delayed( scr_var, arg2, arg0, arg1 );
	}
	public const scr_var_delayed = scr_var_delay;
	public const scr_delay_var = scr_var_delay;
	
	public function scr_var( varname, val )
	{
		this[varname] = val;
	}
	
	public function scr_lerpvar( ...argument )
	{
		var argument_count = argument.length;
		var ___lerpvar;
		if (argument_count < 6)
			___lerpvar = scr_lerpvar_instance(id, argument[0], argument[1], argument[2], argument[3]);
		else
			___lerpvar = scr_lerpvar_instance(id, argument[0], argument[1], argument[2], argument[3], argument[4], argument[5]);
		return ___lerpvar;
	}
	
	public static function scr_lerpvar_instance( ...argument )
	{
		var argument_count = argument.length;
		var __lerpvar = instance_create( 0, 0, obj_lerpvar );
		__lerpvar.target = argument[0];
		__lerpvar.varname = argument[1];
		__lerpvar.pointa = argument[2];
		__lerpvar.pointb = argument[3];
		__lerpvar.maxtime = argument[4];
		if (argument_count >= 6)
			__lerpvar.easetype = argument[5];
		if (argument_count >= 7)
			__lerpvar.easeinout = argument[6];
		return __lerpvar;
	}
	
	public const scr_lerpvar_respect = scr_lerpvar;
	
	// Lerp Easing
	
	// In
	public function lerp_ease_in(arg0, arg1, arg2, arg3)
	{
		return lerp(arg0, arg1, scr_ease_in(arg2, arg3));
	}

	public function scr_ease_in(arg0, arg1)
	{
		if (arg1 < -3 || arg1 > 7)
			return arg0;
		
		switch (arg1)
		{
			case -3:
				return ease_in_bounce(arg0, 0, 1, 1);
			case -2:
				return ease_in_elastic(arg0, 0, 1, 1);
			case -1:
				var _s = 1.70158;
				return arg0 * arg0 * (((_s + 1) * arg0) - _s);
			case 0:
				return arg0;
			case 1:
				return -cos(arg0 * 1.5707963267948966) + 1;
			case 6:
				return power(2, 10 * (arg0 - 1));
			case 7:
				return -(sqrt(1 - sqr(arg0)) - 1);
			default:
				return power(arg0, arg1);
		}
	}

	public function ease_in_bounce(arg0, arg1, arg2, arg3)
	{
		return (arg2 - ease_out_bounce(arg3 - arg0, 0, arg2, arg3)) + arg1;
	}

	public function ease_in_elastic(arg0, arg1, arg2, arg3)
	{
		var _s = 1.70158;
		var _p = 0;
		var _a = arg2;
		if (arg0 == 0 || _a == 0)
			return arg1;
		arg0 /= arg3;
		if (arg0 == 1)
			return arg1 + arg2;
		if (_p == 0)
			_p = arg3 * 0.3;
		if (_a < abs(arg2))
		{
			_a = arg2;
			_s = _p * 0.25;
		}
		else
			_s = (_p / (2 * pi)) * arcsin(arg2 / _a);
		return -(_a * power(2, 10 * --arg0) * sin((((arg0 * arg3) - _s) * (2 * pi)) / _p)) + arg1;
	}

	// Out
	public function lerp_ease_out(arg0, arg1, arg2, arg3)
	{
		return lerp(arg0, arg1, scr_ease_out(arg2, arg3));
	}

	public function scr_ease_out(arg0, arg1)
	{
		if (arg1 < -3 || arg1 > 7)
			return arg0;
		switch (arg1)
		{
			case -3:
				return ease_out_bounce(arg0, 0, 1, 1);
			case -2:
				return ease_out_elastic(arg0, 0, 1, 1);
			case -1:
				return ease_out_back(arg0, 0, 1, 1);
			case 0:
				return arg0;
			case 1:
				return sin(arg0 * 1.5707963267948966);
			case 2:
				return -arg0 * (arg0 - 2);
			case 6:
				return -power(2, -10 * arg0) + 1;
			case 7:
				arg0--;
				return sqrt(1 - (arg0 * arg0));
			default:
				arg0--;
				
				if (arg1 == 4)
				{
					return -1 * (power(arg0, arg1) - 1);
					break;
				}
				
				return power(arg0, arg1) + 1;
		}
	}
	
	public function ease_out_bounce(arg0, arg1, arg2, arg3)
	{
		arg0 /= arg3;
		if (arg0 < 0.36363636363636365)
		{
			return (arg2 * (7.5625 * arg0 * arg0)) + arg1;
		}
		else if (arg0 < 0.7272727272727273)
		{
			arg0 -= 0.5454545454545454;
			return (arg2 * ((7.5625 * arg0 * arg0) + 0.75)) + arg1;
		}
		else if (arg0 < 0.9090909090909091)
		{
			arg0 -= 0.8181818181818182;
			return (arg2 * ((7.5625 * arg0 * arg0) + 0.9375)) + arg1;
		}
		else
		{
			arg0 -= 0.9545454545454546;
			return (arg2 * ((7.5625 * arg0 * arg0) + 0.984375)) + arg1;
		}
	}
	
	public function ease_out_elastic(arg0, arg1, arg2, arg3)
	{
		var _s = 1.70158;
		var _p = 0;
		var time = arg0;
		var start = arg1;
		var change = arg2;
		var duration = arg3;
		if (time == 0 || change == 0)
			return start;
		time /= duration;
		if (time == 1)
			return start + arg2;
		if (!_p)
			_p = duration * 0.3;
		if (change < abs(arg2))
		{
			change = arg2;
			_s = _p * 0.25;
		}
		else
			_s = (_p / (2 * pi)) * arcsin(arg2 / change);
		return (change * power(2, -10 * time) * sin((((time * duration) - _s) * (2 * pi)) / _p)) + arg2 + start;
	}

	public function ease_out_back(arg0, arg1, arg2, arg3)
	{
		var _s = 1.70158;
		arg0 = (arg0 / arg3) - 1;
		return (arg2 * ((arg0 * arg0 * (((_s + 1) * arg0) + _s)) + 1)) + arg1;
	}

	// Inout
	public function lerp_ease_inout(arg0, arg1, arg2, arg3)
	{
		return lerp(arg0, arg1, scr_ease_inout(arg2, arg3));
	}
	
	public function scr_ease_inout(arg0, arg1)
	{
		if (arg1 < -3 || arg1 > 7)
			return arg0;
		if (arg1 == -3)
			return ease_inout_bounce(arg0, 0, 1, 1);
		else if (arg1 == -2)
			return ease_inout_elastic(arg0, 0, 1, 1);
		else if (arg1 == -1)
			return ease_inout_back(arg0, 0, 1, 1);
		else if (arg1 == 1)
			return -0.5 * cos((pi * arg0) - 1);
		else if (arg1 == 0)
			return arg0;
		arg0 *= 2;
		if (arg0 < 1)
			return 0.5 * scr_ease_in(arg0, arg1);
		else
		{
			arg0--;
			return 0.5 * (scr_ease_out(arg0, arg1) + 1);
		}
	}

	
	public function ease_inout_bounce(arg0, arg1, arg2, arg3)
	{
		if (arg0 < (arg3 * 0.5))
			return (ease_in_bounce(arg0 * 2, 0, arg2, arg3) * 0.5) + arg1;
		return (ease_out_bounce((arg0 * 2) - arg3, 0, arg2, arg3) * 0.5) + (arg2 * 0.5) + arg1;
	}
	
	public function ease_inout_elastic(arg0, arg1, arg2, arg3)
	{
		var _s = 1.70158;
		var _p = 0;
		var _a = arg2;
		if (arg0 == 0 || _a == 0)
			return arg1;
		arg0 /= (arg3 * 0.5);
		if (arg0 == 2)
			return arg1 + arg2;
		if (!_p)
			_p = arg3 * 0.44999999999999996;
		if (_a < abs(arg2))
		{
			_a = arg2;
			_s = _p * 0.25;
		}
		else
			_s = (_p / (2 * pi)) * arcsin(arg2 / _a);
		if (arg0 < 1)
			return (-0.5 * (_a * power(2, 10 * --arg0) * sin((((arg0 * arg3) - _s) * (2 * pi)) / _p))) + arg1;
		return (_a * power(2, -10 * --arg0) * sin((((arg0 * arg3) - _s) * (2 * pi)) / _p) * 0.5) + arg2 + arg1;
	}
	
	public function ease_inout_back(arg0, arg1, arg2, arg3)
	{
		var _s = 1.70158;
		arg0 /= arg3;
		arg0 *= 2;
		if (arg0 < 1)
		{
			_s *= 1.525;
			return (arg2 * 0.5 * (arg0 * arg0 * (((_s + 1) * arg0) - _s))) + arg1;
		}
		arg0 -= 2;
		_s *= 1.525;
		return (arg2 * 0.5 * ((arg0 * arg0 * (((_s + 1) * arg0) + _s)) + 2)) + arg1;
	}
	
	public function i_ex( inst )
	{
		return instance_exists( inst );
	}
	
	public function scr_approach( a, b, amount )
	{
		if ( a < b )
		{
			a += amount;
			if ( a > b )
				return a;
		}
		else
		{
			a -= amount;
			if ( a < b )
				return b;
		}
		return a;
	}
	
	public function scr_depth()
	{
		depth = 100000 - y;
	}
	
	public function scr_doom( inst, time = 1 )
	{
		if ( !instance_exists( inst ) )
			return;
		var _doom = instance_create( 0, 0, obj_doom );
		_doom.time = time;
		_doom.target = inst;
	}
	
	public function scr_even( val )
	{
		return round( val / 2 ) * 2;
	}
	
	public function scr_marker_ext( xx, yy, _sprite, _xscale = 1, _yscale = 1, _imgspd = 0, _image = 0, _blend = 0xFFFFFF, _depth = 0, _depthalt = false, _doom = -1, _alpha = 1 )
	{
		var marker = instance_create( xx, yy, DeltaruneObject );
		//
		marker.depth = _depth;
		marker.sprite_set( _sprite );
		marker.image_xscale = _xscale;
		marker.image_yscale = _yscale;
		marker.image_speed = _imgspd;
		marker.image_index = _image;
		marker.image_blend = _blend;
		marker.image_alpha = _alpha;
		//
		if ( _doom > 0 )
		{
			
		}
		//
		return marker;
	}
	
	public function draw_sprite_ext_centerscale(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
	{
		var _xoff = sprite_get_xoffset(arg0) * image_xscale;
		var _yoff = sprite_get_yoffset(arg0) * image_yscale;
		var _sprite_width = sprite_get_width(arg0) * image_xscale;
		var _sprite_height = sprite_get_width(arg0) * image_yscale;
		draw_sprite_ext(arg0, arg1, arg2 - (((_sprite_width - _xoff) * (arg4 - image_xscale)) / 2), arg3 - (((_sprite_height - _yoff) * (arg5 - image_yscale)) / 2), arg4, arg5, arg6, arg7, arg8);
	}
	
	public function scr_draw_outline_ext(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
	{
		gpu_set_fog( true, arg7, 0, 0 );
		var __xdirA = arg9;
		var __xdirB = 0;
		var __ydirA = 0;
		var __ydirB = arg9;
		if ( ( arg6 % 90 ) != 0 )
		{
			__xdirA = lengthdir_x( arg9, arg6 );
			__xdirB = lengthdir_x( arg9, arg6 + 90 );
			__ydirA = lengthdir_y( arg9, arg6 + 90 );
			__ydirB = lengthdir_y( arg9, arg6 );
		}
		draw_sprite_ext( arg0, arg1, arg2 + __xdirA, arg3 + __ydirA, arg4, arg5, arg6, c_white, arg8 );
		draw_sprite_ext( arg0, arg1, arg2 - __xdirA, arg3 - __ydirA, arg4, arg5, arg6, c_white, arg8 );
		draw_sprite_ext( arg0, arg1, arg2 + __xdirB, arg3 + __ydirB, arg4, arg5, arg6, c_white, arg8 );
		draw_sprite_ext( arg0, arg1, arg2 - __xdirB, arg3 - __ydirB, arg4, arg5, arg6, c_white, arg8 );
		gpu_set_fog( false, c_white, 0, 0 );
	}

	
	public function scr_draw_chaseaura( sprite_index, walk_index, x, y )
    {
		var sprite_width = abs( sprite_get_width( sprite_index ) * image_xscale );
		var sprite_height = ( sprite_get_height( sprite_index ) * image_yscale );
		
		//
		var facing = ( image_xscale < 0 ? 1 : 0 );
		var drawsiner = ( current_time / 1000 ) * 30 * 0.25;
		//
		var i;
		var _xx;
		var _yy;
		var _xscale;
		var _yscale;
		// 
		
		
		var drawx = 0;
		var drawscale = 1;
		
		var superscalex = 0;
		var superdrawx = 0;
		var superscalexb = 1;
		
		if ( facing == 1 )
		{
			drawscale = -1;
			//drawx = sprite_width;
			superscalex = -4;
			superscalexb = -1;
			//superdrawx = -( sprite_width ) * 2;
		}
		
		x += drawx;
		
		if ( true )
		{
			gpu_set_blendmode( bm_add );
			for ( i = 0; i < 5; i++ )
			{
				var aura = ( i * 9 ) + ( ( drawsiner * 3 ) % 9 );
				var aurax = ( aura * 0.75 ) + ( sin( aura / 4 ) * 4 );
				var auray = 45 * scr_ease_in( aura / 45, 1 );
				var aurayscale = min( 80 / sprite_height, 1 );
				_xx = x - ( ( aurax / 180 ) * drawscale * ( sprite_width ) );
				_yy = y - ( ( auray / 82)  * sprite_height * aurayscale );
				_xscale = ( abs( image_xscale ) + ( aurax / 36 ) ) * drawscale;
				_yscale = image_yscale + ( ( auray / 36 ) * aurayscale );
				var _alpha = image_alpha * ( 1 - ( auray / 45) ) * 0.5;
				draw_sprite_ext( sprite_index, walk_index, _xx, _yy, _xscale, _yscale, image_angle, c_red, _alpha );
			}
			gpu_set_blendmode( bm_normal );
		}
		if ( true )
		{
			var xmult = min((70 / ( sprite_width )) * 4, 4);
			var ymult = min((80 / sprite_height) * 5, 5);
			var ysmult = min((80 / sprite_height) * 0.2, 0.2);
			_xx = x + superdrawx + ( sin( drawsiner / 5 ) * xmult );
			_yy = y + ( cos( drawsiner / 5 ) * ymult );
			draw_sprite_ext_centerscale(
				sprite_index,
				walk_index,
				_xx, _yy,
				abs( image_xscale ) + superscalex,
				image_yscale + (sin(drawsiner / 5) * ysmult),
				image_angle, c_red, image_alpha * 0.2
			);
			_xx = (x + superdrawx) - (sin(drawsiner / 5) * xmult)
			_yy = y - ( cos( drawsiner / 5 ) * ymult )
			draw_sprite_ext_centerscale(
				sprite_index, walk_index,
				_xx, _yy,
				abs( image_xscale ) + superscalex,
				image_yscale - (sin(drawsiner / 5) * ysmult), 
				image_angle, c_red, image_alpha * 0.2
			);
		}
		scr_draw_outline_ext( sprite_index, walk_index, x, y, image_xscale * 1, image_yscale, image_angle, c_red, image_alpha * 0.3, 2 );
	}
	
	public static function snd_play( _sound )
	{
		return GMObject.audio_play_sound( _sound  );
	}
	
	public static function snd_stop( _sound )
	{
		return GMObject.audio_stop_sound( _sound );
	}
	
	public static function snd_pitch( _sound, _pitch = 1 )
	{
		
		return null;
	}
	
}


}