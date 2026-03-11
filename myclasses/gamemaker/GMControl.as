
// GM Controller
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
import flash.utils.*;

import com.whirled.*;
import com.threerings.*;

import com.threerings.util.*;

public class GMControl extends ActorControl
{
	public static var debug = false;
	public static var debug_log = [];
	public static var logAddedTime = 0;
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
	public static var baseXOffset = 1<<15;
	public static var baseYOffset = 1<<15;
	
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
	
	
	// Gamemaker stuff 
	public static var global = {};
	public static var instances = [];
	public static var instances_of = {};
	
	public static var drawcolor = 0xFFFFFF;
	public static var drawalpha = 1;
	public static var drawfont = { name: "_sans", size: 12 };
	public static var drawhalign = 0;
	public static var drawvalign = 0;
	public static var drawtextformat = new TextFormat();
	
	public function GMControl( media )
	{
		AddEventListener( media, Event.UNLOAD, GMCleanup );
		
		GMControl.media = media;
		GMControl.container = new Sprite();
		GMControl.container.cacheAsBitmap = true;
		
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
		// 
		while ( instances.length > 0 )
		{
			inst = instances.shift();
			inst.GMCleanup();
		}
		while ( internalspritelist.length > 0 )
		{
			inst = internalspritelist.shift();
			inst.Cleanup();
		}
		while ( internalsoundlist.length > 0 )
		{
			inst = internalsoundlist.shift();
			inst.Cleanup();
		}
	}
	
	/*
		INIT
	*/
	
	public static function Init( media )
	{
		Log( "GMControl Init" );
		
		GMControl.media = media;
		GMControl.root = media.root;
		
		//PrepareSymbols( media );
		
		media.addChild( container );
	}
	
