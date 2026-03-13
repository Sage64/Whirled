
package deltarune

{

import gamemaker.*;

import flash.display.*;
import flash.events.*;
import flash.utils.*;

import com.threerings.util.*
import com.whirled.*

public class MikeBody extends MonsterBody
{
	public var spr_blush = sprite_get( "spr_blush" );
	public var spr_mic_2x = sprite_get( "spr_mic_2x" );
	public var spr_mike_big = sprite_get( "spr_mike_big" );
	public var spr_mike_m = sprite_get( "spr_mike_m" );
	public var spr_mike_m_sad = sprite_get( "spr_mike_m_sad" );
	public var spr_mike_med = spr_mike_m;
	public var spr_mike_s_mic_up = sprite_get( "spr_mike_s_mic_up" );
	public var spr_mike_s_point_down = sprite_get( "spr_mike_s_point_down" );
	public var spr_mike_s_pointing_aggressive = sprite_get( "spr_mike_s_pointing_aggressive" );
	public var spr_mike_small = sprite_get( "spr_mike_small" );
	
	public var mic_timer = 0;
	public var mic_x = 0;
	public var mic_y = 0;
	
	public var mike_s;
	public var mike_m;
	public var mike_b;
	public var mic;
	
	public var inst;
	
	public function MikeBody()
	{
		use_damage = false;
		use_mercy = false;
		
		super();
		
		mystates["battat"] = DWState( "-BATTAT-", spr_mike_small );
		mystates["battat_mikeup"] = DWState( "Mic up", spr_mike_s_mic_up );
		mystates["battat_pointdown"] = DWState( "Point down", spr_mike_s_point_down );
		mystates["batatt_point_l"] = DWState( "Point left", spr_mike_s_pointing_aggressive );
		mystates["batatt_point_r"] = DWState( "Point right", spr_mike_s_pointing_aggressive );
		
		mystates["pluey"] = DWState( "-PLUEY-", spr_mike_m );
		mystates["pluey_sad"] = DWState( ":-(", spr_mike_m_sad );
		
		mystates["jongler"] = DWState( "-JONGLER-", spr_mike_big );
		
		mystates["trio"] = DWState( "-THE BOYS-", spr_mike_small );
		
		mystates["mic"] = DWState( "-Mic-", spr_mic_2x );
		
	}
	
	override public function DoBodyDebug()
	{
		SetState( mystates["batatt_point_l"] );
	}
	
	
	override public function OnStateChanged()
	{
		super.OnStateChanged();
		
		sprite_set( -1 );
		
		var spr;
		if ( curState )
			spr = curState.sprite;
		
		image_speed = 0;
		image_alpha = 1;
		
		x = originX;
		y = originY;
		
		characterH = 88 * 2;
		
		if ( curState == mystates["mic"] )
		{
			
			mic_timer = 0;
			characterH = 80 * 2;
			mic = instance_create( x, y - 16, DeltaruneObject );
			
			mic.sprite_set( global.spr_mic_2x );
			mic.image_index = 0;
			mic.image_xscale = 2;
			mic.image_yscale = 2;
			mic.image_alpha = -1;
		}
		else if ( instance_exists( mic ) )
		{
			instance_destroy( mic );
			mic = null;
		}
		
		if ( curState == mystates["trio"] )
		{
			instance_destroy( inst );
			if ( !instance_exists( mike_s ) )
			{
				mike_s = instance_create( x, y, obj_mike );
				if ( instance_exists( inst ) )
					mike_s.image_alpha = inst.image_alpha;
				else
					mike_s.image_alpha = 0;
			}
			mike_s.sprite_set( global.spr_mike_small );
			mike_s.image_index = 0;
			mike_s.howtall = 46 * 2;
			mike_s.depth = -1;
			mike_s.scr_lerpvar( "x", mike_s.x, 0, 15, 2 );
			mike_s.scr_lerpvar( "y", mike_s.y, 4, 15, 2 );
			mike_s.scr_lerpvar( "image_alpha", mike_s.image_alpha, 1, 10, 2 );
			
			if ( !instance_exists( mike_m ) )
			{
				mike_m = instance_create( x - 256, y - 64, obj_mike );
				mike_m.image_alpha = 0;
			}
			mike_m.sprite_set( global.spr_mike_m );
			mike_m.image_index = 0;
			mike_m.image_speed = 0.25;
			mike_m.howtall = 60 * 2;
			mike_m.depth = 2;
			mike_m.scr_lerpvar( "x", mike_m.x, -50, 15, 2 );
			mike_m.scr_lerpvar( "y", mike_m.y, -8, 15, 2 );
			mike_m.scr_lerpvar( "image_alpha", mike_m.image_alpha, 1, 10, 2 );
			
			if ( !instance_exists( mike_b ) )
			{
				mike_b = instance_create( x + 256, y - 64, obj_mike );
				mike_b.image_alpha = 0;
			}
			mike_b.sprite_set( global.spr_mike_big );
			mike_b.image_index = 0;
			mike_b.howtall = 88 * 2;
			mike_b.depth = 1;
			mike_b.scr_lerpvar( "x", mike_b.x, 50, 15, 2 );
			mike_b.scr_lerpvar( "y", mike_b.y, -8, 15, 2 );
			mike_b.scr_lerpvar( "image_alpha", mike_b.image_alpha, 1, 10, 2 );
		}
		else
		{
			var mike;
			var doomed;
			
			// Pluey
			if ( spr == spr_mike_m || spr == spr_mike_m_sad )
			{
				if ( !instance_exists( mike_m ) )
				{
					mike_m = instance_create( x - 128, y, obj_mike );
					mike_m.image_alpha = 0;
				}
				mike = mike_m;
				mike.sprite_set( spr );
				mike.image_speed = 0.25;
				mike.howtall = 60 * 2;
				mike.scr_lerpvar( "x", mike.x, 0, 15, 2 );
				mike.scr_lerpvar( "y", mike.y, 0, 15, 2 );
				mike.scr_lerpvar( "image_alpha", mike.image_alpha, 1, 10, 0 );
			}
			else if ( instance_exists( mike_m ) )
			{
				mike_m.scr_lerpvar( "x", mike_m.x, -128, 10, 0 );
				mike_m.scr_lerpvar( "y", mike_m.y, 0, 10, 0 );
				mike_m.scr_lerpvar( "image_alpha", mike_m.image_alpha, 0, 10, 0 );
				mike_m.scr_doom( mike_m, 10 );
				mike_m = null;
			}
			// Jongler
			if ( spr == spr_mike_big )
			{
				if ( !instance_exists( mike_b ) )
				{
					mike_b = instance_create( x + 128, y, obj_mike );
					mike_b.image_alpha = 0;
				}
				mike = mike_b;
				mike.sprite_set( spr );
				mike.image_index = 0;
				mike.howtall = 88 * 2;
				mike.scr_lerpvar( "x", mike.x, 0, 15, 2 );
				mike.scr_lerpvar( "y", mike.y, 0, 15, 2 );
				mike.scr_lerpvar( "image_alpha", mike.image_alpha, 1, 10, 0 );
			}
			else if ( instance_exists( mike_b ) )
			{
				mike_b.scr_lerpvar( "x", mike_b.x, 128, 10, 0 );
				mike_b.scr_lerpvar( "y", mike_b.y, 0, 10, 0 );
				mike_b.scr_lerpvar( "image_alpha", mike_b.image_alpha, 0, 10, 0 );
				mike_b.scr_doom( mike_b, 10 );
				mike_b = null;
			}
			
			// Battat
			if ( spr == spr_mike_small )
			{
				if ( !instance_exists( mike_s ) )
				{
					mike_s = instance_create( x, y, obj_mike );
					if ( instance_exists( inst ) )
						mike_s.image_alpha = inst.image_alpha;
					else
						mike_s.image_alpha = 0;
				}
				mike = mike_s;
				mike.sprite_set( spr );
				mike.image_index = 0;
				mike.howtall = 46 * 2;
				mike.scr_lerpvar( "x", mike.x, 0, 15, 2 );
				mike.scr_lerpvar( "y", mike.y, 0, 15, 2 );
				mike.scr_lerpvar( "image_alpha", mike.image_alpha, 1, 10, 0 );
			}
			else if ( instance_exists( mike_s ) )
			{
				mike_s.scr_lerpvar( "image_alpha", mike_s.image_alpha, 0, 10, 0 );
				mike_s.scr_doom( mike_s, 10 );
				doomed = mike_s;
				mike_s = null;
			}
			
			if ( mike || instance_exists( mic ) )
			{
				instance_destroy( inst );
			}
			else if ( spr )
			{
				if ( !instance_exists( inst ) )
				{
					inst = instance_create( x, y, DeltaruneObject );
					inst.image_alpha = 0;
				}
				inst.x = x;
				inst.y = y;
				inst.sprite_set( spr );
				inst.image_index = 0;
				inst.image_xscale = 2;
				inst.image_yscale = 2;
				
				characterH = 46 * 2;
				
				if ( !instance_exists( doomed ) )
					doomed = mike_s;
				if ( instance_exists( doomed ) )
				{
					inst.x = doomed.x;
					inst.y = doomed.y;
					inst.image_alpha = doomed.image_alpha;
					inst.image_xscale = doomed.image_xscale;
					inst.image_yscale = doomed.image_yscale;
					instance_destroy( doomed );
					
					inst.scr_lerpvar( "x", inst.x, 0, 15, 2 );
					inst.scr_lerpvar( "y", inst.y, 0, 15, 2 );
					inst.scr_lerpvar( "image_alpha", inst.image_alpha, 1, 15, 2 );
				}
				else
					inst.image_alpha = 1;
			}
		}
		
		
		SetViewOffset( 0, ( y - originY ) - 16 - ( 88 ) );
	}
	
	override public function OnUpdateLook()
	{
		super.OnUpdateLook();
		
		if ( instance_exists( mike_s ) )
		{
			if ( mike_s.sprite_current == spr_mike_s_point_down )
				mike_s.image_xscale = 2;
			else if ( mike_s.sprite_current == spr_mike_s_pointing_aggressive )
				mike_s.image_xscale = 2 * ( curState == mystates["point_l"] ? -1 : 1 );
			else
				mike_s.image_xscale = image_xscale;
		}
		if ( instance_exists( mike_m ) )
			mike_m.image_xscale = image_xscale;
		
		if ( instance_exists( mike_b ) )
			mike_b.image_xscale = image_xscale;
		
		if ( instance_exists( mic ) )
		{
			mic.image_xscale = image_xscale;
		}
		
		if ( instance_exists( inst ) )
		{
			if ( curState == mystates["batatt_point_l"] )
				inst.image_xscale = -2;
			else if ( curState == mystates["batatt_point_r"] )
				inst.image_xscale = 2;
			else
				inst.image_xscale = image_xscale;
		}
	}
	
	override public function OnSentChat( message )
	{
		var talker = null;
		if ( instance_exists( mike_s ) )
		{
			talker = mike_s;
		}
		else if ( instance_exists( mike_b ) )
		{
			talker = mike_b;
		}
		if ( talker )
		{
			talker.talking = 1;
			talker.talk_timer = message.length;
			if ( talker.talk_timer < 15 )
				talker.talk_timer = 15;
		}
		
		if ( GMControl.isControl )
		{
			if ( curState == mystates["pluey"] )
			{
				if ( message == ":-(" )
				{
					SetState( mystates["pluey_sad"].name );
				}
			}
			else if ( curState == mystates["pluey_sad"] )
			{
				if ( message == ":-)" )
				{
					SetState( mystates["pluey"].name );
				}
			}
		}
	}
	
	override public function Step()
	{
		if ( instance_exists( mic ) )
		{
			++mic_timer;
			if ( mic.image_alpha < 1 )
			{
				mic.image_alpha = Math.min( 1, ( mic_timer - 30 ) / 60 );
			}
			if ( ( mic_timer % 6 ) == 0 )
			{
				mic.x = mic.xstart + gml.random( 2 ) - 1;
				mic.y = mic.ystart + gml.random( 2 ) - 1;
			}
		}
	}
	
	override public function Draw()
	{
		x = 0;
		y = 0;
		var mike;
		if ( instance_exists( mike_s ) )
			mike = mike_s;
		else if ( instance_exists( mike_m ) )
			mike = mike_m;
		else if ( instance_exists( mike_b ) )
		{
			mike = mike_b;
			x -= mike.image_xscale * 15;
		}
		if ( mike )
		{
			x += mike.x;
			y += mike.y;
			characterH = mike.howtall + mike.anim[8];
		}
		else if ( instance_exists( inst ) )
		{
			x += inst.x;
			y += inst.y;
		}
	}
}

}

