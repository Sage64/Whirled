package deltarune.objects
{

import deltarune.*;
import gamemaker.*;

public class obj_spareanim extends DeltaruneObject
{
	public var t = 0;
	public var starcount = 0;
	public var afterimage = 0;
	public var tone = 0;
	public var neotone = 0;
	public var special = 0;
	public var star = [];
	
	public var xsign = 1;
	
	public function obj_spareanim()
	{
		image_speed = 0;
	}
	
	override public function Create()
	{
		snd_stop( global.snd_spare );
		snd_play( global.snd_spare );
	}
	
	override public function Step()
	{
		// sprite_update();
		// var sprite_xoffset = sprite_get_xoffset( sprite_current ) * image_xscale;
		// var sprite_yoffset = sprite_get_yoffset( sprite_current ) * image_yscale;
		// var sprite_width = sprite_get_width( sprite_current ) * image_xscale;
		// var sprite_height = sprite_get_height( sprite_current ) * image_yscale;
		
		xsign = sign( image_xscale );
		
		var i = 0;
		var xx = -sprite_xoffset;
		var yy = -sprite_yoffset;
		
		if ( t >= 1 && t <= 5 )
		{
			for ( i = 0; i < 2; ++i )
			{
				var inst = instance_create( x + xx + random( sprite_width ), y + yy + random( sprite_height ), obj_marker );
				star[starcount++] = inst;
				with ( inst )
				{
					image_xscale = 2;
					image_yscale = 2;
					sprite_set( global.spr_sparestar_anim );
					image_alpha = 2;
					image_speed = 0.25;
					hspeed = -3 * xsign;
					gravity = 0.5;
					gravity_direction = xsign > 0 ? 0 : 180;
				}
			}
		}
		
		if ( t >= 5 && t <= 30 )
		{
			for ( i = 0; i < starcount; ++i )
			{
				if ( !i_ex( star[i] ) )
					continue;
				star[i].image_angle += 10;
				star[i].image_alpha -= 0.1;
				if ( star[i].image_alpha <= 0 )
					instance_destroy( star[i] );
			}
		}
		if ( t >= 5 && t <= 30 )
			tone += 1;
		if ( t >= 9 )
		{
			neotone += 1;
			if ( neotone >= 30 )
			{
				for ( i = 0; i < starcount; ++i )
				{
					instance_destroy( star[i] );
				}
			}
		}
		t += 1;
	}
	
	override public function Draw()
	{
		if (t >= 6 && t <= 26)
		{
			afterimage += 1;
			gpu_set_fog( true, c_white, 0, 1) ;
			draw_sprite_ext( sprite_current, image_index, x + (afterimage * 4 * xsign), y, image_xscale, image_yscale, 0, image_blend, 0.7 - (afterimage / 25));
			draw_sprite_ext( sprite_current, image_index, x + (afterimage * 8 * xsign), y, image_xscale, image_yscale, 0, image_blend, 0.4 - (afterimage / 30));
			gpu_set_fog( false, c_black, 0, 0 );
		}
		if (t < 6)
		{
			if (t < 5)
				draw_sprite_ext( sprite_current, image_index, x, y, image_xscale, image_yscale, 0, image_blend, 1 - (neotone / 4));
			gpu_set_fog( true, c_white, 0, 1 );
			var maxwhite = t / 5;
			if (maxwhite > 1)
				maxwhite = 1;
			draw_sprite_ext( sprite_current, image_index, x, y, image_xscale, image_yscale, 0, image_blend, maxwhite - (tone / 5));
			gpu_set_fog( false, c_black, 0, 0 );
		}

	}
}


}