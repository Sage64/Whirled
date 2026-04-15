// PlayerBody
package ganggarrison
{
import gamemaker.*;
import flash.display.*;
import flash.geom.*;
import flash.utils.*;

public class PlayerBody extends GMBody
{
	public var player;
	public var character;
	public var rewards = {};
	
	public var newTeam = -1;
	public var newClass = -1;
	
	public var gamewindow_obj;
	
	public var mouseAim = true;
	public var aim_mousex = 40;
	public var aim_mousey = -12;
	public var aim_mousex_prev = 0;
	public var aim_mousey_prev = 0;
	public var aim_lerp = 0;
	public var aim_dir = 0;
	public var aim_dis = 24;
	
	public var aimDirection = 0;
	
	public var syncrate = 8.5;
	public var lastAimDirection = null;
	public var lastSyncTime = 0;
	
	public function PlayerBody()
	{
		super();
		
		SetVersion( 0 );
		
		SetScale( 3 );
		
		nametag = 0;
		
		global.delta_factor = 1;
		
		mystates["default"] = AddState( "Default" );
		
		// Rewards
		mymemories["rewards"] = AddMemory( "ganggarrison.rewards", {}, OnRewards );
		
		if ( GetMemory( "gm.purchase_version" ) < 10 )
		{
			AddAction( "[Toggle Reward: Gold Weapon]", Action_ToggleReward, "GW" );
		}
		
		myactions["input"] = AddAction( "[Open Input]", Action_InputPopup );
		myactions["teammenu"] = AddAction( "[Change Team]", Action_TeamMenu );
		myactions["classmenu"] = AddAction( "[Change Class]", Action_JoinClass );
		if ( true )
		{
			myactions["scout"] = AddAction( "[Runner]", Action_JoinClass, CLASS_SCOUT );
			myactions["pyro"] = AddAction( "[Firebug]", Action_JoinClass, CLASS_PYRO );
			myactions["soldier"] = AddAction( "[Rocketman]", Action_JoinClass, CLASS_SOLDIER );
			myactions["heavy"] = AddAction( "[Overweight]", Action_JoinClass, CLASS_HEAVY );
			myactions["demoman"] = AddAction( "[Detonator]", Action_JoinClass, CLASS_DEMOMAN );
			myactions["medic"] = AddAction( "[Healer]", Action_JoinClass, CLASS_MEDIC );
			myactions["engineer"] = AddAction( "[Constructor]", Action_JoinClass, CLASS_ENGINEER );
			myactions["spy"] = AddAction( "[Infiltrator]", Action_JoinClass, CLASS_SPY );
			myactions["sniper"] = AddAction( "[Rifleman]", Action_JoinClass, CLASS_SNIPER );
		}
		
		
		mystates["humiliated"] = AddState( "Humiliated" );
		state.humiliated = true;
		
		myactions["jump"] = AddAction( "[Jump]", Action_Jump );
		myactions["attack"] = AddAction( "[Fire]", Action_Shoot, 0 );
		myactions["attack2"] = AddAction( "[Alt. Fire]", Action_Shoot, 1 );
		myactions["taunt"] = AddAction( "[Taunt]", Action_Taunt );
		
		mymemories["class_select"] = AddMemory( "ganggarrison.class_select", CLASS_SCOUT, OnStateChanged );
		mymemories["team_select"] = AddMemory( "ganggarrison.team_select", TEAM_RED, OnStateChanged );
		
		mymemories["inputstate"] = AddMemory( "ganggarrison.inputstate", [ 0, 0, 0 ], OnInputState );
		memory.dontlog = true;
	}
	
	override public function Create()
	{
		super.Create();
		
		global.gg2Font = font_add_sprite( global.gg2FontS, ord( "!" ), false, 0 );
		
	}
	
	override public function OnStateChanged()
	{
		super.OnStateChanged();
		
		newTeam = GetMemory( "ganggarrison.team_select" );
		newClass = GetMemory( "ganggarrison.class_select" );
		
		if ( !instance_exists( player ) )
			player = instance_create_depth( 0, 0, 0, Player );
		global.paramPlayer = player;
		player.team = newTeam;
		player.rewards = GetMemory( "ganggarrison.rewards" );
		
		if ( !instance_exists( gamewindow_obj ) )
			gamewindow_obj = instance_create_depth( 0, 0, 0, GameWindow );
		
		var classObj = GetClassObject( newClass );
		
		if ( instance_exists( character ) )
		{
			if ( ( character.object_index != classObj ) || ( character.team != player.team ) )
				instance_destroy( character );
		}
		
		if ( !instance_exists( character ) )
		{
			character = instance_create_depth( 0, 0, 0, classObj );
			character.x = 0;
			character.y = 0 + ( character.sprite_yoffset ) - ( character.sprite_height );
		}
		
		x = 0;
		y = character.y - ( character.sprite_yoffset ) + ( character.sprite_height );
		characterH = 55;
		
		if ( curState )
		{
			if ( curState.humiliated )
			{
				character.humiliated = true;
				character.humiliationOffset = irandom(10) * 3;
			}
			else
				character.humiliated = false;
		}
		
		
		SetViewOffset( 0, -32 );
	}
	
	override public function OnUpdateLook()
	{
		super.OnUpdateLook();
		if ( ( aimDirection == null ) && instance_exists( character ) )
		{
			aim_mousex = character.x + ( 50 * ( hDir > 0 ? 1 : -1 ) );
			aim_mousey = character.y - 5;
			aimDirection = point_direction( character.x, character.y, aim_mousex, aim_mousey );
		}
	}
	
	override public function Step()
	{
		super.Step();
		if ( mouseAim && instance_exists( character ) )
			StepMouseAim();
	}
	
	public function StepMouseAim()
	{
		var xx, yy, dir, inputstate;
		if ( GMControl.isControl )
		{
			var _time = getTimer();
			if ( _time > ( lastSyncTime + ( 1000 / syncrate ) ) )
			{
				lastSyncTime = _time;
				if ( instance_exists( gamewindow_obj ) )
				{
					xx = gamewindow_obj.aimx;
					yy = gamewindow_obj.aimy;
					dir = point_direction( character.x, character.y, xx, yy );
					if ( dir != lastAimDirection )
					{
						inputstate = [ 0, dir ];
						SetMemory( "ganggarrison.inputstate", inputstate );
						lastAimDirection = dir;
					}
				}
			}
		}
		xx = character.x;
		yy = character.y;
		xx += lengthdir_x( aim_dis, aim_dir );
		yy += lengthdir_y( aim_dis, aim_dir );
		aim_lerp = Math.min( 1, aim_lerp + ( ( timescale_delta * syncrate ) / 30 ) );
		aim_mousex = lerp( aim_mousex_prev, xx, aim_lerp );
		aim_mousey = lerp( aim_mousey_prev, yy, aim_lerp );
		aimDirection = point_direction( character.x, character.y, aim_mousex, aim_mousey );
	}
	
	override public function Draw()
	{
		if ( false && GMControl.isControl )
		{
			var _sc = ( 1 / ( GM.overlay.transform.concatenatedMatrix.a ) ) * 2;
			var _xx = GM.container.x - GM.overlay.x;
			var _yy = GM.container.y - GM.overlay.y;
			surface_set_target( GM.overlay );
			_xx += ( aim_mousex * container.scaleX );
			_yy += ( aim_mousey * container.scaleY );
			draw_sprite_ext( global.CrosshairS, 0, _xx, _yy, _sc, _sc, 0, c_white, 1 );
			surface_reset_target();
		}
	}
	
	// 
	
	public function hasClassReward( _player, reward )
	{
		var rewards = _player.rewards;
		return ( rewards && rewards[reward] ) ? true : false;
	}
	
	public function OnRewards( data = null )
	{
		this.rewards = data;
		//instance_destroy( character );
		if ( instance_exists( character ) )
			character.UpdateSprites();
		OnStateChanged();
	}
	
	public function GetClassObject( classId )
	{
		trace( classId );
		switch ( classId )
		{
			case CLASS_SCOUT:
				return Scout;
			case CLASS_SOLDIER:
				return Soldier;
			case CLASS_PYRO:
				return Pyro;
			case CLASS_DEMOMAN:
				return Demoman;
			case CLASS_HEAVY:
				return Heavy;
			case CLASS_ENGINEER:
				return Engineer;
			case CLASS_MEDIC:
				return Medic;
			case CLASS_SNIPER:
				return Sniper;
			case CLASS_SPY:
				return Spy;
		}
		return Scout;
	}
	
	public function OnInputState( data = null )
	{
		aim_mousex_prev = aim_mousex;
		aim_mousey_prev = aim_mousey;
		aim_lerp = 0;
		aim_dir = data[1];
	}
	
	// Actions
	
	public function Action_ToggleReward( reward = null )
	{
		if ( !GMControl.isControl )
			return;
		var rewards = GetMemory( "ganggarrison.rewards" );
		rewards[reward] = ( rewards[reward] ? null : 1 );
		SetMemory( "ganggarrison.rewards", rewards );
	}
	
	public function Action_InputPopup( data = null )
	{
		if ( !GMControl.isControl )
			return;
		if ( !instance_exists( gamewindow_obj ) )
			gamewindow_obj = instance_create_depth( 0, 0, 0, GameWindow );
		GMControl.DoPopupObject( null, 600, 450 );
	}
	
	public function Action_TeamMenu( data = null )
	{
		if ( !GMControl.isControl )
			return;
		if ( data == null )
		{
			data = ( this.newTeam == TEAM_RED ) ? TEAM_BLUE : TEAM_RED;
			// return Action_InputPopup();
		}
		SetMemory( "ganggarrison.team_select", data );
	}
	
	public function Action_JoinClass( data = null )
	{
		if ( !GMControl.isControl )
			return;
		if ( data == null )
		{
			Action_InputPopup();
			return;
		}
		SetMemory( "ganggarrison.class_select", data );
	}
	
	public function Action_Jump( data = null )
	{
		
	}
	
	public function Action_Shoot( data = null )
	{
		
	}
	
	public function Action_Taunt( data = null )
	{
		with( character )
		{
			taunting = false;
			omnomnomnom = false;
			
			taunting = true;
			tauntindex = 0;
			image_speed = tauntspeed;
		}
	}
}
}