import gamemaker.*;
import deltarune.*;
import deltarune.objects.*;

import flash.display.*;
import flash.events.*;
import flash.utils.*;

import com.threerings.util.*
import com.whirled.*

class obj_mike extends obj_monsterparent
{
	public var spr_blush = sprite_get( "spr_blush" );
	public var spr_mic_2x = sprite_get( "spr_mic_2x" );
	public var spr_mike_big = sprite_get( "spr_mike_big" );
	public var spr_mike_m = sprite_get( "spr_mike_m" );
	public var spr_mike_m_sad = sprite_get( "spr_mike_m_sad" );
	public var spr_mike_med = spr_mike_m;
	public var spr_mike_s_mic_up = sprite_get( "spr_mike_s_mic_up" );
	public var spr_mike_s_point_down = sprite_get( "spr_mike_s_point_down" );
	public var spr_mike_s_pointing_aggressive = sprite_get( "spr_mike_s_pointing_aggressive" );
	public var spr_mike_small = sprite_get( "spr_mike_small" );
	
	public var anim = new Array( 12 );
	
	public var howtall = 0;
	
	public var sad = 0;
	
	public var talking;
	public var talk_ind = 0;
	public var talk_timer = 0;
	
	public var xscale = 1;
	public var yscale = 1;
	
