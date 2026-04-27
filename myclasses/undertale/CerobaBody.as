// CerobaBody
package undertale
{
import gamemaker.*;
import undertale.*;
public class CerobaBody extends MonsterBody
{
	public var ceroba;
	public var ceroba_battle;
	
	
	public function CerobaBody()
	{
		super();
		
		UTState( "Default" );
		UTState( "Run" );
		state.run = true;
		UTState( "Guard", global.spr_ceroba_guard_1 );
		UTState( "Kneel", global.spr_flashback_ceroba_sit );
		UTState( "Lean", global.spr_ceroba_cool );
		UTState( "Lean - Side look", global.spr_ceroba_cool_alt );
		UTState( "Worried", global.spr_flashback_ceroba_worried );
		UTState( "Pre-fight", global.spr_new_home_03_pref_ceroba_loop );
		mystates["battle"] = BattleState( "Battle - Phase 1", 0 );
		mystates["battle_phase2"] = BattleState( "Battle - Phase 2", 1 );
		mystates["battle_phase2b"] = BattleState( "Battle - Phase 2b", 2 );
	}
	
	override public function Cleanup()
	{
		instance_destroy( ceroba );
		instance_destroy( ceroba_battle );
	}
	
	override public function DoBodyDebug()
	{
		
	}
	
	
	override public function Draw() {}
	
	override public function OnStateChanged()
	{
		x = 0;
		y = 0;
		
		super.OnStateChanged();
		
		if ( !state )
		{}
		else if ( state.battle )
		{
			instance_destroy( ceroba );
			if ( !instance_exists( ceroba_battle ) )
			{
				ceroba_battle = instance_create_depth( 0, 0, 0, obj_ceroba_battle );
				enemy = ceroba_battle;
				flip = 0;
				SetScale( 1 );
				SetViewOffset( 0, -55 * 3 );
				characterH = 225;
				SetMoveSpeed( 5 * 3 );
			}
			var phase = 0;
			if ( state.data is Array && state.data.length > 0 )
				phase = ceroba_battle.phase = state.data[0];
			
			ceroba_battle.phase = phase;
		}
		else
		{
			instance_destroy( ceroba_battle );
			if ( !instance_exists( ceroba ) )
			{
				ceroba = instance_create_depth( 0, 0, 0, obj_ceroba );
				npc = ceroba;
				flip = 0;
				SetScale( 3 );
				SetViewOffset( 0, -55 );
				characterH = 54;
			}
			ceroba.run = ( state.run ) ? true : false;
			if ( state.sprite )
			{
				ceroba.fun = 1;
				ceroba.sprite = state.sprite;
				//ceroba.image_index = ( ceroba.image_index % ceroba.image_number );
			}
			else
				ceroba.sprite = -1;
			ceroba.TestSpeed();
		}
	}
	
	override public function OnUpdateLook()
	{
		super.OnUpdateLook();
		if ( instance_exists( npc ) )
		{
			npc.facing = global.facing;
			npc.press_d = ( speed == 0 ) ? 0 : ( npc.facing == 0 ); // global.input_held[0];
			npc.press_r = ( speed == 0 ) ? 0 : ( npc.facing == 1 ); // global.input_held[1];
			npc.press_u = ( speed == 0 ) ? 0 : ( npc.facing == 2 ); // global.input_held[2];
			npc.press_l = ( speed == 0 ) ? 0 : ( npc.facing == 3 ); // global.input_held[3];
			npc.GetFacingSprite();
		}
	}
}
}
import gamemaker.*;
import undertale.*;
class obj_ceroba extends GMObject
{
	public var fun = 0;
	
	// Input
	public var press_l = 0;
	public var press_r = 0;
	public var press_d = 0;
	public var press_u = 0;
	public var nopress = 0;
	public var pressdir = -1;
	
	// Movement
	public var px = 0;
	public var py = 0;
	public var walk = 0;
	public var walkbuffer = 0;
	public var walktimer = 0;
	public var bwspeed = 3;
	public var wspeed = 3;
	public var run = 0;
	public var autorun = 0;
	public var runtimer = 0;
	public var runmove = 0;
	public var canrun = true;
	public var runcounter = 0;
	
