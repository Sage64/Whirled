
// Spamton

package deltarune
{

import gamemaker.*;

import flash.display.*;
import flash.events.*;
import flash.utils.*;

import com.threerings.util.*
import com.whirled.*


public class SpamtonBody extends MonsterBody
{
	public static var spr_spamton_cherub;
	
	public var inst;
	public var sp_actor;
	public var sneo;
	public var sneo_ghost;
	
	public var sneo_drawvines = 1;
	
	public var spamton_vocab = {};
	public var spamton_vocab_neo = {};
	
	public function SpamtonBody()
	{
		spr_spamton_cherub = sprite_get( "spr_spamton_cherub" );
		
		super();
		
		// spamton
		mystates["default"] = SpamState( "Default" ); 
		mystates["hidden"] = DWState( "Hidden" );
		
		myactions["f1"] = AddAction( "[Press F1 For] HELP (close)", Anim_F1, [ 50, 70 ] );
		myactions["f1_far"] = AddAction( "[Press F1 For] HELP (far)", Anim_F1, [ 180, 70 ] );
		myactions["f1_tall"] = AddAction( "[Press F1 For] HELP (tall)", Anim_F1, [ 100, 140 ] );
		
		mystates["slide1"] = SpamState( "Sliding" ); 
		mystates["slide2"] = SpamState( "Sliding (faster)" ); 
		mystates["laugh"] = SpamState( "Laugh" ); 
		mystates["laugh_shaking"] = SpamState( "Laugh (shaking)" ); 
		mystates["laugh_glitch"] = SpamState( "Laugh (glitch)" ); 
		
		mystates["garbage"] = SpamState( "* LIVING IN A GODDAMN GARBAGE CAN???" ); 
		mystates["flag20_3"] = SpamState( "* [[Genorisity]]" ); 
		mystates["f1_spam"] = SpamState( "VERY helpful" ); 
		mystates["attack1"] = SpamState( "ENL4RGE" ); 
		
		// spamton_neo
		mystates["neo_idle"] = NeoState( "NEO - Idle" );
		
		mymemories["neo_vines"] = AddMemory( "deltarune.spamton.drawvines", 1, SetVinesVisible );
		myactions["neo_togglevines"] = AddAction( "[NEO - Toggle Vines]", Action_ToggleVines );
		
		// Preview
		mystates["neo_preview"] = NeoState( "NEO - Preview / Ambush" );
		myactions["neo_reveal"] = AddAction( "NEO - Reveal", Anim_Reveal );
		//myactions["neo_reveal"] = AddAction( "NEO - Reveal (shortened)", Anim_Reveal, true );
		mystates["neo_pester"] = NeoState( "NEO - * KRIS." );
		mystates["neo_pester2"] = NeoState( "NEO - * KRIS. KRIS. KRIS." );
		mystates["neo_pester3"] = NeoState( "NEO - * BIG" );
		mystates["neo_pester4"] = NeoState( "NEO - * VERY   VERY    BIG" );
		mystates["neo_pester5"] = NeoState( "NEO - * H E A V E N" );
		
		mystates["neo_jitter"] = NeoState( "NEO - Jitter" );
		mystates["neo_shocked"] = NeoState( "NEO - Shocked/Hurt" );
		
		// Shootydance
		mystates["neo_shootydance"] = NeoState( "NEO - Shooty Dance" );
		mystates["neo_happy"] = NeoState( "NEO - * [FRIENDSHIP]" );
		mystates["neo_happy2"] = NeoState( "NEO - * WATCH ME FLY, [MAMA]" );
		mystates["neo_dead"] = NeoState( "NEO - Freedom" );
		
		
		spamton_vocab["their"] = "[There]";
		spamton_vocab["soul"] = "[HeartShapedObject]";
		spamton_vocab_neo["soul"] = "[[SOUL]]";
		spamton_vocab["you're"] = "you;re";
		spamton_vocab["hello"] = "HEY HEY HEY!";
	}
	
	override public function Cleanup()
	{
		super.Cleanup();
		
		inst = instance_destroy( inst );
		sneo = instance_destroy( sneo );
		sneo_ghost = instance_destroy( sneo_ghost );
	}
	
	override public function DoBodyDebug()
	{
		//SetState( mystates["f1_spam"].name );
		GMControl.GMActionTriggered( myactions["neo_reveal"] );
	}
	
	public function SpamState( statename )
	{
		var state = DWState( statename );
		state.neo = 0;
		state.spam = 1;
		return state;
	}
	
	public function NeoState( statename )
	{
		var state = SpamState( statename );
		state.neo = 1;
		state.spam = 0;
		return state;
	}
	
	override public function OnStateChanged()
	{
		if ( prevState == mystates["neo_dead"] )
		{
			sneo = instance_destroy( sneo );
		}
		
		sneo_ghost = instance_destroy( sneo_ghost );
		
		if ( sneo )
		{
			if ( sneo.eyeshine )
			{
				sneo.eyeshine = instance_destroy( sneo.eyeshine );
			}
		}
		
		var spd = 200 / 30;
		
		x = originX;
		y = originY;
		
		characterH = 0;
		SetViewOffset( 0, 0 );
		
		if ( curState )
		{
			if ( curState == mystates["hidden"] )
			{
				nametag.alpha = 0;
				spd = 20;
				inst = instance_destroy( inst );
				if ( sneo )
				{
					sneo.headforceframe = -1;
					// sneo.partmode = 0;
					sneo.gravity = -2;
				}
				else
				{
					y = -300;
				}
				characterH = 95 * 2;
				SetViewOffset( 0, -( 65 + ( characterH / 2 ) ) );
			}
			else
			{
				if ( curState == mystates["laugh_glitch"] )
				{
					inst = instance_destroy( inst );
				}
				
				if ( curState.neo == 1 )
				{
					if ( inst )
					{
						instance_destroy( inst );
						inst = null;
					}
					if ( !sneo )
					{
						sneo = instance_create( x, -300, obj_spamton_neo );
						sneo.body = this;
						sneo.gravity = 2;
						sneo.drawvines = sneo_drawvines;
					}
				}
				if ( curState.spam == 1 )
				{
					nametag.alpha = 1;
					if ( sneo )
					{
						instance_destroy( sneo );
						sneo = null;
					}
					if ( !inst )
					{
						inst = instance_create( x, y, obj_spamton );
						inst.body = this;
					}
				}
				// Spamton
				if ( inst )
				{
					characterH = ( 34 + 1 ) * 2;
					SetViewOffset( 0, -( 110 + ( characterH / 2 ) ) );
					
					ctrl.setPreferredY( 0 );
					
					inst.x = x;
					inst.y = y;
					inst.remx = x;
					inst.remy = y;
					
					inst.slideamt = 0;
					inst.slidespd = 0;
					
					if ( curState == mystates["slide1"] )
					{
						inst.slideamt = 32;
						inst.slidespd = 1;
						inst.siner = 0;
					}
					else if ( curState == mystates["slide2"] )
					{
						inst.slideamt = 8;
						inst.slidespd = 4;
					}
					else if ( curState == mystates["garbage"] )
					{
						global.flag[20] = 9;
					}
					else if ( curState == mystates["flag20_3"] )
					{
						global.flag[20] = 3;
					}
					else if ( curState == mystates["laugh"] )
					{
						global.flag[20] = 8;
					}
					else if ( curState == mystates["laugh_glitch"] )
					{
						global.flag[20] = 7;
					}
					else if ( curState == mystates["laugh_shaking"] )
					{
						global.flag[20] = 2;
					}
					else
					{
						global.flag[20] = 0;
						inst.sprite_set( inst.idlesprite );
					}
					
				}
				
				// Neo
				if ( sneo )
				{
					characterH = 95 * 2;
					SetViewOffset( 0, -( 65 + ( characterH / 2 ) ) );
					
					ctrl.setPreferredY( 50 );
					
					sneo.Parts_Default();
					// sneo.partmode = 1;
					sneo.bullet_controller = false;
					sneo.ballooncon = 0;
					
					if ( curState == mystates["neo_jitter"] )
					{
						sneo.partmode = 2;
					}
					else if ( curState == mystates["neo_preview"] )
					{
						sneo.ResetAnim();
						sneo.headforceframe = -1;
						sneo.shadow_amount = 1;
						sneo.partmode = 30;
						sneo.partframe[5] = 0;
						if ( sneo.y < 0 )
						{
							sneo.y = -300;
							sneo.gravity = 4;
						}
					}
					else if ( curState == mystates["neo_pester"] )
					{
						sneo.partmode = 1;
						sneo.headforceframe = 1;
					}
					else if ( curState == mystates["neo_pester2"] )
					{
						sneo.partmode = 21;
						sneo.headforceframe = -1;
					}
					else if ( curState == mystates["neo_pester3"] )
					{
						sneo.partmode = 23;
						sneo.headforceframe = 1;
					}
					else if ( curState == mystates["neo_pester4"] )
					{
						sneo.partmode = 24;
						sneo.headforceframe = 2;
					}
					else if ( curState == mystates["neo_pester5"] )
					{
						sneo.partmode = 25;
						sneo.headforceframe = 0;
					}
					else if ( curState == mystates["neo_shocked"] )
					{
						sneo.ResetAnim();
						sneo.partmode = 40;
						sneo.shockthreshold = 10;
						sneo.shocktimer = 0;
						sneo.headforceframe = -1;
					}
					else if ( curState == mystates["neo_shootydance"] )
					{
						sneo.ResetAnim();
						sneo.endcon = 0;
						sneo.dancealtcon = 0;
						sneo.partmode = 36;
						sneo.bullet_controller = true;
						sneo.dance_timer = 0;
					}
					else if ( ( curState == mystates["neo_happy"] ) || ( curState == mystates["neo_happy2"] ) )
					{
						// sneo.ResetAnim();
						sneo.headforceframe = -1;
						sneo.partmode = 36;
						sneo.bullet_controller = false;
						sneo.endcon = 3;
						sneo.ballooncon = 13;
						sneo.dancealtcon = 0;
						if ( curState == mystates["neo_happy2"] )
						{
							sneo.endcon = 4;
							sneo.ballooncon = 0;
							sneo.dancealtcon = 2;
						}
					}
					else if ( curState == mystates["neo_dead"] )
					{
						Anim_Freedom();
					}
					else
					{
						sneo.headforceframe = -1;
						if ( prevState == mystates["neo_preview"] )
							sneo.ResetAnim();
						sneo.partmode = 1;
					}
					
				}
			}
		}
		else
		{
			inst = instance_destroy( inst );
			sneo = instance_destroy( sneo );
		}
		SetMoveSpeed( spd );
	}
	
	override public function OnUpdateLook()
	{
		if ( inst )
		{
			if ( hDir > 0 )
				inst.image_xscale = -Math.abs( inst.image_xscale );
			else
				inst.image_xscale = Math.abs( inst.image_xscale );
			
			var xoff = 0;
			if ( curState == mystates["f1_spam"] )
				xoff = inst.image_xscale * -50
			SetViewOffset( xoff, -( 110 + ( characterH / 2 ) ) );
		}
	}
	
	override public function Step()
	{
		super.Step();
		
		if ( GMControl.isControl )
		{
			if ( curState == mystates["hidden"] )
			{
				if ( sneo == null )
				{
					if ( sneo_ghost == null )
					{
						sneo_ghost = instance_create( originX, originY, obj_spamton_neo );
						sneo_ghost.partmode = 30;
					}
				}
				if ( sneo_ghost )
				{
					sneo_ghost.image_alpha = 0.2 + ( Math.sin( sneo_ghost.partsiner[0] / 15 ) * 0.15 );
				}
			}
			else if ( curState == mystates["f1_spam"] )
			{
				if ( gml.random( 1 ) < 0.2 )
					TriggerAction( myactions["f1"].name, [ gml.random_range( 20, 250 ), gml.random_range( 20, 150 ) ] );
			}
		}
		if ( sneo && nametag )
		{
			nametag.alpha = 1 - sneo.shadow_amount;
		}
	}
	
	override public function Draw()
	{
		super.Draw();
		
		if ( false && GMControl.isControl )
		{
			if ( inst )
			{
				// cherub preview
				var xsc = hDir > 0 ? 1 : -1;
				var xoff = 80;
				var yoff = 70;
				var xx = originX + ( xoff * xsc );
				var yy = originY - yoff;
				
				draw_sprite_ext( spr_spamton_cherub, 5, xx, yy, -image_xscale, image_yscale, 0, 0xFFFFFF, 0.1 );
			}
		}
	}
	
	override public function OnChat( speaker_id, message )
	{
		if ( message.toLowerCase() == "f1" )
		{
			TriggerAction( myactions["f1"].name );
		}
	}
	
	override public function OnHurt( amount = 0 )
	{
		GMControl.Log( "Ouch! (" + amount + ")" );
		c_stop();
		if ( inst )
		{
			enemy = inst;
			inst.Anim_Hurt();
		}
		if ( sneo )
		{
			enemy = sneo;
			sneo.Anim_Hurt();
		}
		super.OnHurt( amount );
	}
	
	override public function OnSentChat( message )
	{
		if ( instance_exists( sneo ) )
			textsound = global.snd_txtspam2;
		else if ( instance_exists( inst ) )
			textsound = global.snd_txtspam;
		else
			textsound = global.snd_text;
		
		super.OnSentChat( message );
	}
	
	public function Action_ToggleVines( data = null )
	{
		SetMemory( "deltarune.spamton.drawvines", ( sneo_drawvines == 1 ) ? 0 : 1 );
	}
	
	public function SetVinesVisible( val = 0 )
	{
		if ( val == 1 )
			sneo_drawvines = 1;
		else
			sneo_drawvines = 0;
		
		if ( instance_exists( sneo ) )
			sneo.drawvines = sneo_drawvines;
	}
	
	public function Anim_F1( data = null )
	{
		var xsc = hDir > 0 ? 1 : -1;
		var xoff = 80;
		var yoff = 70;
		if ( data )
		{
			xoff = data[0];
			yoff = data[1];
		}
		var xx = originX + ( xoff * xsc );
		var yy = originY - yoff;
		var cherub = instance_create( xx, yy, obj_spamton_cherub );
		cherub.healer = 1;
		cherub.image_xscale = 2 * -xsc;
	}
	
	public function Anim_Reveal( data = null )
	{
		var shortened = ( data ) ? true : false;
		
		var w = 30;
		
		if ( curState == mystates["hidden"] || !sneo )
			w += 60;
		
		var dest_state = mystates["neo_preview"];
		SetState( dest_state.name );
		sneo.partmode = 30;
		sneo.shadow_amount = ( shortened ? 0 : 1 );
		c_start();
		c_wait( w );
		c_var_instance(sneo, "shake_head", 1);
		c_wait(30);
		c_var_instance(sneo, "shake_head", 1);
		c_wait(30);
		c_var_instance(sneo, "shake_head", 1);
		c_wait(30);
		c_fadeout(5);
		c_wait(30);
		c_var_instance(sneo, "partmode", 31);
		c_wait(60);
		c_var_instance(sneo, "partmode", 33);
		c_wait(1);
		c_state( mystates["neo_idle"] );  //c_var_instance(sneo, "partmode", 1);
		c_fadein( 5 );
		c_wait( 30 );
		
	}
	
	public function Anim_Freedom( data = null )
	{
		if ( !sneo )
			SetState( mystates["neo_idle"].name );
		c_start();
		c_wait( 1 );
		c_var_instance( sneo, "partmode", 99 );
		if ( prevState == mystates["neo_happy2"] )
			c_wait( 60 );
		c_var_instance( sneo, "headforceframe", -1 );
		c_var_instance( sneo, "y", originY );
		sneo.falltimer = 0;
		sneo.fakegrav = 0;
		c_var_instance( sneo, "partmode", 43 );
		SetViewOffset( 0, -( 0 + ( characterH / 2 ) ) );
	}
}

}


