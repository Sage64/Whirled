
// Mizzle

// sharing one of my avis as an example
// https://www.whirled.club/#shop-l_5_3602

/*
	While the Body class itself can be used as the character, and has a few
	of the object methods for convenience, using it to instead create
	and manage objects is much preferred.
	This avatar creates/deletes different objects depending on its state
	
	The nametag position is based on the body's X/Y position and "characterH"
	It can be moved around (such as to the relevant object) freely to match it
	
*/

package deltarune
{

import gamemaker.*;
import deltarune.objects.*;

import flash.display.*;
import flash.events.*;
import flash.utils.*;

import com.threerings.util.*
import com.whirled.*


public class HolyWaterBody extends MonsterBody
{
	public var spr_watercooler = sprite_get( "spr_watercooler" );
	
	public var mizzle;
	public var singer;
	public var watercooler;
	public var bigmizzle;
	
	public function HolyWaterBody()
	{
		super();
		
		mystates["default"] = DWState( "Default" );
		mystates["idle"] = DWState( "Awake" );
		mystates["sleep"] = DWState( "Asleep" );
		mystates["singing"] = DWState( "Singing" );
		mystates["watercooler"] = DWState( "Watercooler" );
		mystates["watercooler_patrol"] = DWState( "Watercooler (Patrol)" );
	}
	
	override public function OnStateChanged()
	{
		super.OnStateChanged();
		
		x = originX;
		y = originY;
		characterH = 0;
		SetViewOffset( 0, 0 ); //-( 15 + characterH / 2 ) );
		
		instance_destroy( singer );
		
		switch ( curState )
		{
			case mystates["watercooler"]:
			case mystates["watercooler_patrol"]:
				// Watercooler
				instance_destroy( mizzle );
				instance_destroy( bigmizzle );
				if ( !instance_exists( watercooler ) )
					watercooler = instance_create( x, y, obj_dw_church_watercooler );
				
				watercooler.x = originX;
				watercooler.y = originY;
				watercooler.x -= ( spr_watercooler.x * 2 );
				watercooler.y -= ( spr_watercooler.y * 2 );
				watercooler.inst = null;
				
				characterH = ( 43 + 2 ) * 2;
				SetViewOffset( 0, - ( 58 + ( characterH / 2 ) ) );
				
				if ( curState == mystates["watercooler_patrol"] )
				{
					watercooler.con = 0;
					watercooler.dist = 32;
				}
				else
				{
					watercooler.con = 0;
					watercooler.dist = 1024;
					if ( watercooler.i_ex( watercooler.mizzle ) )
						watercooler.con = 20;
				}
				
				break;
			
			case mystates["singing"]:
				// Singer
				characterH = ( ( 43 + 2 ) * 2 );
				instance_destroy( mizzle );
				instance_destroy( bigmizzle );
				instance_destroy( watercooler );
				if ( !instance_exists( singer ) )
					singer = instance_create( x, y - 24, obj_mizzle_singer );
				y = singer.y;
				break;
			
			case mystates["awake"]:
			case mystates["sleep"]:
			default:
				instance_destroy( bigmizzle );
				// Mizzle
				characterH = ( ( 38 + 2 ) * 2 );
				if ( instance_exists( watercooler ) )
				{
					SetViewOffset( 0, - ( 58 + ( characterH / 2 ) ) );
					instance_destroy( mizzle );
					if ( !instance_exists( watercooler.mizzle ) )
					{
						watercooler.con = 0;
					}
					watercooler.dist = 32;
					watercooler.inst = this;
				}
				else
				{
					if ( !instance_exists( mizzle ) )
						mizzle = instance_create( x, y - 24, obj_mizzle );
				}
				
				break;
		}
	}
	
	override public function OnUpdateLook()
	{
		super.OnUpdateLook();
		
		if ( hDir > 0 )
			image_xscale = -2;
		else
			image_xscale = 2;
		
		if ( instance_exists( mizzle ) )
		{
			mizzle.image_xscale = image_xscale;// Math.abs( mizzle.image_xscale ) * ( ( hDir > 0 ) ? -1 : 1 );
			
			if ( curState == mystates["awake"] )
			{
				mizzle.monsterstatus = 0;
			}
			else
			{
				if ( curState == mystates["sleep"] || isSleeping )
					mizzle.monsterstatus = 1;
				else
					mizzle.monsterstatus = 0;
			}
			mizzle.OnUpdateLook();
		}
		if ( instance_exists( singer ) )
		{
			singer.OnUpdateLook();
		}
		if ( instance_exists( watercooler ) )
		{
			watercooler.OnUpdateLook();
		}
	}
	
	override public function OnMercy( amount = 0 )
	{
		if ( instance_exists( mizzle ) )
		{
			mizzle.mercymod = amount;
		}
		OnUpdateLook();
	}
	
	override public function OnHurt( amount = 0 )
	{
		if ( instance_exists( mizzle ) )
		{
			scr_damage_enemy( mizzle, amount );
		}
	}
	
	override public function DoBodyDebug()
	{
		//SetState( mystates["watercooler_patrol"].name );
		//GMControl.GMActionTriggered( myactions["f1"] );
	}
	
	override public function Step()
	{
		
	}
}

}

