
// GM Control
// by sage [ https://github.com/Sage64/Whirled ]
// Control object, combines all control types into one

/*
	GMControl is used in place of AvatarControl/PetControl etc
*/

package gamemaker
{
// 
import flash.display.*;
import flash.errors.*;
import flash.events.*;
import flash.text.*;
import flash.ui.*;
import flash.utils.*;

import com.whirled.*;
import com.threerings.*;
import com.threerings.util.*;

public class GMControl extends ActorControl
{
	public static var initdone;
	
	public static var debug = false;
	public static const debug_log = GM.debug_log;
	public static var debugTracker = "";
	public static var hasErrored = false;
	
	public static var isBitmap = true;
	
	public static var curCharacter;
	public static var characterList = [];
	public static var characters = {};
	public static var characterInit = 0;
	
	public static var root;
	public static var media;
	public static var container;
	public static var ctrl; // the specific instance of GMControl created for the actor
	public static var body;
	
	public static var popup_surface; // draw target for a popup
	
	public static var isLoaded = false;
	
	public static var isControl = false;
	
	public static var isConnected = false;
	
	public static var entityID;
	public static var memberID;
	
	public static var isAvatar = false;
	public static var isPet = false;
	public static var isFurni  = false;
	
	// AvatarControl
	protected static var _actions = [];
	protected static var _states = [];
	protected static var _isSleeping;
	
	
	// 
	public static var _eventlisteners = {
		list: [],
		func: {}
	 };
	public static var _eventqueue = [];
	
	public static var remoteEntities = {};
	public static var remoteEntitiesList = [];
	
	public static var originX = 0;
	public static var originY = 0;
	
	public static var viewXOffset = 0;
	public static var viewYOffset = 0;
	public static var baseXOffset = 1<<15;
	public static var baseYOffset = 1<<15;
	
	public static var scale = 1;
	public static var forceScale = null;
	
	public static var unscaleX = 1;
	public static var unscaleY = 1;
	
	public static var popupPanel = null;
	
	public static var _tempsymbols = [];
	public static var _tempdrawsprites = [];
	public static var internalstageitems = {};
	public static var internalspritelist = [];
	public static var internalspritemap = {};
	public static var internalspritecur = null;
	
	public static var internalsoundlist = [];
	public static var internalsoundmap = {};
	
	public function GMControl( media )
	{
		GMControl.media = media;
		GMControl.ctrl = this;
		GMControl.isConnected = ctrl.isConnected();
		
		super( media );
		
		if ( !initdone )
		{
			Init( media );
		}
		
		// InitWhirled();
		
		GMUpdateView();
	}
	
	public static function GMCleanup()
	{
		var i, len;
		var listener, inst, event, func;
		
		GMControl.Log( "Cleaning up" );
		// Remove the event listeners added through AddEventListener
		for ( i = 0, len = _eventlisteners.length; i < len; ++i )
		{
			listener = _eventlisteners.pop();
			inst = listener[0];
			event = listener[1];
			func = listener[2];
			inst.removeEventListener( event, func );
		}
	}
	
	/*
		INIT
	*/
	
	public static function Init( media, stageW = 600, stageH = 450 )
	{
		if ( !GM.gm )
			GM.Init( media, stageW, stageH );
		if ( !ctrl )
		{
			ctrl = new GMControl( media );
			return;
		}
		
		GMControl.initdone = true;
		Log( "GMControl Init" );
		GMControl.media = media;
		GMControl.root = media.root;
		
		AddEventListener( media, Event.UNLOAD, GMCleanup );
		
		container = GM.container;
		
		popup_surface = new Sprite();
		popup_surface.cacheAsBitmap = false;
		
		// GMControl.container = new Sprite();
		// GMControl.container.cacheAsBitmap = true;
		// media.addChild( GMControl.container );
		
		InitWhirled();
	}
	
	public static function InitWhirled( ww = 600, hh = 450 )
	{
		// Init( media );
		Log( "GMControl InitWhirled" );
		
		GM.ctrl = ctrl;
		
		if ( !ctrl.isConnected() )
		{
			// Always run in debug mode if not connected to whirled
			GMControl.Log( "Debug Mode" );
			debug = true;
			GMGotControl();
			try
			{
				AddEventListener( media.stage, KeyboardEvent.KEY_DOWN, DebugKeyDown );
			}
			catch ( e )
			{
				GMControl.Warn( "tried to add keyboard to stage (security violation)" );
			} 
		}
		
		entityID = ctrl.getMyEntityId();
		Log( "entityID = " + entityID );
		
		GetEntity( entityID );
		
		memberID = ctrl.getEntityProperty( PROP_MEMBER_ID, entityID );
		Log( "memberID = " + memberID );
		
		var _type = ctrl.getEntityProperty( PROP_TYPE, entityID );
		Log( "PROP_TYPE = " + _type );
		switch( _type )
		{
			case TYPE_AVATAR:
				isAvatar = true;
				break;
			case TYPE_PET:
				isPet = true;
				break;
			case TYPE_FURNI:
				isFurni = true;
				break;
		}
		
		ctrl.setMemory( "GMControl", 1 );
		
		AddEventListener( ctrl, "GMBodyReady", null );
		
		AddEventListener( ctrl, ControlEvent.CONTROL_ACQUIRED, GMGotControl );
		
		AddEventListener( ctrl, ControlEvent.CHAT_RECEIVED, GMGotChat );
		
		AddEventListener( ctrl, ControlEvent.ENTITY_MOVED, GMEntityMoved );
		AddEventListener( ctrl, ControlEvent.ENTITY_ENTERED, GMEntityJoined );
		AddEventListener( ctrl, ControlEvent.ENTITY_LEFT, GMEntityLeft );
		
		AddEventListener( ctrl, ControlEvent.MEMORY_CHANGED, GMMemoryChanged );
		
		AddEventListener( ctrl, ControlEvent.MESSAGE_RECEIVED, GMReceiveMessage );
		AddEventListener( ctrl, ControlEvent.SIGNAL_RECEIVED, GMReceiveMessage );
		
		AddEventListener( ctrl, ControlEvent.ACTION_TRIGGERED, GMActionTriggered );
		AddEventListener( ctrl, ControlEvent.APPEARANCE_CHANGED, GMUpdateLook );
		AddEventListener( ctrl, ControlEvent.AVATAR_SPOKE, GMAvatarSpoke );
		AddEventListener( ctrl, ControlEvent.STATE_CHANGED, GMStateChanged );
		
		if ( ctrl.hasControl() )
		{
			GMGotControl();
		}
		
		if ( debug )
			OpenControlPanel();
		
	}
	
	// Add a character
	// 
	public static function AddCharacter( dispname, internalname )
	{
		if ( characters[internalname] != null )
		{
			GMControl.Log( "Character " + internalname + " already exists" );
			return;
		}
		GMControl.Log( "Adding character " + internalname +  " (" + dispname + ")" );
		
		var NewChar = {};
		characters[internalname] = NewChar;
		characterList.push( NewChar );
		characters[internalname] = NewChar;
		
		NewChar.name = dispname;
		NewChar.internalname = internalname;
		NewChar.body = null;
		
		return NewChar;
	}
	
	// Add a Body class
	public static function AddBody( dispname, internalname, bodyclass )
	{
		var NewChar = characters[internalname];
		if ( NewChar == null )
			NewChar = AddCharacter( dispname, internalname );
		GMControl.Log( "Adding Body for character '" + dispname + "'" );
		body = new bodyclass();
		NewChar.body = body;
		
		// container.addChild( body );
	}
	
	public static function AddSprites( asset )
	{
		return GM.AddSprites( asset );
	}
	
	public static function AddSound( asset )
	{
		return GM.AddSound( asset );
	}
	
	/*
		EVENT PROCESSING
	*/
	
	// Add an event listener
	public static function AddEventListener( inst, event, func )
	{
		GMControl.Log( "Listening for " + event );
		// the function to be called by this event
		_eventlisteners.func[event] = func;
		// the func used in the event listener callback
		func = GMControlEvent;
		_eventlisteners.list.push( [ inst, event, func ] );
		 inst.addEventListener( event, func );
	}
	
	public static function GMControlEvent( event )
	{
		_eventqueue.push( event );
		// GMControl.Log( "Event: " + event.type );// + ": \"" + event.name + "\", " + event.value );
	}
	
	private static  function GMProcessEvents()
	{
		for ( var i = 0; i < _eventqueue.length; ++i )
		{
			GM.debugTracker = "GMProcessEvents";
			var event = _eventqueue.shift();
			var func = _eventlisteners.func[event.type];
			if ( !func )
				continue;
			try
			{
				func( event );
			}
			catch ( e )
			{
				Caught( e );
			}
		}
	}
	
	public static function GMGotControl( event = null )
	{
		GMControl.Log( "GOT CONTROL" );
		isControl = true;
	}
	
	public static function GMGotChat( event )
	{
		var Entity = GMControl.GetEntity( event.name );
		if ( Entity )
			GM.Log( Entity.name + ": " + event.value );
		if ( !body )
			return;
		if ( event.name == entityID )
		{
			// I spoke
			body.TriggerAction( "GMSentChat", event.value );
		}
		else
		{
			// Someone/something else spoke
		}
		
		body.OnChat( event.name, event.value );
	}
	
	public static function GMEntityMoved( event )
	{
		var Entity = GetEntity( event.name );
		if ( Entity )
		{
			Entity.GetPosition();
			var bounds = ctrl.getRoomBounds();
			if ( bounds )
			{
				if ( event.value )
				{
					Entity.destination = bounds;
					bounds[0] *= event.value[0];
					bounds[1] *= event.value[1];
					bounds[2] *= event.value[2];
				}
			}
		}
		if ( body )
			body.GMEntityMoved( event );
	}
	
	public static function GMEntityJoined( event )
	{
		GM.Log( "EntityJoined: " + event.name );
		var Entity = GMControl.GetEntity( event.name );
	}
	public static function GMEntityLeft( event )
	{
		GM.Log( "EntityLeft: " + event.name );
		var Entity = remoteEntities[event.name];
		if ( Entity != null )
		{
			GM.Log( "Removing RemoteEntity for " + Entity.name );
			Entity.Cleanup();
			remoteEntities[event.name] = null;
		}
	}
	
	
	public static function GMReceiveMessage( event )
	{
		if ( !body )
			return;
		var message = event.name;
		
		if ( event.type == ControlEvent.SIGNAL_RECEIVED )
		{
			GM.Log( "Received Signal: " + event.name + ", " + event.value );
			body.OnReceiveSignal( message );
		}
		if ( event.type == ControlEvent.MESSAGE_RECEIVED )
		{
			GM.Log( "Received Message: " + event.name + ", " + event.value );
			body.OnReceiveMessage( message );
		}
	}
	
	
	
	public static function GMActionTriggered( event )
	{
		if ( !event || !body )
			return;
		body.actionName = event.name;
		body.OnTriggerAction( event.name, event.value );
	}
	
	public static function GMAvatarSpoke( event )
	{ 
		if ( !body )
			return;
		body.OnSpeak();
	}
	
	public static function GMUpdateLook( event )
	{
		if ( body )
			body.GMUpdateLook( event );
	}
	
	public static function GMStateChanged( event )
	{
		if ( body )
			body.GMStateChanged( event );
	}
	
	public static function GMKeyboardDown( ev )
	{
		GM.Log( "GMKeyboardDown" );
	}
	
	/*
		DEBUG
	*/
	
	public static function DebugKeyDown( ev )
	{
		if ( !ev )
			return;
		var i;
		var key = ev.keyCode;
		// 
		if ( key >= 48 && key <= 57 )
		{
			var _num = key - 48;
			if ( key == 48 )
				_num += 10;
			--_num;
			if ( body )
			{
				var _getstate = null;
				if ( ev.shiftKey )
				{
					if ( _num < body.actionList.length )
					{
						_getstate = body.actionList[_num];
						if ( _getstate )
							body.TriggerAction( _getstate );
					}
				}
				else
				{
					if ( _num < 0 )
					{
						body.SetState( null );
					}
					else if ( _num < body.stateList.length )
					{
						_getstate = body.GetState( body.stateList[_num] );
						if ( _getstate )
							body.SetState( _getstate );
					}
				}
			}
		} 
		else if ( key == 189 )
		{
			// -
			trace( "prev state" );
			for ( i = 1; i < body.stateList.length; ++i )
			{
				if ( body.curState == body.stateList[i] )
				{
					body.SetState( body.stateList[i - 1] );
					break;
				}
			}
		}
		else if ( key == 187 )
		{
			// +
			trace( "next state" );
			for ( i = 0; ( i + 1 ) < body.stateList.length; ++i )
			{
				if ( body.curState == body.stateList[i] )
				{
					body.SetState( body.stateList[i + 1] );
					break;
				}
			}
		}
		
		switch( key ) 
		{
			case Keyboard.S:
				GMControl._isSleeping = !GMControl._isSleeping;
				ctrl.dispatchEvent( new ControlEvent( ControlEvent.APPEARANCE_CHANGED ) );
				break;
			case Keyboard.D:
				ctrl.dispatchEvent( new ControlEvent( ControlEvent.APPEARANCE_CHANGED ) );
				break;
		}
	}
	
	public static function Caught( e )
	{
		return GM.Caught( e );
	}
	
	public static function Log( text = "" )
	{
		if ( GMControl.isControl )
			return GM.Log( text );
	}
	
	public static function Warn( text )
	{
		return GM.Warn( text );
	}
	
	public static function GetControlPanel()
	{
		if ( !ctrl.hasControl() )
			return;
		return GM.GetControlPanel();
	}
	
	public static function OpenControlPanel()
	{
		if ( true )
		{
			// disable the error effects upon opening the log
			media.transform.colorTransform.redMultiplier = 1;
			media.transform.colorTransform.greenMultiplier = 1;
			media.transform.colorTransform.blueMultiplier = 1;
			media.alpha = 1;
		}
		
		var _panel = GetControlPanel();
		if ( !_panel )
			return;
		DoPopup( _panel, _panel.width, _panel.height );
	}
	
	public static function OpenConfig()
	{
		if ( false )
		{
			OpenControlPanel();
			return null;
		}
		
		var _panel = GetControlPanel();
		return _panel;
	}
	
	public static function DoPopup( _panel, _w, _h )
	{
		if ( !ctrl )
		{
			return;
		}
		var _title = "Popup";
		if ( _panel == null )
		{
			_panel = popup_surface;
			_panel.width = _w;
			_panel.height = _h;
		}
		_title = _panel.name;
		var res = ctrl.showPopup( _title, _panel, _w, _h, 0x000000, 0 );
		if ( res )
		{
			// _panel.addEventListener( Event.REMOVED, PopupClosedEvent );
		}
	}
	
	public static function DoPopupGM()
	{
		
	}
	
	public static function PopupClosedEvent( ev )
	{
		GM.Log( "Popup closed" );
	}
	
	/*
		Remote entities
	*/
	
	public static function GetEntity( _entityid )
	{
		if ( _entityid == null )
		{
			//return null;
			_entityid = "NULL";
		}
		var Entity = remoteEntities[_entityid];
		if ( Entity == null )
		{
			Entity = new GMRemoteEntity( _entityid )
			remoteEntities[ _entityid ] = Entity;
			remoteEntitiesList.push( Entity );
			
		}
		return Entity;
	}
	
	/*
		Main Loop
	*/
	
	public static function CharacterInitStep()
	{
		Log( "CharacterInitStep" );
		GM.debugTracker = "Characters Init";
		// 
		var char = characterList[characterInit];
		if ( characterInit == 0 )
		{
			body = char.body;
		}
		
		++characterInit;
		if ( characterInit >= characterList.length )
		{
			body = characterList[0].body;
			GM.debugTracker = "Character Init Ready";
			CharacterInitDone();
		}
	}
	
	public static function CharacterInitDone()
	{
		Log( "CharacterInitDone" );
		// GMControl.media.addChild( container );
		body.Ready();
	}
	
	public static function SwitchCharacter( char )
	{
		if ( body )
		{
			
		}
		if ( char )
		{
			body = char.body;
			body.Ready();
		}
	}
	
	public static function Loop( event = null )
	{
		var i;
		GM.debugTracker = "GMControl.Loop";
		
		// return GM.Loop();
		
		try
		{
			if ( !GM.isLoaded && GM.root )
			{
				if ( GM.root.loaderInfo.bytesLoaded < GM.root.loaderInfo.bytesTotal )
				{
					Log( "Loading " + GM.root.loaderInfo.bytesLoaded + " / " + GM.root.loaderInfo.bytesTotal );
				}
				else
				{
					GM.isLoaded = true;
					Log( "Loaded " + GM.root.loaderInfo.bytesTotal + "b" );
				}
			}
			
			if ( true && characterInit < characterList.length )
			{
				CharacterInitStep();
				media.gotoAndPlay( 2 );
				return;
			}
			
			GMProcessEvents();
			
			return GM.Loop();
		}
		catch (e)
		{
			Caught( e );
		}
		media.gotoAndPlay( 2 );
	}
	
	public static function GMStep()
	{
		GM.debugTracker = "GMControl.GMStep";
		
		if ( body )
			body.GMStep();
	}
	
	public static function GMDraw()
	{
		if ( popup_surface )
			popup_surface.graphics.clear();
		
		GM.debugTracker = "GMControl.GMDraw";
		if ( body )
			body.GMDraw();
		
		if ( false )
		{
			GMObject.surface_set_target( GM.overlay );
			for each ( var Entity in remoteEntities )
			{
				GM.debugTracker = "Debug Draw - " + Entity;
				if ( !Entity )
					continue;
				Entity.GetPosition();
				Entity.DrawDebug( GM.overlay.graphics );
			}
			GMObject.surface_reset_target();
			GM.debugTracker = "After Debug Draw";
		}
	}
	
	/*
		View
	*/
	
	public static function SetViewOffset( xx = null, yy = null )
	{
		if ( xx != null )
			viewXOffset = xx;
		if ( yy != null )
			viewYOffset = yy;
	}
	
	public static function GMUpdateView( xx = 0, yy = 0, hh = 0 )
	{
		if ( !media )
			return;
		
		var _scale = ( forceScale == null ) ? scale : forceScale;
		
		var _w = GM.stageW;
		var _h = GM.stageH;
		
		if ( true )
		{
			media.x = 0;
			media.y = 0;
			container.scaleX = ( body && body.flipped ) ? -_scale : _scale;
			container.scaleY = _scale;
		}
		else
		{
			media.scaleX = _scale * ( media.scaleX > 0 ? 1 : -1 ) ;
			media.scaleY = _scale;
			media.x = -Math.floor( ( ( _w * media.scaleX ) - _w ) / 2 );
			media.y = -Math.floor( ( ( _h * media.scaleY ) - _h ) / 2 );
		}
		// Artificially extend the screen space by offsetting it and the hotspot
		// by the view x/y offsets
		// this offset seems to be restricted by whirled in one way, so is offset massively by default
		// 
		
		var offx = ( ( viewXOffset ) * _scale );
		var offy = ( ( viewYOffset ) * _scale );
		media.x -= ( offx );
		media.y -= ( offy );
		
		GM.view_width = GM.stageW / _scale;
		GM.view_height = GM.stageH / _scale;
		
		GM.view_x = ( offx ) - ( GM.stageW / 2 );
		GM.view_y = ( offy ) - ( GM.stageH / 2 );
		
		if ( GM.isLoaded )
		{
			GM.container.x = baseXOffset;
			GM.container.y = baseYOffset;
			
			media.x -= GM.container.x;// * _scale;
			media.y -= GM.container.y;// * _scale;
			
			GM.container.x += GM.stageW / 2;
			GM.container.y += GM.stageH / 2;
			
			GM.view_x += ( container.x );
			GM.view_y += ( container.y );
			
			offx -= GM.stageW / 2;
			offy -= GM.stageH / 2;
			
		}
		
		GM.overlay.x = GM.view_x;
		GM.overlay.y = GM.view_y;
		
		ctrl.setHotSpot( xx - offx, yy - offy, hh );
	}
	
	public static function SetScale( amount )
	{
		if ( amount == scale )
			return;
		scale = amount;
		GM.Log( "Scale = " + scale );
	}
	
	/*
		Data
	*/
	
	public function SetMemory( key, value )
	{
		ctrl.setMemory( key, value );
		GMControl.Log( "Setting memory '" + key + "' to '" + value + "'" );
	}
	
	public function GetMemory( key, defaultval = null )
	{
		var val = ctrl.getMemory( key, defaultval );
		return val;
	}
	
	public static function GMMemoryChanged( event )
	{
		Log( "Got memory '" + event.name + "' = '" + event.value + "'" );
		if ( body )
		{
			body.OnMemoryChanged( event.name, event.value );
			body.OnUpdateLook();
			body.RegisterActions();
		}
	}
	
	/*
		Whirled Control
	*/
	
	override public function getState() :String
	{
		var _state = super.getState();
		if ( _state == null )
		{
			if ( false && _states.length > 0 )
				_state = _states[0];
			else
				_state = "default";
		}
		return _state;
	}
	
	override public function setUserProps( o :Object ) :void
	{
		super.setUserProps( o );
		// Avatar
		o["avatarSpoke_v1"] = avatarSpoke_v1;
		o["getActions_v1"] = getActions_v1;
		o["getStates_v1"] = getStates_v1;
		// Pet
		o["receivedChat_v2"] = receivedChat_v2;
	}
	
	override protected function gotInitProps( o :Object ) :void
	{
		super.gotInitProps( o );
		_isSleeping = (o["isSleeping"] as Boolean);
	}
	
	override protected function appearanceChanged_v2( location :Array, orient :Number, moving :Boolean, sleeping :Boolean) :void
	{
		_isSleeping = sleeping;
		super.appearanceChanged_v2( location, orient, moving, sleeping );
	}
	
	/*
		AvatarControl
	*/
	
	public function registerActions( ... actions )
	{
		actions = Util.unfuckVarargs( actions );
		ctrl.verifyActionsOrStates( actions, true );
		_actions = actions;
		// Log( "Registering actions: " + _actions );
	}
	
	public function registerStates( ... states )
	{
		states = Util.unfuckVarargs( states );
		ctrl.verifyActionsOrStates( states, false );
		_states = states;
		// Log( "Registering states: " + _states );
	}
	
	public function isSleeping()
	{
		return _isSleeping;
	}
	
	
	public function setPreferredY( pixels )
	{
		callHostCode( "setPreferredY_v1", pixels );
	}
	
	protected function avatarSpoke_v1()
	{
		dispatchCtrlEvent( ControlEvent.AVATAR_SPOKE );
	}
	
	protected function getActions_v1()
	{
		return _actions;
	}
	
	protected function getStates_v1()
	{
		return _states;
	}
	
	protected function verifyActionsOrStates( val, isAction = false )
	{
		
		return;
	}
	/*
		PetControl
	*/
	
	public function sendChat( text )
	{
		callHostCode( "sendChatMessage_v1", text );
	}
	
	public function getOwnerId() :int
	{
		return int( getEntityProperty( PROP_MEMBER_ID ) );
	}
	
}
}

