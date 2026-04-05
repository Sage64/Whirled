
package deltarune
{

import gamemaker.*;

import flash.display.*;
import flash.events.*;
import flash.utils.*;

import com.threerings.util.*
import com.whirled.*

public class SwatchlingBody extends MonsterBody
{
	public var actor;
	
	public var lerphue;
	public var warmth = -1;
	public var hue = 0;
	public var hue_1 = 160;
	public var hue_2 = 96;
	public var hue_3 = 64;
	public var hue_4 = 32;
	public var hue_5 = 0;
	
	public function SwatchlingBody()
	{
		
		super();
		
		mystates["default"] = DWState( "Default", [ global.spr_npc_butler, global.spr_npc_butler ] );
		mystates["pose"] = DWState( "Arms down", global.spr_npc_swatchling_down );
		mystates["pose2"] = DWState( "Face Away", global.spr_npc_swatchling_up );
		mystates["clap"] = DWState( "Clapping", global.spr_npc_butler_clap );
		mystates["clap_fast"] = DWState( "Clapping (Fast)", global.spr_npc_butler_clap );
		mystates["sweep"] = DWState( "Sweeping", [ global.spr_npc_swatchling_sweep, global.spr_npc_swatchling_sweep_walk ]  );
		mystates["sweep_fast"] = DWState( "Sweeping (Fast)", [ global.spr_npc_swatchling_sweep, global.spr_npc_swatchling_sweep_walk ]  );
		mystates["scared"] = DWState( "Scared", global.spr_npc_swatchling_scared );
		mystates["scared_fast"] = DWState( "Scared (Fast)", global.spr_npc_swatchling_scared );
		mystates["peck"] = DWState( "Peck", global.spr_npc_swatchling_peck );
		mystates["peck_fast"] = DWState( "Peck (Fast)", global.spr_npc_swatchling_peck );
		mystates["fan"] = DWState( "Fan", global.spr_npc_swatchling_fan );
		mystates["fan_fast"] = DWState( "Fan (Fast)", global.spr_npc_swatchling_fan );
		
		
		AddEnemyStates();
		mystates["enemy_dead"].hidden = true;
		mystates["enemy_frozen"].hidden = true;
		
		if ( false )
		{
			mymemories["warmth"] = AddMemory( "deltarune.swatchling.warmth", -1, SetWarmth );
			myactions["act_red_2"] = AddAction( "Warmify", AddWarmth, 2 );
			myactions["act_red_1"] = AddAction( "Half-Warm", AddWarmth, 1 );
			myactions["act_blue_1"] = AddAction( "Half-Cold", AddWarmth, -1 );
			myactions["act_blue_2"] = AddAction( "Coldify", AddWarmth, -2 );
		}
		
		
	}
	
	override public function DoBodyDebug()
	{
		SetState( mystates["enemy_idle"] );
	}
	
	override public function OnStateChanged()
	{
		super.OnStateChanged();
		x = originX;
		y = originY;
		characterH = 0;
		if ( curState && curState.enemy )
		{
			instance_destroy( actor );
			if ( !instance_exists( enemy ) )
				enemy = instance_create( x, y, obj_swatchling_enemy );
			characterH = enemy.sprite_height;
			characterH += 16;
		}
		else
		{
			instance_destroy( enemy );
			if ( !instance_exists( actor ) )
			{
				actor = instance_create( x, y, obj_npc_swatchling );
			}
			var spr = null;
			if ( curState )
				spr = curState.sprite;
			if ( is_array( spr ) )
			{
				if ( spr.length > 1 )
				{
					actor.idlesprite = spr[0];
					actor.walksprite = spr[1];
					actor.sprite_set( actor.idlesprite );
				}
			}
			else
			{
				actor.idlesprite = spr;
				actor.walksprite = null;
				actor.sprite_set( actor.idlesprite );
			}
			actor.offset_x = sprite_get_width( actor.sprite_current ) / 2;
			actor.offset_y = sprite_get_height( actor.sprite_current ) - 2;
			actor.image_speed = 0;
			actor.idlespeed = 0.25;
			switch ( actor.idlesprite )
			{
				case global.spr_npc_butler:
					actor.offset_y -= 9;
					actor.offset_x += 9;
					actor.idlespeed = 0;
					actor.image_index = 0;
					break;
				case global.spr_npc_swatchling_down:
				case global.spr_npc_swatchling_up:
					break;
				case global.spr_npc_butler_clap:
					actor.idlespeed = ( curState == mystates["clap_fast"] ) ? 1 : 0.25;
					actor.offset_x = ( global.spr_npc_swatchling_down.width / 2 );
					break;
				case global.spr_npc_swatchling_scared:
					actor.idlespeed = ( curState == mystates["scared_fast"] ) ? 1 : 0.25;
					actor.offset_y += 2;
					break;
				case global.spr_npc_swatchling_sweep:
					actor.idlespeed = ( curState == mystates["sweep_fast"] ) ? 1 : 0.1;
					actor.offset_x += 9;
					break;
				case global.spr_npc_swatchling_peck:
					actor.idlespeed = ( curState == mystates["peck_fast"] ? 1 : 0.2 );
					actor.offset_x += 9;
					break;
				case global.spr_npc_swatchling_fan:
					actor.idlespeed = ( curState == mystates["fan_fast"] ? 1 : 0.2 );
					actor.offset_x += 19;
					actor.offset_y += 2;
					break;
			}
			characterH = actor.sprite_height;
			characterH += 16;
		}
		SetViewOffset( 0, 0 - ( 10 + ( characterH / 2 ) ) );
	}
	
	override public function OnUpdateLook()
	{
		super.OnUpdateLook();
		
		if ( instance_exists( actor ) )
		{
			actor.facing = ( image_xscale > 0 ) ? 1 : -1;
			actor.image_xscale = actor.facing * 2;
			
			if ( actor.walksprite )
			{
				if ( isMoving )
				{
					actor.sprite_set( actor.walksprite );
					actor.image_speed = 0.25;
				}
				else
				{
					actor.sprite_set( actor.idlesprite );
					actor.image_speed = actor.idlespeed;
				}
			}
			else
			{
				actor.image_speed = actor.idlespeed;
			}
			if ( actor.image_speed == 0 )
					actor.image_index = 0;
		}
		
		if ( instance_exists( enemy ) )
		{
			enemy.image_xscale = image_xscale;
			enemy.facing = ( image_xscale > 0 ) ? 1 : -1;
		}
	}
	
	public function AddWarmth( val = 0 )
	{
		if ( warmth < 0 )
			warmth = 4;
		warmth += val;
		clamp( warmth + val, 0, 4 )
		SetMemory( "deltarune.swatchling.warmth", warmth );
	}
	
	public function SetWarmth( val = 0 )
	{
		var dest = hue;
		switch( val )
		{
			case 0:
				dest = hue_1;
				break;
			case 1:
				dest = hue_2;
				break;
			case 2:
				dest = hue_3;
				break;
			case 3:
				dest = hue_4;
				break;
			default:
				dest = hue_5;
				break;
		}
		if ( warmth < 0 )
			hue = dest;
		else
		{
			if ( dest != hue )
				ToHue( dest );
		}
		warmth = val;
	}
	
	public function ToHue( val )
	{
		instance_destroy( lerphue );
		lerphue = DeltaruneObject.scr_lerpvar_instance( this, "hue", hue, val, 30 );
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

class obj_npc_swatchling extends obj_overworldenemy_parent
{
	public var facing = 1;
	
	public var idlesprite;
	public var walksprite;
	public var idlespeed = 0.25;
	
	public var offset_x = 0;
	public var offset_y = 0;
	
	public function obj_npc_swatchling()
	{
		super();
		image_speed = idlespeed;
		image_xscale = 2;
		image_yscale = 2;
		sprite_set( global.spr_npc_butler );
		
		offset_x = ( sprite_width / 2 );
		offset_y = ( sprite_height - 2 );
	}
	
	override public function Create()
	{
		super.Create();
		
	}
	
	override public function Step()
	{
		
	}
	
	override public function Draw()
	{
		// var sprite_width = ( this.sprite_width * image_xscale );
		// var sprite_height = ( this.sprite_height * image_yscale );
		
		var xpos = this.x;
		var ypos = this.y;
		x = xpos - ( offset_x * image_xscale );
		y = ypos - ( offset_y * image_yscale );
		
		if ( body && body.chaseaura )
		{
			scr_draw_chaseaura( sprite_current, image_index, x, y );
		}
		
		draw_self();
		
		x = xpos;
		y = ypos;
	}
	
	
}


class obj_swatchling_enemy extends obj_monsterparent
{
	public var facing = 1;
	
	public var timer = 0;
	
	public function obj_swatchling_enemy()
	{
		super();
		sprite_index = global.spr_swatchling_body;
		
		image_speed = ( 1 / 6 );
		
		// image_blend = c_red;
		
		idlesprite = global.spr_swatchling_body;
		hurtsprite = global.spr_swatchling_hurt;
		sparedsprite = global.spr_swatchling_spared;
		
		monstername = "Swatchling";
		monstermaxhp = 300;
		monsterhp = monstermaxhp;
		monsterat = 9;
		monsterdf = 0;
		
		offset_x = ( sprite_get_width( idlesprite ) / 2 ) + 9;
		offset_y = ( sprite_get_height( idlesprite ) - 2 ) + 0.5;
	}
	
	override public function Create()
	{
		
	}
	
	override public function Step()
	{
		timer += 1;
		if ( state == 0 )
		{
			
		}
		
		if ( state == 3 )
		{
			scr_enemy_hurt();
		}
		
		if ( body )
		{
			image_blend = c_white;
		}
	}
	
	override public function Draw()
	{
		var x = this.x - ( offset_x * image_xscale );
		var y = this.y - ( offset_y * image_yscale );
		
		if ( body )
		{
			body.x = this.x;
			body.y = this.y;
			body.characterH = sprite_height;
			body.characterH += 16;
		}
		
		if ( state == 3 )
		{
			// hurtspriteoffx = x - this.x;
			// hurtspriteoffy = y - this.y;
			scr_enemy_drawhurt_generic();
			// body.characterH += 16;
		}
		else if ( state == 0 )
		{
			var _siner = sin( timer / 6 );
			draw_sprite_ext( global.spr_swatchling_legs, 0, x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha );
			draw_sprite_ext( global.spr_swatchling_body, 0, x, y + ( _siner * 3 ), image_xscale, image_yscale, image_angle, image_blend, image_alpha );
			draw_sprite_ext( global.spr_swatchling_head, 0, x, y + _siner, image_xscale, image_yscale, image_angle, image_blend, image_alpha );
			
			if ( body )
			{
				body.characterH -= ( _siner );
			}
		}
	}
}