import gamemaker.*;

internal const TEAM_NONE = 0;
internal const TEAM_RED = 1;
internal const TEAM_BLUE = 2;
internal const TEAM_SPECTATOR = 3;
internal const TEAM_ANY = 4;

internal const CLASS_NONE = 0;
internal const CLASS_SCOUT = 1;
internal const CLASS_SOLDIER = 2;
internal const CLASS_PYRO = 3;
internal const CLASS_DEMOMAN = 4;
internal const CLASS_HEAVY = 5;
internal const CLASS_ENGINEER = 6;
internal const CLASS_MEDIC = 7;
internal const CLASS_SNIPER = 8;
internal const CLASS_SPY = 9;
internal const CLASS_QUOTE = 10;

internal const CHARACTER_ANIMATION_NORMAL = 0;
internal const CHARACTER_ANIMATION_INTEL = 2;
internal const CHARACTER_ANIMATION_LEN = 4;

class GameWindow extends GMObject
{
	public var aimx = 0;
	public var aimy = 0;
	
	override public function Step()
	{
		aimx = mouse_x; // GM.container.mouseX;
		aimy = mouse_y; // GM.container.mouseY;
	}
	
	override public function Draw()
	{
		surface_set_target( GMControl.popup_surface );
		DrawMenu();
		surface_reset_target();
	}
	