	// Appearance
	public var offset_x = 0;
	public var offset_y = 14;
	public var facing = 0;
	public var dsprite = global.spr_ceroba_down_walk;
	public var rsprite = global.spr_ceroba_right_walk;
	public var usprite = global.spr_ceroba_up_walk;
	public var lsprite = global.spr_ceroba_left_walk;
	public var drunsprite = global.spr_ceroba_down_run;
	public var rrunsprite = global.spr_ceroba_right_run;
	public var urunsprite = global.spr_ceroba_up_run;
	public var lrunsprite = global.spr_ceroba_left_run;
	
	// Other
	public var sprite = -1;
	
	public function obj_ceroba()
	{
		super();
		sprite_index = dsprite;
		image_speed = 0;
	}
	
	override public function Create()
	{
		super.Create();
		TestSpeed();
	}
	
	// 
	
	override public function Draw()
	{
		var x = this.x - ( offset_x * image_xscale );
		var y = this.y - ( offset_y * image_yscale );
		
		draw_sprite_ext( sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha );
	}
	
	// 
	
	override public function Step()
	{
		if ( !global.interact )
			PlayerControl();
		if ( fun == 0 )
			AnimateWalk();
		GetFacingSprite();
	}
	
	public function PlayerControl()
	{
		px = 0;
		py = 0;
		pressdir = -1;
		if ( press_r )
			px = wspeed;
		if ( press_l )
			px = -wspeed;
		if ( press_d )
			py = wspeed;
		if ( press_u )
			py = -wspeed;
		// 
		nopress = 0;
		//
		runmove = 0;
		if ( ( run == 1 ) && ( px != 0 || py != 0 ) )
		{
			runmove = 1;
			runtimer += timescale;
			runcounter += timescale;
		}
		else
			runtimer = 0;
	}
	
	public function TestSpeed()
	{
		wspeed = ( run ) ? bwspeed * 2 : bwspeed;
		body.SetMoveSpeed( wspeed );
	}
	
	// Animate walking frames
	public function AnimateWalk()
	{
		walk = 0;
		if ( nopress == 0 )
		{
			if ( px != 0 || py != 0 )
				walk = 1;
		}
		if ( walk == 1 )
			walkbuffer = 6;
		if ( walkbuffer > 3 )
		{
			walktimer += ( runmove ? 3 : 1.5 ) * timescale;
			walktimer = walktimer % ( image_number * 10 );
			image_index = Math.floor( walktimer / 10 );
		}
		if ( walkbuffer <= 0 )
		{
			if ( walktimer < 10 )
				walktimer = 9.5;
			if ( walktimer >= 10 && walktimer < 20 )
				walktimer = 19.5;
			if ( walktimer >= 20 && walktimer < 30 )
				walktimer = 29.5;
			if ( walktimer >= 30 )
				walktimer = 39.5
			image_index = 0;
		}
		walkbuffer -= 0.75 * timescale;
	}
	