import deltarune.*;
import deltarune.objects.*;
import gamemaker.*;
import flash.display.*;
import flash.utils.getTimer;

/*
	SPAMTON
*/

class obj_spamton extends obj_monsterparent
{
	public var spr_cutscene_14_spamton_arms_up = sprite_get( "spr_cutscene_14_spamton_arms_up" );;
	public var spr_cutscene_14_spamton_grab = sprite_get( "spr_cutscene_14_spamton_grab" );
	public var spr_cutscene_14_spamton_laugh_glitch = sprite_get( "spr_cutscene_14_spamton_laugh_glitch" );
	public var spr_cutscene_14_spamton_laugh_large = sprite_get( "spr_cutscene_14_spamton_laugh_large" );
	public var spr_cutscene_14_spamton_laugh_right = sprite_get( "spr_cutscene_14_spamton_laugh_right" );
	public var spr_spamton_dark = sprite_get( "spr_spamton_dark" );
	public var spr_spamton_hurt = sprite_get( "spr_spamton_hurt" );
	public var spr_spamton_idle = sprite_get( "spr_spamton_idle" );
	public var spr_spamton_laugh_left = sprite_get( "spr_spamton_laugh_left" );
	public var spr_spamton_spared = sprite_get( "spr_spamton_spared" );
	
