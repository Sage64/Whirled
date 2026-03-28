
// Deltarune body base
// should supply global behaviour/interaction basis for
// other deltarune characters

package deltarune
{

import gamemaker.*;
import deltarune.objects.*;

import flash.display.*;
import flash.events.*;
import flash.utils.*;

import com.threerings.util.*
import com.whirled.*

/*
	In the darkworld (darkmode = true) most things are scaled 2x
	the media scale and movement is halved to compensate for this
	this means, for example, an object moving 10 pixels actually has to move 20
	// as the 1x1 pixel is now 2x2
*/

public class DeltaruneBody extends GMBody
{
	// 
	
	public var darkmode = false;
	
	public var bscale = 3;
	public var darkscale = bscale / 2;
	
	public var aqcolor = 0x03a5fc;
	public var lighty = 0xfff947;
	
	public var cutscene;
	
	public var textsound = global.snd_text;
	public var textsoundinst;
	
	
	public var lwcontroller;
	public var dwcontroller;
	
	public function DeltaruneBody()
	{
		var i;
		
		if ( !global.damagefont )
		{
			global.damagefont = { name: "_sans", size: 12 };
		}
		
		super( 30 );
		use_delta = false;
		
		SetScale ( bscale );
		
		if ( SetNameTag() )
		{
			var _size = 20;
			nametag.SetBaseColor( 0xFFFFFF );
			nametag.SetBaseOutline( 0x000000 );
			// nametag.SetFont( "8bitoperator JVE", true );
			nametag.SetFont( "Determination Sans", true );
			nametag.SetSize( _size * 1 );
			nametag.textInit.outlineWidth = _size / 3.75;
			nametag.textInit.sharpness = 400;
			//nametag.SetScale( 1 );
			nametag.Apply();
		}
		
		if ( !global.deltarune )
		{
			global.deltarune = 1;
			global.flag = new Array( 100 );
			global.interact = 0;
			global.chapter = 1;
			global.darkzone = 0;
		}
		
		mymemories["chapter"] = AddMemory( "deltarune.chapter", global.chapter, SetChapter );
		mymemories["forcedarkzone"] = AddMemory( "deltarune.forcedarkzone", global.darkzone, SetForceDarkMode );
	}
	
	public function LWState( statename, sprites = null )
	{
		var State = AddState( statename );
		// 
		State.darkzone = false;
		State.run = false;
		State.board = false;
		State.sprite = sprites;
		State.sprites = sprites;
		State.directional = 0;
		
		if ( sprites != null )
		{
			if ( ( sprites.constructor == Array ) && sprites.length > 0 )
			{
				if ( sprites.length >= 4 )
				{
					State.sprites = sprites;
					State.directional = 4;
					State.sprite = sprites[0];
				}
			}
			else
				State.sprite = sprites;
			// trace( "sprite: " + State.sprite );
		}
		// 
		return State;
	}
	
	public function DWState( statename, sprites = null )
	{
		var State = LWState( statename, sprites );
		// 
		State.darkzone = true;
		// 
		return State;
	}
	
	public function BoardState( statename, sprites = null )
	{ 
		var State = DWState( statename, sprites );
		// 
		State.board = true;
		//
		return State;
	}
	
	override public function OnStateChanged()
	{
		super.OnStateChanged();
		
		global.darkzone = ( curState && curState.darkzone ) ? 1 : ( mymemories["forcedarkzone"].value ? 1 : 0 );
		
		if ( global.darkzone )
		{
			instance_destroy( lwcontroller );
			dwcontroller = instance_create( 0, 0, obj_darkcontroller );
		}
		else
		{
			instance_destroy( dwcontroller );
			lwcontroller = instance_create( 0, 0, obj_overworldc );
		}
	}
	
	override public function OnUpdateLook()
	{
		super.OnUpdateLook();
		SetScale ( global.darkzone ? darkscale : bscale  );
		
		if ( hDir > 0 )
			image_xscale = -Math.abs( image_xscale );
		else
			image_xscale = Math.abs( image_xscale );
		
		var tireddraw = ( isSleeping && nametag );
		if ( tireddraw && global.spr_tiredmark )
		{
			var _sprscale = 1.25;
			var xx;
			var yy;
			if ( true )
			{
				surface_set_target( nametag.surf );
				xx = ( nametag.textObj.width / 2 ) + 4 + ( 4 * _sprscale );
				yy = ( -nametag.textFormat.size / 2 ) - ( ( sprite_get_height( global.spr_tiredmark ) * _sprscale ) / 2 );
				draw_sprite_ext( global.spr_tiredmark, 0, xx, yy );
				surface_reset_target();
			}
		}
	}
	
	override public function OnSleep()
	{
		
	}
	
	override public function OnWake()
	{
		
	}
	
	override public function OnSentChat( message )
	{
		snd_stop( textsoundinst );
		
		var _snd = textsound;
		if ( _snd && ( _snd.constructor == Array ) )
		{
			_snd = _snd[irandom( _snd.length - 1 )]
		}
		textsoundinst = snd_play( _snd );
	}
	
	override public function Step()
	{
		super.Step();
	}
	
	override public function Draw()
	{
		draw_self();
	}
	
	override public function DrawEnd()
	{
		super.DrawEnd();
		return;
	}
	
	// 
	
	override public function OnOtherMoveStart( _id, _dest )
	{
		// wip follow behaviour for pets
		return;
		
	}
	
	public function UpdateSprites( ... ignored )
	{
		
	}
	
	public function SetChapter( val = 0 )
	{
		global.chapter = val;
		UpdateSprites();
	}
	
	public function SetForceDarkMode( val = 0 )
	{
		OnStateChanged();
		UpdateSprites();
	}
	
	// Deltarune gamemaker functions
	
	public function button1_h()
	{
		return false;
	}
	
	public function button2_h()
	{
		return false;
	}
	
	public function button3_h()
	{
		return false;
	}
	
	public function scr_approach( a, b, amount )
	{
		if ( a < b )
		{
			a += amount;
			if ( a > b )
				return a;
		}
		else
		{
			a -= amount;
			if ( a < b )
				return b;
		}
		return a;
	}
	
	public static function snd_play( _sound )
	{
		return GMObject.audio_play_sound( _sound  );
	}
	
	public static function snd_stop( _sound )
	{
		return GMObject.audio_stop_sound( _sound );
	}
	
	public function c_start()
	{
		if ( cutscene )
			instance_destroy( cutscene );
		cutscene = instance_create( 0, 0, obj_cutscene );
		cutscene.owner = this;
		
		return cutscene;
	}
	
	public function c_stop()
	{
		if ( cutscene )
		{
			cutscene.Done();
			cutscene = instance_destroy( cutscene );
		}
	}
	
	public function c_cmd( ...args )
	{
		if ( !cutscene )
			return;
		cutscene.AddCommand( args );
	}
	
	public function c_state( statename )
	{
		if ( typeof statename == "object" )
			statename = statename.name;
		c_cmd( "state", statename );
	}
	
	public function c_wait( time = 30 )
	{
		c_cmd( "wait", time );
	}
	
	// Change the value of a variable on an instance
	// variable must not currently be null 
	public function c_var_instance( inst, varname = "", val = 0 )
	{
		if ( !inst )
			return;
		if ( inst[varname] == null )
			return;
		c_cmd( "var", inst, varname, val );
	}
	
	public function c_fadeout( amnt = 5 )
	{
		
	}
	
	public function c_fadein( amnt = 5 )
	{
		
	}
}

} // Package

