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
	public var xsign = 1;
	
	public function obj_deathanim()
	{
		super();
		image_speed = 0;
	}
	
	override public function Create()
	{
		snd_stop( global.snd_deathnoise );
		snd_play( global.snd_deathnoise );
	}
	
	override public function Step()
	{
		var sprite_index = sprite_current;
		var i,j;
		if ( t == 0 )
		{
			if ( image_xscale < 0 )
				xsign = -1;
			x -= sprite_get_xoffset( sprite_index ) * image_xscale;
			y -= sprite_get_yoffset( sprite_index ) * image_yscale;
			truew = sprite_get_width(sprite_index);
			trueh = sprite_get_height(sprite_index);
			imgx = image_xscale;
			imgy = image_yscale;
			if ( truew >= 100 || truew >= 100 )
				bsize = 16;
			else if ( truew >= 50 || trueh >= 50 )
				bsize = 8;
			xs = ceil(truew / bsize);
			ys = ceil(trueh / bsize);
			for (i = 0; i <= xs; i += 1)
			{
				bl[i] = new Array( ys );
				bh[i] = new Array( ys );
				bx[i] = new Array( ys );
				bspeed[i] = new Array( ys );
				bsin[i] = new Array( ys );
				for (j = 0; j <= ys; j += 1)
				{
					bl[i][j] = i * bsize;
					bh[i][j] = j * bsize;
					bx[i][j] = x + (i * bsize * imgx);
					bspeed[i][j] = 0;
					bsin[i][j] = (4 + (j * 3)) - i;
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
						bspeed[i][j] += 1;
					bx[i][j] += ( bspeed[i][j] * xsign );
					bsin[i][j] -= 1;
					
					var _y = y + (j * bsize * imgy);
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
		//var sprite_index = sprite_current;
		for ( i = 0; i <= xs; i += 1 )
		{
			for ( j = 0; j <= ys; j += 1 )
			{
				draw_sprite_part_ext(sprite_index, image_index, bl[i][j], bh[i][j], bsize, bsize, bx[i][j], y + (j * bsize * imgy), imgx, imgy, image_blend, 1 - (bspeed[i][j] / 12));
			}
		}
	}
}


}