	public var bodymode = 0;
	public var remx = 0;
	public var remy = 0;
	public var slideamt = 0;
	public var slidespd = 0;
	
	public var expand_spam = 0;
	
	public function obj_spamton()
	{
		
		super();
		
		sprite_set( idlesprite );
		
		idlesprite = spr_spamton_idle;
		hurtsprite = spr_spamton_hurt;
		sparedsprite = spr_spamton_spared;
		
		remx = x;
		remy = y;
	}
	
	override public function Step()
	{
		if ( slideamt > 0 )
		{
			siner += ( slidespd / 100 );
		}
	}
	
	override public function Draw()
	{
		if ( bodymode == 0 )
		{
			var _sinerspd = 1 / 6;
			
			if ( slideamt > 0 )
			{
				x = body.originX + lengthdir_y( slideamt, ( siner * 45 * slidespd ) );
				remx = x;
				body.x = x;
			}
			
			if ( state == 3 )
			{
				// scr_enemyhurt_tired_after_damage(0.5);
				if ( hurttimer < 1 )// && global.monster[myself] > 0)
				{
					state = 0;
				}
				else
				{
					hurttimer -= 1;
					// if (global.monster[myself] == 0)
					//	hurtsprite = idlesprite;
					hurtshake += 1;
					if ( hurtshake > 1 )
					{
						if ( shakex > 0 )
							shakex -= 1;
						else if ( shakex < 0 )
							shakex += 1;
						shakex = -shakex;
						hurtshake = 0;
					}
					
					draw_sprite_ext( hurtsprite, 0, x + shakex + hurtspriteoffx, y + hurtspriteoffy, image_xscale, image_yscale, 0, image_blend, 1 );
				}
			}
			var shakeamt = 0;
			idlesprite = spr_spamton_idle;
			switch ( global.flag[20] )
			{
				case 1:
					idlesprite = spr_spamton_dark;
					break;
				case 2:
					idlesprite = spr_spamton_laugh_left;
					shakeamt = 2;
					break;
				case 3:
					idlesprite = spr_cutscene_14_spamton_grab;
					shakeamt = 2;
					break;
				case 4:
					idlesprite = spr_cutscene_14_spamton_arms_up;
					break;
				case 5:
					idlesprite = spr_cutscene_14_spamton_laugh_right;
					shakeamt = 2;
					break;
				case 6:
					idlesprite = spr_cutscene_14_spamton_laugh_large;
					shakeamt = 2;
					break;
				case 7:
					idlesprite = spr_cutscene_14_spamton_laugh_glitch;
					shakeamt = 0;
					_sinerspd = 0.25;
					break;
				case 8:
					idlesprite = spr_spamton_laugh_left;
					break;
				case 9:
					idlesprite = spr_spamton_dark;
					shakeamt = 2;
					break;
			}
			if (state == 0)
			{
				if (shakeamt > 0)
				{
					x = remx + random_range(-shakeamt, shakeamt);
					y = remy + random_range(-shakeamt, shakeamt);
				}
				else
				{
					x = remx;
					y = remy;
				}
			}
			
			scr_enemy_drawidle_generic( _sinerspd );
			if (becomeflash == 0)
				flash = 0;
			becomeflash = 0;
		}
		else if ( bodymode == 1 )
		{
			
		}
	}
	