import gamemaker.*;

import flash.display.*;
import flash.media.*;

import com.threerings.*;
import com.whirled.*;


// Another entity that it is in the room
// 
class GMRemoteEntity// extends EntityControl
{
	public static const ENV_ROOM :String = "room";
	public static const ENV_SHOP :String = "shop";
	public static const ENV_VIEWER :String = "viewer";
	//
	public static const TYPE_AVATAR :String = "avatar";
	public static const TYPE_FURNI :String = "furni";
	public static const TYPE_PET :String = "pet";
	// 
	public static const PROP_DIMENSIONS :String = "std:dimensions";
	public static const PROP_HOTSPOT :String = "std:hotspot";
	public static const PROP_LOCATION_LOGICAL :String = "std:location_logical";
	public static const PROP_LOCATION_PIXEL :String = "std:location_pixel";
	public static const PROP_MEMBER_ID :String = "std:member_id";
	public static const PROP_MOVE_SPEED :String = "std:move_speed";
	public static const PROP_NAME :String = "std:name";
	public static const PROP_ORIENTATION :String = "std:orientation";
	public static const PROP_TYPE :String = "std:type";
	
	
	public var entityID;
	public var memberID
	
	public var media = GMControl.media;
	public var ctrl = GMControl.ctrl;
	