	// Get facing sprite
	public function GetFacingSprite()
	{
		if ( fun != 0 )
		{
			var done = false;
			switch( sprite_index )
			{
				case null:
					break;
				case global.spr_ceroba_guard_1:
					if ( image_index > image_number - 1 )
					{
						image_index = image_number - 1;
						image_speed = 0;
					}
					if ( sprite == global.spr_ceroba_guard_1 )
						break;
					sprite_index = global.spr_ceroba_guard_2;
					image_speed = ( 2 / 5 );
					image_index = 0;
				case global.spr_ceroba_guard_2:
					if ( image_index >= image_number - 1 )
					{
						image_index = 0;
						image_speed = 0;
						fun = 0;
						done = true;
						break;
					}
					break;
				//
				case global.spr_flashback_ceroba_sit:
					if ( sprite == sprite_index )
					{
						if ( image_index > ( image_number - 1 ) )
						{
							image_index = ( image_number - 1 );
							image_speed = 0;
						}
					}
					else
					{
						if ( image_index >= 1 )
							image_speed = -( 2 / 5 );
						if ( image_index < 1 )
						{
							image_index = 0;
							image_speed = 0;
							fun = 0;
							done = true;
							break;
						}
					}
					break;
				default:
					done = true;
			}
			if ( ( done ) && ( ( fun == 0 ) || ( sprite_index != sprite ) ) )
			{
				if ( sprite == -1 )
				{
					fun = 0;
					image_speed = 0;
					image_index = 0;
				}
				else
				{
					fun = 1;
					sprite_index = sprite;
					switch( sprite )
					{
						case global.spr_ceroba_guard_1:
							image_index = 0;
							image_speed = ( 2 / 5 );
							break;
						case global.spr_flashback_ceroba_sit:
							image_index = 0;
							image_speed = ( 2 / 5 );
							break;
						case global.spr_new_home_03_pref_ceroba_loop:
							image_speed = 1 * ( 5 / 30 );
							break;
					}
				}
			}
		}
		if ( fun == 0 )
		{
			var dsprite = ( runmove ) ? this.drunsprite : this.dsprite;
			var rsprite = ( runmove ) ? this.rrunsprite : this.rsprite;
			var usprite = ( runmove ) ? this.urunsprite : this.usprite;
			var lsprite = ( runmove ) ? this.lrunsprite : this.lsprite;
			switch( facing )
			{
				case 1:
					sprite_set( rsprite );
					break;
				case 2:
					sprite_set( usprite );
					break;
				case 3:
					sprite_set( lsprite );
					break;
				case 0:
				default:
					sprite_set( dsprite );
			}
		}
		offset_x = 0.5;
		offset_y = 15;
		image_xscale = 1;
		image_yscale = 1;
		switch( sprite_index )
		{
			case global.spr_ceroba_up_walk:
				break;
			case global.spr_ceroba_right_walk:
			case global.spr_ceroba_left_walk:
				offset_x = 1.5;
				break;
			case global.spr_ceroba_down_walk:
				offset_y -= 1;
				break;
			case global.spr_ceroba_left_run:
				offset_x = -0.5;
				offset_y += 1;
				break;
			case global.spr_ceroba_right_run:
				offset_x = 0.5;
				offset_y += 1;
				break;
			case global.spr_ceroba_down_run:
				offset_x = 1.5;
				offset_y -= 2;
				break;
			case global.spr_flashback_ceroba_sit:
				offset_x = 1.5;
				if ( image_index >= 8 )
					offset_y -= 1;
				image_xscale = ( body.hDir > 0 ) ? -1 : 1;
				break;
			case global.spr_flashback_ceroba_worried:
				offset_x = 0;
				offset_y -= 4;
				image_xscale = ( body.hDir < 0 ) ? 1 : -1;
				break;
			case global.spr_ceroba_guard_1:
			case global.spr_ceroba_guard_2:
				offset_x = 1.5;
				image_xscale = ( body.hDir < 0 ) ? -1 : 1;
				break;
			case global.spr_ceroba_cool:
			case global.spr_ceroba_cool_alt:
				offset_x = 0.5;
				image_xscale = ( body.hDir > 0 ) ? -1 : 1;
				break;
			case global.spr_new_home_03_pref_ceroba_loop:
				offset_x = 163.5;
				offset_y = 135;
				break;
		}
	}
}

// Battle
class obj_ceroba_battle extends GMObject
{	
	public const float_height = 50;
	
	public var phase = 0;
	
	public var floatin = 0;
	public var fadein = 0;
	public var fadein_wait = 0;
	
	public var offset_x = 0;
	public var offset_y = 0;
	
	// Phase 1
	public var mask = global.spr_ceroba_transformation_p1_mask_start;
	public var mask_frame = 0;
	public var mask_x = 0;
	public var mask_y = 0;
	public var head = global.spr_ceroba_head;
	public var head_x = 3;
	public var head_y = -122;
	public var hair = global.spr_ceroba_ponytail;
	public var hair_x = 5;
	public var hair_y = -177;
	public var staff = global.spr_ceroba_staff_battle;
	public var staff_x = -14;
	public var staff_y = -99;
	public var hand_left = global.spr_ceroba_hand_left;
	public var hand_left_x = -18;
	public var hand_left_y = -116;
	public var hand_right = global.spr_ceroba_hand_right;
	public var hand_right_x = 28;
	public var hand_right_y = -123;
	// Phase 2 
	public var cape_1 = global.spr_ceroba_cape_1;
	public var cape_1_x = -8;
	public var cape_1_y = -178;
	public var cape_2 = global.spr_ceroba_cape_2;
	public var cape_2_x = -30;
	public var cape_2_y = -190;
	public var legs = global.spr_ceroba_legs;
	public var legs_x = -42;
	public var legs_y = -174;
	public var sideburn = global.spr_ceroba_sideburn;
	public var sideburn_1_x = -1;
	public var sideburn_1_y = -208;
	public var sideburn_2_x = 0;
	public var sideburn_2_y = -208;
	