	public function Anim_Hurt( data = null )
	{
		
	}
}

/*
	SPAMTON NEO
*/

class obj_spamton_neo extends obj_monsterparent
{
	public var spr_sneo_arml = sprite_get( "spr_sneo_arml" );
	public var spr_sneo_armr = sprite_get( "spr_sneo_armr" );
	public var spr_sneo_body = sprite_get( "spr_sneo_body" );
	public var spr_sneo_head = sprite_get( "spr_sneo_head" );
	public var spr_sneo_head_preview = sprite_get( "spr_sneo_head_preview" );
	public var spr_sneo_legl = sprite_get( "spr_sneo_legl" );
	public var spr_sneo_legr = sprite_get( "spr_sneo_legr" );
	public var spr_sneo_wingl = sprite_get( "spr_sneo_wingl" );
	public var spr_sneo_wingr = sprite_get( "spr_sneo_wingr" );
	
	public static var obj_heart;
	
	public static var snd_bump = global.snd_bump;
	public static var snd_closet_impact = global.snd_closet_impact;
	public static var snd_swallow = global.snd_swallow;
	public static var snd_weaponpull_fast = global.snd_weaponpull_fast;

	// 
	
	public var ballooncon = 0;
	
	//
	public var f = 2;
	public var headsize = 0;
	public var shake_head = 0;
	
	// Shock
	public var shocktimer = 0;
	public var shocker = 0;
	public var shocker_threshold = 10;
	public var shockthreshold = 10;
	
	//public var offset_x = 55;
	//public var offset_y = 190;
	
	public var facing = 0;
	public var lastxoff = 0;
	
	public var aimmode = 0;
	public var armaim = 0;
	public var armangle = 0;
	public var armendx = 0;
	public var armendy = 0;
	public var armlength = 24;
	
	public var partmode = 0;
	
	public var headforceframe = -1;
	public var parts = 0;
	public var partsprite = [];
	public var partframe = [];
	public var partsiner = [];
	public var partrot = [];
	public var partblend = [];
	public var partx = [];
	public var party = [];
	public var partxoff = [];
	public var partyoff = [];
	public var partvisible = [];
	
	public var idealrot = [];
	
	public var partsiner_back = [];
	public var partx_back = [];
	public var party_back = [];
	public var partxoff_back = [];
	public var partyoff_back = [];
	public var partvisible_back = [];
	
	// vines
	public var drawvines = 1;
	
	// hurt
	public var hurttimer2 = 0;
	
	// preview
	public var shadow_amount = 0;
	public var eyeshine;
	
	// bulletcontroller
	public var bullet_controller = false;
	public var idealx = [];
	
	// shootydance
	public var endcon = 0;
	public var headendcon = 0;
	public var dancealtcon = 0;
	public var dance_timer = 0;
	public var head_recoil_amount = 0;
	
	// die
	public var dead = 0;
	public var fakegrav = 0;
	public var falltimer = 0;
	public var fallshake = 10;
	
	public function obj_spamton_neo()
	{
		var i;
		
		offset_x = 55;
		offset_y = 190;
		
		Parts_Default();
		
		image_xscale = 2;
		image_yscale = 2;
		
		ResetAnim();
		
	}
	