	public function DrawMenu()
	{
		var ww = GMControl.popup_width;
		var hh = GMControl.popup_height;
		draw_set_color( c_black );
		draw_set_alpha( 0.2 );
		draw_rectangle( 0, 0, ww, hh, false );
		
		
		draw_set_alpha( 1 );
		draw_set_color( c_white );
		var xx = aimx;
		var yy = aimy;
		draw_sprite_ext( global.CrosshairS, 0, xx, yy, 1, 1, 0, c_white, 1 );
	}
}

// 

class GG2Entity extends GMObject
{
	public var team = TEAM_RED;
	public var teamcolor = c_red;
	public var teamName = "Red";
	
	// status
	public var ubered = false;
	
	override public function Create()
	{
		super.Create();
		if ( team == TEAM_BLUE )
		{
			teamcolor = c_blue;
			teamName = "Blue";
		}
		else
		{
			teamcolor = c_red;
			teamName = "Red";
		}
	}
	
	// Function 
	
	public function draw_characterpart_ext( _sprite, _subimg, _x, _y, _xsc, _ysc, _ang, _col, _alpha )
	{
		draw_sprite_ext( _sprite, _subimg, _x, _y, _xsc, _ysc, _ang, _col, _alpha );
		if ( ubered )
		{
			draw_sprite_ext( _sprite, _subimg, _x, _y, _xsc, _ysc, _ang, teamcolor, _alpha * 0.7 );
		}
	}
	
