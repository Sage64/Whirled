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
		var i = 0;
		
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
			draw_sprite_ext( sprite_current, image_index, x + (afterimage * 4), y, image_xscale, image_yscale, 0, image_blend, 0.7 - (afterimage / 25));
			draw_sprite_ext( sprite_current, image_index, x + (afterimage * 8), y, image_xscale, image_yscale, 0, image_blend, 0.4 - (afterimage / 30));
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