	override public function Step()
	{
		var i;
		
		var ts = body.timescale_delta;
		var f_d = f * ts;
		
		facing = body.hDir < 0 ? 1 : -1;
		if ( facing < 0 )
			lastxoff = 110;
		else
			lastxoff = 0;
		
		if ( partmode == 2 )
		{
			shocker -= f;
		}
		
		if ( bullet_controller == 0 )
		{
			idealx[5] = 0;
			idealrot[5] = 0;
			partsiner[5] = 0;
			partrot[5] = 0;
			partx[5] = 0;
			party[5] = 0;
			partxoff[5] = (partsprite[5].x) * 2;
			partyoff[5] = (partsprite[5].y) * 2;
		}
		else if ( bullet_controller == 1 )
		{
			
		}
		
		if ( headendcon == 1 )
		{
			partrot[5] = -37 + sin(partsiner[4] / 16);
			partframe[5] = 1;
			partsprite[5] = spr_sneo_head;
		}

		if (headendcon == 2)
		{
			partrot[5] = 15 + sin(partsiner[4] / 16);
			partsprite[5] = spr_sneo_head; //_sad;
		}

		if (headendcon == 3)
			partsprite[5] = spr_sneo_head;
		
		if ( partmode == 36 )
		{
			if ( ballooncon == 13 )
			{
				siner += 2;
				
				for (i = 0; i < 8; i += 1)
					partsiner[i] += 0.6;
			}
			if ( endcon == 4 )
			{
				
				if (ballooncon == 0 )// && endtimer == 0)
				{
					siner += 3;
					
					for (i = 0; i < 8; i += 1)
						partsiner[i] += 0.9;
				}
			}
		}
		
		if ( partmode >= 30 && partmode <= 33 )
		{
			
		}
		else
		{
			if ( shadow_amount > 0 )
				shadow_amount = Math.max( 0, shadow_amount - ( 1 / 30 ) );
		}
		
		if ( gravity == 0 && partmode <= 34 )
		{
			x = gml.lerp( x, body.originX, 0.25 );
			y = gml.lerp( y, body.originY, 0.25 );
		}
		
		for ( i = 0; i < parts; ++i )
		{
			if ( partmode < 20 )
			{
				// None
				if ( partmode == 0 )
				{
					partframe[i] = 0;
					partsiner[i] = 0;
					if ( i == 5 )
					{
						partrot[i] = gml.lerp(partrot[i], 0, 0.25 * f);
						partx[i] = gml.lerp(partx[i], 0, 0.25 * f);
						party[i] = gml.lerp(party[i], 0, 0.25 * f);
						
						if (dead == 1)
							partframe[i] = 3;
					}
					else
					{
						partframe[i] = 0;
						partrot[i] = gml.lerp(partrot[i], 0, 0.25 * f);
						partx[i] = gml.lerp(partx[i], 0, 0.25 * f);
						party[i] = gml.lerp(party[i], 0, 0.25 * f);
						
						if (abs(partrot[i]) < 1)
							partrot[i] = 0;
						
						if (abs(partx[i]) < 1)
							partx[i] = 0;
						
						if (abs(party[i]) < 1)
							party[i] = 0;
					}
				}
				// Standard
				else if (partmode == 1 || partmode == 3 || partmode >= 5)
				{
					if (partmode == 1 && aimmode != 0)
						aimmode = 0;
					
					if ( ( partmode == 3 || ( partmode >= 9 && partmode <= 13 ) ) && i == 1 )
					{
						if ( aimmode == 2 && instance_exists( obj_heart ) && partmode == 3 )
							armaim = gml.point_direction( 0, 0, 100, 30 ) - 90;
							//armaim = point_direction(x + partxoff[i], y + partyoff[i], obj_heart.x + 8, obj_heart.y + 8) + 90;
						else if (aimmode != 1)
							armaim = -80;
						
						if (partmode < 10)
							partrot[i] = lerp(partrot[i], armaim, 0.25 * f);
						
						if (partmode < 9)
							partframe[i] = (partmode == 3) ? 1 : 3;
						
						if (partmode == 12)
							partframe[i] = 1;
						
						if (partmode >= 10)
						{
							if (partrot[i] == armaim)
								partrot[i] = armaim + 2;
							else
								partrot[i] = armaim;
						}
					}
					else if (partmode >= 6 && partmode < 11 && i == 1)
					{
						partrot[i] = lerp(partrot[i], -160, 0.25 * f);
						
						if (partframe[i] != 2 && partrot[i] <= -90)
							partframe[i] = 2;
					}
					else
					{
						if (i == 1)
						{
							if (partmode == 5 || partmode == 1)
								partframe[i] = 0;
						}
						
						partsiner[i] += (1 + (i / 5)) * f;
						partrot[i] = sin(partsiner[i] / 30) * 15;
					}
					
					if (i == 5)
					{
						partx[i] = lerp(partx[i], 0, 0.25 * f);
						party[i] = lerp(party[i], 0, 0.25 * f);
						partrot[i] -= 10 * f;
						
						if (partmode == 5 || partmode == 8 || partmode == 9)
						{
							partrot[i] /= 2;
							partrot[i] += 10 * f;
							partframe[i] = 1;
						}
						else if (partmode == 6 || partmode == 7)
						{
							partrot[i] /= 2;
							
							if (partmode > 6 || partrot[1] <= -120)
								partframe[i] = 0;
						}
						else if (partmode == 11)
						{
							partframe[i] += 0.2 * f;
						}
						else if (partmode == 12)
						{
							partframe[i] += 0.3 * f;
						}
						else
						{
							partframe[i] += 0.05 * f;
						}
						
						if (partframe[i] >= 3)
							partframe[i] = 0;
						
						if (partframe[i] >= 2)
							partrot[i] += 20 * f;
					}
				}
				
				else if ( partmode == 2 )
				{
					partsiner[i] += (1 + (i / 5)) * f;
					partx[i] = sin((partsiner[i] / 2) * f);
					party[i] = cos((partsiner[i] / 2) * f);
					
					if (shocker < 0)
					{
						partrot[i] = 60 - gml.random(120);
						
						if (i == 5)
						{
							partframe[i] += 1 * f_d;
							
							if (partframe[i] >= 3)
								partframe[i] = 0;
						}
					}
				}
				
				if ( i == 5 )
				{
					headsize = lerp(headsize, 0, 0.25);
				}
				
			}
			else if ( partmode >= 21 && partmode < 30 ) 
			{
				if (partmode == 21 || partmode == 23 || partmode == 24 || partmode == 25)
				{
					partsiner[i] += 0.1;
					partx[i] = lerp(partx[i], 0, 0.5);
					party[i] = lerp(party[i], 0, 0.5);
					idealrot[i] = sin(partsiner[i] + (i / 8)) * 20;
					idealrot[1] = sin(partsiner[2]) * 60;
					idealrot[2] = sin(partsiner[2] - 0.1) * 60;
					idealrot[3] = -sin(partsiner[2] + 0.3) * 60;
					idealrot[6] = -sin(partsiner[2] + 0.1) * 60;
					partframe[5] = 1;
					partrot[i] = lerp(partrot[i], idealrot[i], 0.5);
					partrot[5] += 2;
					
					if (i == 5)
					{
						if (partmode == 23)
						{
							partframe[5] = 2;
							headsize = lerp(headsize, 0.5, 0.25);
						}
						else if (partmode == 24)
						{
							partframe[5] = 2;
							headsize = lerp(headsize, 1, 0.25);
						}
						else if (partmode == 25)
						{
							partframe[5] = 2;
							headsize = lerp(headsize, 1.5, 0.25);
							partrot[5] = -15;
							partx[i] = gml.random(2);
							party[i] = gml.random(2);
						}
						else
						{
							headsize = lerp(headsize, 0, 0.25);
						}
					}
				}
				
				if (partmode == 22)
				{
					partframe[5] = 0;
					partrot[5] = sin(partsiner[0] / 2) * 4;
					partsiner[0] += 0.1;
					
					if (partsiner[0] >= 5)
					{
						partx[i] = gml.random(2);
						party[i] = gml.random(2);
						
						if (i == 8)
							partsiner[0] = 0;
					}
				}
				
				if (partmode == 27)
				{
					partframe[5] = 1;
					idealrot[i] = 0;
					idealrot[2] = 45;
					partframe[2] = 1;
					partrot[i] = lerp(partrot[i], idealrot[i], 0.5);
				}
			}
			
			// Preview start
			else if ( partmode == 30 )
			{
				headsize = 0;
				
				partsprite[5] = spr_sneo_head_preview;
				if (partframe[5] == 0)
					partframe[5] = 1;
				
				partsprite[0] = -1;
				partsiner[i] += 1;
				
				if (shake_head == 0)
				{
					party[i] = sin(partsiner[i] / 15) * 4;
					idealrot[i] = sin(partsiner[i] / 20) * 4;
				}
				else if (i == 5)
				{
					if (shake_head == 1)
					{
						partframe[5]++;
						snd_play( snd_swallow );
					}
					
					partrot[5] = (sin(shake_head * 2) * 8) + gml.random(4);
					party[5] = gml.random(4);
					partx[5] = gml.random(4);
					shake_head++;
					
					if (shake_head >= 6)
					{
						shake_head = 0;
						partrot[5] = 0;
					}
				}
				// 
				if ( i == 5 )
					{
						partrot[i] = lerp(partrot[i], 0, 0.25 * f);
						partx[i] = lerp(partx[i], 0, 0.25 * f);
						party[i] = lerp(party[i], 0, 0.25 * f);
					}
					else
					{
						partframe[i] = 0;
						partrot[i] = lerp(partrot[i], 0, 0.25 * f);
						partx[i] = lerp(partx[i], 0, 0.25 * f);
						party[i] = lerp(party[i], 0, 0.25 * f);
						
						if (abs(partrot[i]) < 1)
							partrot[i] = 0;
						
						if (abs(partx[i]) < 1)
							partx[i] = 0;
						
						if (abs(party[i]) < 1)
							party[i] = 0;
					}
			}
			// Preview
			else if ( partmode == 31 )
			{
				if (i == 5)
				{
					snd_play( snd_weaponpull_fast );
					if ( true )
					{
						var _n = 0;
						var xx;
						var yy;
						for ( var _ni = 0; _ni < 6; ++_ni )
						{
							xx = (_n * 8 * -facing) + x + (partx[5] * facing) + (partxoff[5] * facing) + lastxoff;
							yy = y + party[5] + partyoff[5]
							var obj = obj_afterimage_grow;
							eyeshine = instance_create( xx - offset_x, yy - offset_y, obj );
							eyeshine.sprite_set( spr_sneo_head_preview );
							eyeshine.image_index = 0;
							eyeshine.image_speed = 0;
							eyeshine.image_xscale = ( 2 * facing ) - ( (_n / 5) * ( facing ) );
							eyeshine.image_yscale = 2 + (_n / 5);
							eyeshine.xrate = 0;
							eyeshine.yrate = 0;
							eyeshine.image_alpha = 1 + _n;
							_n += 0.2;
						}
						eyeshine.image_angle = partrot[5] * facing;
						//eyeshine = scr_dark_marker(x + (partx[5] * facing) + (partxoff[5] * facing) + lastxoff, y + party[5] + partyoff[5], spr_sneo_head_preview);
						eyeshine.x = x + (partx[5] * facing) + (partxoff[5] * facing) + lastxoff - offset_x;
						eyeshine.y = y + party[5] + partyoff[5] - offset_y;
						eyeshine.xrate = 0;
						eyeshine.yrate = 0;
						eyeshine.fade = 0;
						eyeshine.image_alpha = 1;
						//eyeshine.image_xscale = -2;
					}
					partmode = 32;
				}
			}
			else if ( partmode == 33 )
			{
				eyeshine = instance_destroy( eyeshine );
				Parts_Default();
				ResetAnim();
				partmode = 0;
				snd_play( snd_bump );
			}
			// Shooty dance
			else if (partmode == 36)
			{
				var fastshot = 0;
				var shootydancex = body.originX;
				var shootydancey = body.originY - 16;
				
				//if (shootydanceinit == 0)
				//{
					//shootydanceinit = 1;
					//shootydancex = x;
					//shootydancey = y;
				//}
				
				if ( endcon > 0 )
				{
					if (dancealtcon == 1)
						siner += 0.23 * ts;
					
					if (dancealtcon == 2)
						siner += 0.23 * ts;
					
					x = shootydancex + (sin(siner / 20) * 10);
					y = shootydancey + (sin(siner / 6) * 20);
				}
				else
				{
					x = shootydancex + (sin(siner / 20) * 10);
					y = shootydancey + (sin(siner / 6) * 20);
				}
				
				armendx = x + partx[1] + partxoff[1] + lengthdir_x(armlength, partrot[1] - 93);
				armendy = y + party[1] + partyoff[1] + lengthdir_y(armlength, partrot[1] - 93);
				
				if (dance_timer == 0)
				{
					//if (i_ex(obj_heart))
					//	armangle = gml.point_direction(partxoff[1], partyoff[1], obj_heart.x, obj_heart.y);
					armangle = gml.point_direction( 0, 0, 100, 10 ) - 90;
					armaim = armangle;
					
					
					idealrot[5] = -15;
				}
				
				if (i != 1 || endcon > 0)
				{
					partsiner[i] += 0.1 * ts;
					partx[i] = lerp(partx[i], 0, 0.5);
					party[i] = lerp(party[i], 0, 0.5);
					idealrot[i] = sin(partsiner[i] + (i / 8)) * 20;
					idealrot[1] = sin(partsiner[2]) * 60;
					idealrot[2] = sin(partsiner[2] - 0.1) * 60;
					idealrot[3] = -sin(partsiner[2] + 0.3) * 60;
					idealrot[6] = -sin(partsiner[2] + 0.1) * 60;
					partrot[5] = -15 - (abs(sin(head_recoil_amount / 60)) * ( 150 / 2 ));
					// partframe[5] = 2;
					head_recoil_amount = lerp(head_recoil_amount, 0, 0.03);
					partrot[i] = lerp(partrot[i], idealrot[i], 0.5);
				}
				
				if ( i == 5 )
				{
					partframe[i] = 2;
					headsize = lerp(headsize, 0, 0.25);
				}
				
				if (i == 0 && endcon == 0)
				{
					siner += 1.3 * ts;
					dance_timer++;
					
					if (dance_timer == (17 - (fastshot * 10)) || dance_timer == (52 - (fastshot * 10)))
					{
						//d = instance_create(x, y, obj_sneo_biglaser);
						//d.depth += 1;
						//d._type = 1;
						// chargeshot_sound = snd_loop(snd_chargeshot_charge);
						// chargesfxtimer = 1;
					}
					
					if (dance_timer == (42 - (fastshot * 10)))
					{
						//with (obj_sneo_biglaser)
						//	instance_destroy();
						//shot = instance_create(armendx, armendy, obj_spamtonshot);
						//shot.target = mytarget;
						//shot.damage = damage;
						armaim += 360;
						head_recoil_amount = -170;
						//snd_stop(chargeshot_sound);
						//snd_play_x(snd_chargeshot_fire, 0.6, 0.5);
					}
					
					if (dance_timer == (84 - (fastshot * 20)))
					{
						//with (obj_sneo_biglaser)
						//	instance_destroy();
						//shot = instance_create(armendx, armendy, obj_spamtonshot);
						//shot.target = mytarget;
						//shot.damage = damage;
						armaim -= 360;
						head_recoil_amount = -170;
						//snd_stop(chargeshot_sound);
						//snd_play_x(snd_chargeshot_fire, 0.6, 0.5);
					}
					
					if (dance_timer >= (85 - (fastshot * 20)))
						dance_timer = 3;
					
					if ( false )
					{
						if (chargesfxtimer == 1)
						{
							chargepitch = 0.1;
							snd_pitch(chargeshot_sound, chargepitch);
							snd_volume(chargeshot_sound, 0, 0);
							snd_volume(chargeshot_sound, 0.8, 20);
						}
						if (chargesfxtimer > 0 && chargesfxtimer <= 30)
						{
							chargesfxtimer++;
							chargepitch += 0.03;
							snd_pitch(chargeshot_sound, chargepitch);
						}
					}
				}
				
				if (i == 1 && endcon == 0)
				{
					var shakebuster = 0;
					
					//if (instance_exists(obj_sneo_biglaser))
					//	shakebuster = -4 + random(8);
					
					partrot[i] = lerp(partrot[i], armaim, 0.12) + shakebuster;
					partframe[i] = 1;
					
					//with (obj_sneo_biglaser)
					//{
					//	x = obj_spamton_neo_enemy.armendx;
					//	y = obj_spamton_neo_enemy.armendy;
					//}
				}
			}
			// Damaged
			else if ( partmode == 40 )
			{
				var dontchangepose = 0;
				if (i == 0 && dontchangepose == 0)
					shocktimer++;
				
				partsiner[i] += (1 + (i / 5)) * f;
				partx[i] = sin((partsiner[i] / 2) * f);
				party[i] = cos((partsiner[i] / 2) * f);
				
				if ( false )
				{
					// smoking
					if ((shockthreshold <= 5 && hurttimer2 == 0 && i == 0) || (smokethreshold > 1 && i == 0))
					{
						smoketimer++;
						
						if (smoketimer >= smokethreshold)
						{
							var smokey = instance_create(x + 50, y + 80, obj_afterimage_grow);
							smokey.visible = 0;
							
							with (smokey)
								scr_script_delayed(scr_var, 1, "visible", 1);
							
							smokey.depth = depth + 10;
							smokey.image_alpha = 2.5;
							smokey.sprite_index = spr_cakesmoke;
							smokey.hspeed = random_range(2, 8);
							smokey.gravity = -0.5;
							smokey.friction = 0.2;
							smokey.vspeed = random_range(-1, -2);
							smoketimer = 0;
						}
					}
					if (shockthreshold <= 8 && hurttimer2 == 0 && global.flag[8] == 0)
					{
						fsiner = partsiner[i] / 8;
						flash = 1;
					}
					if (global.flag[8] == 1)
						shockthreshold = clamp(shockthreshold, 5, 100);
				}
				
				if (shocktimer >= shockthreshold)
				{
					partrot[i] = 60 - random(120);
					
					if (i == 4)
						partrot[i] = 40 - random(80);
					
					if (i == 5)
					{
						partframe[i] += 1 * f;
						
						if (partframe[i] >= 3)
							partframe[i] = 0;
					}
					
					if (i == 7)
						shocktimer = 0;
				}
			}
			
			else if ( partmode == 43 && i == 0 )
			{
				var fallen = 0;
				
				falltimer++;
				var desty = body.originY + 90;
				var destgrav = 16.5;
				if ( y < desty )
				{
					fallshake = 10;
					fakegrav += (0.5 + (fakegrav / 10));
					fakegrav = gml.clamp(fakegrav, 0, destgrav );
					y += fakegrav;
					if ( y >= desty )
					{
						fakegrav = destgrav;
						fakegrav = destgrav;
					}
					body.SetViewOffset( null, ( y - 100 ) - body.originY );
				}
				else
				{
					fakegrav = destgrav;
					fakegrav = destgrav;
					fallen = 1;
				}
				
				headsize = lerp(headsize, 0, 0.25);
				
				partframe[5] = 7;
				partrot[1] = -fakegrav * 6;
				partx[1] = fakegrav * 2;
				party[1] = fakegrav * 1.5;
				partrot[6] = -fakegrav * 6;
				partx[6] = fakegrav * 0.6;
				party[6] = fakegrav * 2;
				partrot[2] = -fakegrav * 6;
				partx[2] = -fakegrav * 1.6;
				party[2] = -fakegrav * 0.65;
				partrot[3] = -fakegrav * 6;
				partx[3] = -fakegrav * 2.5;
				party[3] = -fakegrav * 0.15;
				partrot[4] = -fakegrav * 6.25;
				partx[4] = fakegrav * 2;
				party[4] = fakegrav / 1.5;
				partrot[5] = -fakegrav * 8;
				partx[5] = fakegrav * 1.8;
				party[5] = fakegrav * 2;
				partrot[0] = -fakegrav * 4;
				party[0] = fakegrav * 3;
				partrot[7] = -fakegrav * 4;
				party[7] = fakegrav * 3;
				
				if (fallen != 0)
				{
					if (fallshake == 10)
						snd_play( snd_closet_impact );
					
					for (var ii = 0; ii < 7; ii++)
					{
						party[ii] += gml.random(fallshake * 2) - fallshake;
						partx[ii] += gml.random(fallshake * 2) - fallshake;
					}
					
					if (fallshake > 0)
						fallshake--;
				}
			}
			
		}
		
		if ( headforceframe != -1 )
			partframe[5] = headforceframe;
		
		if (shocker < 0)
		{
			shocker = shocker_threshold;
			if (shocker_threshold > 2)
				shocker_threshold -= (0.25 * f);
		}
		
		if ( gravity > 0 )
		{
			if ( y > body.originY )
			{
				y = body.originY;
				gravity = 0;
				vspeed = 0;
			}
		}
		if ( gravity < 0 )
		{
			if ( y < -300 )
			{
				instance_destroy();
				if ( body.sneo == this )
					body.sneo = null;
			}
		}
		if ( body.sneo == this )
		{
			body.x = x + ( partx[5] * facing * GMControl.scale );
			body.y = y + ( party[5] * GMControl.scale );
		}
		
		if ( hurttimer2 > 0 )
		{
			--hurttimer2;
			if ( hurttimer2 <= 1 )
			{
				if ( endcon == 0 )
				{
					shockthreshold = 10;
					body.SetState( body.mystates["neo_idle"].name );
					partmode = 1;
				}
			}
		}
	}
	
