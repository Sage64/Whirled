
// GM Body
// by sage [ https://github.com/Sage64/Whirled ]
// feel free to use anything here

/*
	This is the base class I use for my whirled bodies and update as I go
	It's designed primarily to work with sprites like a GameMaker project
	
	It may be useful to you if you wish to make an avatar primarily through code
	
	Currently very WIP, a lot of stuff is very messy as this started as just this body
	but im slowly moving everything over to the be handled by GMControl instead 
	
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
public class GMBody extends GMObject
{
	public static const FLAG_HIDENAME = 1 << 0;
	
	public var gm_flags = 0;
	
	public var timescale_fps = 30; 	// base framerate for timing behaviour
	public var use_delta = true; 	// compensate for lag by increasing the timescale
	
	// Whirled - Init
	
	public var gm = GM;
	public var media = GMControl.ctrl;
	public var container = GMControl.container;
	public var ctrl = GMControl.ctrl;
	//public var body = this;
	
	public var _eventlisteners = {
		list: [],
		func: {}
	 };
	 
	public var _eventqueue :Array = [];
	
	public var secure = false; // if true, don't share body ref through properties
	public var customProps = {};
	
	public var isMoving = false;
	public var wasMoving = false;
	public var isSleeping = false;
	public var wasSleeping = false;
	
	public var stepStartTime;
	public var lastms = 0;
	public var stepEndTime;

	// the base hotspot position
	// you shouldn't need to change it
	// handle the "feet" position by correctly aligning the symbols or using this object's X and Y
	public var originX = 0;
	public var originY = 0;
	
	// nameplate height above this objects x/y
	public var characterH = 32;
	
	public var hDir = 0;
	public var vDir = 0;
	
	public var flipped = false;
	
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
	public var curAction = null;
	
	public var states = {}; // Maps.newMapOf( String );
	public var stateList :Array = [];
	public var stateName = ""; // current state name
	public var stateListCurrent :Array = [];
	public var state; // current state being created by AddState
	
	public var actions = {}; //Maps.newMapOf( String );
	public var actionList :Array = [];
	public var actionName = ""; // current action name
	public var action; // the current action that caused the event
	
	public var memories = {};
	public var memoryList = [];
	public var memory; // the current memory that caused the event
	
	// structs for simple state references, e.g mystates["attacking"] = AddState( "Swinging Sword" );
	public var mystates = {};
	public var myactions = {};
	public var mymemories = {};
	
	
	
	// internal sprite manager
	

	// Custom nametag
	public var nametag = null;
	public var _usenametag;
	
	// Avatar common
	public var scale = 1;
	
	// Gamemaker - OLD. Body now extends GMObject
	/*
	*/
	
	public function GMBody( base_fps = 30 )
	{
		super();
		
		image_speed = 0;
		
		name = "GMBody";
		gm = GM;
		media = GMControl.media;
		container = GMControl.container;
		ctrl = GMControl.ctrl;
		this.body = this;
		
		GMControl.Log( "Creating" );
		
		this.stepStartTime = getTimer();
		this.stepEndTime = this.stepStartTime;
		
		this.timescale_fps = base_fps;
		
		SetOrigin( 0, 0 );
		
		SetMoveSpeed( 3 );
		SetViewOffset( 0, 0 );
		
		AddMemory( "gm", 1 ); // is a "GM" avatar
		AddMemory( "gm.flags", 0, GMFlagsChanged );
		AddMemory( "gm.character", null, null );
		AddMemory( "gm.version", 0 );
		AddMemory( "gm.purchase_version", -1 );
		
		// mystates["gm_devmode"] = AddState( "DevMode", true );
		// mystates["gm_devmode"].hidden = true;
		
		myactions["gm_devpanel"] = AddAction( "[GM Control Panel]", Action_OpenControlPanel );
		
		myactions["gm_chatsent"] = AddAction("GMSentChat", GMSentChat, "GMChatSent with null message" );
		myactions["gm_chatsent"].hidden = true;
		
		// myactions["gm_resetmemories"] = AddAction( "[RESET] (2x to confirm)" );
		
		myactions["gm_togglename"] = AddAction( "[Toggle Name]", Action_ToggleName );
		
		if ( true )
		{
			ctrl.registerCustomConfig( GMControl.OpenConfig );
			myactions["gm_devpanel"].hidden = true;
		}
		
		// Action_OpenControlPanel();
	}
	
	// Clean up
	public function GMCleanup()
	{
		GMControl.Log( "Cleaning up" );
		Cleanup();
	}
	
	override public function Cleanup()
	{
		super.Cleanup();
		// override if needed
	}
	
	// Called after the body is created, initialized and ready.
	// Could be used to, for example, reset Memory values when
	// the character is first loaded/switched to
	override public function Create()
	{
		super.Create();
		
	}
	
	/*
		INIT PROCESS
	*/
	
	public function GMControlEvent( event )
	{
		GMControl.Log( "Event: " + event.type + ": \"" + event.name + "\", " + event.value );
		_eventqueue.push( event );
	}
	
	private function GMProcessEvents()
	{
		GM.debugTracker = "GMBody.GMProcessEvents";
		for ( var i = 0; i < _eventqueue.length; ++i )
		{
			var event = _eventqueue.shift();
			if ( !event )
				continue;
			GM.debugTracker = "GMBody.GMProcessEvents ( event )";
			var func = _eventlisteners.func[event.type];
			if ( !func )
				continue;
			try
			{
				func( event );
			}
			catch(e)
			{
				GMControl.Caught(e);
			}
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
		
		// get memories
		
		GMControl.Log( "Ready!" );
		
		ctrl.dispatchEvent( new ControlEvent( "GMBodyReady", name ) );
		
		if ( GMControl.debug )
		{
			DoBodyDebug();
		}
	}
	
	public function SetVersion( version = 0 )
	{
		var _current = GetMemory( "gm.version" );
		var _bought = GetMemory( "gm.purchase_version" );
		
		if ( _bought == -1 )
		{
			SetMemory( "gm.purchase_version", version );
			_bought = version;
		}
		
		if ( version > _current )
		{
			GMControl.Log( "new version!" );
		}
		if ( version > _bought )
		{
			GMControl.Log( "you own version " + _bought );
		}
		
		GMControl.Log( "purchase_version: " + _bought );
		GMControl.Log( "current: " + _current );
		GMControl.Log( "release: " + version );
		SetMemory( "gm.version", version );
	}
	
	/*
		DEBUG FUNCTIONS
	*/
	
	
	public function DoBodyDebug()
	{
		
	}
	
	
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
			nametag = new GMNameTag( ctrl, media );
		}
		if ( text == null )
			text = GetName();
		nametag.SetText( text );
		return nametag;
	}
	
	// return custom data from getEntityProperty 
	public function OnProperty( key = null )
	{
		return customProps[key];
	}
	
	/*
		FLAGS
	*/
	
	public function GMFlagsChanged( data )
	{
		GM.Log( "gm.flags = " + data );
		gm_flags = data;
		if ( nametag )
		{
			if ( gm_flags & FLAG_HIDENAME )
				nametag.Hide();
			else
				nametag.Show();
		}
		OnFlagsChanged( data );
	}
	public static function OnFlagsChanged( flags ) {}
	
	public function SetFlag( flag = 0, on = true )
	{
		if ( !GMControl.isControl )
			return;
		var flags = GetMemory( "gm.flags" );
		if ( on )
			flags |= ( flag );
		else
			flags &= ~flag;
		SetMemory( "gm.flags", flags );
	}
	
	
	public function Action_ToggleName( ... ignored )
	{
		if ( !GMControl.isControl )
			return;
		var on = ( gm_flags & FLAG_HIDENAME );
		SetFlag( FLAG_HIDENAME, !on );
	}
	
	/*
		APPEARANCE
	*/
	
	// Triggered upon first appearing, moving, sleeping, walking, changing states, etc
	// assume it can happen whenever, and don't just change animations immediately
	// anytime its called
	public function GMUpdateLook( event = null )
	{
		wasMoving = isMoving;
		isMoving = ctrl.isMoving();
		wasSleeping = isSleeping;
		isSleeping = ctrl.isSleeping();
		orientation = ctrl.getOrientation();
		
		direction = orientation - 90;
		
		if ( GMControl.debug )
		{
			direction = point_direction( 0, 0, container.mouseX / container.scaleX, container.mouseY / container.scaleY );
			// trace( direction );
			GMControl.debugMove = !GMControl.debugMove;
			isMoving = GMControl.debugMove;
		}
		if ( direction < 0 )
			direction += 360;
		hDir = 0;
		vDir = 0;
		switch( direction )
		{
			case 0:
				hDir = 1;
				break;
			case 90:
				vDir = -1;
				break;
			case 180:
				hDir = -1;
				break;
			case 270:
				vDir = 1;
				break;
			default:
				hDir = dcos( direction );
				vDir = -dsin( direction );
		}
		//GMControl.Log( "direction = " + direction + ", hDir: " + hDir + ", vDir: " + vDir );
		
		currentPosition = GetPosition();
		currentPositionReal = GetPositionReal();
		
		if ( isMoving )
		{
			speed = moveSpeed;
			hspeed = hDir * speed;
			vspeed = vDir * speed;
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
						movePathAmount = ( point_distance( currentPositionReal[0], currentPositionReal[2], movePathDestReal[0], movePathDestReal[2] ) / movePathLength );
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
		
		if ( nametag )
		{
			if ( nametag.surf )
				nametag.surf.graphics.clear();
		}
		
		OnUpdateLook();
		
		if ( nametag )
		{
			nametag.UpdateLook();
		}
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
	
	public function MoveTo( _x, _y, _z, _dir = 0 )
	{
		if ( ctrl )
		{
			ctrl.setPixelLocation( _x, _y, _z, 90-_dir );
		}
	}
	public function MoveTo_Speed( _spd, _x, _y, _z, _dir = 0 )
	{
		if ( ctrl )
		{
			ctrl.setMoveSpeed( _spd );
			MoveTo( _x, _y, _z, _dir );
			ctrl.setMoveSpeed( moveSpeedReal );
		}
	}
	
	// SetMoveSpeed
	// 
	public function SetMoveSpeed( _speed )
	{
		var changed = ( moveSpeed != _speed );
		
		moveSpeed = _speed;
		moveSpeedReal = Math.max( 50, moveSpeed * timescale_fps * scale );
		ctrl.setMoveSpeed( moveSpeedReal );
		//if ( changed )
		//	GMControl.Log( "moveSpeedReal = " + moveSpeedReal );
	}
	
	public function GMEntityMoved( event )
	{
		GMControl.debugTracker = "GMEntityMoved";
		if ( event == null )
			return;
		var Entity = GMControl.GetEntity( event.name );
		if ( event.name == GMControl.entityID )
		{
			GMControl.debugTracker = "GMEntityMoved - self";
			// I started to move
			++movePathClicks;
			currentPosition = GetPosition();
			currentPositionReal = GetPositionReal();
			
			movePathStart = currentPosition;
			movePathStartReal = movePathStart;
			
			if ( movePathStart == null )
			{
				GMControl.Warn( "no start pos! - potentially caused by starting a move immediately before changing rooms" );
				return;
			}
			
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
				if ( movePathDestReal != null && movePathDest != null )
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
			
			// GMControl.Log( "startPos = " + movePathStartReal );
			// GMControl.Log( "destPos = " + movePathDestReal );
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
		movePathDirection = point_direction( x1, y1, x2, y2 );
		movePathLength = point_distance( x1, y1, x2, y2 );
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
		state = states[statename];
		if ( !state )
			state = {};
		var _pos = stateList.indexOf( state );
		if ( _pos >= 0 )
			stateList.splice( _pos, 1 );
		
		state.name = statename;
		state.substates = null;
		state.subactions = null;
		state.func = null;
		
		// Define these as an array to choose what is either selectively
		// hidden or shown for this state
		state.showStates = null;
		state.hideStates = null;
		state.showActions = null;
		state.hideActions = null;
		state.hidden = hidden;
		
		state.IsHidden = function()
		{
			return hidden;
		}
		
		//
		if ( curState == null )
		{
			// curState = state;
			stateName = statename;
		}
		//
		
		stateList.push( state );
		states[ statename ] = state;
		return state;
	}
	
	// force a state swap on the avatar
	// also "updates it" now
	// expect an appearance update after the server
	// also processes it
	public function SetState( statename )
	{
		if ( statename == null )
		{
			// seems deliberate;
			ctrl.setState( null );
			GMStateChanged( new ControlEvent( ControlEvent.STATE_CHANGED, null ) );
		}
		else
		{
			var State = GetState( statename );
			if ( !State )
			{
				GMControl.Log( "SetState invalid" );
				return;
			}
			ctrl.setState( State.name );
			GMStateChanged( new ControlEvent( ControlEvent.STATE_CHANGED, State.name ) );
		}
	}
	
	public function GetState( statename = null )
	{
		GMControl.debugTracker = "GetState";
		var _getstate = statename;
		if ( statename != null )
		{
			if ( typeof statename == "object" )
				statename = statename.name;
			_getstate = states[ statename ];
		}
		if ( _getstate == null )
		{
			for ( var i = 0; i < stateList.length; ++i )
			{
				if ( stateList[i].hidden )
					continue;
				_getstate = stateList[i];
				break;
			}
		}
		return _getstate;
	}
	
	public function GetStateName()
	{
		var _get = ctrl.getState();
		var _getstate = GetState( _get );
		if ( _getstate )
			return _getstate.name;
		return _get;
	}
	
	public function RegisterStates()
	{
		// GMControl.Log( "Registering states" );
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
			if ( typeof _state != "object" )
			{
				GMControl.Log( "state should be an object" );
				continue;
				//_state = states[]
			}
			if ( _state.hidden )
				continue;
			if ( OnRegisterState( _state ) )
				continue;
			_state = _state.name;
			if ( curState && curState.hideStates && ( curState.hideStates.indexOf( _state ) >= 0 ) )
				continue;
			//GMControl.Log( i + ": " + _state );
			names.push( _state );
		}
		ctrl.registerStates( names );
	}
	
	public function OnRegisterState( state )
	{
		// override, hide this state if returns true ( or state.hidden = true; )
	}
	
	public function GMStateChanged( event )
	{
		GMControl.debugTracker = "GMStateChanged (did you forget to account for curState/prevState being null?)";
		if ( !event )
		{
			GMControl.Warn( "no event" );
			return;
		}
		stateName = event.name;
		GMControl.Log( "State set to " + stateName );
		curState = GetState( stateName );
		trace( prevState );
		if ( curState )
		{
			if ( curState.func )
				curState.func();
		}
		else
			curState = null;
		if ( prevState == curState )
		{
			GMControl.Log( "No change in state, not executing OnStateChanged" );
		}
		else
		{
			GMControl.debugTracker = "GMStateChanged - OnStateChanged";
			OnStateChanged();
			OnUpdateLook();
		}
		RegisterStates();
		RegisterActions();
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
	
	public function AddAction ( actionname :String = "action", actionfunc = null, actionvalue = null )
	{
		GMControl.Log( "Adding action \"" + actionname + "\" with data " + actionvalue );
		action = actions[actionname];
		if ( !action )
			action = {};
		
		var _pos = actionList.indexOf( action );
		if ( _pos >= 0 )
			actionList.splice( _pos, 1 );
		
		action.initname = actionname;
		action.name = actionname;
		action.value = actionvalue;
		action.hidden = 0;
		action.OnTriggered = null;
		if ( actionfunc )
			action.func = actionfunc;
		if ( actions[actionname] == null )
			actionList.push( action );
		actions[actionname] = action;
		return action;
	}
	
	public function AddAction_Options( actionname = "option", actionfunc = null, options = null, startval = null )
	{
		if ( !options )
			options = [ false, true ];
		if ( startval == null )
			startval = options[0];
		
		var Action = AddAction( actionname, actionfunc, options[0] );
		Action.option = 0;
		Action.options = options;
		
		for ( var i = 0; i < options.length; ++i )
		{
			var _name = Action.initname + " (is: " + options[i] + ")";
			actions[_name] = Action;
			trace( _name );
			if ( options[i] == startval )
				Action.name = _name;
		}
		
		Action.OnTriggered = function()
		{
			trace( "Action: " + this );
		}
		
		return Action;
	}
	
	public function AddAction_ToggleMemory( actionname = "memory_toggle", memoryname = null, options = null )
	{
		// memory must be added before this action can be
		// memory will be toggled between the options, or assumed [false, true] by default
		if ( memoryname == null )
			return;
		var startval = null;
		var memory = memories[memoryname];
		if ( memory )
			startval = memory.value;
		
		
		if ( options == null )
			options = [ false, true ];
		var Action = AddAction_Options( actionname, null, options, startval );
		
		Action.togglememory = [ memoryname, options ];
		
		return Action;
	}
	
	public function GetAction( actionname )
	{
		return actions[actionname];
	}
	
	public function RegisterActions()
	{
		// GMControl.Log( "Registering actions" );
		var names = [];
		
		var _showActions = this.actionList;
		if ( curState && curState.showActions )
			_showActions = curState.showActions;
		
		for ( var i = 0; i < _showActions.length; ++i )
		{
			var _action = _showActions[i];
			if ( typeof _action == "object" )
			{
				if ( _action.hidden )
					continue;
				if ( OnRegisterAction( _action ) )
					continue;
				_action = _action.name;
			}
			//GMControl.Log( i + ": " + _action );
			names.push( _action );
		}
		ctrl.registerActions( names );
	}
	
	public function OnRegisterAction( action )
	{
	}
	
	public function TriggerAction( _action = "", _data = null )
	{
		GM.debugTracker = "GMBody.TriggerAction";
		if ( typeof _action == "object" )
			_action = _action.name;
		if ( ctrl.isConnected() )
			ctrl.triggerAction( _action, _data );
		else
			OnTriggerAction( _action, _data );
	}
	
	public function OnTriggerAction( actionname = null, actiondata = null )
	{
		if ( actionname == null )
		return;
		action = actions[actionname];
		curAction = action;
		// var Action = actions[ actionname ];
		if ( action )
		{
			if ( action.togglememory )
			{
				var _mem = memories[ action.togglememory[0] ];
				if ( _mem )
				{
					var i = 0;
					if ( _mem.value == action.togglememory[1][0] )
					{
						SetMemory( _mem, action.togglememory[1][1] );
						i = 1;
					}
					else
						SetMemory( _mem, action.togglememory[1][0] );
					action.name = action.initname + " (is: " + action.togglememory[1][i] + ")";
					RegisterActions();
				}
				else
				{
					GM.Log( "ToggleMemory failed" );
				}
				return;
			}
			else if ( action.options )
			{
				++action.option;
				if ( action.option > action.options.length )
					action.option = 0;
				//actiondata = Action.options[Action.option];
				if ( action.func )
					action.func( action.options[action.option] );
				actions[action.actionname] = action;
				if ( action.OnTriggered )
					action.OnTriggered();
			}
			else
			{
				if ( actiondata == null )
					actiondata = action.value;
				if ( action.func )
					action.func( actiondata );
			}
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
	
	public function Action_PlaySound( data = null )
	{
		GMObject.audio_play_sound( global[data], 0, false );
	}
	
	// 
	
	/*
		MAIN LOOP
	*/
	
	override public function GMStep()
	{
		GM.debugTracker = "GMBody.GMStep";
		
		// Timer
		stepStartTime = getTimer();
		timescale_delta = Math.min( 30.0, ( ( stepStartTime - lastms ) / 1000 ) * timescale_fps );
		if ( use_delta )
			timescale = timescale_delta;
		lastms = stepStartTime;
		
		current_time = ( stepStartTime );
		GMObject.current_time = current_time;
		
		GMProcessEvents();
		
		roomHMove = -hspeed;
		roomVMove = -vspeed / 5;
		
		// Step self
		
		GM.debugTracker = "GMBody.Step";
		Step();
		
		GM.debugTracker = "GMBody.GMStep";
		// Animate self based on image_speed
		
		if ( image_speed != 0 && sprite_current )
		{
			image_index += ( image_speed * timescale_delta );
			if ( image_index >= image_number )
			{
				OnAnimationEnd();
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
		var hh = ( -( 1<<31 ) );
		
		_usenametag = ( nametag )
		if ( ( nametag == 0 ) || ( gm_flags & FLAG_HIDENAME ) )
		{
			_usenametag = 0;
		}
		else if ( !_usenametag )
			hh = ( ( originY - y ) * container.scaleY ) + ( characterH * container.scaleY );
		
		// ctrl.setHotSpot( xx, yy, hh );
		
		GMUpdateView( xx, yy, hh );
		
		stepEndTime = getTimer();
		// duration = stepEndTime - stepStartTime;
	}
	override public function Step()
	{
		// override
	}
	
	/*
		DRAW
	*/
	
	override public function GMDraw()
	{
		GM.debugTracker = "GMBody.GMDraw"
		try
		{
			Draw();
		}
		catch(e)
		{
			GMControl.Caught(e);
		}
		
		if ( nametag )
		{
			nametag.x = x * container.scaleX;
			nametag.y = ( y - characterH ) * container.scaleY;//( _usenametag ) ? ( y - characterH ) : ( 65500 );
			
			nametag.x += container.x;
			nametag.y += container.y;
			
			// nametag.y = Math.min( nametag.y, GM.view_y + GM.view_height );
			// nametag.y = Math.max( nametag.y, GM.view_y + nametag.height );
			
			nametag.UpdatePosition();
		}
		
		if ( nametag )
		{
			if ( true || _usenametag )
			{
				nametag.parent.setChildIndex( nametag, nametag.parent.numChildren - 1 )
			}
		}
		
		DrawEnd();
		
		if ( GMControl.debug )
		{
			var xx = 4 * image_xscale;
			var ww = image_xscale / 2;
			draw_set_color( c_red );
			draw_line_width( x - xx, y, x + xx, y, ww );
			draw_line_width( x, y - characterH, x, y, ww );
		}
	}
	
	override public function Draw()
	{
		draw_self();
	}
	
	override public function DrawEnd()
	{
		
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

	public function GMUpdateView( xx, yy, hh )
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
	
	override public function OnAnimationEnd()
	{
		// override
	}
	
	// Interaction
	
	
	public function AddMemory( key, defaultval = null, func = null )
	{
		GM.debugTracker = "GMBody.AddMemory"
		memory = {}
		memory.name = key;
		var memval;
		if ( ctrl )
		{
			memval = ctrl.getMemory( key, null );
		}
		else
		{
			GMControl.Warn( "AddMemory: NO CTRL!" );
		}
		
		if ( memval == null )
		{
			memval = defaultval;
			GMControl.Log( "Adding memory \"" + key + "\", value: " + memval );
		}
		else
		{
			// defaultval = memval;
			GMControl.Log( "Adding memory \"" + key + "\", value: " + memval + " (default: " + defaultval + ")" );
		}
		
		
		memory.value = memval;
		memory.func = func;
				
		memories[key] = memory;
		memoryList.push( memory );
		
		var event = {};
		event.type = ControlEvent.MEMORY_CHANGED;
		event.name = memory.name;
		event.value = memory.value;
		
		GMControl.GMControlEvent( event );
		
		GM.debugTracker = "After GMBody.AddMemory"
		return memory;
	}
	
	// Set a memory via its AddMemory name
	public function SetMemory( name, value )
	{
		if ( name is String )
		{}
		else
			name = name.name;
		memory = memories[name];
		if ( !memory )
		{
			GMControl.Log( "memory " + name + " not found" );
			return;
		}
		if ( !memory.dontlog )
			GMControl.Log( memory.name + " = " + memory.value );
		if ( memory.value == value )
		{
			
		}
		//ctrl.SetMemory( memory.name, value );
		if ( ctrl.isConnected() )
		{
			ctrl.setMemory( memory.name, value );
		}
		else
		{
			memory.value = value;
			var event = {};
			event.type = ControlEvent.MEMORY_CHANGED;
			event.name = memory.name;
			event.value = memory.value;
			GMControl.GMControlEvent( event );
		}
	}
	
	// Retrieve a memory from its AddMemory name
	public function GetMemory( name, defaultval = 0 )
	{
		memory = memories[name];
		if ( memory )
			return memory.value;
	}
	
	public function OnMemoryChanged( key, value )
	{
		memory = memories[key];
		//GM.Log( "Memory \"" + key + "\" set to \"" + value + "\"" );
		if ( memory )
		{
			memory.value = value;
			if ( memory.func )
			{
				if ( memory.func.length == 0 )
					memory.func();
				else
					memory.func( value );
			}
		}
	}
	
	public function BroadcastMessage( message = "", data = null )
	{
		ctrl.sendMessage( message, data );
	}
	
	public function OnReceiveMessage( message )
	{
		
	}
	
	public function OnReceiveSignal( message )
	{
		
	}
	
	
	
	
} // class


} // Package