	public function draw_characterpart_ext_overlay( _sprite, _overlay, _gear, _subimg, _x, _y, _xsc, _ysc, _ang, _col, _alpha, _voffset = 0 )
	{
		draw_characterpart_ext( _sprite, _subimg, _x, _y, _xsc, _ysc, _ang, _col, _alpha );
		if ( _overlay != -1 )
		{
			for ( var i = 0; i < _overlay.length; ++i )
			{
				draw_characterpart_ext( _overlay[i], _subimg, _x, _y + _voffset, _xsc, _ysc, _ang, _col, _alpha );
			}
		}
	}
}

// PLAYER

class Player extends GG2Entity
{
	public var classId = 0;
	public var object;
	
	public var badges = [];
	public var rewards = {};
	
	public function Player()
	{
		super();
	}
	
	override public function Cleanup()
	{
		super.Cleanup();
		if ( instance_exists( object ) )
		{
			instance_destroy( object );
		}
	}
}



// CHARACTERS

class Character extends GG2Entity
{
	public var player = global.paramPlayer;
	public var maxHp = 100;
	public var weapons = [null];
	
	public var classId = CLASS_SCOUT;
	public var className = "Scout";
	public var stateName = "Run";
	
	public var hoverName = false;
	
	public var canDoubleJump = 0;
	public var canCloak = 0;
	public var canBuild = 0;
	public var baseJumpStrength = ( 8.3 );
	public var jumpStrength = baseJumpStrength;
	public var capStrength = 1;
	
	public var applied_gravity = 0;
	
	// status
	public var hp = maxHp;
	public var flamecount = 0;
	public var invisible = false;
	public var intel = false;
	public var taunting = false;
	public var doubleJumpUsed = 0;
	//public var ubered = false; // GG2Entity
	public var stabbing = false;
	public var onCabinet = false;
	public var wantToJump = false;
	public var timeUnscathed = 0;
	public var syncWrongness = 0;
	public var humiliated = false;
	
	// animation state
	public var equipmentOffset = 0;
	public var onground = true;
	public var still = true;
	public var yoffset = 0;
	public var sprite_special = false;
	public var tauntindex = 0;
	
	// sprites
	public var spriteStand;
	public var spriteWalk;
	public var spriteRun;
	public var spriteJump;
	public var spriteLeanL;
	public var spriteLeanR;
	public var spriteIntel;
	public var spriteDead;
	public var humiliationPoses;
	public var tauntsprite;
	public var intelSprite;
	public var goldTaunt;
	
	// scout
	// soldier
	// pyro
	// demoman
	// heavy
	public var omnomnomnom = false;
	public var canEat = true;
	public var eatCooldown = 1350;
	// engineer
	public var maxNutsNBolts = 100;
	public var nutsNBolts = maxNutsNBolts;
	// medic
	// sniper
	public var zoomed = false;
	// spy
	
	// control
	public var moveStatus = 0;
	public var baseControl = 0.85;
	public var baseFriction = 1.15;
	public var controlFactor = baseControl;
	public var frictionFactor = baseFriction;
	public var baseRunPower = 1;
	public var runPower = baseRunPower;
	public var basemaxspeed;
	public var highestbasemaxspeed = 9.735;
	
	
	// controls
	public var aimDirection = 0;
	public var aimDistance = 0;
	
	public var animationOffset = CHARACTER_ANIMATION_NORMAL;
	public var animationImage = 0;
	public var humiliationOffset = irandom(10) * 3;
	
	public var tauntspeed = 3;
	
	// overlays
	public var overlayOffset = 0;
	public var stillOverlays = [];
	public var leanLOverlays = [];
	public var leanROverlays = [];
	public var jumpOverlays = [];
	public var runOverlays = [];
	public var walkOverlays = [];
	public var tauntOverlays = [];
	public var crouchOverlays = [];
	public var omnomnomnomOverlays = [];
	
	public var gearList = [];
	
	// weapon
	public var currentWeapon;
	
	public function Character()
	{
		super();
		image_speed = 0;
		
		if ( instance_exists( player ) )
			team = player.team;
	}
	
	override public function Create()
	{
		super.Create();
		
		// status
		hp = maxHp;
		
		// sprites
		UpdateSprites();
		
		// control
		runPower = baseRunPower
		basemaxspeed = Math.abs( ( baseRunPower * baseControl ) / ( baseFriction - 1 ) );
		body.SetMoveSpeed( basemaxspeed );
		
		// weapon
		global.paramOwner = this;
		currentWeapon = instance_create_depth( x, y, depth, weapons[0] );
		global.paramOwner = null;
		
		
	}
	
