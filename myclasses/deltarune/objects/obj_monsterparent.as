package deltarune.objects
{

import deltarune.*;
import gamemaker.*;

public class obj_monsterparent extends DeltaruneObject
{
	public var idlesprite;
	public var hurtsprite;
	public var sparedsprite;
	//
	
	public var myself = 0;
	
	public var monster = 1;
	public var monstername = "Enemy";
	public var monstermaxhp = 130;
	public var monsterhp = monstermaxhp;
	public var monsterstatus = 0;
	
	public var mercymod = 0;
	public var mercymax = 100;
	
	public var state = 0;
	public var siner = 0;
	public var fsiner = 0;
	public var flash = 0;
	public var becomeflash = 0;
	
	// hurt
	public var attacked = 0;
	public var hurt = 0;
	public var hurttimer = 0;
	public var hurtshake = 0;
	public var shakex = 0;
	
	public var hurtspriteoffx = 0;
	public var hurtspriteoffy = 0;
	
	// 
	
	public function obj_monsterparent()
	{
		super();
		
		image_xscale = 2;
		image_yscale = 2;
	}
	
	
	public function scr_enemy_drawidle_generic( _sinerspd )
	{
		if ( state == 0 )
		{
			fsiner += 1;
			siner += _sinerspd;
			var spr = idlesprite;
			
			// if ( global.mercymod[myself] >= global.mercymax[myself] )
			//	spr = sparedsprite;
			
			draw_monster_body_part( spr, siner, x, y );
		}
	}
	
	public function scr_enemy_drawhurt_generic()
	{
		if (state == 3 && hurttimer >= 0)
			draw_sprite_ext(hurtsprite, 0, x + shakex + hurtspriteoffx, y + hurtspriteoffy, image_xscale, image_yscale, image_angle, image_blend, image_alpha );
	}

	
	public function scr_enemy_hurt()
	{
		hurttimer -= 1;
		if (hurttimer < 0)
			state = 0;
		else
		{
			//if (global.monster[myself] == 0)
			//	scr_defeatrun();
			hurtshake += 1;
			if (hurtshake > 1)
			{
				if (shakex > 0)
					shakex -= 1;
				if (shakex < 0)
					shakex += 1;
				shakex = -shakex;
				hurtshake = 0;
			}
		}
	}
	
	public function scr_enemyhurt_tired_after_damage( perc )
	{
		return;
	}
	
	public function draw_monster_body_part( _sprite, _image, _x, _y )
	{
		draw_sprite_ext( _sprite, _image, _x, _y, image_xscale, image_yscale, image_angle, image_blend, image_alpha );
		
		//if ( flash == 1 )
		//	draw_sprite_ext_flash( _sprite, _image, _x, _y, image_xscale, image_yscale, image_angle, image_blend, ( -cos( fsiner / 5 ) * 0.4 ) + 0.6 );
	}

}


}