import gamemaker.*;
import deltarune.*;
import deltarune.objects.*;
import flash.display.*;


class obj_mizzle extends obj_monsterparent
{
	// Initialize asset vars first
	public var spr_holywater_alarm = sprite_get( "spr_holywater_alarm" );
	public var spr_holywater_alarm_pink = sprite_get( "spr_holywater_alarm_pink" );
	public var spr_holywater_hurt = sprite_get( "spr_holywater_hurt" );
	public var spr_holywater_hurt_pink = sprite_get( "spr_holywater_hurt_pink" );
	public var spr_holywater_idle = sprite_get( "spr_holywater_idle" );
	public var spr_holywater_idle_pink = sprite_get( "spr_holywater_idle_pink" );
	
	
	public var awake = true;
	
	public var firstframe = 0;
	
	public function obj_mizzle()
	{
		super();
		
		idlesprite = spr_holywater_alarm;
		hurtsprite = spr_holywater_hurt;
		sparedsprite = spr_holywater_alarm;
		
		monstername = "Mizzle";
		monstermaxhp = 470;
		monsterhp = 470;
		
		
		mercymod = body.GetMemory( "deltarune.monster.mercy" );
		
	}
	
	override public function Create()
	{
		
	}
	
	public function OnUpdateLook()
	{
		if ( monsterstatus == 1 )
			idlesprite = ( mercymod >= 100 ) ? spr_holywater_idle_pink : spr_holywater_idle;
		else
			idlesprite = ( mercymod >= 100 ) ? spr_holywater_alarm_pink : spr_holywater_alarm;
		hurtsprite = ( mercymod >= 100 ) ? spr_holywater_hurt_pink : spr_holywater_hurt;
		sparedsprite = idlesprite;
		if ( body.nametag )
			body.nametag.alpha = alpha;
	}
	
	override public function Step()
	{
		if ( state == 3 )
		{
			scr_enemyhurt_tired_after_damage(0.5);
			scr_enemy_hurt();
		}
		
		// 
		
		y = ystart + (sin(siner * 0.5) * 5);
		if ( body )
		{
			body.x = x;
			body.y = y;
			
			if ( state == 3 )
			{
				body.x += ( 2 * image_xscale ) + shakex;
				body.y += 8;
			}
			else
				body.x -= ( 8 * image_xscale );
		}
	}
	
	override public function Draw()
	{
		firstframe++;
		if ( true ) //(firstframe > 1 )
		{
			scr_enemy_drawhurt_generic();
			scr_enemy_drawidle_generic(0.16666666666666666);
		}
		if (becomeflash == 0)
			flash = 0;
		becomeflash = 0;
	}
}

class obj_mizzle_singer extends DeltaruneObject
{
	public var spr_holywater_sing = sprite_get( "spr_holywater_sing" );
	
	public var animtimer = 0;
	
	public function obj_mizzle_singer()
	{
		super();
		sprite_set( spr_holywater_sing );
		image_speed = 0.1;
		
		image_xscale = -body.image_xscale;
		image_yscale = 2;
	}
	
	override public function Step()
	{
		if ( image_alpha > 0 )
		{
			animtimer += 0.5;
			image_index = floor( animtimer / 4 ) % 3;
		}
	}
	