	public function UpdateSprites()
	{
		// Rewards
		goldTaunt = false;
		if ( body.hasClassReward( player, "GW" ) )
		{
			switch ( classId )
			{
				case CLASS_HEAVY:
					
				case CLASS_SCOUT:
				case CLASS_SOLDIER:
				case CLASS_PYRO:
				case CLASS_DEMOMAN:
				case CLASS_MEDIC:
				case CLASS_SNIPER:
					goldTaunt = true;
			}
		}
		
		var pre = className + teamName;
		var suf = "S";
		spriteStand = global[pre + "Stand" + suf];
		spriteWalk = global[pre + "Walk" + suf];;
		spriteRun = global[pre + "Run" + suf];
		spriteJump = global[pre + "Jump" + suf];
		spriteLeanL = global[pre + "LeanL" + suf];
		spriteLeanR = global[pre + "LeanR" + suf];
		spriteIntel = global[pre + "Intel" + suf];
		spriteDead = global[pre + "Dead" + suf];
		humiliationPoses = global[pre + "H" + suf];
		tauntsprite = global[pre + ( goldTaunt ? "GoldWeaponTaunt" : "Taunt" ) + suf];
		
		if ( instance_exists( currentWeapon ) )
			currentWeapon.UpdateSprites();
	}
	
	override public function Step()
	{
		CharacterBeginStep();
		
		aimDirection = body.aimDirection;//point_direction( x, y, body.aim_mousex, body.aim_mousey );
		
		CharacterEndStep();
		
		hoverName = false;
		if ( !hoverName )
		{
			if ( point_distance( x, y, mouse_x, mouse_y ) < ( 8 + 25 ) )
				hoverName = true;
		}
	}
	
	override public function GMMovement()
	{
		if ( false )
		{
			super.GMMovement();
		}
	}
	
	public function CharacterBeginStep()
	{
		switch( moveStatus )
		{
			
			
			default:
				if ( humiliated )
					controlFactor = ( baseControl - 0.2 );
				else if ( intel )
					controlFactor = baseControl - 0.1;
				else
					controlFactor = baseControl;
				frictionFactor = baseFriction;
		}
		
		
		if ( false )
		{
			// Whirled forced movement
			hspeed = body.speed * ( body.hspeed > 0 ? 1 : -1 );
		}
		else
		{
			// "Game" movement
			var moveleft = false;
			var moveright = false;
			if ( player.body.isMoving )
			{
				if ( player.body.hspeed > 0 )
					moveright = true;
				else
					moveleft = true;
			}
			var controlling = false;
			for ( var i = 0; i < 1; ++i )
			{
				// Do Movement
				if ( true )
				{
					if ( moveleft && moveright )
					{
						
					}
					else
					{
						if ( moveleft && ( hspeed >= -basemaxspeed ) )
						{
							hspeed -= ( runPower * controlFactor );
							controlling = true;
						}
						if ( moveright && ( hspeed <= basemaxspeed ) )
						{
							hspeed += ( runPower * controlFactor );
							controlling = true;
						}
					}
				}
				hspeed /= ( ( Math.abs( hspeed ) > ( basemaxspeed * 2 ) ) ? baseFriction : frictionFactor ) * 1;
			}
			if ( !controlling && ( Math.abs( hspeed ) < 0.195 ) )
				hspeed = 0;
		}
		
		var sprite_length;
		
		if ( humiliated )
			sprite_length = 2;
		else if ( zoomed || ( className == "Querly" ) )
			sprite_length = 2;
		else
			sprite_length = CHARACTER_ANIMATION_LEN;
		
		var jumpAnimationImage = 1;
		if ( humiliated )
			jumpAnimationImage = 2;
		
		if ( onground && ( hspeed == 0 ) )
			animationImage = 0;
		else if ( !onground )
			animationImage = jumpAnimationImage;
		else
		{
			animationImage += ( Math.min( Math.abs( hspeed ) , 8 ) * sign( hspeed ) * image_xscale ) * global.delta_factor / 20;
			animationImage = ( animationImage + sprite_length ) % sprite_length;
			//trace( animationImage );
		}
	}
	
