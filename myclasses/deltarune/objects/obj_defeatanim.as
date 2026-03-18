package deltarune.objects
{

import deltarune.*;
import gamemaker.*;

public class obj_defeatanim extends DeltaruneObject
{
	public static const DEFEAT_IMAGE_COUNT = 80;
	public var t = 0;
	public var g = 0;
	public var starcount = 0;
	public var redup = 0;
	public var bsize = 6;
	public var xsign = 1;
	
	public function obj_defeatanim()
	{
		super();
		image_speed = 0;
	}
	
	override public function Create()
	{
		snd_stop( global.snd_defeatrun );
		snd_play( global.snd_defeatrun );
	}
	
	override public function Step()
	{
		if ( g == 0 )
		{
			xsign = sign( image_xscale );
		}
		g += 1;
		if ( g >= 15 )
			t += 1;
		if ( t > 15 )
			instance_destroy();
	}
	
	override public function Draw()
	{
		var i;
		if ( t == 0 )
			draw_self();
		
		if ( g <= 5 || ( g >= 9 && g <= 15 ) )
			draw_sprite_ext( global.spr_defeatsweat, 0, x - 6, y - 6, xsign, 1 );
		
		if ( t >= 1 )
		{
			for ( i = 0; i <= DEFEAT_IMAGE_COUNT; i += 1 )
			{
				draw_sprite_ext(
					sprite_current, image_index,
					x + ( 4 * xsign * i ), y,
					image_xscale, image_yscale,
					image_angle, image_blend, ( alpha - ( t / 8 ) + ( i / 200 ) )
				);
			}
		}
	}
}


}