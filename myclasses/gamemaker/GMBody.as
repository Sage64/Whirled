
// GM Body
// by sage [ https://github.com/Sage64/Whirled ]
// feel free to use anything here

/*
	This is the base class I use for my whirled bodies and update as I go
	It's designed primarily to work with sprites like a GameMaker project
	
	It may be useful to you if you wish to make an avatar primarily through code
	
	Currently very WIP
	
	kinda just sharing it on a whim without properly
	planning for it, but it's usable if you can interpret it or I am currently
	talking to you and just linked it
	
	Basic usage relies on extending your own body class from it
	
	see GM_ExampleBody.as
*/

package gamemaker
{
//
import flash.display.*
//
import flash.events.*;
// 
import flash.filters.*;
// 
import flash.geom.*;
//
import flash.text.*; 
//
import flash.utils.Dictionary;
import flash.utils.getTimer;

import com.threerings.util.*
import com.whirled.*;

// 
public class GMBody extends Sprite
{
	public static const CONFIG_CUSTOM_NAMETAG =  ( 1 << 0 );
	public static const CONFIG_DYNAMIC_MOVESPEED = ( 1 << 1 );
	
	public var timescale_fps = 30; 	// base framerate for timing behaviour
	public var use_delta = true; 	// compensate for lag by increasing the timescale
	
	// Whirled - Init
	
	public var media;
	public var container;
	public var ctrl;
	
	public var _eventlisteners = {
		list: [],
		func: {}
	 };
	 
	public var _eventqueue :Array = [];
	public var _lastsprite = null;
	
	public var configFlags = GMBody.CONFIG_CUSTOM_NAMETAG | GMBody.CONFIG_DYNAMIC_MOVESPEED;
	
	public var isLoaded = false;
	public var isMoving = false;
	public var wasMoving = false;
	public var isSleeping = false;
	public var wasSleeping = false;
	
	public var stepStartTime;
	public var timescale = 1;
	public var timescale_delta = 1;
	public var lastms = 0;
	public var stepEndTime;
	
	// the "view" of the canvas is offset by this amount
	// giving the canvas more room
	public var viewXOffset = 0;
	public var viewYOffset = 0;
	// seems this offset trick has a limit in one direction but not the other
	// or atleast considerably larger in one direction
	// so, we will offset it by this much to get around that

	// the base hotspot position and nameplate height above this objects x/y
	// you shouldn't need to change it
	// handle the "feet" position by correctly aligning the symbols or using this.x and this.y
	public var originX = 0;
	public var originY = 0;
	public var characterH = 32;
	
	public var hDir = 0;
	public var vDir = 0;
	
	public var roomHMove = 0; // pixels the avatar has moved this frame, relative to its scale
	public var roomVMove = 0;
	
	public var moveSpeed = -1;
	public var moveSpeedReal = -1;
	public var orientation = 0;
	
	public var movePathStart = null;
	public var movePathDest = null;
	public var movePathStartReal = null;
	public var movePathDestReal = null;
	
	public var currentPosition = null;
	public var currentPositionReal = null;
	public var lastPosition = null;
	public var movePathDirection = 0;
	public var movePathLength = null;
	public var movePathAmount = 0;
	public var movePathClicks = 0; // amount of times moved without stopping
	
	// Whirled - States
	public var curState = null;
	public var prevState = null;
	
	public var action = null;
	public var curAction = null;
	
	public var states = {}; // Maps.newMapOf( String );
	public var stateList :Array = [];
	public var stateName = ""; // current state name
	public var stateListCurrent :Array = [];
	
	public var actions = {}; //Maps.newMapOf( String );
	public var actionList :Array = [];
	public var action_name = ""; // current action name
	
	// internal sprite manager
	

	// Custom nametag
	public var nametag = null;
	public var _usenametag;
	
	// Avatar common
	public var scale = 1;
	
	// Gamemaker
	
	// Sprite
	public var sprite_index = null;
	public var sprite_current = null; // the symbol that will be used as the primary sprite
	public var image_number = 1;
	public var image_index = 0;
	public var image_speed = 0;
	public var image_xscale = 1;
	public var image_yscale = 1;
	public var image_angle = 0;
	public var image_blend = 0xFFFFFF;
	public var image_alpha = 1;
	
	// Object
	public var depth = 0;
	public var direction = 0; 	// 0 = right, 90 = up, 180 = left, 270 = down
	public var speed = 0; 		// 0 if not moving, moveSpeed if moving, etc
	public var hspeed = 0;		// horizontal speed ( left/right of the backdrop )
	public var vspeed = 0;		// vertical speed ( on the whirled Z axis, or back/front of the backdrop )	
	
	// Color constants
	static var c_black = 0x000000;
	static var c_white = 0xFFFFFF;
	
	// Base constructor - var body = new GMBody();
	public function GMBody( base_fps = 30 )
	{
		name = "GMBody";
		this.ctrl = GMControl.ctrl;
		this.media = GMControl.media; 
		this.container = GMControl.container;
		
		GMControl.Log( "Creating" );
		
		this.stepStartTime = getTimer();
		this.stepEndTime = this.stepStartTime;
		
		this.timescale_fps = base_fps;
		
		SetOrigin( GMControl.stageW / 2, GMControl.stageH / 2 );
		SetMoveSpeed( 3 );
		SetViewOffset( 0, 0 );
		
		AddState( "DevMode", true );
		AddAction("GMSentChat", GMSentChat, true );
		
		AddAction( "[Avatar Control Panel]", Action_OpenControlPanel );
		
		// ctrl.registerCustomConfig( GMControl.OpenConfig );
	}
	
	// Clean up
	public function GMCleanup()
	{
		GMControl.Log( "Cleaning up" );
		// Remove the event listeners this body created
		for ( var i = 0, len = _eventlisteners.length; i < len; ++i )
		{
			var _listener = _eventlisteners.pop();
			var _inst = _listener[0];
			var _event = _listener[1];
			var _func = _listener[2];
			_inst.removeEventListener( _event, _func );
		}
		media.removeChild( this );
		Cleanup();
	}
	
	public function Cleanup()
	{
		// override
	}
	
	/*
		INIT PROCESS
	*/
	
	// Add an event listener
	public function AddEventListener( inst, event, func )
	{
		GMControl.Log( "Listening for " + event );
		// the function to be called by this event
		_eventlisteners.func[event] = func;
		// the func used in the event listener callback
		func = GMControlEvent;
		_eventlisteners.list.push( [ inst, event, func ] );
		 inst.addEventListener( event, func );
	}
	
	private function GMControlEvent( event )
	{
		GMControl.Log( "Event: " + event.type + ": \"" + event.name + "\", " + event.value );
		_eventqueue.push( event );
	}
	private function GMProcessEvents()
	{
		for ( var i = 0; i < _eventqueue.length; ++i )
		{
			var event = _eventqueue.shift();
			var func = _eventlisteners.func[event.type];
			if ( !func )
				continue;
			func( event );
		}
	}
	
	// Unsorted Events
	public function OnSpeak() {}
	public function OnChat( speaker_id, message ) {}
	public function GMSentChat( message )
	{
		OnSentChat( message );
	}
	public function OnSentChat( message ) {}
	
	// Initialize the body after defining it
	// Registers states and makes sure it looks correct immediately
	public function Ready()
	{
		GMControl.debugTracker = "GMBody.Ready()";
		GMControl.Log( "Ready()" );
		
		timescale = timescale_fps / 30;
		
		this.x = originX;
		this.y = originY;
		
		RegisterStates();
		RegisterActions();
		prevState = null;
		GMStateChanged( {name: GetStateName()} );
		GMUpdateLook( null );
		
		// GMStep();
		// Loop();
		
		GMControl.Log( "Ready!" );
		
		ctrl.dispatchEvent( new ControlEvent( "GMBodyReady", name ) );
	}
	
	/*
		DEBUG FUNCTIONS
	*/
	
	
	
	
	
	public function GetName()
	{
		if ( GMControl.entityID == null )
			GMControl.entityID == ctrl.getMyEntityId();
		if ( GMControl.entityID != null )
		{
			var _get = ctrl.getEntityProperty( EntityControl.PROP_NAME, GMControl.entityID )
			if ( _get != null )
			{
				name = String( _get );
				return name;
			}
		}
		return name + ".GetName()Failed";
	}
	
	public function SetNameTag( text = null )
	{
		if ( text == -1 )
		{
			if ( nametag )
				nametag.Cleanup();
			nametag = null;
			return;
		}
		if ( !nametag )
		{
			nametag = new GMNameTag( ctrl, container );
		}
		if ( text == null )
			text = GetName();
		nametag.SetText( text );
		return nametag;
	}
	
	/*
		
		INPUT
		
	*/
	
	public function GMKeyUp( event )
	{
		trace( event );
	}
	
	public function GMKeyDown( event )
	{
		trace( event );
	}
	
	/*
		APPEARANCE
	*/
	
	// Triggered upon first appearing, moving, sleeping, walking, changing states, etc
	// assume it can happen anytime, and not just
	// reset an animation from it
	public function GMUpdateLook( event = null )
	{
		GMControl.Log( "GMUpdateLook" );
		wasMoving = isMoving;
		isMoving = ctrl.isMoving();
		wasSleeping = isSleeping;
		isSleeping = ctrl.isSleeping();
		orientation = ctrl.getOrientation();
		
		if ( false ) // debug test
		{
			isMoving = true;
		}
		
		direction = 90 - orientation;
		
		hDir = gml.dcos( direction );
		vDir = gml.dsin( direction );
		
		currentPosition = GetPosition();
		currentPositionReal = GetPositionReal();
		
		if ( isMoving )
		{
			speed = moveSpeed;
			hspeed = hDir * speed;
			vspeed = vDir * speed;
			// var transformMatrix = media.transform.concatenatedMatrix;
			// var transformScaleX = 1; // / transformMatrix.a;
			// var transformScaleY = 1; // / transformMatrix.d;
			roomHMove = 0;
			roomVMove = 0;
			if ( false )
			{
				if ( currentPositionReal != null && lastPosition != null )
				{
					roomHMove = ( lastPosition[0] - currentPositionReal[0] ) * scale;
					roomVMove = ( currentPositionReal[2] - lastPosition[2] ) * scale;
					if ( movePathDestReal != null )
					{
						movePathAmount = ( gml.point_distance( currentPositionReal[0], currentPositionReal[2], movePathDestReal[0], movePathDestReal[2] ) / movePathLength );
					}
				}
			}
			if ( !wasMoving )
				OnMoveStart();
		}
		else
		{
			hspeed = 0;
			vspeed = 0;
			speed = 0;
			roomHMove = 0;
			roomVMove = 0;
		}
		
		if ( isSleeping && !wasSleeping )
		{
			OnSleep();
		}
		else if ( !isSleeping && wasSleeping )
		{
			OnWake();
		}
		
		GetName();
		
		if ( nametag )
		{
			nametag.SetText( name );
			nametag.Apply();
		}
		
		OnUpdateLook();
		
		if ( nametag )
			nametag.UpdateLook();
	}
	
	public function OnUpdateLook()
	{
		
	}
	
	public function OnSleep()
	{
		
	}
	
	public function OnWake()
	{
		
	}
	
	public function Look( dir )
	{
		dir -= 90;
		ctrl.setOrientation( dir );
	}
	
	public function SetScale ( amount )
	{
		scale = amount;
		return GMControl.SetScale( amount );
	}
	
	/*
		POSITION
	*/
	
	public function MoveTo( _x, _y, _z )
	{
		
	}
	
	// SetMoveSpeed
	// 
	public function SetMoveSpeed( _speed )
	{
		var changed = ( moveSpeed != _speed );
		
		moveSpeed = _speed;
		moveSpeedReal = Math.max( 50, moveSpeed * timescale_fps * scale );
		ctrl.setMoveSpeed( moveSpeedReal );
		
		//GMControl.Log( "moveSpeed = " + moveSpeed );
		
		// disabling this behaviour for a multitude of reasons
		// including rate limiting, lag, and errors
		if ( false )
		{
			if ( changed && ( configFlags & GMBody.CONFIG_DYNAMIC_MOVESPEED ) &&  isMoving && ( movePathDest != null ) )
			{
				// start moving again to the same point to update the walk speed
				// warning! if you spam this, whirled lags and delays your movement
				// incredibly hard for a while
				var pos = movePathDest;
				if ( pos == null || pos.length < 3 )
					return;
				ctrl.setLogicalLocation( pos[0], pos[1], pos[2], orientation );
			}
		}
		
	}
	
	public function GMEntityMoved( event )
	{
		GMControl.debugTracker = "GMEntityMoved";
		if ( event == null )
			return;
		if ( event.name == GMControl.entityID )
		{
			GMControl.debugTracker = "GMEntityMoved - self";
			// I started to move
			++movePathClicks;
			currentPosition = GetPosition();
			currentPositionReal = GetPositionReal();
			
			movePathStart = currentPosition;
			movePathStartReal = movePathStart;
			
			if ( currentPosition != null )
			{
				movePathStartReal = ctrl.getRoomBounds();
				if ( movePathStartReal != null )
				{
					movePathStartReal[0] *= currentPosition[0];
					movePathStartReal[1] *= currentPosition[1];
					movePathStartReal[2] *= currentPosition[2];
				}
			}
			
			movePathDest = null;
			movePathDestReal = null;
			
			if ( event.value == null  )
			{
				// I arrived at my destination
				OnMoveStop();
				movePathClicks = 0;
			}
			else
			{
				// I started moving.
				// Applies each time you spam click while moving too
				// so the OnMoveStart event is fired in its own check
				// as an appearance update rather than here
				movePathDest = event.value;
				movePathDestReal = ctrl.getRoomBounds();
				if ( movePathDestReal != null )
				{
					movePathDestReal[0] *= movePathDest[0];
					movePathDestReal[1] *= movePathDest[1];
					movePathDestReal[2] *= movePathDest[2];
				}
				var x1 = movePathStartReal[0];
				var y1 = movePathStartReal[2];
				var x2 = movePathDestReal[0];
				var y2 = movePathDestReal[2];
				GMMoved( x1, y1, x2, y2 );
			}
			
			GMControl.Log( "startPos = " + movePathStartReal );
			GMControl.Log( "destPos = " + movePathDestReal );
		}
		else
		{
			GMControl.debugTracker = "GMEntityMoved - Other";
			// Someone else moved
			if ( event.value == null )
			{
				// they stopped moving
				OnOtherMoveStop( event.name );
			}
			else
			{
				// they started moving
				OnOtherMoveStart( event.name, event.value );
			}
		}
		GMControl.debugTracker = "GMEntityMoved - After";
	}
	
	public function OnOtherStartMove( _id ) {}
	public function OnOtherStopMove( _id ) {}
	
	public function GMMoved( x1, y1, x2, y2 )
	{
		movePathAmount = 0;
		movePathLength = 0;
		movePathDirection = gml.point_direction( x1, y2, x2, y1 );
		movePathLength = gml.point_distance( x1, y1, x2, y2 );
	}
	
	public function OnMoveStart() {}
	public function OnMoveStop() {}
	
	public function OnOtherMoveStart( _id, _dest ) {}
	public function OnOtherMoveStop( _id ) {}
	
	
	
	public function GetPosition()
	{
		currentPosition = ctrl.getEntityProperty( EntityControl.PROP_LOCATION_LOGICAL, GMControl.entityID );
		return currentPosition;
	}
	
	public function GetPositionReal()
	{
		currentPositionReal = ctrl.getEntityProperty( EntityControl.PROP_LOCATION_PIXEL, GMControl.entityID );
		return currentPositionReal;
	}
	
	/*
		STATES
	*/
	
	// basic state adding function
	public function AddState( statename, hidden = false )
	{
		GMControl.Log( "Adding state \"" + statename + "\"" );
		var State = {}
		State.name = statename;
		State.substates = null;
		State.subactions = null;
		State.func = null;
		
		// Define these as an array to choose what is either selectively
		// hidden or shown for this state
		State.showStates = null;
		State.hideStates = null;
		State.showActions = null;
		State.hideActions = null;
		State.hidden = hidden;
		
		
		//
		if ( curState == null )
		{
			curState = State;
			stateName = statename;
		}
		// 
		states[ statename.toLowerCase() ] = State;
		if ( !hidden )
			stateList.push( State );
		return State;
	}
	
	// force a state swap on the avatar
	// also "updates it" now
	// expect an appearance update after the server
	// also processes it
	public function SetState( statename )
	{
		var State = GetState( statename );
		if ( !State )
		{
			GMControl.Log( "SetState invalid" );
			return;
		}
		ctrl.setState( State.name );
		var event = new ControlEvent( ControlEvent.STATE_CHANGED, State.name );
		GMStateChanged( event );
	}
	
	public function GetState( statename = null )
	{
		if ( typeof statename == "object" )
			statename = statename.name;
		var _getstate = states[ statename.toLowerCase() ];
		
		if ( _getstate == null )
		{
			if ( stateList.length < 1 )
				return null;
			return stateList[0] ;
		}
		return _getstate;
	}
	
	public function GetStateName()
	{
		var _get = ctrl.getState();
		var _getstate = GetState( _get );
		// trace( "getstate: " + _getstate );
		if ( _getstate != null )
			return _getstate.name;
		return _get;
	}
	
	public function RegisterStates()
	{
		GMControl.Log( "Registering states" );
		var names = [];
		
		var _showStates = this.stateList;
		if ( curState && curState.showStates )
			_showStates = curState.showStates;
		
		for ( var i = 0; i < _showStates.length; ++i )
		{
			var State = _showStates[i];
			if ( State == null )
				continue;
			var _state = State;
			if ( typeof _state == "object" )
				_state = _state.name;
			if ( curState && curState.hideStates && ( curState.hideStates.indexOf( _state ) >= 0 ) )
				continue;
			GMControl.Log( i + ": " + _state );
			names.push( _state );
		}
		ctrl.registerStates( names );
	}
	
	public function GMStateChanged( event )
	{
		GMControl.debugTracker = "GMStateChanged (did you forget to account for curState being null?)";
		stateName = event.name;
		GMControl.Log( "State Changed to " + stateName );
		prevState = curState;
		curState = GetState( stateName );
		if ( curState != null )
		{
			if ( curState.func )
				curState.func();
		}
		OnStateChanged();
		OnUpdateLook();
	}
	
	public function OnStateChanged()
	{
		// override
	}
	
	public function ApplyState()
	{
		stateName = GetStateName();
		curState = GetState( stateName );
		stateName = curState.name;
		
	}
	
	/*
		ACTIONS
	*/
	
	public function AddAction ( actionname :String = "action", method = null, hidden = false )
	{
		GMControl.Log( "Adding action \"" + actionname + "\"" );
		var Action = {};
		Action.name = actionname;
		if ( method )
			Action.action = method;
		actions[ actionname.toLowerCase()] = Action;
		if ( !hidden )
			actionList.push( Action );
		return Action;
	}
	
	public function GetAction( actionname )
	{
		return actions.get( actionname.toLowerCase() );
	}
	
	public function RegisterActions()
	{
		GMControl.Log( "Registering actions" );
		var names = [];
		
		var _showActions = this.actionList;
		if ( curState && curState.showActions )
			_showActions = curState.showActions;
		
		for ( var i = 0; i < _showActions.length; ++i )
		{
			var Action = _showActions[i];
			var _action = Action;
			if ( typeof _action == "object" )
				_action = _action.name;
			GMControl.Log( i + ": " + _action );
			names.push( _action );
		}
		ctrl.registerActions( names );
	}
	
	public function TriggerAction( _action = "", _data = null )
	{
		ctrl.triggerAction( _action, _data );
	}
	
	public function OnTriggerAction( actionname = null, actiondata = null )
	{
		if ( actionname == null )
		return;
		var Action = actions[ actionname.toLowerCase() ];
		if ( Action )
		{
			if ( Action.action )
				Action.action( actiondata );
		}
	}
	
	// Sample actions
	
	public function Action_GotoRoomMiddle( data = null )
	{
		ctrl.setLogicalLocation( 0.5, 0.15, -( 1 / 512 ), 0 );
	}
	
	public function Action_InvertPos( data = null )
	{
		var pos = ctrl.getLogicalLocation();
		var dir = ctrl.getOrientation();
		
		if ( pos[2] > 0 )
			pos[2] = -( 1 + pos[2] );
		else
			pos[2] = 1 - pos[2];
		
		ctrl.setLogicalLocation( pos[0], pos[1], pos[2], dir );
	}
	
	public function Action_OpenControlPanel( data = null )
	{
		return GMControl.OpenControlPanel();
	}
	
	// 
	
	/*
		MAIN LOOP
	*/
	
	// Call body.Loop() on frame 3 of the timeline
	// Not neccessary if GMControl is doing it already
	public function Loop()
	{
		GMStep();
		media.gotoAndPlay( 2 );
		// GMEndStep();
	}
	
	public function GMStep()
	{
		if ( root && !isLoaded )
		{
			if ( root.loaderInfo.bytesLoaded < root.loaderInfo.bytesTotal )
			{}
			else
			{
				isLoaded = true;
				GMControl.Log( "Loaded " + root.loaderInfo.bytesTotal + "b" );
			}
		}
		
		// Timer
		stepStartTime = getTimer();
		if ( use_delta )
			timescale_delta = Math.min( 30.0, ( ( stepStartTime - lastms ) / 1000 ) * timescale_fps );
		lastms = stepStartTime;
		
		GMProcessEvents();
		
		// hide previous sprite incase we're not using it this frame
		if ( _lastsprite != null )
		{
			_lastsprite.symbol.visible = false;
			_lastsprite = null;
		}
		
		if ( false ) // only works in birdseye. rip.
		{
			currentPositionReal = GetPositionReal();
			if ( currentPositionReal != null && lastPosition != null )
			{
				roomHMove = ( lastPosition[0] - currentPositionReal[0] ) / scale;
				roomVMove = ( currentPositionReal[2] - lastPosition[2] ) / scale;
				if ( ( movePathDestReal != null ) && ( movePathLength > 0 ) )
				{
					movePathAmount = ( point_distance( currentPositionReal[0], currentPositionReal[2], movePathDestReal[0], movePathDestReal[2] ) / movePathLength );
				}
			}
		}
		else
		{
			roomHMove = -hspeed;
			roomVMove = -vspeed / 5;
		}
		
		// Step self
		
		Step();
		
		// Animate self based on image_speed
		
		if ( image_speed != 0 && sprite_current )
		{
			image_index += ( image_speed * timescale_delta );
			if ( image_index >= image_number )
			{
				GMAnimationEnd();
				while ( image_index > image_number )
				{
					image_index -= image_number;
				}
			}
			while ( image_index < 0 )
				image_index += image_number;
		}
		
		lastPosition = currentPositionReal;
		
		var xx = originX;
		var yy = originY;
		var hh = ( 1 << 31 );
		
		_usenametag = ( ( configFlags & GMBody.CONFIG_CUSTOM_NAMETAG ) && ( nametag ) )
		if ( !_usenametag )
			hh = ( ( originY - y ) * scale ) + ( characterH * scale );
		
		ctrl.setHotSpot( xx, yy, hh );
		
		GMUpdateView( xx, yy, hh );
		
		_lastsprite = sprite_current;
		stepEndTime = getTimer();
		// duration = stepEndTime - stepStartTime;
	}
	public function Step()
	{
		// override
	}
	
	/*
		DRAW
	*/
	
	public function GMDraw()
	{
		if ( nametag )
		{
			nametag.x = x;
			nametag.y = ( _usenametag ) ? ( y - characterH ) : ( 1 << 31 );
			nametag.UpdatePosition();
		}
		
		Draw();
	}
	
	public function Draw()
	{
		draw_self();
	}
	
	/*
		VIEW
	*/
	
	// Set the origin point on the stage
	public function SetOrigin( xx = null, yy = null, hh = null )
	{
		if ( xx != null )
			this.originX = xx;
		if ( yy != null )
			this.originY = yy;
		if ( hh != null )
			this.characterH = hh;
	}

	private function GMUpdateView( xx, yy, hh )
	{
		return GMControl.GMUpdateView( xx, yy, hh );
	}
	
	public function SetViewOffset( xx = null, yy = null )
	{
		return GMControl.SetViewOffset( xx, yy );
	}
	
	// 

	
	public function OnSpriteChanged()
	{
		// override
	}
	
	private function GMAnimationEnd()
	{
		OnAnimationEnd();
	}
	
	public function OnAnimationEnd()
	{
		// override
	}
	
	// Interaction
	
	public function BroadcastMessage( message = "", data = null )
	{
		ctrl.sendMessage( message, data );
	}
	
	public function OnReceiveSignal( message )
	{
		
	}
	
	public function OnReceiveMessage( message )
	{
		
	}
	
	/*
		GAMEMAKER-BASED INSTANCE FUNCTIONS
	*/
	
	/*
		Instances
	*/
	
	public function instance_create( _x, _y, _obj )
	{
		return GMControl.InternalInstanceCreate( _x, _y, _obj );
	}
	
	public function instance_destroy( _inst = null )
	{
		if ( _inst == null )
			_inst = this;
		return GMControl.InternalInstanceDestroy( _inst );
	}
	
	
	/*
		Sprites
	*/
	
	// Use a sprite, e.g not the current sprite_current temporarily
	public static function draw_sprite( _sprite, _image = null, _x = null, _y = null )
	{
		return GMControl.InternalSpriteDraw( _sprite, _image, _x, _y, 1, 1, 0, 0xFFFFFF, 1 );
	}
	
	public static function draw_sprite_ext( _sprite, _image = null,
	_x = null, _y = null, _xscale = 1, _yscale = 1,
	_rot = 0, _col = 0xFFFFFF, _alpha = 1 )
	{
		return GMControl.InternalSpriteDraw( _sprite, _image, _x, _y, _xscale, _yscale, _rot, _col, _alpha  );
	}
	
	public function draw_self()
	{
		return GMControl.InternalSpriteDraw( sprite_current, image_index, x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha  );
	}
	
	public function sprite_set( sprite_ref )
	{
		if ( sprite_ref == -1 )
			sprite_ref = null;
		if ( sprite_ref == sprite_current )
		{
			trace( "no change" );
			return;
		}
		
		if ( sprite_current )
		{
			sprite_current.symbol.visible = false;
			sprite_current = null;
		}
		
		if ( sprite_ref )
		{
			trace( "sprite = " + sprite_ref.name );
			sprite_current = sprite_ref;
			image_number = sprite_current.count;
		}
	}
	
	public static function sprite_get( sprite_name )
	{
		return GMControl.InternalSpriteGet( sprite_name );
	}
	
	// Path
	
	
	
} // class


} // Package