	public function CharacterEndStep()
	{
		var facing = ( dcos( aimDirection ) > 0 ) ? 1 : -1;
		image_xscale = facing * Math.abs( image_xscale );
		
		if ( instance_exists( currentWeapon ) )
		{
			currentWeapon.image_xscale = Math.abs( image_xscale );
			currentWeapon.image_angle = aimDirection;
			if ( image_xscale < 0 )
			{
				currentWeapon.image_xscale *= -1;
				currentWeapon.image_angle += 180;
			}
			currentWeapon.x = x;
			currentWeapon.y = y;
		}
		
		if ( taunting )
		{
			tauntindex += tauntspeed * 0.1 * global.delta_factor;
			if ( tauntindex >= sprite_get_number( tauntsprite ) )
				taunting = false;
		}
	}
	
	override public function Draw()
	{
		var xx = x;
		var yy = y;
		
		var sprite = sprite_index;
		var subimg = animationImage + animationOffset;
		var overlayList = -1;
		var noNewAnim = ( humiliated || className == "Querly" );
		if ( zoomed )
		{
			sprite = global["Sniper" + teamName + "CrouchS"];
			animationImage = animationImage % 2;
			overlayList = crouchOverlays;
		}
		else if ( !noNewAnim )
		{
			if ( !onground )
			{
				sprite = spriteJump;
				overlayList = jumpOverlays;
			}
			else
			{
				if ( hspeed == 0 )
				{
					sprite = spriteStand;
					overlayList = stillOverlays;
				}
				else
				{
					if ( ( spriteWalk != null ) && ( Math.abs( hspeed ) < 3 ) )
					{
						sprite = spriteWalk;
						overlayList = walkOverlays;
					}
					else
					{
						sprite = spriteRun;
						overlayList = runOverlays;
					}
				}
			}
		}
		
		var yoffset = 0;
		if ( !noNewAnim && !taunting && !stabbing && !omnomnomnom && ( sprite != sprite_index ) && ( sprite == spriteLeanL || sprite == spriteLeanR ) )
			yoffset = 6;
		
		equipmentOffset = ( ( onground ) && ( sprite == spriteRun ) && ( ( Math.floor( animationImage ) % 2 ) == 0 ) ) ? -2 : 0;
		overlayOffset = equipmentOffset;
		
		if ( !noNewAnim )
			animationOffset = 0;
		
		var drawWeapon = instance_exists( currentWeapon );
		
		equipmentOffset += yoffset;
		
		yy += yoffset;
		
		var overlays = overlayList;
		var gear = gearList;
		
		if ( taunting )
		{
			sprite = tauntsprite;
			subimg = tauntindex;
			overlays = tauntOverlays;
			drawWeapon = false;
		}
		else if ( humiliated )
		{
			sprite = humiliationPoses;
			overlays = -1;
			gear = -1;
			subimg = ( Math.floor( animationImage ) + humiliationOffset );
			if ( hspeed != 0 )
				subimg += 1;
			drawWeapon = false;
		}
		else
		{
			if ( intel )
				draw_sprite_ext( intelSprite, 0, xx, yy + equipmentOffset, image_xscale, image_yscale, 0, c_white, image_alpha );
			if ( zoomed )
				overlayOffset += 4;
		}
		draw_characterpart_ext_overlay( sprite, overlays, gear, subimg, xx, yy, image_xscale, image_yscale, image_angle, image_blend, image_alpha, overlayOffset );
		if ( drawWeapon )
			currentWeapon.Draw();
		if ( hoverName )
			CharacterDrawName();
	}
	
	public function CharacterDrawName()
	{
		draw_set_color( teamcolor );
		var width, height;
		
		width = 0;
		height = 0;
		
		var _x, _y, _alpha;
		
		_x = ( this.x );
		_y = ( this.y - 35 - height );
		_alpha = 1;
		
		draw_set_halign( fa_top );
		draw_set_valign( fa_left );
		
		for ( var i = 0; i < player.badges.length; ++i )
		{
			
		}
		
		draw_text( _x, _y, player.name, _alpha );
	}
}

class Scout extends Character
{
	public function Scout()
	{
		super();
		classId = CLASS_SCOUT;
		className = "Scout";
		sprite_index = global[className+"RedS"];
		//
		baseRunPower = 1.4;
		maxHp = 100;
		weapons[0] = Scattergun;
	}
	
	override public function Create()
	{
		super.Create();
		capStrength = 2;
		canDoubleJump = true;
	}
}
class Soldier extends Character
{
	public function Soldier()
	{
		super();
		sprite_index = global.SoldierRedS;
		classId = CLASS_SOLDIER;
		className = "Soldier";
		//
		baseRunPower = 0.9;
		maxHp = 160;
		weapons[0] = Rocketlauncher;
	}
}

