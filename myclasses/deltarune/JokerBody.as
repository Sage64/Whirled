
// Jevil

package deltarune
{

import gamemaker.*;

import flash.display.*;
import flash.events.*;
import flash.utils.*;

import com.threerings.util.*
import com.whirled.*


public class JokerBody extends MonsterBody
{
	public var inst;
	
	public var jev_drawshadow = 1;
	
	
	public function JokerBody()
	{
		super();
		
		SetUseMercy( false );
		
		textsound = global.snd_txtjok;
		
		// 
		
		mymemories["shadow"] = AddMemory( "deltarune.jevil.drawshadow", 1, SetDrawShadow );
		
		mystates["default"] = EnemyState( "Default" );
		mystates["teleport"] = EnemyState( "Teleport" );
		mystates["disappear"] = EnemyState( "Disappear" );
		mystates["dance"] = EnemyState( "Dance" );
		mystates["dance_chaos"] = EnemyState( "Dance (chaos)" );
		mystates["tired"] = EnemyState( "Tired" );
		mystates["scythe"] = EnemyState( "Metamorphosis" );
		mystates["postbattle"] = EnemyState( "Post-battle" );
		
		myactions["toggle_shadow"] = AddAction_ToggleMemory( "[Toggle Shadow]", mymemories["shadow"], [0, 1] );
		
		myactions["snd_joker_oh"] = AddAction( "o", Action_PlaySound, "snd_joker_oh" );
		myactions["snd_joker_chaos"] = AddAction( "Chaos, Chaos!", Action_PlaySound, "snd_joker_chaos" );
		myactions["snd_joker_anything"] = AddAction( "ANYTHING!", Action_PlaySound, "snd_joker_anything" );
		
		// AddEnemyStates();
	}
	
	
	override public function OnStateChanged()
	{
		x = originX;
		y = originY;
		
		characterH = 0;
		characterH = ( 41 + 2 ) * 2;
		
		SetMoveSpeed( 6 );
		
		SetViewOffset( 0, y - ( ( 32 ) + characterH / 2 ) );
		
		if ( curState == null )
		{
			if ( nametag )
				nametag.alpha = 0;
			instance_destroy( enemy );
		}
		else if ( curState == mystates["disappear"] )
		{
			SetMoveSpeed( 50 );
			if ( instance_exists( enemy ) )
			{
				if ( enemy.jbody.condition != 4 )
					enemy.jbody.condition = 2;
			}
			else
			{
				enemy = instance_create( x, y, obj_joker );
				enemy.jbody.size = 0;
				enemy.jbody.condition = 4;
				nametag.alpha = 0;
			}
				
		}
		else
		{
			if ( !instance_exists( enemy ) )
			{
				enemy = instance_create( x, y, obj_joker );
				enemy.jbody.condition = 3;
				enemy.jbody.size = 0;
				enemy.jbody.nextcon = 0;
			}
			
			enemy.jbody.fade = 0;
			enemy.jbody.nextcon = 0;
			
			if ( curState == mystates["teleport"] )
			{
				SetMoveSpeed( 50 );
			}
			
			if ( curState == mystates["scythe"] )
			{
				if ( prevState == mystates["disappear"] )
					enemy.jbody.condition = 3;
				enemy.jbody.nextcon = 5;
			}
			else if ( curState == mystates["postbattle"] )
			{
				enemy.jbody.fade = 1;
				enemy.jbody.dancelv = 0;
			}
			else if ( curState == mystates["dance"] )
			{
				enemy.jbody.dancelv = 1;
				characterH += 8;
			}
			else if ( curState == mystates["dance_chaos"] )
			{
				enemy.jbody.dancelv = 3;
				SetViewOffset( 0, y - ( ( 12 ) + characterH / 2 ) );
			}
			else if ( curState == mystates["tired"] )
			{
				enemy.jbody.dancelv = 2;
			}
			else
			{
				enemy.jbody.dancelv = 0;
				enemy.jbody.nextcon = 0;
			}
		}
	}
	
	override public function OnUpdateLook()
	{
		super.OnUpdateLook();
		//
		if ( curState == mystates["teleport"] && isMoving )
		{
			
		}
		else if ( instance_exists( enemy ) )
		{
			if ( false && ( curState == mystates["dance"] || curState == mystates["dance_chaos"] ) )
			{
				
			}
			else
			{
				enemy.image_xscale = image_xscale;
				if ( curState == mystates["default"] )
				{
					if ( isSleeping )
						enemy.jbody.dancelv = 2;
					else
						enemy.jbody.dancelv = 0;
				}
			}
		}
		
	}
	
	override public function OnMoveStart()
	{
		if ( instance_exists( enemy ) )
		{
			if ( enemy.jbody.condition == 4 )
				return;
			if ( enemy.jbody.condition == 5 )
				return;
			
			if ( curState == mystates["teleport"] )
			{
				enemy.state = 0;
				enemy.jbody.sndcon = 1;
				enemy.jbody.condition = 2;
				enemy.jbody.size = 0;
				//enemy.jbody.size = 0;
			}
		}
	}
	
	override public function OnMoveStop()
	{
		if ( instance_exists( enemy ) )
		{
			if ( enemy.jbody.condition == 4 )
					return;
			if ( enemy.jbody.condition == 5 )
				return;
			if ( curState == mystates["teleport"] )
			{
				enemy.state = 0;
				enemy.jbody.condition = 3;
				enemy.jbody.size = 0;
			}
		}
	}
	
	public function Action_ToggleShadow( data = null )
	{
		SetMemory( "deltarune.jevil.drawshadow", ( jev_drawshadow == 1 ) ? 0 : 1 );
	}
	
	public function SetDrawShadow( val = 0 )
	{
		if ( val == 1 )
			jev_drawshadow = 1;
		else
			jev_drawshadow = 0;
	}
}

}