	public var isControl = false;
	public var isMoving = false;
	public var isSleeping = false;
	
	public var type;
	
	public var name;
	
	public var x = 0;
	public var y = 0;
	public var z = 0;
	public var orient = 0;
	
	public var xsize = 48;
	public var ysize = 128;
	public var zsize = 48;
	
	public var location = [];
	public var destination = [];
	
	public function GMRemoteEntity( _entityid )
	{
		GM.debugTracker = "GMRemoteEntity";
		this.entityID = _entityid;
		this.memberID = GetProperty( PROP_MEMBER_ID );
		this.name = GetProperty( PROP_NAME );
		this.type = GetProperty( PROP_TYPE );
		GetPosition();
		GMControl.Log( "new GMRemoteEntity( " + _entityid + " ); - " + name );
	}
	
	public function Cleanup() {}
	
	public function DrawDebug( g )
	{
		var drawscale = 1 / 2;
		var x = this.x * drawscale;
		var y = this.y * drawscale;
		var z = ( GM.stageH - this.z ) * drawscale;
		var xsize = this.xsize * drawscale;
		var ysize = this.ysize * drawscale;
		var zsize = this.zsize * drawscale;
		
		// x += GM.stageW / 2;
		// y += GM.stageH / 2;
		
		// g.beginFill( 0x00FF00 );
		// g.drawRect( x1 / 4, y1 / 4, ( x1 + xsize ) / 4, ( y1 + ysize ) / 4 );
		// g.endFill();
		GMObject.draw_set_color( 0x00FF00 );
		GMObject.draw_rectangle( x, z, ( x + xsize ), ( z + zsize ) );
	}
	