class Pyro extends Character
{
	public function Pyro()
	{
		super();
		classId = CLASS_PYRO;
		className = "Pyro";
		sprite_index = global[className+"RedS"];
		//
		baseRunPower = 0.9;
		maxHp = 160;
		weapons[0] = Flamethrower;
	}
}

class Demoman extends Character
{
	public function Demoman()
	{
		super();
		
		classId = CLASS_DEMOMAN;
		className = "Demoman";
		sprite_index = global[className+"RedS"];
		//
		baseRunPower = 1;
		maxHp = 120;
		weapons[0] = Minegun;
	}
}

class Heavy extends Character
{
	public function Heavy()
	{
		super();
		
		classId = CLASS_HEAVY;
		className = "Heavy";
		sprite_index = global[className+"RedS"];
		//
		baseRunPower = 1;
		maxHp = 120;
		weapons[0] = Minigun;
	}
}

class Engineer extends Character
{
	public function Engineer()
	{
		super();
		
		classId = CLASS_ENGINEER;
		className = "Engineer";
		sprite_index = global[className+"RedS"];
		//
		baseRunPower = 1;
		maxHp = 120;
		weapons[0] = Shotgun;
	}
}

class Medic extends Character
{
	public function Medic()
	{
		super();
		
		classId = CLASS_MEDIC;
		className = "Medic";
		sprite_index = global[className+"RedS"];
		//
		baseRunPower = 1;
		maxHp = 120;
		weapons[0] = Medigun;
	}
}

class Sniper extends Character
{
	public function Sniper()
	{
		super();
		classId = CLASS_SNIPER;
		className = "Sniper";
		sprite_index = global[className+"RedS"];
		//
		baseRunPower = 0.9;
		maxHp = 120;
		weapons[0] = Rifle;
	}
}

class Spy extends Character
{
	public function Spy()
	{
		super();
		classId = CLASS_SPY;
		className = "Spy";
		sprite_index = global[className+"RedS"];
		//
		baseRunPower = 0.9;
		maxHp = 120;
		weapons[0] = Revolver;
	}
	
	override public function Create()
	{
		super.Create();
		canCloak = true;
	}
}

// WEAPONS

class Weapon extends GG2Entity
{
	public var owner = global.paramOwner;
	public var ownerPlayer = owner.player;
	public var golden = false;
	
	public var weaponId = 0;
	public var weaponName = "Weapon";
	
	public var xoffset = 0;
	public var yoffset = 0;
	
	public var idle = true;
	
	public var maxAmmo = 1;
	public var ammoCount = 1;
	
	public var readyToShoot = false;
	public var justShot = false;
	public var refireTime = 30;
	
	public var reloadTime = 15;
	public var reloadBuffer = 20;
	
	public var normalSprite;
	public var recoilSprite;
	public var reloadSprite;
	
	public var recoilTimer = 0;
	public var recoilTime = 0;
	public var recoilAnimLength = 0;
	public var recoilImageSpeed = 0;
	
	public var reloadAnimLength = 0;
	public var reloadImageSpeed = 0;
	
	public function Weapon()
	{
		super();
		visible = false;
		team = owner.team;
		
		golden = body.hasClassReward( ownerPlayer, "GW" );
	}
	
	override public function Create()
	{
		super.Create();
		
		ammoCount = maxAmmo;
		if ( recoilTime == 0 )
			recoilTime = refireTime;
		
		UpdateSprites();
		
		sprite_index = normalSprite;
		
		xoffset += sprite_get_xoffset( sprite_index );
		yoffset += sprite_get_yoffset( sprite_index );
	}
	
	public function UpdateSprites()
	{
		golden = body.hasClassReward( ownerPlayer, "GW" );
		
		var pre = weaponName;
		var suf = golden ? "GoldS" : "S"
		normalSprite = global[pre+""+suf];
		recoilSprite = global[pre+"F"+suf];
		reloadSprite = global[pre+"FR"+suf];
		recoilAnimLength = sprite_get_number( recoilSprite ) / 2;
		recoilImageSpeed = recoilAnimLength / recoilTime;
		reloadAnimLength = sprite_get_number( reloadSprite ) / 2;
		reloadImageSpeed = reloadAnimLength / reloadTime;
	}
	