	public var anim_loop_time = ( 30 * 4 );
	public var anim_stretch_current = 1;
	public var anim_stretch_max = 1.1;
	public var anim_stage = 1;
	public var anim_inc_multiplier = 2;
	public var anim_inc_multiplier_max = 2;
	
	public var damage_disjoint_count = 0;
	public var damage_disjoint_x = 0;
	
	public function obj_ceroba_battle()
	{
		super();
		sprite_index = global.spr_ceroba_body;
		image_speed = 0;
	}
	
	override public function Cleanup()
	{
		super.Cleanup();
		
	}
	
	override public function Create()
	{
		super.Create();
		Create_Phase1();
	}
	
	public function Create_Phase1()
	{
		fadein = 0;
		floatin = 0;
		fadein_wait = 0;
		x = 0;
		y = 0;
		image_yscale = 1;
		mask = global.spr_ceroba_transformation_p1_mask_start;
		mask_frame = 0;
		mask_x = 0;
		mask_y = -174
		head = global.spr_ceroba_head;
		head_x = 3;
		head_y = -122;
		hair = global.spr_ceroba_ponytail;
		hair_x = 5;
		hair_y = -177;
		staff = global.spr_ceroba_staff_battle;
		staff_x = -14;
		staff_y = -99;
		
		anim_loop_time = ( 30 * 4 );
		anim_stretch_current = 1;
		anim_inc_multiplier = 2;
	}
	
	public function Create_Phase2()
	{
		fadein_wait = 0;
		x = 0;
		image_yscale = 1;
		mask = global.spr_ceroba_transformation_p1_mask_start;
		mask_x = 0;
		mask_y = -170;
		head = global.spr_ceroba_phase_2_head;
		head_x = -94;
		head_y = -256;
		hair = global.spr_ceroba_hair;
		hair_x = 2;
		hair_y = -145;
		staff = global.spr_ceroba_phase_2_staff;
		staff_x = -54;
		staff_y = -260;
		
		anim_loop_time = ( 30 * 3 );
		anim_stretch_current = 1;
		anim_inc_multiplier = 2;
	}
	
	// 
	
