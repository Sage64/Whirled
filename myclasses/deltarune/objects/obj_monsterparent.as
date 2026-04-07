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
	
	public var offset_x = 0;
	public var offset_y = 0;
	
	public var myself = 0;
	
	public var monster = 1;
	public var monsterstatus = 0;
	public var monstername = "Enemy";
	public var monstermaxhp = 130;
	public var monsterhp = monstermaxhp;
	public var monsterat = 1;
	public var monsterdf = 1;
	public var monsterexp = 0;
	public var monstergold = 100;
	
	public var mercymod = 0;
	public var mercymax = 100;
	
	public var recruitable = 1;
	
	public var state = 0;
	public var siner = 0;
	public var fsiner = 0;
	public var flash = 0;
	public var becomeflash = 0;
	
	// hurt
	public var attacked = 0;
	public var hurt = 0;
	public var hurtamt = 0;
	public var hurttimer = 0;
	public var hurtshake = 0;
	public var shakex = 0;
	
	public var hurt_fatal = 0;
	public var hurt_frozen = 0;
	
	public var hurtspriteoffx = 0;
	public var hurtspriteoffy = 0;
	
	// 
	
	public function obj_monsterparent()
	{
		super();
		
		image_xscale = 2;
		image_yscale = 2;
	}
	
	override public function Create()
	{
		super.Create();
		monsterhp = monstermaxhp;
		body.SetMemory( body.mymemories["monsterhp"], monsterhp );
	}
	
	public function scr_spare()
	{
		scr_spareanim();
		scr_recruit();
		scr_monsterdefeat();
		instance_destroy();
	}
	
	public function scr_recruit()
	{
		if ( recruitable )
		{
			snd_play( global.snd_sparkle_gem );
		}
	}
	
	public function scr_spareanim()
	{
		var x = this.x - ( offset_x * image_xscale );
		var y = this.y - ( offset_y * image_yscale );
		var spareanim = instance_create( x, y, obj_spareanim );
		spareanim.sprite_set( sparedsprite );
		spareanim.image_index = 0;
		spareanim.image_xscale = image_xscale;
		spareanim.image_yscale = image_yscale;
		return spareanim;
	}
	
	public function scr_monsterdefeat()
	{
		if ( monster == 1 )
		{
			monster = 0;
		}
	}
	
	public function scr_defeatrun()
	{
		var x = this.x - ( offset_x * image_xscale );
		var y = this.y - ( offset_y * image_yscale );
		var defeatanim;
		
		if ( hurt_fatal )
		{
			defeatanim = instance_create( x, y, obj_deathanim );
		}
		else if ( hurt_frozen )
		{
			defeatanim = instance_create( x, y, obj_defeatanim );
		}
		else
		{
			defeatanim = instance_create( x, y, obj_defeatanim );
		}
		
		if ( instance_exists( defeatanim ) )
		{
			defeatanim.sprite_set( hurtsprite );
			defeatanim.image_index = 0;
			defeatanim.image_xscale = image_xscale;
			defeatanim.image_yscale = image_yscale;
		}
		instance_destroy();
	}
	
	public function draw_monster_body_part_ext( _spr, _subimg, _x, _y, _xsc, _ysc, _ang, _col, _a )
	{
		draw_sprite_ext( _spr, _subimg, _x, _y, _xsc, _ysc, _ang, _col, _a );
		
	}
	
	public function scr_enemy_drawidle_generic( _sinerspd )
	{
		var x = this.x - ( offset_x * image_xscale );
		var y = this.y - ( offset_y * image_yscale );
		
		if ( state == 0 )
		{
			fsiner += 1;
			siner += _sinerspd;
			var spr = idlesprite;
			
			 if ( mercymod >= mercymax )
				spr = sparedsprite;
			
			draw_monster_body_part( spr, siner, x, y );
		}
	}
	
	public function scr_enemy_drawhurt_generic()
	{
		var x = this.x - ( offset_x * image_xscale );
		var y = this.y - ( offset_y * image_yscale );
		
		if ( state == 3 && hurttimer >= 0 )
			draw_sprite_ext( hurtsprite, 0, x + shakex + hurtspriteoffx, y + hurtspriteoffy, image_xscale, image_yscale, image_angle, image_blend, image_alpha );
	}

	
	public function scr_enemy_hurt()
	{
		hurttimer -= 1;
		if ( hurttimer < 0 )
			state = 0;
		else
		{
			if ( monster == 0 )
				scr_defeatrun();
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