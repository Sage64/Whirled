
// GM
// Main engine

package gamemaker
{

import flash.display.*;
import flash.errors.*;
import flash.events.*;
import flash.text.*;
import flash.ui.*;
import flash.utils.*;

import com.whirled.*;
import com.threerings.*;
import com.threerings.util.*;

public class GM
{
	// Debug
	public static var debug = false;
	public static var debug_log = [];
	public static var debugTracker = "";
	public static var hasErrored = false;
	public static var controlPanel;
	
	// Root Level
	public static var isLoaded = false;
	public static var gm;
	public static var root;
	public static var media;
	public static var container;
	public static var stageW = 600;
	public static var stageH = 450;
	public static var scale = 1;
	public static var forceScale = null;
	public static var unscaleX = 1;
	public static var unscaleY = 1;
	
	// Events
	public static var _eventlisteners = {
		list: [],
		func: {}
	 };
	public static var _eventqueue = [];
	
	// Whirled
	public static var ctrl;
	public static var isConnected = false;
	
	// Internal drawing
	public static var internalstageitems = {};
	public static var _tempsymbols = [];
	public static var _tempdrawsprites = [];
	public static var internaldrawalpha = 1;
	public static var internaldrawcolor = 0xFFFFFF;
	public static var internaldrawfont = { name: "_sans", size: 12 };
	public static var internaldrawhalign = 0;
	public static var internaldrawvalign = 0;
	public static var internaldrawtextformat = new TextFormat();
	public static var internalblendmode = BlendMode.NORMAL;
	public static var internalfog = null;
	
	public static var internalspritelist = [];
	public static var internalspritemap = {};
	
	public static var internalsoundlist = [];
	public static var internalsoundmap = {};
	
	
	// Gamemaker
	
	public static var global = {};
	
	public static var instances = [];
	public static var instances_of = {};
	
	
	public static var view_x = 0;
	public static var view_y = 0;
	public static var view_width = stageW;
	public static var view_height = stageH;
	
	// 
	
	public function GM( _media )
	{
		gm = this;
		media = _media;
		
		Init( _media );
	}
	
	public static function GMCleanup()
	{
		var inst;
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
	
	public static function Init( _media )
	{
		Log( "GM Init" );
		GM.media = _media;
		GM.root = _media;
		
		GM.container = new Sprite();
		GM.container.cacheAsBitmap = true;
		
		media.addChild( GM.container );
	}
	
	/*
		EVENT PROCESSING
	*/
	
	// Add an event listener
	public static function AddEventListener( inst, event, func )
	{
		Log( "Listening for " + event );
		// the function to be called by this event
		_eventlisteners.func[event] = func;
		// the func used in the event listener callback
		func = GMEvent;
		_eventlisteners.list.push( [ inst, event, func ] );
		 inst.addEventListener( event, func );
	}
	
	public static function GMEvent( event )
	{
		_eventqueue.push( event );
		Log( "Event: " + event.type );// + ": \"" + event.name + "\", " + event.value );
	}
	
	public static  function GMProcessEvents()
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
	
	/*
		ASSETS
	*/
	
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
			Warn( "Invalid media" );
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
		Log( "AddSprite \"" + sprname + "\" with " + symbol.totalFrames + " frames" );
		if ( internalstageitems[sprname] != null )
		{
			Log( "already exists" );
			return;
		}

		internalstageitems[sprname] = symbol;
		var _bitmap = true; //isBitmap;
		if ( symbol["isBitmap"] == false )
		{
			Log( "isBitmap = false" );
			_bitmap = false;
		}
		if ( _bitmap )
		{
			symbol.cacheAsBitmap = true;
		}
		symbol.visible = false;
		symbol.gotoAndStop( 1 );
		symbol.x = -1024;
		symbol.y = -1024;
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
		Log( "AddSound \"" + sndname + "\"" );
		if ( internalsoundmap[sndname] != null )
		{
			Warn( sndname + " already exists" );
		}
		
		var snd = new GMInternalSound( audio );
		internalsoundlist.push( snd );
		internalsoundmap[sndname] = snd;
		
		global[sndname] = snd;
	}
	
	
	/*
		Debug
	*/
	
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
				// OpenControlPanel();
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
		if ( !ctrl )
			return;
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
	
	/*
		MAIN
		LOOP
	*/
	
	public static function Loop()
	{
		var i;
		debugTracker = "GMControl.Loop";
		try
		{
			if ( !isLoaded && root )
			{
				if ( root.loaderInfo.bytesLoaded < root.loaderInfo.bytesTotal )
				{
					Log( "Loading " + root.loaderInfo.bytesLoaded + " / " + root.loaderInfo.bytesTotal );
				}
				else
				{
					isLoaded = true;
					Log( "Loaded " + root.loaderInfo.bytesTotal + "b" );
				}
			}
			
			GMProcessEvents();
			
			GMStep();
			
			// GMUpdateView();
			
			var transformMatrix = media.transform.concatenatedMatrix;
			unscaleX = ( 1 / transformMatrix.a );
			unscaleY = ( 1 / transformMatrix.d );
			
			// sort by draw depth
			if ( true )
			{
				instances.sort( function( A, B )
				{
					return ( B.depth - A.depth );
				} ) ;
			}
			
			
			while ( _tempdrawsprites.length > 0 )
			{
				var spr = _tempdrawsprites.shift();
				
				spr.x = 0; //( container.width / 2 );
				spr.y = 512; //( container.height );
				spr.scaleX = 1 / 100;
				spr.scaleY = 1 / 100;
				spr.alpha = ( 1 / 100 );
				spr.visible = false;
				// trace( spr.name );
			}
			
			while ( _tempsymbols.length > 0 )
			{
				var sym = _tempsymbols.shift();
				sym.visible = false;
				container.removeChild( sym );
				sym.x = container.x - ( 1024 );
				sym.y = container.y - ( 1024 );
			}
			
			container.graphics.clear();
			//media.graphics.clear();
			
			GMDraw();
		}
		catch (e)
		{
			Caught( e );
		}
		media.gotoAndPlay( 2 );
		//trace( debugTracker );
	}
	
	public static function GMStep()
	{
		debugTracker = "GM.GMStep";
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
		
		if ( GMControl.ctrl )
			GMControl.GMStep();
	}
	
	/*
		DRAW
	*/
	
	public static function GMDraw()
	{
		debugTracker = "GM.GMDraw";
		for ( var i = 0; i < instances.length; ++i )
		{
			var inst = instances[i];
			inst.Draw(); //GMDraw();
		}
		
		if ( GMControl.ctrl )
			GMControl.GMDraw();
	}
	
	/*
		Internal Functions
	*/
	
	// Instances
	
	public static function InternalInstanceCreate( _x, _y, _obj )
	{
		debugTracker = "InternalInstanceCreate";
		Log( "Create instance " + _obj );
		
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
		// Remove
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
		
		var color;
		if ( internalfog )
		{
			color = _symbol.transform.colorTransform;
			color.color = internalfog;
			_symbol.transform.colorTransform = color;
		}
		else
		{
			color = _symbol.transform.colorTransform;
			color.redOffset = 0;
			color.greenOffset = 0;
			color.blueOffset = 0;
			color.redMultiplier = r;
			color.greenMultiplier = g;
			color.blueMultiplier = b;
			color.alphaMultiplier = 1;
			_symbol.transform.colorTransform = color;
		}
		_symbol.blendMode = internalblendmode;
		
		_symbol.gotoAndStop( Math.floor( _image % _symbol.totalFrames ) + 1 );
		_symbol.x = _x;
		_symbol.y = _y;
		_symbol.scaleX = _xscale;
		_symbol.scaleY = _yscale;
		_symbol.rotation = -_angle;
		_symbol.alpha = _alpha;
		_symbol.visible = true;
		return _symbol;
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
		internaldrawcolor = col;
	}
	
	public static function InternalSetAlpha( alpha )
	{
		internaldrawalpha = alpha;
	}
	
	public static function InternalDrawLine( x1, y1, x2, y2, w, a = null )
	{
		var g = container.graphics;
		if ( a == null )
			a = internaldrawalpha;
		g.lineStyle( w, internaldrawcolor, a );
		g.moveTo( x1, y1 );
		g.lineTo( x2, y2 );
	}
	
	public static function InternalDrawRectangle( x1, y1, x2, y2, outline = false )
	{
		var g = container.graphics;
		var a = null;
		if ( a == null )
			a = internaldrawalpha;
		// drawcolor;
		if ( outline )
		{
			InternalDrawLine( x1, y1, x2, y1, a );
			InternalDrawLine( x2, y1, x2, y2, a );
			InternalDrawLine( x2, y2, x1, y2, a );
			InternalDrawLine( x1, y2, x1, y1, a );
		}
		else
		{
			g.beginFill( internaldrawcolor, internaldrawalpha );
			g.drawRect( x1, y1, x2 - x1, y2 - y1 );
		}
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
		_symbol.alpha = internaldrawalpha;
		_symbol.textColor = internaldrawcolor;
		
		if ( internaldrawfont && internaldrawfont != -1 )
		{
			internaldrawtextformat.font = internaldrawfont.font;
			internaldrawtextformat.size = internaldrawfont.size;
		}
		else
		{
			internaldrawtextformat.font = "_sans";
			internaldrawtextformat.size = 12;
		}
		if ( internaldrawhalign == GMObject.fa_center )
			internaldrawtextformat.align = TextFormatAlign.CENTER;
		else if ( internaldrawhalign == GMObject.fa_right )
			internaldrawtextformat.align = TextFormatAlign.RIGHT;
		
		_symbol.text = _text;
		_symbol.setTextFormat( internaldrawtextformat );
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
		// _sound.Stop();
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