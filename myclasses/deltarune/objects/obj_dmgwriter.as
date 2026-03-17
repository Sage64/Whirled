package deltarune.objects
{

import deltarune.*;
import gamemaker.*;

public class obj_dmgwriter extends DeltaruneObject
{
	public var spr_battlemsg;
	
	public var spec = 0;
	public var delaytimer = 0;
	public var delay = 2;
	public var active = 0;
	public var damage = 50;
	public var bounces = 0;
	public var type = -1;
	public var stretch = 0.2;
	public var stretchgo = 1;
	public var lightf = merge_color(c_purple, c_white, 0.6);
	public var lightb = merge_color(c_aqua, c_white, 0.5);
	public var lightg = merge_color(c_lime, c_white, 0.5);
	public var lighty = merge_color(c_yellow, c_white, 0.3);
	public var init = 0;
	public var kill = 0;
	public var killtimer = 0;
	public var killactive = 0;

	//with (obj_dmgwriter)
	//{
	//	if (type != 3)
	//		killtimer = 0;
	//}

	public var specialmessage = 0;
	public var stayincamera = 1;
	public var xx = 0;//camerax();
	public var message_sprite;//scr_84_get_sprite("spr_battlemsg");
	
	public var col;
	public var damagemessage = "";
	public var flip = 0;
	public var message;
	public var vstart = 0;
	
	public function Sprites()
	{
		spr_battlemsg = sprite_get( "spr_battlemsg" );
	}
	
	public function obj_dmgwriter()
	{
		Sprites();
		
		
	}
	
	override public function Step()
	{
		if (delaytimer < delay)
		{
			//with (obj_dmgwriter)
				killtimer = 0;
		}
		delaytimer += 1;
		if (delaytimer == delay)
		{
			vspeed = -5 - random(2);
			hspeed = 10;
			vstart = vspeed;
			flip = 90;
		}
		if (delaytimer >= delay)
		{
			col = (c_white);
			if (type == 0)
				col = (lightb);
		   else  if (type == 1)
				col = (lightf);
			else if (type == 2)
				col = (lightg);
			if (type == 3)
				col = (c_lime);
			if (type == 4)
				col = (c_red);
			if (type == 5 && damage < 0)
				col = (c_ltgray);
			if (type == 6)
				col = (lighty);
			
			message = specialmessage;
			
			if (damage == 0)
				message = 1;
			if (type == 4)
				message = 2;
			if (type == 5 && damage == 100)
				message = 5;
			if (type != 5)
				draw_set_font(global.damagefont);
			if (type == 5)
				draw_set_font(global.damagefontgold);
			if (hspeed > 0)
				hspeed -= 1;
			if (hspeed < 0)
				hspeed += 1;
			if (abs(hspeed) < 1)
				hspeed = 0;
			if (init == 0)
			{
				damagemessage = string(damage);
				if (type == 5)
					damagemessage = "+" + string(damage) + "%";
				if (type == 5 && damage < 0)
					damagemessage = string(damage) + "%";
				init = 1;
			}
			
			if (bounces < 2)
				vspeed += 1;
			if (y > ystart && bounces < 2 && killactive == 0)
			{
				y = ystart;
				vspeed = vstart / 2;
				bounces += 1;
			}
			
			if (bounces >= 2 && killactive == 0)
			{
				vspeed = 0;
				y = ystart;
			}
			
			if (stretchgo == 1)
				stretch += 0.4;
			
			if (stretch >= 1.2)
			{
				stretch = 1;
				stretchgo = 0;
			}
			
			killtimer += 1;
			
			if (killtimer > 35)
				killactive = 1;
			
			if (killactive == 1)
			{
				kill += 0.08;
				y -= 4;
			}
			
			if (kill > 1)
				instance_destroy();
		}

		if (global.fighting == 1)
		{
			if (stayincamera == 1)
			{
				if (x >= (xx + 600))
					x = xx + 600;
			}
		}

	}
	
	override public function Draw()
	{
		draw_set_color( col );
		if (message == 0)
		{
			draw_set_alpha(1 - kill);
			draw_set_halign(fa_right);
			if (spec == 0)
				draw_text_transformed(x + 30, y, damagemessage, 2 - stretch, stretch + kill, 0);
			if (spec == 1)
				draw_text_transformed(x + 30, y, damagemessage, 2 - stretch, stretch + kill, 90);
			draw_set_halign(fa_left);
			draw_set_alpha(1);
		}
		else
		{
			if (message == 1)
				draw_sprite_ext(message_sprite, 0, x + 30, y, 2 - stretch, stretch + kill, 0, draw_get_color(), 1 - kill);
			if (message == 2)
				draw_sprite_ext(message_sprite, 1, x + 30, y, 2 - stretch, stretch + kill, 0, c_red, 1 - kill);
			if (message == 3)
				draw_sprite_ext(message_sprite, 2, x + 30, y, 2 - stretch, stretch + kill, 0, c_lime, 1 - kill);
			if (message == 4)
				draw_sprite_ext(message_sprite, 3, x + 30, y, 2 - stretch, stretch + kill, 0, c_lime, 1 - kill);
			if (message == 5)
				draw_sprite_ext(message_sprite, 5, x + 30, y, 2 - stretch, stretch + kill, 0, c_lime, 1 - kill);
			if (message == 6)
				draw_sprite_ext(message_sprite, 8, x + 30, y, 2 - stretch, stretch + kill, 0, c_white, 1 - kill);
			if (message == 7)
				draw_sprite_ext(message_sprite, 9, x + 30, y, 2 - stretch, stretch + kill, 0, c_white, 1 - kill);
			if (message == 8)
				draw_sprite_ext(message_sprite, 10, x + 30, y, 2 - stretch, stretch + kill, 0, c_white, 1 - kill);
			if (message == 9)
				draw_sprite_ext(message_sprite, 11, x + 30, y, 2 - stretch, stretch + kill, 0, c_white, 1 - kill);
		}
	}
}


}