	override public function Draw()
	{
		var x = this.x - ( offset_x );
		var y = this.y - ( offset_y );
		
		var _xsc = 1;
		var _ysc = 1;
		
		var blend = image_blend;
		
		if ( sprite_index == global.spr_ceroba_body )
		{
			var rot = ( 1 - image_yscale ) * 35;
			draw_monster_part_ext_outlined( staff, 0, x + staff_x - ( rot ), y + ( staff_y * image_yscale ), image_xscale, 1, image_angle + ( rot * 0.5 ), blend, image_alpha );
			draw_sprite_ext( sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, blend, image_alpha );
			draw_monster_part_ext_outlined( hair, 0, x + hair_x, y + ( hair_y * image_yscale ), image_xscale, 1, image_angle, blend, image_alpha );
			draw_monster_part_ext( hand_left, 0, x + hand_left_x - ( rot ), y + ( hand_left_y * image_yscale ), image_xscale, 1, image_angle + ( rot * 0.5 ), blend, image_alpha );
			draw_monster_part_ext( hand_right, 0, x + hand_right_x, y + ( hand_right_y * image_yscale ), image_xscale, 1, image_angle - ( rot * 1.5 ), blend, image_alpha );
			draw_monster_part_ext( head, 0, x + head_x, y + ( head_y * image_yscale ), image_xscale, 1, image_angle, blend, image_alpha );
			if ( body )
			{
				body.y = y;
				body.characterH = 225;
			}
		}
		else
		{
			if ( fadein < 1 )
			{
				blend = merge_color( c_black, blend, ( fadein * 2 ) - 1 );
			}
			var drawmask = false;
			var drawhair = false;
			
			if ( sprite_index == ( global.spr_ceroba_p2_1 ) )
			{
				if ( fadein < 1 )
					drawmask = true;
				drawhair = true;
			}
			else if ( sprite_index == global.spr_ceroba_phase_2_head )
			{
				drawhair = true;
				drawmask = true;
			}
			else if ( ( sprite_index == global.spr_ceroba_p2_idle_reveal ) && ( image_index >= 16 ) )
				drawhair = true;
			
			if ( drawhair )
			{
				draw_monster_part_ext( hair, ( current_time / 1000 ) * ( 8 ) , x + hair_x, y + ( hair_y - ( hair_y * ( image_yscale - 1 ) ) ), _xsc, _ysc, image_angle, blend, ( fadein < 1 ) ? ( ( ( mask_frame / 12 ) * 2 ) - 1 ) : 1 );
			}
			
			var mask_offset = 0;
			if ( sprite_index == global.spr_ceroba_phase_2_head )
			{
				// Phase 2b
				var frame = ( current_time / 1000 );
				
				mask_offset += ( mask_y - ( mask_y * image_yscale ) );
				
				draw_monster_part_ext( cape_2, frame * 10, x + cape_2_x, y + ( cape_2_y - ( cape_2_y * ( image_yscale - 1 ) ) ), _xsc, _ysc, image_angle, blend, image_alpha );
				draw_monster_part_ext( staff, frame * 10, x + staff_x, y + staff_y + ( 100 * ( image_yscale - 1 ) ), _xsc, _ysc, image_angle, blend, image_alpha );
				draw_monster_part_ext( legs, 0, x + legs_x, y + ( legs_y - ( legs_y * ( image_yscale - 1 ) ) ), _xsc, _ysc, image_angle, blend, image_alpha );
				draw_monster_part_ext( head, 0, x + head_x, y + head_y + mask_offset, _xsc, _ysc, image_angle, blend, image_alpha );
				draw_monster_part_ext( sideburn, frame * 10, x + sideburn_1_x, y + sideburn_1_y + mask_offset, -_xsc, _ysc, image_angle, blend, image_alpha );
				draw_monster_part_ext( sideburn, frame * 10, x + sideburn_2_x, y + sideburn_2_y + mask_offset, _xsc, _ysc, image_angle, blend, image_alpha );
				draw_monster_part_ext( cape_1, frame * 10, x + cape_1_x, y + ( cape_1_y - ( cape_1_y * ( image_yscale - 1 ) ) ), _xsc, _ysc, image_angle, blend, image_alpha );
			}
			else
				draw_sprite_ext( sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, blend, image_alpha );
			
			if ( drawmask )
			{
				draw_monster_part_ext( mask, mask_frame, x + mask_x, y + mask_y + mask_offset, _xsc, _ysc, image_angle, image_blend, image_alpha );
			}
			
			if ( body )
			{
				body.y = y;
				body.characterH = ( floatin < 1 ) ? ( 225 + ( 35 * ( floatin ) ) ) : 260;
			}
		}
	}
	
	override public function OnAnimationEnd()
	{
		switch ( sprite_index )
		{
			case global.spr_ceroba_p2_idle_reveal:
				sprite_index = global.spr_ceroba_phase_2_head;
				image_index = 0;
				image_speed = 0;
				anim_stretch_current = 1;
				anim_inc_multiplier = 2;
				mask_frame = 12;
				break;
		}
	}
	
	// 
	
	override public function Step()
	{
		super.Step();
		if ( phase == 0 )
			Step_Phase1();
		else if ( phase == 1 || phase == 2 )
			Step_Phase2();
	}
	
	public function Step_Phase1()
	{
		if ( sprite_index != global.spr_ceroba_body )
		{
			Create_Phase1();
			sprite_index = global.spr_ceroba_body;
		}
		
		if ( sprite_index == global.spr_ceroba_body )
		{
			image_yscale = anim_stretch_current;
			var anim_inc_current = ( ( anim_stretch_max - 1 ) / ( anim_loop_time / 2 ) ) * anim_inc_multiplier;
			if ( anim_stage == 1 )
			{
				anim_stretch_current += ( anim_inc_current );
				anim_inc_multiplier -= ( anim_inc_multiplier_max / ( anim_loop_time / 2 ) );
				if ( anim_stretch_current >= anim_stretch_max )
				{
					anim_stretch_current = anim_stretch_max;
					anim_stage = 2;
					anim_inc_multiplier = anim_inc_multiplier_max;
				}
			}
			if ( anim_stage == 2 )
			{
				anim_stretch_current -= ( ( anim_stretch_max - 1 ) / ( anim_loop_time / 2 ) );
				anim_inc_multiplier -= ( ( anim_inc_multiplier_max ) / ( anim_loop_time / 2 ) );
				if ( anim_stretch_current <= 1 )
				{
					anim_stretch_current = 1;
					anim_stage = 1;
					anim_inc_multiplier = anim_inc_multiplier_max;
				}
			}
		}
	}
	