	override public function Draw()
	{
		if ( !body )
			return;
		// body.hDir = Math.sin( getTimer() / 30 );
		var scalebonus = 0;
		var expand = 0 ;
		
		var shakevar = 0;
		
		var x = this.x - offset_x;
		var y = this.y - offset_y;
		
		var i;
		
		var x1, y1, x2, y2;
		
		if ( drawvines && partmode != 43 && partmode != 99 )
		{
			// BG Vines
			// var hidebgvines = 0;
			// var bgvinecount = 0;
			draw_set_color( 0x003300 ); // make_colour_rgb(0, 51, 0);
			for ( i = 0; i < 18; ++i )
			{
				// if (partvisible_back[i] == 1)
				//	bgvinecount++;
				partsiner_back[i] += 0.5;
				if ( true ) // (partvisible_back[i] == 1)
				{
					x1 = x + partx_back[i] + partxoff_back[i] + (sin(partsiner_back[i] / 30) * 2);
					y1 = y + party_back[i] + partyoff_back[i];
					x2 = x + partx_back[i] + partxoff_back[i];
					draw_line_width( x1, y1, x2, -400, 1, image_alpha );
				}

			}
			// FG Vines
			// var fgvinecount = 0;
			draw_set_color( 0x008000 ); // c_green
			for ( i = 0; i < 6; i += 1)
			{
				if ( true ) //(partvisible[i] == 1)
				{
					x1 = x + partx[i] + (partxoff[i] / 1.2) + (i * 5) + (sin(partsiner[i] / 30) * 2); // + weakenshakeamount2;
					y1 = ((y + party[i]) - 10) + partyoff[i]; // + weakenshakeamount2;
					x2 = x + partx[i] + (partxoff[i] / 1.5) + (i * 8);
					
					draw_line_width( x1, y1, x2, -400, 2, image_alpha );
					// fgvinecount++;
				}
			}
		}
		// Body
		for ( i = 0; i < parts; ++i )
		{
			if ( hurttimer2 > 0 )
			{
				shakevar = ( random( hurttimer2 ) / 2 ) - ( hurttimer2 / 4 );
			}
			
			partblend[i] = merge_color( c_white, c_black, shadow_amount );
			
			scalebonus = 0;
			
			if ( i == 5 )
				scalebonus = headsize;
			
			var spr = partsprite[i];
			var frm = partframe[i];
			var xx = x + (partx[i] * facing) + (partxoff[i] * facing) + lastxoff + shakevar;
			var yy = (y + party[i] + partyoff[i]) - shakevar;
			var xsc = ((2 + scalebonus) * facing) + expand;
			var ysc = 2 + scalebonus + expand;
			var ang = partrot[i] * facing;
			var col = partblend[i];
			
			draw_sprite_ext( spr, frm, xx, yy, xsc, ysc, ang, col, image_alpha );
		}
	}
	