import gamemaker.*;
import deltarune.*;
import deltarune.objects.*;

// 
class obj_cutscene extends DeltaruneObject
{
	public var owner;
	public var commands = [];
	public var count = 0;
	public var index = 0; 
	public var wait_timer = 0;
	
	public function obj_cutscene()
	{
		super();
		index = 0;
		GMControl.Log( "cutscene created" );
	}
	
	// 
	
	override public function Step()
	{
		if ( index >= count )
		{
			return Done();
		}
		
		var i;
		if ( wait_timer > 0 )
		{
			wait_timer -= body.timescale_delta;
			return;
		}
		
		while ( index < count )
		{
			var cmd = commands[index];
			++index;
			DoCommand( cmd );
			if ( wait_timer > 0 )
				break;
		}
	}
	
	public function Done()
	{
		index = count;
		instance_destroy();
	}
	
	public function AddCommand( ...args )
	{
		trace( "add " + args );
		commands.push( args[0] );
		++count;
	}
	
	public function DoCommand( arg )
	{
		if ( arg.length < 1 )
			return;
		var command = arg[0];
		var statename;
		var inst, varname, val;
		GMControl.Log( "cutscene: " + command );
		switch ( command )
		{
			case "state":
				statename = arg[1];
				if ( statename != null )
					body.SetState( statename );
				break;
			case "wait":
				wait_timer = arg[1];
				break;
			case "var":
				inst = arg[1];
				varname = arg[2];
				val = arg[3];
				inst[varname] = val;
				break;
		}
	}
}