	public static function InitWhirled( ww = 600, hh = 450 )
	{
		Log( "GMControl InitWhirled" );
		
		if ( !ctrl.isConnected() )
		{
			// Always run in debug mode if not connected to whirled
			GMControl.Log( "Debug Mode" );
			debug = true;
			GMGotControl();
			// AddEventListener( root, KeyboardEvent.KEY_DOWN, DebugKeyDown );
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
		
		Init( media );
		
		if ( debug )
			OpenControlPanel();
		
	}
	
	// Add a character that from its scene
	public static function AddCharacter( dispname, scenename )
	{
		if ( characters[scenename] != null )
		{
			GMControl.Log( "Character " + scenename + " already exists" );
			return;
		}
		GMControl.Log( "Adding character " + scenename +  " (" + dispname + ")" );
		
		var NewChar = {};
		characters[scenename] = NewChar;
		characterList.push( NewChar );
		characters[scenename] = NewChar;
		
		NewChar.name = dispname;
		NewChar.scenename = scenename;
		NewChar.body = null;
		
		return NewChar;
	}
	
	// Add a Body class
	public static function AddBody( dispname, scenename, bodyclass )
	{
		var NewChar = characters[scenename];
		if ( NewChar == null )
			NewChar = AddCharacter( dispname, scenename );
		GMControl.Log( "Adding Body for character '" + dispname + "'" );
		body = new bodyclass();
		NewChar.body = body;
		
		container.addChild( body );
	}
	
	public static function AddSprites( spriteclass )
	{
		var spr = new spriteclass();
		PrepareSymbols( spr );
	}
	
	// Add the symbols within an object as sprites
	public static function PrepareSymbols( media )
	{
		debugTracker = "PrepareSymbols";
		//GMControl.Log( "Preparing symbols" );
		if ( !media )
		{
			GMControl.Warn( "Invalid media" );
			return;
		}
		var _symbols = [];
		var Child;
		var i;
		// GMControl.Log( media.numChildren + " symbols" );
		for ( i = 0; i < media.numChildren; ++i )
		{
			Child = media.getChildAt( i );
			if ( Child == container )
				continue;
			_symbols.push( Child );
		}
		for ( i = 0; i < _symbols.length; ++i )
		{
			AddSprite_Symbol( _symbols[i] );
		}
	}
	
	// Add a sprite from a MovieClip symbol
	public static function AddSprite_Symbol( symbol )
	{
		var sprname = symbol.name;
		GMControl.Log( "AddSprite \"" + sprname + "\" with " + symbol.totalFrames + " frames" );
		if ( internalstageitems[sprname] != null )
		{
			GMControl.Log( "already exists" );
			return;
		}

		internalstageitems[sprname] = symbol;
		var _bitmap = isBitmap;
		if ( symbol["isBitmap"] == false )
		{
			GMControl.Log( "isBitmap = false" );
			_bitmap = false;
		}
		if ( _bitmap )
		{
			symbol.cacheAsBitmap = true;
		}
		symbol.visible = false;
		symbol.gotoAndStop( 1 );
		symbol.x = 0;
		symbol.y = 0;
		symbol.alpha = 0;

		var spr = new GMInternalSprite( symbol );
		internalspritelist.push( spr );
		internalspritemap[sprname] = spr;
		
		global[sprname] = spr;
		
		var Parent = symbol.parent;
		Parent.removeChild( symbol );
		if ( container )
			container.addChild( symbol );

		symbol.gotoAndStop( 1 );
	}
	
	// Add a sound via its class
	public static function AddSound( audio )
	{
		var sndname = getQualifiedClassName( audio );
		GMControl.Log( "AddSound \"" + sndname + "\"" );
		if ( internalsoundmap[sndname] != null )
		{
			GMControl.Warn( sndname + " already exists" );
		}
		
		var snd = new GMInternalSound( audio );
		internalsoundlist.push( snd );
		internalsoundmap[sndname] = snd;
		
		global[sndname] = snd;
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
		GMControl.Log( "Event: " + event.type + ": \"" + event.name + "\", " + event.value );
		_eventqueue.push( event );
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
		
	}
	
	public static function Caught( e )
	{
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
		var _time = new Date();
		
		var hh = String( _time.getHours() );
		if ( hh.length < 2 )
			hh = "0" + hh;
		var mm = String( _time.getMinutes() );
		if ( mm.length < 2 )
			mm = "0" + mm;
		var ss = String( _time.getSeconds() );
		if ( ss.length < 2 )
			ss = "0" + ss;
		
		text = "[" + hh + ":" + mm + ":" + ss +  "]" + String( text );
		trace( "Log: " + text );
		debug_log.push( text );
		if ( debug_log.length > 64 )
			debug_log.shift();
		
		if ( controlPanel )
			controlPanel.Relayout();
	}
	
	public static function Warn( text )
	{
		Log( "WARNING at " + debugTracker + ": " + text );
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
		// PrepareSymbols( media );
		
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
		debugTracker = "GMControl.Loop";
		try
		{
			if ( !isLoaded && root )
			{
				if ( root.loaderInfo.bytesLoaded < root.loaderInfo.bytesTotal )
				{}
				else
				{
					GMControl.isLoaded = true;
					GMControl.Log( "Loaded " + root.loaderInfo.bytesTotal + "b" );
				}
			}
			
			if ( true && characterInit < characterList.length )
			{
				CharacterInitStep();
				media.gotoAndPlay( 2 );
				return;
			}
			
			GMProcessEvents();
			
			GMStep();
			
			// GMUpdateView();
			
			var transformMatrix = media.transform.concatenatedMatrix;
			unscaleX = 1 / transformMatrix.a;
			unscaleY = 1 / transformMatrix.d;
			
			// sort by draw depth
			if ( true )
			{
				instances.sort( function( A, B )
				{
					return ( B.depth - A.depth );
				} ) ;
			}
			
			var i = 0;
			while ( _tempdrawsprites.length > 0 )
			{
				var spr = _tempdrawsprites.shift();
				spr.visible = false;
				spr.x = -(1 << 15);
				spr.y = -(1 << 15);
			}
			
			while ( _tempsymbols.length > 0 )
			{
				var sym = _tempsymbols.shift();
				sym.visible = false;
				container.removeChild( sym );
				sym.x = -( 1 << 15 );
				sym.y = -( 1 << 15 );
			}
			
			container.graphics.clear();
			media.graphics.clear();
			
			
			GMDraw();
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
		var i = 0;
		
		if ( controlPanel )
			controlPanel.Step();
		
		for ( i = instances.length - 1; i >= 0; --i )
		{
			var inst = instances[i];
			inst.GMStep();
			if ( i >= instances.length )
				i = instances.length;
		}
		
		if ( body )
			body.GMStep();
	}
	
	public static function GMDraw()
	{
		for ( var i = 0; i < instances.length; ++i )
		{
			var inst = instances[i];
			inst.Draw(); //GMDraw();
		}
		
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
		
		if ( isLoaded )
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
			_state = ( false && _states.length > 0 ) ? _states[0] : "default";
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
	
	
	// Instances
	
	public static function InternalInstanceCreate( _x, _y, _obj )
	{
		debugTracker = "InternalInstanceCreate";
		//GMControl.Log( "Create instance " + _obj );
		
		if ( !_obj )
			return;
		GMObject._createx = _x;
		GMObject._createy = _y;
		var Inst = new _obj();
		if ( true )
			debugTracker += " - " + _obj;
		
		container.addChild( Inst );
		instances.push( Inst );
		
		Inst.Create();
		
		return Inst;
	}
	
	
	public static function InternalInstanceDestroy( _inst )
	{
		if ( !_inst )
			return;
		// Remove from GMControl
		var pos = instances.indexOf( _inst );
		if ( pos < 0 )
			return;
		instances.splice( pos, 1 );
		_inst.Cleanup();
		_inst.exists = false;
		// Remove from container
		pos = container.getChildIndex( _inst )
		if ( pos < 0 )
			return;
		container.removeChild( _inst );
	}
	
	// Sprites
	
	public static function InternalSpriteDraw( _sprite, _image, _x, _y, _xscale = 1, _yscale = 1, _angle = 0, _blend = 0xFFFFFF, _alpha = 1 )
	{
		if ( !_sprite || ( _sprite == -1 ) )
			return;
		//trace( "draw " + _sprite.name + "[" + _image + "] at " + _x + ", " + _y );
		// real bitmap cached drawing not implemented yet
		// currently just moves symbols into place and hides them next frame
		
		var _symbol = _sprite.GetImage( _image );
		if ( !_symbol )
			return;
		if ( _symbol.constructor != MovieClip && _symbol.visible )
		{
			_symbol = new _symbol.constructor();
			container.addChild( _symbol );
			_tempsymbols.push( _symbol );
		}
		else
		{
			_tempdrawsprites.push( _symbol );
			var pos = container.numChildren;
			container.setChildIndex( _symbol, pos - 1 );
		}
		
		var r = ( ( _blend >> 16 ) & 0xFF ) / 255;
		var g = ( ( _blend >> 8 ) & 0xFF ) / 255;
		var b = ( ( _blend ) & 0xFF ) / 255;
		
		var color = _symbol.transform.colorTransform;
		color.redMultiplier = r;
		color.greenMultiplier = g;
		color.blueMultiplier = b;
		color.alphaMultiplier = 1;
		_symbol.transform.colorTransform = color;
		
		_symbol.gotoAndStop( Math.floor( _image % _symbol.totalFrames ) + 1 );
		_symbol.x = _x;
		_symbol.y = _y;
		_symbol.scaleX = _xscale;
		_symbol.scaleY = _yscale;
		_symbol.rotation = -_angle;
		_symbol.alpha = _alpha;
		_symbol.visible = true;
	}
	
	public static function InternalSpriteGet( sprname )
	{
		var spr;
		if ( typeof sprname == "string" )
			spr = internalspritemap[ sprname ];
		else
			spr = internalspritemap[ sprname.name ];
		if ( spr == null )
			return -1;
		return spr;
	}
	
	// Drawing
	
	public static function InternalSetColor( col )
	{
		drawcolor = col;
	}
	
	public static function InternalSetAlpha( alpha )
	{
		drawalpha = alpha;
	}
	
	public static function InternalDrawLine( x1, y1, x2, y2, w, a = null )
	{
		var g = container.graphics;
		if ( a == null )
			a = drawalpha;
		g.lineStyle( w, drawcolor, a );
		g.moveTo( x1, y1 );
		g.lineTo( x2, y2 );
	}
	
	public static function InternalTextDraw( _x, _y, _text, _xscale = 1, _yscale = 1, _angle = 0 )
	{
		var _symbol = new TextField();
		container.addChild( _symbol );
		_tempsymbols.push( _symbol );
		_symbol.x = _x;
		_symbol.y = _y;
		_symbol.scaleX = _xscale;
		_symbol.scaleY = _yscale;
		_symbol.alpha = drawalpha;
		_symbol.textColor = drawcolor;
		
		if ( drawfont && drawfont != -1 )
		{
			drawtextformat.font = drawfont.font;
			drawtextformat.size = drawfont.size;
		}
		else
		{
			drawtextformat.font = "_sans";
			drawtextformat.size = 12;
		}
		if ( drawhalign == GMObject.fa_center )
			drawtextformat.align = TextFormatAlign.CENTER;
		else if ( drawhalign == GMObject.fa_right )
			drawtextformat.align = TextFormatAlign.RIGHT;
		
		_symbol.text = _text;
		_symbol.setTextFormat( drawtextformat );
	}
	
	// Sound
	
	public static function InternalAudioPlay( _sound, _priority, _loop, _gain, _offset, _pitch )
	{
		if ( _sound == null || _sound == -1 )
			return null;
		var aud = _sound.Play( _offset, _loop, _gain  );
		return aud;
	}
	
	public static function InternalAudioStop( _sound )
	{
		if ( _sound == null || _sound == -1 )
			return null;
		_sound.Stop();
	}
}
}

import gamemaker.*;

import flash.display.*;
import flash.media.*;

import com.threerings.*;
import com.whirled.*;

// sprite data automatically generated
// from symbols in the scene when the body is created
// 
class GMInternalSprite
{
	public var symbol;
	public var name = "sprite";
	public var count = 0;
	public var images = [];
	public var x = 0;
	public var y = 0;
	public var width = 0;
	public var height = 0;
	public var bounds;
	
	public var isBitmap = true;
	
	public function GMInternalSprite( _symbol = null, _isbitmap = true )
	{
		symbol = _symbol;
		isBitmap = _isbitmap;
		// 
		
		symbol.x = 0;
		symbol.y = 0;
		symbol.scaleX = 1; // 5;
		symbol.scaleY = 1; // 5;
		
		var transformMatrix = symbol.transform.concatenatedMatrix;
		symbol.scaleX = Math.min( transformMatrix.a, 1 / transformMatrix.a );
		symbol.scaleY = Math.min( transformMatrix.d, 1 / transformMatrix.d );
		
		var getshape = symbol.getChildAt( 0 ) as Shape;
		
		bounds = symbol.transform.pixelBounds;
		
		name = symbol.name;
		width = symbol.width;
		height = symbol.height;
		
		x = -bounds.x;
		y = -bounds.y;
		width = bounds.width;
		height = bounds.height;
		
		var data = getshape.graphics;
		//trace( data );
		
		for ( var i = 0; i < symbol.totalFrames; ++i )
		{
			images[i] = {};
			images[i].sprite = symbol;
			++count;
		}
	}
	
	public function Cleanup()
	{
		while ( images.length > 0 )
		{
			var img = images.pop();
			if ( img == null )
				continue;
			img.bitmap_data.dispose();
		}
	}
	
	public function GetImage( index )
	{
		return symbol;
		var _image = images[ Math.floor( index ) % count ];
		if ( !_image )
			return;
		return _image.sprite;
	}
	
}

class GMInternalSound
{
	public var audio;
	public var sound;
	
	public function GMInternalSound( _audio )
	{
		audio = _audio;
		sound = new audio();
	}
	
	public function Play( _offset = 0, _loop = false, _gain = 1 )
	{
		var chan = sound.play( _offset, _loop, new SoundTransform( _gain ) );
		return chan;
	}
	
	public function Stop()
	{
		sound.close();
		sound = new audio();
	}
}


// Another entity that it is in the room
// 
class GMRemoteEntity
{
	public var entityID;
	
	public var isControl;
	public var isMoving;
	public var isSleeping;
	
	public function GMRemoteEntity( _entityid )
	{
		GMControl.Log( "new GMRemoteEntity( " + _entityid + " );" );
		this.entityID = _entityid;
	}
	
	
	
	public function IsSleeping()
	{
		
	}
	
}