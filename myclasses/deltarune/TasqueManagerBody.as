
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
		
		mystates["default"] = DWState( "Default" );
		
		AddEnemyStates();
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
		characterH = 70 * 2;
		
		switch( curState )
		{
			default:
				if ( !instance_exists( enemy ) )
				{
					enemy = instance_create( x, y, obj_tasque_manager_enemy );
				}
				break;
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
		
		offset_x = 40;;
		offset_y = 69;
		
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
		
		if ( body )
		{
			body.x = x;
			body.y = y;
			body.characterH = ( sprite_get_height( sprite_index ) * image_yscale ) + 5;
		}
		
		
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
			draw_monster_body_part_ext( sprite[1], 0, x + xOffset[1], y + yOffset[1] + ( siner * 2 ), image_xscale, image_yscale, -siner * 2, image_blend, image_alpha );
			// head
			draw_monster_body_part_ext( sprite[0], 0, x + xOffset[0], y + yOffset[0] + ( siner * 3 ), image_xscale, image_yscale, -siner * 10, image_blend, image_alpha );
			
			
		}
		
	}
	
}