import gamemaker.*;
import deltarune.*;
import deltarune.objects.*;

import flash.display.*;
import flash.utils.getTimer;

class obj_joker extends obj_monsterparent
{
	
	public var jbody;
	
	public var thissprite;
	
	public var mhpratio = 1;
	
	public function obj_joker()
	{
		super();
		
		image_xscale = 2;
		image_yscale = 2;
		
		idlesprite = global.spr_joker_main;
		hurtsprite = global.spr_joker_main;
		sparedsprite = global.spr_joker_main;
		
		monstermaxhp = 3500;
		monsterhp = monstermaxhp;
		monsterat = 10;
		monsterdf = 5;
		
		jbody = instance_create( x, y, obj_joker_body );
		jbody.joker = this;
	}
	
	override public function Cleanup()
	{
		super.Cleanup();
		
		instance_destroy( jbody );
	}
	
	override public function Step()
	{
		if ( state == 3 )
		{
			if ( hurttimer > 0 )
			{
				hurttimer = 0;
				jbody.timer = 0;
				jbody.condition = 1;
				jbody.siner = 0;
				jbody.maxdist += 20 + ( hurtamt / 5 );
				
				mhpratio = 1;
				
				jbody.floatsinerspeed = 1 + ( 1 - mhpratio );
				
				switch( irandom( 2 ) )
				{
					case 0:
						snd_play( global.snd_joker_ha0 );
						break;
					case 1:
						snd_play( global.snd_joker_ha1 );
						break;
					default:
						snd_play( global.snd_joker_laugh0 );
						break;
				}
			}
			hurttimer -= 1;
			if ( hurttimer < 0 )
				state = 0;
		}
		if ( state == 0 )
		{
			siner += 1;
			thissprite = idlesprite;
		}
	}
	
	override public function Draw()
	{
		if ( state == 0 )
		{
			
		}
		
	}
	
}

class obj_joker_body extends DeltaruneObject
{
	public var joker;
	
	public var condition = 0;
	public var nextcon = 0;
	