	public function Anim_Hurt( data = null )
	{
		partmode = 40;
		shockthreshold = 15;
		shocktimer = 9999;
		hurttimer2 = 10;
	}
	
	public function Parts_Default()
	{
		parts = 0;
		partframe[1] = 0;
		partsprite[parts++] = spr_sneo_wingl;
		partsprite[parts++] = spr_sneo_arml;
		partsprite[parts++] = spr_sneo_legl;
		partsprite[parts++] = spr_sneo_legr;
		partsprite[parts++] = spr_sneo_body;
		partsprite[parts++] = spr_sneo_head;
		partsprite[parts++] = spr_sneo_armr;
		partsprite[parts++] = spr_sneo_wingr;
		partframe[5] = 0;
	}
	
	public function ResetAnim()
	{
		headsize = 0;
		headforceframe = -1;
		var i;
		for ( i = 0; i < parts; ++i )
		{
			partframe[i] = 0;
			partsiner[i] = 0;
			partrot[i] = 0;
			partblend[i] = 0xFFFFFF;
			partx[i] = 0;
			party[i] = 0;
			partxoff[i] = partsprite[i].x * 2;
			partyoff[i] = partsprite[i].y * 2;
			partvisible[i] = 1;
		}
		// 
		for ( i = 0; i < 18; ++i )
		{
			partsiner_back[i] = 0;
			partx_back[i] = 0;
			party_back[i] = 0;
			partxoff_back[i] = ( partsprite[0].x ) * ( 1.8 + (i / 9) );
			partyoff_back[i] = ( partsprite[0].y ) * 2;
			partvisible_back[i] = 1;
		}
	}
}