	public function Step_Phase2()
	{
		if ( ( sprite_index == global.spr_ceroba_body ) || ( phase == 1 && ( sprite_index != global.spr_ceroba_p2_1 ) ) )
		{
			Create_Phase2();
			sprite_index = global.spr_ceroba_p2_1;
			image_index = 0;
			image_speed = 1 * ( 6 / 30 );
		}
		
		if ( fadein < 1 )
		{
			var factor = 1; // ( phase == 1 ) ? 1 : 3;
			if ( floatin < 1 )
			{
				floatin += ( 1 / 30 ) * factor;
				if ( floatin >= 1 )
				{
					floatin = 1;
				}
				y = lerp( 0, -float_height, sin( floatin * ( Math.PI / 2 ) ) );
			}
			else if ( mask_frame < 12 )
			{
				mask_frame += ( 10 / 30 );
				if ( mask_frame > 12 )
					mask_frame = 12;
			}
			else
			{
				if ( ( fadein_wait < 30 ) && ( factor == 1 ) )
					fadein_wait += ( 1 );
				else
				{
					fadein += ( 1 / 30 ) * factor;
					if ( fadein >= 1 )
						fadein = 1;
				}
			}
		}
		
		if ( sprite_index == global.spr_ceroba_p2_1 )
		{
			if ( ( phase == 2 ) && ( fadein >= 1 ) )
			{
				sprite_index = global.spr_ceroba_p2_idle_reveal;
				image_index = 0;
				image_speed = 1 * ( 10 / 30 );
			}
		}
		if ( sprite_index == global.spr_ceroba_phase_2_head )
		{
			var anim_inc_current = ( ( anim_stretch_max - 1 ) / ( anim_loop_time ) ) * anim_inc_multiplier;
			if ( anim_stage == 1 )
			{
				anim_stretch_current += ( anim_inc_current );
				anim_inc_multiplier -= ( anim_inc_multiplier_max / ( anim_loop_time ) );
				if ( anim_stretch_current >= anim_stretch_max )
				{
					anim_stretch_current = anim_stretch_max;
					anim_stage = 2;
					anim_inc_multiplier = anim_inc_multiplier_max;
				}
			}
			if ( anim_stage == 2 )
			{
				anim_stretch_current -= ( ( anim_stretch_max - 1 ) / ( anim_loop_time ) );
				anim_inc_multiplier -= ( ( anim_inc_multiplier_max ) / ( anim_loop_time ) );
				if ( anim_stretch_current <= 1 )
				{
					anim_stretch_current = 1;
					anim_stage = 1;
					anim_inc_multiplier = anim_inc_multiplier_max;
				}
			}
			image_yscale = anim_stretch_current;
		}
	}
	
	// 
	
	public function draw_monster_part_ext( _spr, _img, _x, _y, _xsc, _ysc, _ang, _col, _alpha )
	{
		if ( true )
		{
			_x = Math.round( _x );
			_y = Math.round( _y );
		}
		draw_sprite_ext( _spr, _img, _x, _y, _xsc, _ysc, _ang, _col, _alpha );
	}
	
	public function draw_monster_part_ext_outlined( _spr, _img, _x, _y, _xsc, _ysc, _ang, _col, _alpha, _scale = 2 )
	{
		draw_monster_part_ext( _spr, _img, _x - ( _xsc * _scale ), _y, _xsc, _ysc, _ang, c_black, _alpha ); 
		draw_monster_part_ext( _spr, _img, _x, _y - ( _ysc * _scale ), _xsc, _ysc, _ang, c_black, _alpha ); 
		draw_monster_part_ext( _spr, _img, _x + ( _xsc * _scale ), _y, _xsc, _ysc, _ang, c_black, _alpha ); 
		draw_monster_part_ext( _spr, _img, _x, _y + ( _ysc * _scale ), _xsc, _ysc, _ang, c_black, _alpha ); 
		// 
		draw_monster_part_ext( _spr, _img, _x, _y, _xsc, _ysc, _ang, _col, _alpha ); 
	}
}