	override public function Step()
	{
		if ( justShot )
		{
			justShot = false;
			if ( sprite_index != recoilSprite )
			{
				sprite_index = recoilSprite;
				image_index = 0;
				image_speed = ( recoilImageSpeed * global.delta_factor );
			}
			recoilTimer = ( recoilTime / global.delta_factor );
		}
	}
	
	override public function Draw()
	{
		var sprite = normalSprite;
		var xx = x + ( xoffset * image_xscale );
		var yy = y + ( yoffset * image_yscale );
		
		var isblue = ( teamcolor == c_blue );
		var imageOffset = ( isblue ) ? 1 : 0;
		yy += owner.equipmentOffset * owner.image_yscale;
		draw_characterpart_ext( sprite, imageOffset, xx, yy, image_xscale, image_yscale, image_angle, image_blend, image_alpha );
	}
	
}

class Scattergun extends Weapon
{
	public function Scattergun()
	{
		super();
		weaponName = "Scattergun";
		sprite_index = global[weaponName+"S"];
		// 
		xoffset = -5;
		yoffset = -4;
		refireTime = 20;
		maxAmmo = 6;
		reloadTime = 15;
		reloadBuffer = refireTime;
	}
}

class Rocketlauncher extends Weapon
{
	public var rocketrange = 501;
	
	public function Rocketlauncher()
	{
		super();
		weaponName = "Rocketlauncher";
		sprite_index = global[weaponName+"S"];
		//
		xoffset = -15;
		yoffset = -10;
		refireTime = 30;
		reloadTime = 22;
		reloadBuffer = refireTime;
		maxAmmo = 4;
	}
}

class Flamethrower extends Weapon
{
	public function Flamethrower()
	{
		super();
		weaponName = "Flamethrower";
		sprite_index = global[weaponName+"S"];
		// 
		xoffset = -11;
		yoffset = 4;
		refireTime = 1;
		maxAmmo = 200;
		reloadBuffer = 7;
	}
}

class Minegun extends Weapon
{
	public var maxMines = 8;
	public var lobbed = 0;
	
	public function Minegun()
	{
		super();
		weaponName = "Minegun";
		sprite_index = global[weaponName+"S"];
		// 
		xoffset = -3;
		yoffset = -2;
		refireTime = 26;
		maxAmmo = 8;
		reloadTime = 15;
		reloadBuffer = refireTime;
		recoilTime = 3;
	}
}

class Minigun extends Weapon
{
	public function Minigun()
	{
		super();
		weaponName = "Minigun";
		sprite_index = global[weaponName+"S"];
		// 
		xoffset = -11;
		yoffset = 0;
		refireTime = 2;
		maxAmmo = 200;
		reloadBuffer = 10;
	}
}

class Shotgun extends Weapon
{
	public function Shotgun()
	{
		super();
		weaponName = "Shotgun";
		sprite_index = global[weaponName+"S"];
		// 
		xoffset = -5;
		yoffset = -2;
		refireTime = 20;
		maxAmmo = 6;
		reloadTime = 15;
		reloadBuffer = refireTime;
	}
}

class Medigun extends Weapon
{
	public function Medigun()
	{
		super();
		weaponName = "Medigun";
		sprite_index = global[weaponName+"S"];
		// 
		xoffset = -7;
		yoffset = 0;
		refireTime = 3;
		maxAmmo = 40;
		reloadTime = 55;
		reloadBuffer = refireTime;
		recoilTime = refireTime + 1;
	}
}


class Rifle extends Weapon
{
	public var unscopedDamage = 35;
	public var baseDamage = 45;
	public var maxDamage = 75;
	public var chargeTime = 105;
	public var hitDamage = baseDamage;
	public var shot = false;
	public var tracerAlpha = 0;
	public var longRecoilTime = 60;
	
	public function Rifle()
	{
		super();
		weaponName = "Rifle";
		sprite_index = global[weaponName+"S"];
		// 
		xoffset = -5;
		yoffset = -8;
		refireTime = 40;
		reloadTime = 40;
		reloadBuffer = refireTime;
		maxAmmo = 0;
		recoilTime = 15;
	}
}

class Revolver extends Weapon
{
	public var StabreloadTime = 32;
	public var readyToStab = true;
	public var ejected = 0;
	
	public function Revolver()
	{
		super();
		weaponName = "Revolver";
		sprite_index = global[weaponName+"S"];
		// 
		xoffset = -3;
		yoffset = -6;
		refireTime = 18;
		maxAmmo = 6;
		reloadTime = 45;
		reloadBuffer = refireTime;
	}
}
