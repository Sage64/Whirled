package deltarune.objects
{

import gamemaker.*;

import deltarune.*;

public class obj_hallway_mirror extends DeltaruneObject
{
	public var cursor = {};
	public var shadows = [];
	
	public function obj_hallway_mirror()
	{
		GM.AddSprites( sprites_kris_lw );
		cursor.x = 0;
		cursor.y = 0;
		cursor.z = 0;
		cursor.orient = 180;
		
		sprite_index = global.spr_torhouse_mirror;
	}
	
	override public function Step()
	{
		shadows = [];
		var i = 0;
		shadows[i++] = cursor;
		cursor.x = mouse_x * 3;
		cursor.z = ( 240 - mouse_y ) * 3;
		
		for each ( var Entity in GMControl.remoteEntitiesList )
		{
			if ( Entity && Entity.GetPosition() )
			{
				shadows[i++] = Entity;
			}
		};
		if ( i == 1 )
			shadows[i++] = { x: mouse_x * 3, z: ( 240 - mouse_y ) * 3 };
		shadows.sort( function( A, B )
		{
			if ( B && A )
				return ( A.z - B.z );
		})
		shadows[i] = null;
	}
	
	
	override public function Draw()
	{
		draw_self();
		
		for each ( var Shadow in shadows )
		{
			if ( !Shadow )
				break;
			try
			{
				DrawReflection( Shadow );
			}
			catch(e)
			{
				// GM.Caught(e);
				DrawPlaceholder( Shadow );
			}
		}
		draw_set_color( c_white );
		draw_set_alpha( 0.1 );
		draw_rectangle( x, y, x + sprite_width, y + sprite_height, false );
		draw_set_alpha( 1 );
	}
	
	public function DrawReflection( Shadow )
	{
		var xx = Shadow.x / 3;
		var yy = ( 192 + 38 + 29 ) - ( 240 - ( Shadow.z / 3 ) );
		var direction = ( 90 - Shadow.orient );
		xx = ( xx );
		yy = ( yy );
		if ( Shadow == cursor )
		{
			// mouse
			draw_set_color( c_white );
			draw_set_alpha( 0.5 );
			draw_rectangle( xx - 3.5, yy - 1.5, xx + 3.5, yy + 1.5 );
			draw_set_color( c_black );
			draw_rectangle( xx - 2.5, yy - 1, xx + 2.5, yy + 1 );
			draw_set_alpha( 1 );
		}
		else if ( direction == 0 || direction )
		{
			try
			{
				var isgm = Shadow.GetProperty( "gm" )
				var isdeltarune = Shadow.GetProperty( "deltarune" );
				var character = Shadow.GetProperty( "gm:character" );
				if ( isdeltarune ) // if deltarune
				{
					var _body = Shadow.GetProperty( "gm:body" );
					var spr;
					var image = 0;
					var offset_x = 0;
					var offset_y = 0;
					var feet_y = 1;
					var sprites = [ global.spr_krisu, global.spr_krisl, global.spr_krisd, global.spr_krisr ];
					var nothing = Shadow.GetProperty( "subimage" );
					if ( !image )
						image = 0;
					var facing = ( ( Math.round( ( ( 360 + 90 ) - direction ) / 90 ) ) % 4 );
					spr = sprites[2];
					var xscale = 1;
					var yscale = 1;
					offset_x = ( sprite_get_width( spr ) / 2 );
					offset_y = ( sprite_get_height( spr ) - sprite_get_yoffset( spr ) );
					
					if ( _body )
					{
						var leader = variable_instance_get( _body, "leader" );
						if ( instance_exists( leader ) )
						{
							var gm = variable_instance_get( _body, "gm" );
							if ( gm )
							{
								var remtarget = gm.internalrendertarget;
								var remspr = leader.sprite_index;
								var remx = leader.x;
								var remy = leader.y;
								var remxsc = leader.image_xscale;
								var remysc = leader.image_yscale;
								var remdir;
								var remfacing = leader.facing;
								gm.InternalSetDrawTarget( GM.container );
								// 
								leader.sprite_index = remspr;
								leader.x = xx;
								leader.y = yy;
								if ( leader.darkmode )
								{
									leader.image_xscale *= 0.5;
									leader.image_yscale *= 0.5;
								}
								var flip = 1;
								if ( leader.fun == 0 )
								{
									if ( leader.facing == 0 )
									{
										leader.facing = 2;
										if ( leader.dsprite != leader.usprite )
											flip = -1;
									}
									else if ( leader.facing == 2 )
									{
										leader.facing = 0;
										if ( leader.dsprite != leader.usprite )
											flip = -1;
									}
									else if ( leader.facing == 1 )
									{
										leader.facing = 3;
										if ( leader.lsprite != leader.rsprite )
											flip = -1;
									}
									else if ( leader.facing == 3 )
									{
										leader.facing = 1;
										if ( leader.lsprite != leader.rsprite )
											flip = -1;
									}
								}
								leader.GetFacingSprite();
								leader.image_xscale *= flip;
								leader.Draw();
								// 
								leader.sprite_index = remspr;
								leader.x = remx;
								leader.y = remy;
								leader.facing = remfacing;
								leader.image_xscale = remxsc;
								leader.image_yscale = remysc;
								gm.InternalSetDrawTarget( remtarget );
							}
							else
							{
								facing = leader.facing;
								sprites[0] = sprite_verify( leader.usprite );
								sprites[1] = sprite_verify( leader.lsprite );
								sprites[2] = sprite_verify( leader.dsprite );
								sprites[3] = sprite_verify( leader.rsprite );
								image = leader.image_index;
								offset_x = leader.offset_x;
								offset_y = leader.offset_y;
								feet_y = leader.feet_y;
								spr = sprites[facing];
								xscale *= -1;
								draw_sprite_ext( spr, image, xx - ( offset_x * xscale ), yy - ( ( offset_y - feet_y ) * yscale ), xscale, yscale, 0, c_white, 1 );
							}
						}
					}
					else
					{
						spr = sprites[facing];
						xscale *= -1;
						draw_sprite_ext( spr, image, xx - ( offset_x * xscale ), yy - ( ( offset_y - feet_y ) * yscale ), xscale, yscale, 0, c_white, 1 );
					}
				}
				else
				{
					// placeholder generic shadow
					draw_set_color( c_black );
					draw_set_alpha( 0.35 );
					draw_rectangle( xx - 8, yy - 2, xx + 8, yy + 2, 0 );
					draw_set_alpha( 1 );
				}
			}
			catch(e)
			{
				GM.Caught(e);
			}
			draw_set_alpha( 1 );
		}
	}
	
	public function DrawPlaceholder( Shadow )
	{
	
	}
}


}