	// 
	
	public function IsSleeping()
	{
		return isSleeping;
	}
	
	public function GetProperty( key )
	{
		return ctrl.callHostCode( "getEntityProperty_v1", entityID, key ) ;
	}
	
	public function GetPosition()
	{
		var pos = GetProperty( PROP_LOCATION_PIXEL );
		if ( pos == null )
			return;
		if ( pos.length >= 3 )
		{
			x = pos[0];
			y = pos[1];
			z = pos[2];
			return true;
		}
	}
	
	public function IsTouching( Entity )
	{
		if ( !Entity )
			return;
		if ( !GetPosition() || !Entity.GetPosition() )
			return;
		var x1 = x - ( xsize / 2 );
		var x2 = x1 + xsize;
		var x1b = Entity.x - ( Entity.xsize / 2 );
		var x2b = x1b + Entity.xsize;
		if ( x2 < x1b || x1 > x2b )
			return false;
		var z1 = z - ( zsize / 2 );
		var z2 = z1 + zsize;
		var z1b = Entity.z - ( Entity.zsize / 2 );
		var z2b = z1b + Entity.zsize;
		if ( z2 < z1b || z1 > z2b )
			return false;
		var y1 = y - ( ysize );
		var y2 = y;// + ysize;
		var y1b = Entity.y - ( Entity.ysize / 2 );
		var y2b = y1b + Entity.ysize;
		if ( y2 < y1b || y1 > y2b )
			return false;
		return true;
	}
}