	public var sndcon = 0;
	
	public var timer = 0;
	public var s_xscale = 2;
	public var s_yscale = 2;
	public var s_sprite = global.spr_joker_teleport;
	public var s_y = 0;
	public var s_vspeed = 0;
	public var spintimer = 0;
	public var s_alpha = 1;
	
	public var xsiner = 0;
	public var ysiner = 0;
	public var rotsiner = 0;
	
	public var maxchain = 6
	public var maxdist = 0;
	public var size = 2;
	
	public var floatsiner = 0;
	public var floatsinerspeed = 1;
	public var fly = 0;
	public var flyx = 0;
	
	public var dancelv = 0;
	public var dancesiner = 0;
	public var dancemade = 0;
	public var dalpha = new Array( 7 );
	public var shadowx = new Array( 7 );
	public var shadowy = new Array( 7 );
	public var sfactor = new Array( 7 );
	
	public var ji = 0;
	public var siner = 0;
	public var sinadd;
	public var sinx;
	public var siny;
	
	public var fade = 0;
	
	public function obj_joker_body()
	{
		var i;
		super();
		
		image_speed = 0.334;
		image_xscale = 2;
		image_yscale = 2;
		
		for ( i = 0; i < 7; ++i )
		{
			shadowx[i] = 0;
			shadowy[i] = 0;
			sfactor[i] = 1;
		}

	}
	