/*
	HEALING CHERUB
*/

class obj_spamton_cherub extends DeltaruneObject
{
	public var spr_spamton_cherub = global.spr_spamton_cherub;
	public var spr_sparestar_anim = global.spr_sparestar_anim;
	
	public var snd_sparkle_glock = global.snd_sparkle_glock;
	
	public static var inst_snd_sparkle_glock;
	
	public var timer = 0;
	public var xspawn = x;
	public var yspawn = y;
	public var offset = Math.random() * 2 * pi;
	public var healer = false;
	public var heal_state = 0;
	public var xoff = -cos( 8 + offset ) * 20;
	public var yoff = -sin( 8 + offset ) * 20;
	public var target = 0;
	
	public function obj_spamton_cherub()
	{
		super();
		
		sprite_set( spr_spamton_cherub );
		
		y -= 150;
		yspawn = y;
		
		image_xscale = 2;
		image_yscale = 2;
		image_speed = 0.5;
		
	}
	
	override public function Create()
	{
		
	}
	
	override public function Step() 
	{
		var d;
		
		if ( timer == 0 )
		{
			x += ( 100 * image_xscale );
			xspawn = x;
		}
		
		if (timer == target)
		{
			if ( inst_snd_sparkle_glock )
			{
				inst_snd_sparkle_glock.stop();
				inst_snd_sparkle_glock = null;
			}
			inst_snd_sparkle_glock = snd_play( snd_sparkle_glock );
			snd_pitch( inst_snd_sparkle_glock, 1.1 + ( target * 0.2 ) );
		}

		timer++;

		if (timer >= 24)
		{
			x = xstart;
			y = ystart;
			
			if (timer == 24)
			{
				d = instance_create(x, y, obj_animation);
				d.sprite_set( sprite_current );
				d.image_xscale = image_xscale;
				d.image_yscale = 2;
			}
			
			if (!healer)
				instance_destroy();
			else if (timer == 48)
				{}//scr_spamton_heal(heal_state);
			else if (timer >= 63)
				instance_destroy();
		}
		else if (timer >= 0 && timer <= 24)
		{
			x = lerp(xspawn, xstart + xoff, clamp(timer / 25, 0, 1));
			y = lerp(yspawn, ystart + yoff, clamp(timer / 25, 0, 1));
			
			if ((timer % 2) == 0)
			{
				d = instance_create(x + (cos((timer / 3) + offset) * 20), y + (sin((timer / 3) + offset) * 20), obj_animation);
				d.sprite_set( spr_sparestar_anim );
				d.image_speed = 0.5;
				d.image_blend = c_lime;
				d.image_xscale = 2;
				d.image_yscale = 2;
			}
		}

	}
	
	override public function Draw()
	{
		
	}
}