	public function OnUpdateLook()
	{
		image_xscale = -body.image_xscale;
	}
}

class obj_dw_church_watercooler extends DeltaruneObject
{
	public var spr_holywater_alarm = sprite_get( "spr_holywater_alarm" );
	public var spr_holywater_idle = sprite_get( "spr_holywater_idle" );
	public var spr_pxwhite = sprite_get( "spr_pxwhite" );
	public var spr_watercooler = sprite_get( "spr_watercooler" );
	public var spr_watercooler_parts = sprite_get( "spr_watercooler_parts" );
	
	public static var c_water1 = 0x2D9BD7;
	public static var c_water2 = 0x99D9EA;
	
	public var con = 0;
	public var timer = 0;
	public var siner = 0;//( ( round( x + y ) * 4) - 80 ) + round( current_second * 30 );
	public var howfull = 6 + scr_even(irandom(14));
	public var type = 0;
	public var mysolid;
	public var drain = 1;
	public var dodrain = false;
	public var mizzle;
	public var mizzle_con = 0;
	public var mizzle_timer = 0;
	public var mizzle_siner = 0;
	public var mizzle_movespeed = 0;
	public var mizzle_alerted = 0;
	public var boss = 0;
	public var alertrad = 180;
	public var patrolradius = 0;
	public var patrolradiusdest = 90;
	public var doappear = 0;
	public var haswater = 1;
	public var dir = 0;
	
	public var init = 0;
	
	public var dist = 1024;
	public var inst;
	
	public function obj_dw_church_watercooler()
	{
		super();
		sprite_set( spr_watercooler_parts );
	}
	
	override public function Cleanup()
	{
		super.Cleanup();
		instance_destroy( mizzle );
	}
	
	override public function Create()
	{
		
	}
	
	public function OnUpdateLook()
	{
		if ( mizzle && body )
		{
			mizzle.image_xscale = body.image_xscale;;
		}
	}
	