	override public function Step()
	{
		var ts = timescale_delta;
		if ( instance_exists( joker ) )
			image_xscale = joker.image_xscale;
		var i;
		floatsiner += floatsinerspeed * ts;
		fly = sin( floatsiner / 8 ) * 3 * ( ( floatsinerspeed * 2 ) - 1 );
		flyx = 0;
		if ( condition != 4 )
		{
			if ( dancelv >= 1 )
				flyx = cos( floatsiner / 8 ) * 3 * ( ( floatsinerspeed * 2 ) - 1 );
			if ( dancelv == 4 )
			{
				flyx = 0;
				fly = 0;
			}
		}
		if ( condition == 0 )
			condition = nextcon;
		if ( condition == 0 )
		{
			
			
			if ( dancelv == 3 )
				dancesiner += 1 * ts;
			for ( i = 0; i < 7; i += 1 )
			{
				if ( i >= 1 )
				{
					shadowx[i] += sin(i + (floatsiner / 5)) * 8 * sfactor[i] * ts;
					shadowy[i] += cos(i + (floatsiner / 5)) * 4 * sfactor[i] * ts;
				}
				dalpha[i] = sin( i + ( dancesiner / 9 ) );
				if (dalpha[i] < 0 && i >= 1)
				{
					shadowx[i] = 60 - random( 120 );
					shadowy[i] = 60 - random( 120 );
					sfactor[i] = 1.5 - random( 3 );
				}
			}
		}
		else if ( condition == 1 )
		{
			if ( maxdist >= 150 )
				maxdist = 150;
			sinadd = 0.8 + (maxdist / 50);
			if (sinadd < 0.8)
				sinadd = 0.8;
			if (sinadd > 2)
				sinadd = 2;
			siner += sinadd * ( image_xscale / 2 );
			sinx = sin(siner / 4) * maxdist;
			siny = -abs(sin(siner / 4)) * (maxdist * 0.7);
			ji = 0;
			if (sinx > (maxdist / 2) && maxdist > 15)
				ji = image_xscale < 0 ? 2 : 1;
			if (sinx < (-maxdist / 2) && maxdist > 15)
				ji = image_xscale < 0 ? 1 : 2;
			if (maxdist < 4)
				ji = 3;
			maxdist -= 1;
			if (maxdist <= 0)
			{
				sinx = 0;
				siny = 0;
				maxdist = 0;
				condition = 0;
			}
		}
		else if ( condition == 2 )
		{
			if ( sndcon == 0 )
			{
				snd_play( global.snd_spearappear );
				sndcon = 1;
			}
			size -= 0.5;
			if ( body.nametag )
				body.nametag.alpha = size / 2;
			if ( size <= 0 )
			{
				size = 2;
				condition = 4;
				sndcon = 0;
				body.SetViewOffset( 0, y - ( ( 0 ) + body.characterH / 2 ) );
			}
		}
		else if ( condition == 3 )
		{
			if ( sndcon == 0 )
			{
				snd_play( global.snd_spearappear );
				sndcon = 1;
			}
			size += 0.5 * ts;
			if ( size >= 2 )
			{
				size = 2;
				condition = 0;
				sndcon = 0;
				body.SetViewOffset( 0, y - ( ( 0 ) + body.characterH / 2 ) );
			}
			if ( body.nametag )
				body.nametag.alpha = size / 2;
		}
		// Metamorphosis
		else if ( condition == 5 )
		{
			ts = 1;
			if ( timer == 0 )
			{
				spintimer = 0;
				s_xscale = 2;
				s_yscale = 2;
				s_sprite = global.spr_joker_teleport;
				s_y = 0;
				s_vspeed = 0;
				s_alpha = 1;
				snd_play( global.snd_joker_metamorphosis );
				body.SetViewOffset( 0, y - ( ( 0 ) + body.characterH / 2 ) );
			}
			timer += 1 * ts;
			if ( timer >= 1 && timer <= 3 )
			{
				s_xscale *= 1.3;
				s_yscale *= 0.7;
			}
			else if ( timer >= 5 && timer <= 15 )
			{
				s_xscale *= 0.7;
				s_yscale *= 1.3;
			}
			else if ( timer >= 15 && timer <= 30 )
			{
				spintimer += 1 * ts;
				s_xscale = sin( spintimer / 3 ) * 2;
				s_sprite = global.spr_joker_scythebody;
				if ( s_xscale > 2 )
					s_xscale = 2;
				if ( s_yscale > 2 )
				{
					s_yscale *= 0.7;
					if ( s_yscale <= 2 )
					{
						s_yscale = 2;
						body.SetViewOffset( 0, y - ( ( 100 ) + body.characterH / 2 ) );
					}
				}
			}
			else if ( timer >= 30 && timer < 41 )
			{
				spintimer += 1 * ts;
				s_xscale = sin( spintimer / 3 ) * 2;
				s_vspeed -= 3;
				s_y += s_vspeed * ts;
				s_alpha -= 0.1 * ts;
			}
			else if ( timer >= 41 )
			{
				timer = 0;
				condition = 4;
				body.SetViewOffset( 0, y - ( ( 0 ) + body.characterH / 2 ) );
			}
			if ( body.nametag )
				body.nametag.alpha = s_alpha;
		}
		if ( condition == 4 )
		{
			if ( ( body.curState == body.mystates["teleport"] && body.isMoving ) || body.curState == body.mystates["disappear"] || ( body.curState == body.mystates["scythe"] ) )
			{
				
			}
			else
			{
				timer = 0;
				condition = 3;
				size = 0;
			}
		}
	}
	
