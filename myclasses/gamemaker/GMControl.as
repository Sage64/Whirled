
// GM Controller
// by sage [ https://github.com/Sage64/Whirled ]
// Control object for my GMBody base, combines all control types into one

/*
	GMControl is used in place of AvatarControl/PetControl without needing to specify
*/

package gamemaker
{
// 
import flash.display.*;
import flash.errors.*;
import flash.events.*;
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
	
	public static var characterList = [];
	public static var characters = {};
	public static var characterInit = 0;
	
	public static var media;
	public static var container;
	public static var ctrl; // the specific instance of GMControl created for the actor
	public static var body;
	
	public static var entityID;
	public static var isAvatar = false;
	public static var isPet = false;
	public static var isFurni  = false;
	
	// AvatarControl
	protected static var _actions = [];
	protected static var _states = [];
	protected static var _isSleeping;
	
	
	public static var _eventlisteners = {
		list: [],
		func: {}
	 };
	public static var _eventqueue = [];
	
	public static var remoteEntities = {};
	public static var remoteEntitiesList = [];
	
	public static var stageW = 600;
	public static var stageH = 450;
	public static var originX = stageW / 2;
	public static var originY = stageH / 2;
	
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
	
	public static var instances = [];
	public static var instances_of = {};
	
	public static var _tempsymbols = [];
	public static var _tempdrawsprites = [];
	public static var internalstageitems = {};
	public static var internalspritelist = [];
	public static var internalspritemap = {};
	
	public function GMControl( media )
	{
		GMControl.media = media;
		GMControl.container = new Sprite();
		GMControl.container.cacheAsBitmap = true;
		
		GMControl.ctrl = this;
		
		super( media );
		InitWhirled();
		
		GMUpdateView();
	}
	
	public static function GMCleanup()
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
		
		while ( instances.length > 0 )
		{
			var Inst = instances.shift();
			Inst.GMCleanup();
		}
	}
	
	/*
		INIT
	*/
	
	public static function Init( media )
	{
		Log( "GMControl Init" );
		
		GMControl.media = media;
		
		PrepareSymbols( media );
		
		media.addChild( container );
		
		AddEventListener( media, Event.UNLOAD, GMCleanup );
	}
	
	public static function InitWhirled( ww = 600, hh = 450 )
	{
		Log( "GMControl InitWhirled" );
		
		if ( !ctrl.isConnected() )
		{
			// Always run in debug mode if not connected to whirled
			GMControl.Log( "Debug Mode" );
			debug = true;
			// AddEventListener( root, KeyboardEvent.KEY_DOWN, DebugKeyDown );
		}
		
		entityID = ctrl.getMyEntityId();
		Log( "entityID = " + entityID );
		
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
		
		ctrl.setMemory( "GMControl", true );
		
		AddEventListener( ctrl, ControlEvent.ENTITY_ENTERED, GMEntityJoined );
		AddEventListener( ctrl, ControlEvent.ENTITY_LEFT, GMEntityLeft );
		
		AddEventListener( ctrl, ControlEvent.MEMORY_CHANGED, GMMemoryChanged );
		
		// AddEventListener( ctrl, ControlEvent.MESSAGE_RECEIVED, GMReceiveMessage );
		// AddEventListener( ctrl, ControlEvent.SIGNAL_RECEIVED, GMReceiveMessage );
		
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
		GMControl.Log( "Adding character '" + dispname + "' from scene " + scenename );
		
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
	public static function AddBody( dispname, scenename, _body )
	{
		var NewChar = characters[scenename];
		if ( NewChar == null )
			NewChar = AddCharacter( dispname, scenename );
		GMControl.Log( "Adding Body for character '" + dispname + "'" );
		body = _body;
		NewChar.body = _body;
		
		container.addChild( _body );
	}
	
	// Add the symbols within an object as sprites
	public static function PrepareSymbols( media )
	{
		debugTracker = "PrepareSymbols";
		GMControl.Log( "Preparing symbols" );
		if ( !media )
		{
			GMControl.Log( "Invalid media" );
			return;
		}
		
		
		var _symbols = [];
		var Child;
		var i;
		for ( i = 0; i < media.numChildren; ++i )
		{
			Child = media.getChildAt( i );
			if ( Child == container )
				continue;
			_symbols.push( Child );
		}
		for ( i = 0; i < _symbols.length; ++i )
		{
			Child = _symbols[i];
			var sprname = Child.name;
			// sprname = getQualifiedClassName( sprname );
			GMControl.Log( "Found symbol \"" + sprname + "\" with " + Child.totalFrames + " frames" );
			if ( Child )
			{
				internalstageitems[sprname] = Child;
				var _bitmap = isBitmap;
				if ( Child["isBitmap"] == false )
				{
					GMControl.Log( "isBitmap = false" );
					_bitmap = false;
				}
				if ( _bitmap )
				{
					Child.cacheAsBitmap = true;
				}
				Child.visible = false;
				Child.gotoAndStop( 1 );
				Child.x = 0;
				Child.y = 0;
				Child.alpha = 0;
				
				var Parent = Child.parent;
				Parent.removeChild( Child );
				if ( container )
					container.addChild( Child );
				
				Child.gotoAndStop( 1 );
				
				var InternalSprite = new GMInternalSprite( Child );
				internalspritelist.push( InternalSprite );
				
				internalspritemap[sprname] = Child;
				
				continue;
			}
		}
	}
	
	public static function PrepareSymbol( symbol )
	{
		
		
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
	
	private static function GMControlEvent( event )
	{
		GMControl.Log( "Event: " + event.type + ": \"" + event.name + "\", " + event.value );
		_eventqueue.push( event );
	}
	
	private static  function GMProcessEvents()
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
	private static function GMAvatarSpoke( event )
	{ 
		
	}
	private static function GMEntityJoined( event )
	{
		var Entity = GMControl.GetEntity( event.name );
	}
	private static function GMEntityLeft( event )
	{
		var Entity = GMControl.GetEntity( event.name );
	}
	private static function GMGotChat( event )
	{
		var Entity = GMControl.GetEntity( event.name );
		
	}
	
	/*
		DEBUG
	*/
	
	public static function DebugKeyDown( ev )
	{
		
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
		if ( debug_log.length > 50 )
			debug_log.shift();
		
		if ( controlPanel )
			controlPanel.Relayout();
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
		var char = characterList[characterInit];
		if ( characterInit == 0 )
		{
			body = char.body;
		}
		if ( char.body == null )
		{
			Log( "goto scene " + char.scenename );
			media.gotoAndPlay( 1, char.scenename );
		}
		else
			Log( "has body" );
		
		PrepareSymbols( media );
		
		++characterInit;
		if ( characterInit >= characterList.length )
		{
			body = characterList[0].body;
			debugTracker = "Character Init Ready";
			for ( var i = 0; i < media.scenes.length; ++i )
			{
				if ( media.scenes[i].name != "main" )
					continue;
				media.gotoAndPlay( 1, "main" );
				break;
			}
			CharacterInitDone();
		}
	}
	
	public static function CharacterInitDone()
	{
		Log( "CharacterInitDone" );
		// GMControl.media.addChild( container );
		body.Ready();
	}
	
	public static function Loop( event = null )
	{
		debugTracker = "GMControl.Loop";
		try
		{
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
			media.alpha = 0.5;
			Log( "ERROR CAUGHT - please share this with the avatar creator!" );
			Log( "tracker: " + debugTracker );
			Log( e.errorID  );
			Log( e.name  );
			Log( e.message  );
			Log( e.prototype  );
			Log( e.getStackTrace() );
			if ( !hasErrored )
			{
				hasErrored = true;
				OpenControlPanel();
			}
			
			// media.transform.colorTransform.redMultiplier = 1.25;
			// media.transform.colorTransform.greenMultiplier = 0.5;
			// media.transform.colorTransform.blueMultiplier = 0.5;
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
			inst.GMDraw();
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
		
		if ( true )
		{
			container.x = baseXOffset;
			container.y = baseYOffset;
			
			media.x -= container.x * _scale;
			media.y -= container.y * _scale;
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
		Log( "Got memory '" + event.name + "' = '" + event.value + "'" );
		OnMemoryGot( event.name, event.value );
	}
	
	public static function OnMemoryGot( key, value )
	{
		
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
		Log( "Registering actions: " + _actions );
	}
	
	public function registerStates( ... states )
	{
		states = Util.unfuckVarargs( states );
		ctrl.verifyActionsOrStates( states, false );
		_states = states;
		Log( "Registering states: " + _states );
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
		var Inst = new _obj();
		Inst.x = _x;
		Inst.y = _y;
		Inst.xstart = _x;
		Inst.ystart = _y;
		
		container.addChild( Inst );
		
		instances.push( Inst );
		
		return Inst;
	}
	
	
	public static function InternalInstanceDestroy( _inst )
	{
		// Remove from GMControl
		var pos = instances.indexOf( _inst );
		if ( pos < 0 )
			return;
		instances.splice( pos, 1 );
		_inst.Cleanup();
		// Remove from container
		pos = container.getChildIndex( _inst )
		if ( pos < 0 )
			return;
		container.removeChild( _inst );
	}
	
	// Sprites
	
	public static function InternalSpriteDraw( _sprite, _image, _x, _y, _xscale, _yscale, _angle, _blend, _alpha )
	{
		if ( !_sprite )
			return;
		//trace( "draw " + _sprite.name + "[" + _image + "] at " + _x + ", " + _y );
		// real bitmap cached drawing not implemented yet
		// currently just moves symbols into place and hides them next frame
		
		if ( _sprite.constructor != MovieClip && _sprite.visible )
		{
			_sprite = new _sprite.constructor();
			container.addChild( _sprite );
			_tempsymbols.push( _sprite );
		}
		else
		{
			_tempdrawsprites.push( _sprite );
			var pos = container.numChildren;
			container.setChildIndex( _sprite, pos - 1 );
		}
		
		_sprite.gotoAndStop( Math.floor( _image % _sprite.totalFrames ) + 1 );
		_sprite.x = _x;
		_sprite.y = _y;
		_sprite.scaleX = _xscale;
		_sprite.scaleY = _yscale;
		_sprite.rotation = _angle;
		_sprite.alpha = _alpha;
		_sprite.visible = true;
	}
	
	public static function InternalSpriteGet( sprname )
	{
		return internalspritemap[ sprname ];
	}
	
}
}

import gamemaker.*;

import flash.display.*;

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
	
	public var isBitmap = true;
	
	public function GMInternalSprite( _symbol = null )
	{
		symbol = _symbol;
		
	}
	
	public function GetImage( _image )
	{
		return images[ Math.floor( _image % count ) ];
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