	public function obj_mike()
	{
		for ( var i = 0; i < 12; ++i )
			anim[i] = 0;
	}
	
	override public function Create()
	{
		
	}
	
	override public function Step()
	{
		if ( talk_timer > 0 )
		{
			talk_timer -= body.timescale;
			if ( talk_timer <= 0 )
			{
				talking = 0;
				talk_timer = 0;
			}
		}
		
		scr_depth();
		
		// Small Mike Animation
		if ( sprite_current == spr_mike_small )
		{
			var _ts = 1;
			anim[0] += 1 * _ts;
			anim[10] += 50 * _ts;
			if ( talking )
			{
				talk_ind += ( 0.5 * _ts );
				if ( talk_ind > 3 )
					talk_ind = 0;
				anim[5] = Math.min( anim[5], 60 );
				anim[1] += Math.sin( anim[0] - 90 ) * 2 * _ts;
				if ( anim[0] > 150 )
					anim[0] = 0;
			}
			else
			{
				talk_ind = 0 ;
				anim[1] = scr_approach( anim[1], 0, 1 );
				anim[5] += 1 * _ts;
			}
			
			anim[2] = Math.cos( anim[10] / 200 ) * 2;
			anim[3] = Math.sin( 100 + ( anim[10] / 400 ) ) - Math.cos( anim[10] / 200 );
			if ( anim[5] > 60 )
			{
				anim[7] += Math.sin( 50 + ( anim[5] * 100 ) ) * 0.05 * _ts;
				if ( anim[5] > 120  )
					anim[5] = 0;
			}
			else
			{
				anim[7] += ( 0 - anim[7] ) * 0.1 * _ts;
			}
			anim[8] = 22 + ( -22 * ( 1 - anim[7] ) );
		}
		// Big Mike Animation
		else if ( sprite_current == spr_mike_big )
		{
			anim[0] += 1;
			anim[10] += 50;
			if (talking)
			{
				anim[5] = Math.min(anim[5], 60);
				anim[1] -= Math.sin((anim[0] - 120) / 4) * 2;
				
				if (anim[0] > 260)
					anim[0] = 0;
			}
			else
			{
				anim[1] = scr_approach(anim[1], 0, 1);
				anim[5] += 1;
			}
			anim[2] = Math.cos(anim[10] / 200) * 2;
			anim[3] = Math.sin(100 + (anim[10] / 400)) - Math.cos(anim[10] / 200);
			if (anim[5] > 90)
			{
				anim[7] += Math.sin(50 + (anim[5] * 75)) * 0.03;
				
				if (anim[5] > 150)
					anim[5] = 0;
			}
			else
			{
				anim[7] += (0 - anim[7]) * 0.1;
			}
			anim[8] = 43 + (-43 * (1 - anim[7]));
		}
	}
	
