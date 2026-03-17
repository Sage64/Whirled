package deltarune.objects
{

import deltarune.*;
import gamemaker.*;

public class obj_deathanim extends DeltaruneObject
{
	public var t = 0;
	public var starcount = 0;
	public var redup = 0;
	public var bsize = 6;
	
	public var truew;
	public var trueh;
	public var imgx;
	public var imgy;
	public var xs;
	public var ys;
	public var acc = 1;
	
	public var bl = [];
	public var bh = [];
	public var bx = [];
	public var bspeed = [];
	public var bsin = [];
	
	public function obj_deathanim()
	{
		super();
		image_speed = 0;
	}
	
	override public function Create()
	{
		snd_play( global.snd_deathnoise );
	}
	
	override public function Step()
	{
		var i,j;
		if ( t== 0 )
		{
			truew = sprite_get_width( sprite_current );
			trueh = sprite_get_width( sprite_current );
			imgx = image_xscale;
			imgy = image_yscale;
			if ( truew >= 50 || trueh >= 50 )
				bsize = 8;
			if ( truew >= 100 || truew >= 100 )
				bsize = 16;
			xs = ceil( truew / bsize );
			ys = ceil( trueh / bsize );
			
			for ( i = 0; i <= xs; ++i )
			{
				bl[i] = [];
				bh[i] = [];
				bx[i] = [];
				bspeed[i] = [];
				bsin[i] = [];
				for ( j = 0; j <= ys; ++j )
				{
					bl[i][j] = i * bsize;
					bh[i][j] = j * bsize;
					bx[i][j] = x + ( i * bsize * imgx );
					bspeed[i][j] = 0;
					bsin[i][j] = ( 4 + ( j * 3 ) ) - i;
				}
			}
		}
		else
		{
			if ( bspeed[0][ys] >= 12 )
        		instance_destroy();
			
			if ( redup < 10 )
				redup += 1;
			image_blend = merge_color( c_white, c_red, redup / 10 );
			for ( i = 0; i <= xs; ++i )
			{
				for ( j = 0; j <= ys; ++j )
				{
					if ( bsin[i][j] <= 0 )
						bspeed[i][j] += acc;
					bx[i][j] += bspeed[i][j];
					bsin[i][j] -= 1;
				}
			}
		}
		t += 1;
	}
	
	override public function Draw()
	{
		if ( t == 0 )
		{
			draw_self();
			return;
		}
		var i,j;
		for ( i = 0; i <= xs; i += 1 )
		{
			for ( j = 0; j <= ys; j += 1 )
			{
				draw_sprite_part_ext(
					sprite_current, image_index,
					bl[i][j], bh[i][j],
					bsize, bsize,
					bx[i][j], y + ( j * bsize * imgy ),
					imgx, imgy,
					image_blend, 1 - ( bspeed[i][j] / 12 )
				);
			}
		}
	}
}


}