	override public function Step()
	{
		var foughtbefore = false;
		if ( con == 0 )
		{
			if ( i_ex( mizzle ) )
				con = 20;
			if ( dist < alertrad )
			{
				doappear = 2;
				con = 1;
			}
		}
		else if ( ( con == 1 ) && i_ex( mizzle ) && ( mizzle.image_alpha == 2 ) )
		{
			if ( inst )// || patrolradius > 70 )
			{
				con = 20;
				// 
				con = 2;
				
				mizzle_con = 99;
			}
		}
		if ( doappear )
		{
			if ( !instance_exists( mizzle ) )
			{
				var xx = ( spr_watercooler.x ) + spr_holywater_idle.x + ( x - (32*0) );
				var yy = y;
				mizzle = scr_marker_ext( xx, yy, spr_holywater_idle, body.image_xscale, body.image_yscale, 0.125, 0, 0xFFFFFF, 0, false, -1, 0 );
				mizzle.depth = -1;
			}
			if ( instance_exists( mizzle ) )
			{
				mizzle.image_alpha = 0;
				var count = 0;
				mizzle.scr_delay_var( "image_alpha", 0.125, count++ );
				mizzle.scr_delay_var( "image_alpha", 0, count++ );
				mizzle.scr_delay_var( "image_alpha", 0.5, count++ );
				mizzle.scr_delay_var( "image_alpha", 0.25, count++ );
				mizzle.scr_delay_var( "image_alpha", 0.75, count++ );
				mizzle.scr_delay_var( "image_alpha", 0.5, count++ );
				mizzle.scr_delay_var( "image_alpha", 1, count++ );
				mizzle.scr_delay_var( "image_alpha", 2, count++ );
			}
			if ( doappear == 2 )
			{
			}
			
			doappear = 0;
		}
		if ( con == 20 )
		{
			if ( i_ex( mizzle ) )
			{
				mizzle.scr_lerpvar( "image_alpha", mizzle.image_alpha, 0, 12, 2, "out" );
			}
			scr_lerpvar_respect( "haswater", haswater, 0, 12, 2, "out" );
			con = 21;
		}
		if ( con == 21 )
		{
			if ( i_ex( mizzle ) && ( mizzle.image_alpha <= 0 ) )
			{
				instance_destroy( mizzle );
				mizzle = 0;
				con = 22;
				patrolradius = 0;
				body.x = body.originX ;
				body.y = body.originY;
				body.characterH = ( 43 + 2 ) * 2;
				dodrain = false;
				drain = 1;
				haswater = 1;
			}
		}
		
		if ( i_ex( mizzle ) )
		{
			if ( patrolradius < patrolradiusdest )
				patrolradius = min( patrolradiusdest, patrolradius + ( patrolradiusdest / 60 ) );
			if ( true )
			{
				siner += 1;
				if ( mizzle_con < 99 )
				{
					mizzle.x = scr_even( ( spr_watercooler.x ) + spr_holywater_idle.x + ( x - (32*0) ) + ( sin( siner / 20 ) * patrolradius ) );
        			mizzle.y = scr_even( ( spr_watercooler.y * 1 ) + ( y - 12 ) + ( cos( siner / 20 ) * patrolradius ) );
				}
				body.x = mizzle.x;
				body.y = mizzle.y;
				body.x -= ( 8 * mizzle.image_xscale );
				body.characterH = ( ( 38 + 2 ) * 2 );
				if ( body.nametag )
					body.nametag.alpha = mizzle.image_alpha;
			}
		}
		else
		{
			siner += 1;
			if ( body.nametag )
				body.nametag.alpha = Math.min( 1, body.nametag.alpha + ( 1 / 15 ) );
		}
		
		if ( instance_exists( mizzle ) )
		{
			if ( mizzle_alerted == 1 )
			{
				if ( mizzle.image_alpha > 0.5 )
				{
					mizzle_alerted = 2;
				}
			}
			if ( mizzle_con == 20 && mizzle.image_alpha == 2 )
			{
				mizzle.sprite_set( global.spr_holywater_alarm );
				mizzle_con = 21;
			}
			if ( mizzle_con == 30 )
			{
				
			}
			if ( mizzle_con == 99 )
			{
				//mizzle.image_speed = 0;
				mizzle.sprite_set( global.spr_holywater_alarm );
				mizzle.image_index = ( mizzle.image_index % 9 );
				mizzle_con = 100;
				if ( body )
				{
					//body.mizzle = instance_create( mizzle.x, mizzle.y, obj_mizzle );
					//body.mizzle.image_index = image_index;
					//body.OnUpdateLook();
					
					var targx = body.originX;
					var targy = body.originY - 24;
					mizzle.scr_lerpvar( "x", mizzle.x, targx, 12, 2, "in" );
					mizzle.scr_lerpvar( "y", mizzle.y, targy, 12, 2, "out" );
					//instance_destroy( mizzle );
				}
				con = 100;
			}
			if ( mizzle_con == 100 )
			{
				mizzle_timer += 1;
				
				if ( mizzle_timer == 12 )
				{
					scr_lerpvar( "image_alpha", image_alpha, 0, 12, 2, "out" );
					//mizzle_timer = 36;
				}
				
				if ( mizzle_timer >= 24 )
				{
					con = 21;
					instance_destroy();
					instance_destroy( mizzle );
					//instance_destroy( mizzle );
					instance_destroy( body.mizzle );
					body.mizzle = instance_create( body.originX, body.originY - 24, obj_mizzle );
					body.mizzle.image_index = mizzle.image_index;
					body.mizzle.siner = 0;//body.mizzle.image_index;
					body.OnUpdateLook();
				}
			}
		}
		
		if (dodrain)
			drain = lerp(drain, 0, 0.125);
	}
	
	override public function Draw()
	{
		var watalph = 1 - haswater;
		if (i_ex(mizzle))
		{
			watalph = mizzle.image_alpha;
			if (watalph != 0)
				dodrain = true;
		}
		draw_sprite_ext( spr_pxwhite, 0, x + 4, y + howfull, 30, 40, 0, merge_color( c_water1, c_white, clamp(sin(siner / 30) * 0.5, 0, 1)), (1 - watalph) * drain * image_alpha );
		draw_sprite_ext( sprite_index, 0, x, y, 2, 2, 0, c_white, image_alpha );
		draw_sprite_ext( sprite_index, 1, x, y, 2, 2, 0, c_water1, 0.25 * image_alpha );
		draw_sprite_ext( sprite_index, 2, x, y, 2, 2, 0, c_water2, 0.5 * image_alpha );

	}
}