	override public function Draw()
	{
		var x = this.x; //body.originX;
		var y = this.y; //body.y;
		if ( sprite_current == spr_mike_small )
		{
			y -= ( 20 * 2 );
			if ( true )
			{
				draw_sprite_ext(spr_mike_small, 1, x, y - anim[8], image_xscale * xscale, (image_yscale * yscale) + anim[7], image_angle, image_blend, image_alpha);
				draw_sprite_ext(spr_mike_small, 2, x, ( y - anim[8] ) + anim[1], image_xscale * xscale, image_yscale * yscale, image_angle, image_blend, image_alpha);
				
				if (sad && !talking)
					draw_sprite_ext(spr_mike_small, 10, x, ((y + 2) - anim[8]) + anim[1], image_xscale * xscale, image_yscale * yscale, image_angle, image_blend, image_alpha);
				else
					draw_sprite_ext(spr_mike_small, 3 + gml.clamp(talk_ind, 0, 3), x, (y - anim[8]) + anim[1], image_xscale * xscale, image_yscale * yscale, image_angle, image_blend, image_alpha);
				
				draw_sprite_ext(spr_mike_small, 7, x + anim[2], (y - anim[8]) + anim[3], image_xscale * xscale, image_yscale * yscale, image_angle, image_blend, image_alpha);
				draw_sprite_ext(spr_mike_small, 8, x + anim[3], (y - anim[8]) + anim[2], image_xscale * xscale, image_yscale * yscale, image_angle, image_blend, image_alpha);
				draw_sprite_ext(spr_mike_small, 9, x, y - anim[8], image_xscale * xscale, image_yscale * yscale, image_angle, image_blend, image_alpha);
			}
			else
				draw_sprite_ext( spr_mike_small, 0, x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha );
		}
		else if ( sprite_current == spr_mike_big )
		{
			x -= image_xscale * 4;
			y -= ( 43 * 2 );
			if ( true )
			{
				draw_sprite_ext(spr_mike_big, 1, x + anim[2], (y - anim[8]) + anim[3], image_xscale * xscale, image_yscale * yscale, image_angle, image_blend, image_alpha);
				draw_sprite_ext(spr_mike_big, 2, x, y - anim[8], image_xscale * xscale, (image_yscale * yscale) + anim[7], image_angle, image_blend, image_alpha);
				draw_sprite_ext(spr_mike_big, 3, x, y - anim[8], image_xscale * xscale, (image_yscale * yscale) + anim[7], image_angle, image_blend, image_alpha);
				draw_sprite_ext(spr_mike_big, 6, x, y - anim[8], image_xscale * xscale, image_yscale * yscale, image_angle + anim[1], image_blend, image_alpha);
				draw_sprite_ext(spr_mike_big, 5, x, y - anim[8], image_xscale * xscale, image_yscale * yscale, image_angle + anim[1], image_blend, image_alpha);
				draw_sprite_ext(spr_mike_big, 4, x, y - anim[8], image_xscale * xscale, image_yscale * yscale, image_angle - anim[2], image_blend, image_alpha);
				draw_sprite_ext(spr_mike_big, 7, x, y - anim[8], image_xscale * xscale, image_yscale * yscale, image_angle, image_blend, image_alpha);
			}
			else
				draw_sprite_ext( spr_mike_big, 0, x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha );
		}
		else
			draw_self();
	}
}