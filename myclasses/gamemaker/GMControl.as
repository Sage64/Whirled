
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
	public static const PROP_CHARACTER = "gm:character";
	public static const PROP_STATE = "gm:state";
	
	
	public static var initdone;
	
	public static var debug = false;
	public static const debug_log = GM.debug_log;
	public static var debugTracker = "";
	public static var debugMove = true;
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
	public var gm;
	
	public static var popup_instance; // will be instance_destroy'd when a popup opens
	public static var popup_width = 0;
	public static var popup_height = 0;
	public static var popup_surface; // draw target for a popup
	public static var popup_mask;
	
	public static var isLoaded = false;
	
	public static var isControl = false;
	
	public static var isConnected = false;
	
	public static var entity;
	public static var entityID;
	public static var memberID;
	public static var entityType;
	
	public static var isActor = false;
	public static var isAvatar = false;
	public static var isPet = false;
	public static var isFurni  = false;
	
	public static var customProps = {};
	
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
	public static var remoteEntitiesList = [];
	public static var remoteEntities = {};
	
	public static var viewXOffset = 0;
	public static var viewYOffset = 0;
	public static var baseXOffset = 1<<15;
	public static var baseYOffset = 1<<15;
	
	public static var scale = 1;
	public static var forceScale = null;
	
	public static var unscaleX = 1;
	public static var unscaleY = 1;
	
	public static var popupPanel = null;
	
	public function GMControl( media )
	{
		GM.debugTracker = "new GMControl()";
		GMControl.media = media;
		GMControl.ctrl = this;
		GMControl.isConnected = ctrl.isConnected();
		
		this.gm = GM;
		
		super( media );
		
		if ( !initdone )
		{
			Init( media );
		}
		
		// InitWhirled();
		
		GMUpdateView( 0, 0, 1 << 16 );
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
		GM.debugTracker = "GMControl.Init";
		if ( !GM.gm )
			GM.Init( media, stageW, stageH );
		if ( !GMControl.ctrl )
		{
			try
			{
				GMControl.ctrl = new GMControl( media );
			}
			catch(e)
			{
				Caught(e);
			}
			return;
		}
		
		GMControl.initdone = true;
		GM.Log( "GMControl Init" );
		GMControl.media = media;
		GMControl.root = media.root;
		
		AddEventListener( media, Event.UNLOAD, GMCleanup );
		
		container = GM.container;
		
		popup_surface = new GMPopupSurface();
		popup_surface.cacheAsBitmap = false;
		popup_mask = new Sprite();
		popup_surface.mask = popup_mask;
		popup_surface.addChild( popup_mask );
		
		try
		{
			InitInputListeners( popup_surface );
		}
		catch(e)
		{
			GM.Warn( "GMControl: Security violation adding input listeners" );
		}
		
		// GMControl.container = new Sprite();
		// GMControl.container.cacheAsBitmap = true;
		// media.addChild( GMControl.container );
		
		InitWhirled();
		
		if ( debug )
		{
			GM.overlay.addChild( popup_surface );
			popup_surface.x = 0;
			popup_surface.y = 0;
		}
	}
	
	public static function InitInputListeners( target )
	{
		GM.debugTracker = "GMControl.InitInputListeners";
		AddEventListener( target, KeyboardEvent.KEY_DOWN, GMKeyboardDown );
		AddEventListener( target, KeyboardEvent.KEY_UP, GMKeyboardUp );
		AddEventListener( target, MouseEvent.CLICK, GMClicked );
		// Left mouse
		AddEventListener( target, MouseEvent.MOUSE_DOWN, GMMouseDown );
		AddEventListener( target, MouseEvent.MOUSE_UP, GM.GMMouseUp );
		// Right mouse
		if ( true )
		{
			AddEventListener( target, MouseEvent.RIGHT_MOUSE_DOWN, GMMouseDown );
			AddEventListener( target, MouseEvent.RIGHT_MOUSE_UP, GM.GMMouseUp );
		}
		return;
	}
	
	public static function InitWhirled( ww = 600, hh = 450 )
	{
		GM.debugTracker = "GMControl.InitWhirled";
		// Init( media );
		GM.Log( "GMControl InitWhirled" );
		
		GM.ctrl = ctrl;
		
		if ( !ctrl.isConnected() )
		{
			// Always run in debug mode if not connected to whirled
			GM.Log( "isConnected(): false" );
			GM.Log( "Debug Mode" );
			debug = true;
			GMGotControl();
			try
			{
				AddEventListener( media.stage, KeyboardEvent.KEY_DOWN, GMKeyboardDown );
				AddEventListener( media.stage, KeyboardEvent.KEY_UP, GMKeyboardUp );
			}
			catch ( e )
			{
				GMControl.Warn( "tried to add keyboard to stage (security violation)" );
			} 
		}
		else
		{
			GM.Log( "isConnected(): true" );
		}
		
		ctrl.registerPropertyProvider( GMPropertyProvider );
		
		entityID = ctrl.getMyEntityId();
		GM.Log( "entityID = " + entityID );
		entityType = ctrl.getEntityProperty( PROP_TYPE );
		GM.Log( "PROP_TYPE = " + entityType );
		switch( entityType )
		{
			case TYPE_AVATAR:
				isAvatar = true;
				isActor = true;
				break;
			case TYPE_PET:
				isPet = true;
				isActor = true;
				break;
			case TYPE_FURNI:
				isFurni = true;
				break;
		}
		
		if ( isActor )
		{
			entity = GetEntity( entityID );
			memberID = entity.GetProperty( PROP_MEMBER_ID );
			GM.Log( "memberID = " + memberID );
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
		
		if ( debug || isAvatar || isPet )
		{
			AddEventListener( ctrl, ControlEvent.ACTION_TRIGGERED, GMActionTriggered );
			AddEventListener( ctrl, ControlEvent.APPEARANCE_CHANGED, GMUpdateLook );
			AddEventListener( ctrl, ControlEvent.AVATAR_SPOKE, GMAvatarSpoke );
			AddEventListener( ctrl, ControlEvent.STATE_CHANGED, GMStateChanged );
		}
		
		if ( ctrl.hasControl() )
		{
			ctrl.clearPopup();
			GMGotControl();
		}
		
		// ShowControlPanel();
		
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
		
		if ( !curCharacter )
			curCharacter = NewChar;
		
		return NewChar;
	}
	
	// Add a Body class
	public static function AddBody( dispname, internalname, bodyclass )
	{
		var NewChar = characters[internalname];
		if ( NewChar == null )
			NewChar = AddCharacter( dispname, internalname );
		else
		{
			GMControl.Warn( "Body " + dispname + " already exists!" );
			return;
		}
		GMControl.Log( "Adding Body for character '" + dispname + "'" );
		try
		{
			body = new bodyclass();
		}
		catch(e)
		{
			Caught(e);
		}
		NewChar.body = body;
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
		// trace( "GMControlEvent( " + event.toString() + " )" );
		_eventqueue.push( event );
	}
	
	private static  function GMProcessEvents()
	{
		GM.debugTracker = "GMControl.GMProcessEvents";
		for ( var i = 0; i < _eventqueue.length; ++i )
		{
			var event = _eventqueue.shift();
			GM.debugTracker = "GMControl.GMProcessEvents (event)";
			var func = _eventlisteners.func[event.type];
			if ( !func )
			{
				trace( "no func in " + event.type );
				continue;
			}
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
		var _moving = ( event.value ) ? true : false;
		var Entity = GetEntity( event.name );
		if ( Entity )
		{
			if ( _moving )
			{
				var bounds = ctrl.getRoomBounds();
				if ( bounds )
				{
					var x = bounds[0];
					var y = bounds[1];
					var z = bounds[2];
					x *= event.value[0];
					y *= event.value[1];
					z *= event.value[2];
					Entity.destination[0] = x;
					Entity.destination[1] = y;
					Entity.destination[2] = z;
				}
			}
			Entity.isMoving = _moving;
			Entity.GetPosition();
		}
		if ( body )
			body.GMEntityMoved( event );
	}
	
	public static function GMEntityJoined( event )
	{
		//GM.Log( "EntityJoined: " + event.name );
		var Entity = GMControl.GetEntity( event.name );
	}
	public static function GMEntityLeft( event )
	{
		// GM.Log( "EntityLeft: " + event.name );
		var Entity = remoteEntities[event.name];
		if ( Entity != null )
		{
			GM.Log( "Removing RemoteEntity " + event.name + " (" + Entity.name + ")" );
			Entity.Cleanup();
			remoteEntities[event.name] = null;
			var pos = remoteEntitiesList.indexOf( Entity );
			if ( pos < 0 )
			{}
			else
				remoteEntitiesList.splice( pos, 1 );
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
	
	// Send a signal containing data that otherwise isn't
	// remotely accessible about us
	public static function GMSendInfo()
	{
		var data = {};
		data.entity_id = entityID;
		data.character = ( curCharacter ) ? curCharacter.internalname : "none";
		data.state = ctrl.getState();
		
		
		ctrl.sendSignal( "gm.entityinfo", data );
	}
	
	public static function GMEntityInfo( data )
	{
		var entity_id = data.entity_id;
		if ( entity_id == null )
			return;
		var Entity = GetEntity( entity_id );
	}
	
	// ctrl.registerPropertyProvider( GMPropertyProvider );
	public static function GMPropertyProvider( key, entityId = null )
	{
		try
		{
			if ( !ctrl )
				return;
			GM.debugTracker = "GMPropertyProvider";
			switch( key )
			{
				case "state":
				case "gm:state":
					return ctrl.getState();
				case "character":
				case "gm:character":
					return ( curCharacter ) ? curCharacter.internalname : "unknown";
				case "body":
				case "gm:body":
					if ( body.secure )
						return null;
					return ( body );
				case PROP_DIMENSIONS:
				case PROP_HOTSPOT:
				case PROP_LOCATION_LOGICAL:
				case PROP_LOCATION_PIXEL:
				case PROP_MEMBER_ID:
				case PROP_MOVE_SPEED:
				case PROP_NAME:
				case PROP_ORIENTATION:
				case PROP_TYPE:
					return ctrl.getEntityProperty( key, entityId );
			}
			var val;
			if ( body )
			{
				val = body.OnProperty( key );
				if ( val != null )
					return val;
			}
			val = customProps[key];
			if ( val != null )
				return val;
			
			if ( val != null )
				return val;
			// Check memories;
			val = ctrl.GetMemory( key );
			if ( val != null )
				return val;
			//
			return val;
		}
		catch(e)
		{
			Caught(e);
		}
		return null;
	}
	
	public static function GMKeyboardDown( ev )
	{
		if ( ev.keyCode == 78 ) // N
			GMControl.debug = !GMControl.debug;
		if ( debug )
			DebugKeyDown( ev );
		return GM.GMKeyboardDown( ev );
	}
	
	public static function GMKeyboardUp( ev )
	{
		return GM.GMKeyboardUp( ev );
	}
	
	public static function GMClicked( ev = null )
	{
		with( GMObject )
		{
			if ( !window_has_focus() )
			{
				//io_clear();
			}
		}
		if ( GM.media.stage.focus != GMControl.popup_surface )
		{
			// GMControl.Log( "focus = popup_surface" );
		}
		GM.media.stage.focus = GMControl.popup_surface;
		return GM.GMClicked( ev );
	}
	
	public static function GMMouseDown( ev = null )
	{
		GMClicked( null );
		return GM.GMMouseDown( ev );
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
		if ( debug || ( isAvatar || isPet ) )
		{
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
							{
								GM.g_pIOManager.IO_Clear();
								GMObject.io_clear();
								body.TriggerAction( _getstate );
							}
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
					GMControlEvent( new ControlEvent( ControlEvent.APPEARANCE_CHANGED ) );
					break;
				case Keyboard.D:
					GMControlEvent( new ControlEvent( ControlEvent.APPEARANCE_CHANGED ) );
					break;
				case Keyboard.F:
					GMControlEvent( new ControlEvent( ControlEvent.APPEARANCE_CHANGED ) );
					break;
			}
		}
		
		
	}
	
	public static function Caught( e )
	{
		return GM.Caught( e );
	}
	
	public static function Log( text = "" )
	{
		// Log but only if in control
		if ( GMControl.isControl )
			return GM.Log( text );
	}
	
	public static function Warn( text )
	{
		return GM.Warn( text );
	}
	
	public static function GetControlPanel( ww = null, hh = null )
	{
		return GM.GetControlPanel( ww, hh );
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
	
	public static function ShowControlPanel()
	{
		// make the panel at 0,0
		var _panel = GM.GetControlPanel( 650, 240 );
		if ( GM.debug )
		{
			_panel.x = GM.stageW;
			trace( _panel.x );
			_panel.y = 0;
		}
		if ( _panel )
			GM.overlay.addChild( _panel );
	}
	
	public static function OpenConfig()
	{
		ctrl.clearPopup();
		var _panel = GetControlPanel();
		GMControl.popup_width = _panel.width;
		GMControl.popup_height = _panel.height;
		return _panel;
	}
	
	public static function ClosePopup()
	{
		if ( !ctrl )
			return;
		ctrl.clearPopup();
	}
	
	public static function DoPopup( _panel = null, _w = 600, _h = 450, _instance = null )
	{
		if ( !ctrl )
			return;
		if ( ctrl.getEnvironment() == "shop" )
			_h = Math.min( _h, 240 );
		if ( GMControl.popup_instance )
		{
			GM.InternalInstanceDestroy( GMControl.popup_instance );
			GMControl.popup_instance = null;
		}
		ctrl.clearPopup();
		if ( _instance )
			GMControl.popup_instance = _instance;
		
		var _title = "Popup";
		GMControl.popup_width = _w;
		GMControl.popup_height = _h;
		if ( _panel == null )
			_panel = popup_surface;
		if ( _panel == popup_surface )
		{
			_panel = popup_surface;
			_panel.graphics.clear();
			_panel.graphics.beginFill( 0, 0 );
			_panel.graphics.drawRect( 0, 0, GMControl.popup_width, GMControl.popup_height );
			_panel.graphics.endFill();
			// _panel.width = _w;
			// _panel.height = _h;
			popup_mask.graphics.clear();
			popup_mask.graphics.beginFill( 0, 0 );
			popup_mask.graphics.drawRect( 0, 0, GMControl.popup_width, GMControl.popup_height );
			popup_mask.graphics.endFill();
		}
		_panel.x = 0;
		_panel.y = 0;
		_panel.scaleX = 1;
		_panel.scaleY = 1;
		_title = _panel.name;
		var res;
		if ( !debug ) // only works inside whirled
			res = ctrl.showPopup( _title, _panel, _w, _h, 0x000000, 0 );
		GM.media.stage.focus = _panel;
		GMControl.Log( "DoPopup - "  + _panel.width + ", " + _panel.height );
	}
	
	public static function DoPopupObject( _w, _h, _instance = null )
	{
		return DoPopup( null, _w, _h, _instance );
	}
	
	
	public static function PopupClosedEvent( ev )
	{
		GM.Log( "Popup closed" );
	}
	
	/*
		Remote entities
	*/
	
	public static function GetEntity( _entityid = null )
	{
		if ( _entityid == null )
		{
			//return null;
			_entityid = "NULL";
		}
		var Entity = remoteEntities[_entityid];
		if ( Entity == null )
		{
			try
			{
				Entity = new GMRemoteEntity( _entityid )
				remoteEntities[ _entityid ] = Entity;
				remoteEntitiesList.push( Entity );
				GMControl.Log( "new GMRemoteEntity( " + _entityid + " ); - " + Entity.name + " (" + Entity.type + ") entities: " + remoteEntitiesList.length );
			}
			catch( e )
			{
				Caught( e );
			}
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
			
			if ( true && ( characterInit < characterList.length ) )
			{
				CharacterInitStep();
				media.gotoAndPlay( 2 );
				return;
			}
			
			GMProcessEvents();
			
			if ( popup_surface )
			{
				popup_surface.graphics.clear();
				popup_surface.graphics.beginFill( 0, 1 / 255 );
				popup_surface.graphics.drawRect( 0, 0, GMControl.popup_width, GMControl.popup_height );
				popup_surface.graphics.endFill();
			}
			
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
		GM.debugTracker = "GMControl.GMDraw";
		if ( body )
			body.GMDraw();
		
		if ( false )
		{
			GMObject.surface_set_target( GM.overlay );
			for each ( var Entity in remoteEntitiesList )
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
	
	public static function GMUpdateView( xx = null, yy = null, hh = null )
	{
		if ( !media )
			return;
		
		var _scale = ( !forceScale ) ? scale : forceScale;
		
		var _w = GM.stageW;
		var _h = GM.stageH;
		
		if ( isActor )
		{
		}
		else
		{
			// return;
		}
		
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
		
		if ( isAvatar || isPet )
		{
			if ( ( xx != null ) && ( hh != null ) && ( hh != null ) )
				ctrl.setHotSpot( xx - offx, yy - offy, hh );
		}
	}
	
	public static function SetScale( amount )
	{
		if ( amount == scale )
			return;
		scale = amount;
		GM.Log( "Scale = " + scale );
		GMUpdateView();
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
		// Log( "Got memory '" + event.name + "' = '" + event.value + "'" );
		if ( body )
		{
			body.OnMemoryChanged( event.name, event.value );
			body.OnUpdateLook();
			body.RegisterActions();
			body.RegisterStates();
		}
	}
	
	/*
		Entity Control
	*/
	
	override protected function entityEntered_v1 (entityId :String) :void
	{
		if ( true )
			dispatchCtrlEvent(ControlEvent.ENTITY_ENTERED, entityId);
	}

	override protected function entityLeft_v1 (entityId :String) :void
	{
		if ( true )
			dispatchCtrlEvent(ControlEvent.ENTITY_LEFT, entityId);
	}

	override protected function entityMoved_v2 (entityId :String, destination :Array) :void
	{
		if ( true )
			dispatchCtrlEvent(ControlEvent.ENTITY_MOVED, entityId, destination);
	}
	
	
	/*
		Actor Control
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



class GMPopupSurface extends Sprite
{
	public var surface_w = 0;
	public var surface_h = 0;
	
	public function GMPopupSurface()
	{
		super();
		name = "GMPopupSurface";
		focusRect = false;
	}
	
	
}



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
	
	public static const PROP_CHARACTER :String = "gm:character";
	public static const PROP_STATE :String = "gm:state";
	
	
	public var entityID;
	public var memberID
	
	public var media = GMControl.media;
	public var ctrl = GMControl.ctrl;
	
	public var isControl = false;
	public var isMoving = false;
	public var isSleeping = false;
	
	public var type;
	
	public var name;
	
	public var character = "gmcharacter";
	public var state = "default";
	
	public var x = 0;
	public var y = 0;
	public var z = 0;
	public var orient = 0;
	
	public var xsize = 48;
	public var ysize = 128;
	public var zsize = xsize;
	
	public var location = [ 0, 0, 0 ];
	public var destination = [ 0, 0, 0 ];
	
	public function GMRemoteEntity( _entityid )
	{
		var get;
		GM.debugTracker = "GMRemoteEntity";
		this.entityID = _entityid;
		this.memberID = GetProperty( PROP_MEMBER_ID );
		this.name = GetProperty( PROP_NAME );
		this.type = GetProperty( PROP_TYPE );
		GetPosition();
		destination[0] = x;
		destination[1] = y;
		destination[2] = z;
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
		try
		{
			return ctrl.callHostCode( "getEntityProperty_v1", entityID, key ) ;
		}
		catch(e)
		{
			GM.Caught(e);
		}
	}
	
	public function GetPosition()
	{
		GetOrientation();
		var pos = GetProperty( PROP_LOCATION_PIXEL );
		if ( pos == null )
			return;
		
		if ( pos.length >= 3 )
		{
			x = pos[0];
			y = pos[1];
			z = pos[2];
			location[0] = x;
			location[1] = y;
			location[2] = z;
			return true;
		}
	}
	
	public function GetOrientation()
	{
		var orient = GetProperty( PROP_ORIENTATION );
		if ( orient )
			this.orient = orient;
		else
			this.orient = 0;
		return this.orient;
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