	override public function Draw()
	{
		var floatheight = 20;
		var i;
		var offx = x - ( 2 * image_xscale );
		var offy = y - ( 21 * 2 ) - (  floatheight );// + 18;
		var finalalpha = image_alpha;
		
		body.x = offx + flyx;
		body.y = ( offy + 22 * 2 ) + fly - y;
		
		
		if ( condition == 0 )
		{
			if ( dancelv == 0 )
			{
				var fade_a = 1;
				if ( fade )
					fade_a = abs( sin( floatsiner / 13 ) );
				draw_sprite_ext( global.spr_joker_main, 0, offx + flyx, offy + fly, image_xscale, image_yscale, image_angle, image_blend, fade_a * image_alpha );
				finalalpha = fade_a * image_alpha;
			}
			else if ( dancelv == 1 )
				draw_sprite_ext( global.spr_joker_dance, floatsiner / 3, offx + flyx, offy + fly, abs( image_xscale ), image_yscale, image_angle, image_blend, image_alpha );
			else if ( dancelv == 2 )
				draw_sprite_ext( global.spr_joker_tired, 0, offx + flyx, offy + fly, image_xscale, image_yscale, image_angle, image_blend, image_alpha );
			else if ( dancelv == 3 )
			{
				for ( i = 0; i < 7; i += 1 )
				{
					draw_sprite_ext( global.spr_joker_dance, ( dancesiner / 2 ) + ( i / 4 ), offx + shadowx[i], offy + shadowy[i], abs( image_xscale ), image_yscale, image_angle, image_blend, dalpha[i] * image_alpha );
				}
				i = 1;
				body.x += shadowx[i];
				body.y += shadowy[i];
				finalalpha = dalpha[i] * image_alpha;
			}
			if (dancelv == 4)
				draw_sprite_ext( global.spr_joker_teleport, 1, offx + flyx, offy + fly, image_xscale, image_yscale, image_angle, image_blend, image_alpha );
			if ( body.nametag )
				body.nametag.alpha = finalalpha;
		}
		else if ( condition == 1 )
		{
			for (i = 0; i < (maxchain - 1); i += 1)
				draw_sprite_ext( global.spr_jokerchain, ji, (offx + (sinx * (i / maxchain))) - 2, offy + 6 + ((siny - 32) * (i / maxchain)) + fly, image_xscale, image_yscale, 0, image_blend, image_alpha );
			draw_sprite_ext( global.spr_jokerbody, 0, offx - ( 42 * 0 ), (offy + fly) - ( 2 * 0 ), image_xscale, image_yscale, image_angle, image_blend, image_alpha );
			draw_sprite_ext( global.spr_jokerhead, ji, (offx + sinx) - 2, (offy + siny + fly) - 14, image_xscale, image_yscale, image_angle, image_blend, image_alpha );
			body.x += sinx;
			body.y += siny;
			if ( body.nametag )
				body.nametag.alpha = finalalpha;
		}
		else if ( condition == 2 || condition == 3 )
		{
			draw_sprite_ext( global.spr_joker_main, 0, offx, offy + fly, ( image_xscale / 2 ) * size, image_yscale, image_angle, image_blend, image_alpha );
		}
		else if ( condition == 4 )
		{
			if ( GMControl.isControl )
			{
				finalalpha = image_alpha * ( 0.125 + ( 0.1 * sin( floatsiner / 8 ) ) );
				draw_sprite_ext( global.spr_joker_main, 0, offx, offy + fly, ( image_xscale ), image_yscale, image_angle, image_blend, finalalpha );
				body.x = offx;
				if ( body.nametag )
					body.nametag.alpha = finalalpha;
			}
		}
		else if ( condition == 5 )
		{
			draw_sprite_ext(s_sprite, 0, offx, offy + s_y, s_xscale * ( image_xscale / 2 ), s_yscale * ( image_yscale / 2 ), 0, image_blend, s_alpha );
			body.y += s_y + 20 - ( 20 * ( s_yscale * ( image_yscale / 2 ) ) );
		}
		
		// Shadow
		if ( condition == 0 || condition == 1 || ( condition == 4 && GMControl.isControl ) )
		{
			if ( dancelv <= 2 && ( body && body.jev_drawshadow ) )
			{
				draw_set_alpha( finalalpha );
				draw_set_color( c_black );
				var ypos = ( y );
				var x1 = ( ( x + ( sprite_width / 2 ) ) - 25 - fly ) + flyx;
				var y1 = ypos - ( fly / 2 );
				var x2 = x + ( sprite_width / 2 ) + 25 + fly + flyx;
				var y2 = ypos + 5 + ( fly / 2 );
				draw_rectangle( x1, y1, x2, y2, false );
				draw_set_alpha( 1 );
			}
		}
	}
	
	
}