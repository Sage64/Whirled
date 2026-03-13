
// Deltarune body base
// should supply global behaviour/interaction basis for
// other deltarune characters

package deltarune
{

import gamemaker.*;

import flash.display.*;
import flash.events.*;
import flash.utils.*;

import com.threerings.util.*
import com.whirled.*

/*
	In the darkworld (darkmode = true) most things are scaled 2x
*/

public class DeltaruneBody extends GMBody
{
	public static var spr_battlebg;
	public static var spr_tiredmark;
	
	// 
	
	public var darkmode = false;
	
	public var bscale = 3;
	public var darkscale = bscale / 2;
	
	public var aqcolor = 0x03a5fc;
	public var lighty = 0xfff947;
	
	public var cutscene;
	public var siner = 0;
	
	public function DeltaruneBody()
	{
		var i;
		
		spr_battlebg = sprite_get( "spr_battlebg" );
		spr_tiredmark = sprite_get( "spr_tiredmark" );
		
		if ( !global.damagefont )
		{
			global.damagefont = { name: "_sans", size: 12 };
		}
		
		super( 30 );
		
		// use_delta = false;
		
		SetScale ( bscale );
		
		if ( SetNameTag() )
		{
			var _size = 20;
			nametag.SetBaseColor( 0xFFFFFF );
			nametag.SetBaseOutline( 0x000000 );
			// nametag.SetFont( "8bitoperator JVE", true );
			nametag.SetFont( "Determination Sans", true );
			nametag.SetSize( _size * 1 );
			nametag.textInit.outlineWidth = _size / 3.5;
			nametag.textInit.sharpness = 400;
			//nametag.SetScale( 1 );
			nametag.Apply();
		}
		
		if ( global.flag == null )
		{
			global.flag = new Array( 100 );
			global.interact = 0;
		}
	}
	
	public function LWState( statename, sprites = null )
	{
		var State = AddState( statename );
		// 
		State.darkzone = 0;
		State.run = 0;
		State.board = 0;
		State.sprite = sprites;
		State.directional = 0;
		
		if ( sprites != null )
		{
			if ( ( sprites.constructor == Array ) && sprites.length > 0 )
			{
				if ( sprites.length >= 4 )
				{
					State.directional = 4;
					State.sprite = [
						sprite_get( sprites[0] ),
						sprite_get( sprites[1] ),
						sprite_get( sprites[2] ),
						sprite_get( sprites[3] )
					]
				}
			}
			else
				State.sprite = sprite_get( sprites );
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
		if ( curState && curState.darkzone )
			global.darkzone = 1;
		else
			global.darkzone = 0;
	}
	
	override public function OnUpdateLook()
	{
		if ( hDir > 0 )
            image_xscale = -Math.abs( image_xscale );
        else
            image_xscale = Math.abs( image_xscale );
	}
	
	override public function OnSleep()
	{
		
	}
	
	override public function OnWake()
	{
		
	}
	
	override public function Step()
	{
		
	}
	
	override public function Draw()
	{
		draw_self();
	}
	
	override public function DrawEnd()
	{
		super.DrawEnd();
		var tireddraw = ( isSleeping && nametag );
		if ( tireddraw && spr_tiredmark )
		{
			var _sprscale = GMControl.unscaleX * 1.25;
			//var xx = nametag.x + ( nametag.textW * _tagscale );
			var xx = nametag.x + ( nametag.width / 2 );
			xx += ( 4 * _sprscale ) + ( GMControl.unscaleX * 4 ) + ( 16 * _sprscale / 2 )
			var yy = nametag.y - ( nametag.height / 2 ); // - ( spr_tiredmark.height / 2 );
			draw_sprite_ext( spr_tiredmark, 0, xx, yy, _sprscale, _sprscale, 0, 0xFFFFFF, nametag.alpha );
		}
	}
	
	// 
	
	override public function OnOtherMoveStart( _id, _dest )
	{
		// wip follow behaviour for pets
		return;
		if ( ctrl.isPet && ( ctrl.getOwnerId() == ctrl.getEntityProperty( EntityControl.PROP_MEMBER_ID, _id ) ) )
		{
			var pos = ctrl.getLogicalLocation();
			var ownerpos = ctrl.getEntityProperty( EntityControl.PROP_LOCATION_LOGICAL, _id );
			if ( _dest == null )
				return;
			if ( ownerpos == null )
				return;
			var dir = 90 - gml.point_direction( pos[0], ownerpos[2], ownerpos[0], pos[2] );
			ctrl.setLogicalLocation( ownerpos[0], ownerpos[1], ownerpos[2], dir );
		}
	}
	
	// Deltarune gamemaker functions
	
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
	
	public function snd_play( _sound )
	{
		return GMObject.audio_play_sound( _sound  );
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
	// variable must exist and not be null
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

// 
class obj_talkballoon extends DeltaruneObject
{
	
}













