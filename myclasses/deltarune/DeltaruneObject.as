


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
	
	public function scr_lerpvar_instance( ...argument )
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
	
	public function i_ex( inst )
	{
		return instance_exists( inst );
	}
	
	public function scr_even( val )
	{
		return round( val / 2 ) * 2;
	}
	
	public function snd_play( _sound )
	{
		return audio_play_sound( _sound  );
	}
	
	public function snd_pitch( _sound, _pitch = 1 )
	{
		
		return null;
	}
	
}


}