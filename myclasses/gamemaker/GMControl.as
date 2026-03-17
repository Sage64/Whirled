
// GM Control
// by sage [ https://github.com/Sage64/Whirled ]
// Control object for my GMBody base, combines all control types into one

/*
	GMControl is used in place of AvatarControl/PetControl etc without needing
	to specify what it is
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
	
	public static var stageW = 600;
	public static var stageH = 450;
	public static var originX = 0;//stageW / 2;
	public static var originY = 0;//stageH / 2;
	
	public static var viewXOffset = 0;
	public static var viewYOffset = 0;
	public static var baseXOffset = 65500;
	public static var baseYOffset = 65500;
	
	public static var scale = 1;
	public static var forceScale = null;
	
	public static var unscaleX = 1;
	public static var unscaleY = 1;
	
	public static var controlPanel;
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
		InitWhirled();
		
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
	
	public static function Init( media )
	{
		if ( !GM.gm )
			GM.Init( media, stageW, stageH );
		
		Log( "GMControl Init" );
		
		GMControl.media = media;
		GMControl.root = media.root;
		
		AddEventListener( media, Event.UNLOAD, GMCleanup );
		
		GMControl.container = GM.container;
		
		// GMControl.container = new Sprite();
		// GMControl.container.cacheAsBitmap = true;
		// media.addChild( GMControl.container );
	}
	
	public static function InitWhirled( ww = 600, hh = 450 )
	{
		Init( media );
		Log( "GMControl InitWhirled" );
		
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
		
		container.addChild( body );
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
		GMControl.Log( "Event: " + event.type );// + ": \"" + event.name + "\", " + event.value );
	}
	
	private static  function GMProcessEvents()
	{
		for ( var i = 0; i < _eventqueue.length; ++i )
		{
			debugTracker = "GMProcessEvents";
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
		if ( body )
			body.GMEntityMoved( event );
	}
	
	public static function GMEntityJoined( event )
	{
		var Entity = GMControl.GetEntity( event.name );
	}
	public static function GMEntityLeft( event )
	{
		var Entity = GMControl.GetEntity( event.name );
	}
	
	
	public static function GMReceiveMessage( event )
	{
		if ( !body )
			return;
		var message = event.name;
		if ( event.type == ControlEvent.SIGNAL_RECEIVED )
			body.OnReceiveSignal( message );
		if ( event.type == ControlEvent.MESSAGE_RECEIVED )
			body.OnReceiveMessage( message );
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
		if ( true )
		{
			if ( media )
				media.alpha = 0.5;
			Log( "*************************************************************" );
			Log( "ERROR CAUGHT - please share this with the avatar creator!" );
			Log( "tracker: " + debugTracker );
			Log( e.errorID  );
			Log( e.name  );
			Log( e.message  );
			Log( e.prototype  );
			Log( e.getStackTrace() );
			Log( "*************************************************************" );
			if ( !hasErrored )
			{
				hasErrored = true;
				OpenControlPanel();
			}
		}
		hasErrored = true;
	}
	
	public static function Log( text = "" )
	{
		if ( GMControl.isControl )
			return GM.Log( text );
	}
	
	public static function Warn( text )
	{
		return Log( "WARNING at " + debugTracker + ": " + text );
	}
	
	public static function GetControlPanel()
	{
		if ( !ctrl.hasControl() )
			return;
		var ww = 640;
		var hh = 420;
		var smallScreen = ( ( ctrl != null ) && ( ctrl.getEnvironment() != EntityControl.ENV_ROOM ) );
		if ( smallScreen )
		{
			ww = 320;
			hh = 240;
		}
		if ( !controlPanel )
			controlPanel = new GMControlPanel( ww, hh );
		controlPanel.SetSize( ww, hh );
		return controlPanel;
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
		OpenControlPanel();
		return null;
		
		var _panel = GetControlPanel();
		return _panel;
	}
	
	public static function DoPopup( _panel, _w, _h )
	{
		if ( !_panel )
			return;
		_panel.SetSize( _w, _h );
		if ( !ctrl )
			return;
		ctrl.showPopup( "title", _panel, _w, _h, 0x000000, 0 );
	}
	
	
	/*
		Remote entities
	*/
	
	public static function GetEntity( _entityid )
	{
		if ( _entityid == null )
		{
			return null;
			_entityid = "none";
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
		debugTracker = "Characters Init";
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
			debugTracker = "Character Init Ready";
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
		debugTracker = "GMControl.Loop";
		
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
		debugTracker = "GMControl.GMStep";
		
		if ( body )
			body.GMStep();
	}
	
	public static function GMDraw()
	{
		if ( body )
			body.GMDraw();
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
		
		var _w = GMControl.stageW;
		var _h = GMControl.stageH;
		
		media.scaleX = _scale * ( media.scaleX > 0 ? 1 : -1 ) ;
		media.scaleY = _scale;
		media.x = -Math.floor( ( ( _w * media.scaleX ) - _w ) / 2 );
		media.y = -Math.floor( ( ( _h * media.scaleY ) - _h ) / 2 );
		
		// Artificially extend the screen space by offsetting it and the hotspot
		// by the view x/y offsets
		// this offset is hard restricted by whirled in one direction however
		// viewXOffset = Math.min( viewXOffset, 150 );
		
		var offx = ( ( viewXOffset ) * _scale );
		var offy = ( ( viewYOffset ) * _scale );
		media.x -= ( offx );
		media.y -= ( offy );
		
		if ( GM.isLoaded )
		{
			container.x = baseXOffset;
			container.y = baseYOffset;
			
			media.x -= container.x * _scale;
			media.y -= container.y * _scale;
			
			container.x += stageW / 2;
			container.y += stageH / 2;
			offx -= stageW / 2;
			offy -= stageH / 2;
		}
		ctrl.setHotSpot( xx - offx, yy - offy, hh );
	}
	
	public static function SetScale( amount )
	{
		if ( amount == scale )
			return;
		scale = amount;
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
		//Log( "Got memory '" + event.name + "' = '" + event.value + "'" );
		if ( body )
		{
			body.OnMemoryChanged( event.name, event.value );
			body.OnUpdateLook();
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
	
	public function SendChat( text )
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
class GMRemoteEntity
{
	public var entityID;
	
	public var isControl;
	public var isMoving;
	public var isSleeping;
	
	public var x = 0;
	public var y = 0;
	public var z = 0;
	public var orient = 0;
	
	public function GMRemoteEntity( _entityid )
	{
		GMControl.Log( "new GMRemoteEntity( " + _entityid + " );" );
		this.entityID = _entityid;
	}
	
	
	
	public function IsSleeping()
	{
		
	}
	
}