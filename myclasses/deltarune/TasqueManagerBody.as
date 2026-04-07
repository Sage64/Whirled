
package deltarune
{

import gamemaker.*;

import flash.display.*;
import flash.events.*;
import flash.utils.*;

import com.threerings.util.*
import com.whirled.*

public class TasqueManagerBody extends MonsterBody
{
	public var actor;
	
	public function TasqueManagerBody()
	{
		
		super();
		
		mystates["default"] = DWState( "NPC - Idle", global.spr_npc_tasquemanager );
		mystates["spr_npc_tm_sing"] = DWState( "NPC - Sing", global.spr_npc_tm_sing );
		mystates["spr_npc_tm_sing"].image_speed = 0.2;
		
		
		AddEnemyStates();
	}
	
	override public function DoBodyDebug()
	{
		
	}
	
	override public function OnStateChanged()
	{
		super.OnStateChanged();
		x = originX;
		y = originY;
		characterH = 70 * 2;
		
		var _offx = 40;
		var _offy = 69;
		
		if ( !curState )
		{}
		else if ( curState.enemy )
		{
			// ENEMY
			instance_destroy( npc );
			if ( !instance_exists( enemy ) )
			{
				enemy = instance_create_depth( x, y, 0, obj_tasque_manager_enemy );
			}
			enemy.offset_x = _offx;
			enemy.offset_y = _offy;
			characterH = ( sprite_get_height( enemy.sprite_index ) * image_yscale ) + 5;
		}
		else
		{
			// NPC
			instance_destroy( enemy )
			if ( !instance_exists( npc ) )
			{
				npc = instance_create_depth( x, y, 0, obj_npc_tasquemanager );
			}
			if ( curState.sprite )
				npc.sprite_index = curState.sprite;
			if ( curState.image_speed )
				npc.image_speed = curState.image_speed;
			
			npc.image_xscale = 2;
			npc.image_yscale = 2;
			npc.offset_x = _offx;
			npc.offset_y = _offy;
			switch( npc.sprite_index )
			{
				case global.spr_npc_tm_sing:
					npc.offset_x = 20;
					npc.offset_y += 1;
					npc.image_xscale *= -1;
					break;
			}
			
			characterH = ( sprite_get_height( npc.sprite_index ) * image_yscale ) + 5;
		}
		
		
		SetViewOffset( 0, 0 - ( 10 + ( characterH / 2 ) ) );
	}
	
	override public function OnUpdateLook()
	{
		super.OnUpdateLook();
		
		flipped = ( hDir > 0 );
		
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

class obj_npc_tasquemanager extends obj_overworldenemy_parent
{
	
	public function obj_npc_tasquemanager()
	{
		super();
		sprite_index = global.spr_npc_tasquemanager;
		image_speed = 0;
		offset_x = 44;
		offset_y = 69;
		
	}
	
	override public function Create()
	{
		
	}
}


class obj_tasque_manager_enemy extends obj_monsterparent
{
	
	public var sprite = [
		global.spr_tm_head,
		global.spr_tm_body,
		global.spr_tm_tail,
		global.spr_tm_hand_l,
		global.spr_tm_hand_r,
		global.spr_tm_legs,
	];
	public var sprite_spare = [
		global.spr_tm_head_spare,
		global.spr_tm_body,
		global.spr_tm_tail_spare,
		global.spr_tm_hand_l_spare,
		global.spr_tm_hand_r_spare,
		global.spr_tm_legs,
	]
	
	public var xOffset = [];
	public var yOffset = [];
	
	public var timer = 0;
	
	public function obj_tasque_manager_enemy()
	{
		super();
		sprite_index = global.spr_npc_tasquemanager;
		offset_x = 44;
		offset_y = 69;
		
		image_speed = ( 1 / 6 );
		
		hurtsprite = global.spr_tm_hurt;
		sparedsprite = global.spr_npc_tasquemanager;
		
		for ( var i = 0; i < 6; ++i )
		{
			xOffset[i] = ( sprite_get_xoffset( sprite[i] ) * 2 ) - 22; 
			yOffset[i] = ( sprite_get_yoffset( sprite[i] ) * 2 ) - 6; 
		}
	}
	
	override public function Create()
	{
		super.Create();
	}
	
	override public function Step()
	{
		var ts = timescale_delta;
		
		// 
		if ( state == 0 )
			timer += ( 1.5 * ts );
		if ( state == 3 )
			scr_enemy_hurt();
	}
	
	override public function Draw()
	{
		var x = this.x;
		var y = this.y;
		
		x -= ( offset_x * image_xscale );
		y -= ( offset_y * image_yscale );
		
		if ( state == 3 )
			scr_enemy_drawhurt_generic();
		else if ( state == 0 )
		{
			var sprite = ( mercymod >= mercymax ) ? this.sprite_spare : this.sprite;
			var siner = sin( timer / 6 );
			
			// tail
			draw_monster_body_part_ext( sprite[2], 0, x + xOffset[2], y + yOffset[2], image_xscale, image_yscale, -siner * 10, image_blend, image_alpha );
			// hand r
			draw_monster_body_part_ext( sprite[4], 0, x + xOffset[4] + ( siner * 2 ), y + yOffset[4] + ( siner * 2 ), 2, 2, 0, c_white, image_alpha);
			// hand l (whip)
			draw_monster_body_part_ext( sprite[3], 0, x + xOffset[3] + ( cos(timer / 6) * 2 ), y + yOffset[3] + ( siner * 2 ), 2, 2, siner * 15, c_white, image_alpha);
			// legs
			draw_monster_body_part_ext( sprite[5], 0, x + xOffset[5], y + yOffset[5], image_xscale, image_yscale, 0, image_blend, image_alpha );
			// body
			draw_monster_body_part_ext( sprite[1], 0, x + xOffset[1], y + yOffset[1] + ( siner * 2 ), image_xscale, image_yscale, 0, image_blend, image_alpha );
			// head
			draw_monster_body_part_ext( sprite[0], 0, x + xOffset[0], y + yOffset[0] + ( siner * 3 ), image_xscale, image_yscale, siner * 10, image_blend, image_alpha );
			
		}
		
	}
	
}