// GM
// Main engine

package gamemaker
{

import flash.display.*;
import flash.errors.*;
import flash.events.*;
import flash.geom.*;
import flash.text.*;
import flash.ui.*;
import flash.utils.*;

import com.whirled.*;
import com.threerings.*;
import com.threerings.util.*;

public class GM extends EventDispatcher
{
	public static const LOG_ENTRY = "gm:logEntry";
	
	// Debug
	public static var debug = false;
	public static var debug_log = [];
	public static var debugTracker = "";
	public static var hasErrored = false;
	public static var controlPanel;
	public static var errorsCaught = 0;
	
	// Root Level
	public static var isLoaded = false;
	public static var gm;
	public static var root;
	
	public static var media;
	public static var stage;
	
	public static var container; // primary surface
	public static var overlay; // "HUD" surface ranging from 0,0 at the top-left to stageW/H at the bottom right
	
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
	public static var internalstageitems = { };
	public static var _tempsymbols = [];
	public static var _tempdrawsprites = [];
	public static var internaldrawmatrix = new Matrix();
	public static var internaldrawfont = { name: "_sans", size: 12 };
	public static var internaldrawhalign = 0;
	public static var internaldrawvalign = 0;
	public static var internaldrawtextformat = new TextFormat();
	public static var internalspritelist = [];
	public static var internalspritemap = { };
	public static var internalsoundlist = [];
	public static var internalsoundmap = { };
	
	
	public static var internalrendertarget;
	public static var internalrenderstack = [];
	public static var graphics; // current graphics target
	
	// Gamemaker
	public static var g_BlendMode = BlendMode.NORMAL;
	public static var g_GlobalAlpha = 1.0;
	public static var g_GlobalColor = 0x000000;
	public static var g_GlobalFog = [ 0, 0, 0, 0 ];
	
	public static var g_GlobalColorTransform = new ColorTransform();
	
	public static var g_Matrix = new Matrix();
	
	public static var g_pIOManager = GMIOManager;
	public static var g_KeyDown = new Array( 256 );
	public static var g_KeyPressed = new Array( 256 );
	public static var g_KeyUp = new Array( 256 );
	
	//public static var g_pInstanceManager = new GMInstanceManager();
	
	// Globals
	
	
	public static var global = {};
	
	public static var instances = [];
	public static var instance_index = 0;
	public static var instances_of = {};
	
	
	public static var view_width = stageW;
	public static var view_height = stageH;
	public static var view_x = 0;
	public static var view_y = 0;
	
	public function GM( _media, _width = null, _height = null )
	{
		debugTracker = "new GM()";
		gm = this;
		media = _media;
		
		Init( _media, _width, _height );
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
	
	public static function Init( _media, _width = null, _height = null )
	{
		debugTracker = "GM.Init";
		Log( "GM Init" );
		GM.media = _media;
		GM.root = _media;
		GM.stage = _media.stage;
		
		if ( _width != null )
			stageW = _width;
		if ( _height != null )
			stageH = _height;
		
		// media.cacheAsBitmap = false;
		
		container = new Sprite();
		container.cacheAsBitmap = false;
		InternalSetDrawTarget( container );
		
		overlay = new Sprite();
		overlay.cacheAsBitmap = false;
		
		media.addChild( GM.container );
		media.addChild( GM.overlay );
		
		if ( !GM.gm )
			GM.gm = true;
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
		GM.debugTracker = "GM.GMProcessEvents";
		for ( var i = 0; i < _eventqueue.length; ++i )
		{
			var event = _eventqueue.shift();
			GM.debugTracker = "GM.GMProcessEvents (event)";
			var func = _eventlisteners.func[event.type];
			if ( !func )
				continue;
			try
			{
				debugTracker = "GM.GMProcessEvents - " + func.toString();
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
		GMControl.Log( "Adding sprites from " + media.constructor );
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
		// Log( "AddSprite \"" + sprname + "\" with " + symbol.totalFrames + " frames" );
		if ( internalstageitems[sprname] != null )
		{
			// Log( "already exists" );
			return;
		}

		internalstageitems[sprname] = 0; //symbol;
		var _bitmap = true; //isBitmap;
		if ( _bitmap )
		{
			symbol.cacheAsBitmap = true;
		}
		symbol.visible = false;
		// symbol.gotoAndStop( 1 );
		// symbol.x = -1024;
		// symbol.y = -1024;
		// symbol.alpha = 0;

		var spr = new GMSprite();
		spr.CreateFromSymbol( symbol );
		
		internalspritelist.push( spr );
		internalspritemap[sprname] = spr;
		global[sprname] = spr;
		
		var Parent = symbol.parent;
		if ( Parent )
		{
			Parent.removeChild( symbol );
		}
	}
	
	public static function AddSprite_Bitmap( sprname, _x, _y, frames )
	{
		var spr = internalspritemap[sprname];
		if ( spr )
		{
			GM.Log( "Sprite " + sprname + " already exists!" );
			return spr;
		}
		spr = new GMSprite();
		spr.name = sprname;
		spr.x = _x;
		spr.y = _y;
		
		trace( "adding sprite " + spr.name );
		
		spr.CreateFromBitmap( frames, true );
		
		internalspritelist.push( spr );
		internalspritemap[sprname] = spr;
		global[sprname] = spr;
		
		return spr;
	}
	
	// Add a sprite by copying another one
	public static function AddSprite_Sprite( sprname, source )
	{
		GM.debugTracker = "AddSprite_Sprite";
		var spr = internalspritemap[sprname];
		if ( spr )
		{
			GM.Log( "Sprite " + sprname + " already exists!" );
			return spr;
		}
		if ( !source )
		{
			GM.Log( "AddSprite_Sprite: no source sprite" );
			return;
		}
		
		spr = new GMSprite();
		spr.name = sprname;
		spr.x = source.x;
		spr.y = source.y;
		
		var frames = [];
		for ( var i = 0; i < source.count; ++i )
		{
			frames[i] = {};
			var _frame = source.images[i];
			var bitmapdata = _frame.bitmapdata.clone();
			frames[i].bitmapData = bitmapdata;
		}
		
		spr.CreateFromBitmap( frames );
		
		internalspritelist.push( spr );
		internalspritemap[sprname] = spr;
		global[sprname] = spr;
		
		return spr;
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
		
		var snd = new GMSound( audio );
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
			Log( "*************************************************************" );
			Log( "ERRORS CAUGHT ( " + ++GM.errorsCaught + " ) - please share this with the creator!" );
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
		if ( debug_log.length > 80 )
			debug_log.shift();
		
		
		// var ev = new GMEvent( GM.LOG_ENTRY, text );
		// dispatchEvent( ev );
		
		if ( controlPanel )
			controlPanel.Relayout();
	}
	
	public static function Warn( text )
	{
		Log( "WARNING at " + debugTracker + ": " + text );
	}
	
	public static function GetControlPanel( ww = null, hh = null )
	{
		var env;
		if ( ctrl )
			env = ctrl.getEnvironment();
		if ( ww == null )
			ww = ( env == "shop" ) ? 320 : 690;
		if ( hh == null )
			hh = ( env == "shop" ) ? 240 : 470;
		if ( !controlPanel )
			controlPanel = new GMControlPanel( ww, hh );
		controlPanel.SetSize( ww, hh );
		return controlPanel;
	}
	
	/*
		Input
	*/
	
	public static function GMKeyboardDown( ev )
	{
		return g_pIOManager.GMKeyboardDown( ev );
	}
	
	public static function GMKeyboardUp( ev )
	{
		return g_pIOManager.GMKeyboardUp( ev );
	}
	
	public static function GMClicked( ev )
	{
		
	}
	
	public static function GMMouseDown( ev )
	{
		return g_pIOManager.GMMouseDown( ev );
	}
	
	public static function GMMouseUp( ev )
	{
		return g_pIOManager.GMMouseUp( ev );
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
			
			var transformMatrix = container.transform.concatenatedMatrix;
			unscaleX = ( 1 / transformMatrix.a );
			unscaleY = ( 1 / transformMatrix.d );
			
			// sort instances by draw depth
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
				sym.parent.removeChild( sym );
				sym.x = container.x - ( 1024 );
				sym.y = container.y - ( 1024 );
			}
			
			
			container.graphics.clear();
			overlay.graphics.clear();
			
			container.blendMode = BlendMode.NORMAL;
			
			internalrendertarget = container;
			
			GMDraw();
		}
		catch (e)
		{
			Caught( e );
		}
		media.gotoAndPlay( 2 );
		GM.debugTracker = "After GM.Loop";
	}
	
	public static function GMStep()
	{
		debugTracker = "GM.GMStep";
		var i = 0;
		
		if ( controlPanel )
			controlPanel.Step();
		
		g_pIOManager.StartStep();
		
		
		for ( instance_index = instances.length - 1; instance_index >= 0; --instance_index )
		{
			var inst = instances[instance_index];
			try
			{
				inst.GMStep();
			}
			catch(e)
			{
				Caught(e);
			}
		}
		
		if ( GMControl.ctrl )
			GMControl.GMStep();
	}
	
	/*
		DRAW
	*/
	
	public static function GMDraw()
	{
		if ( internalrenderstack.length > 0 )
			internalrenderstack = [];
		GMObject.surface_set_target( container );
		debugTracker = "GM.GMDraw Instances";
		
		for ( instance_index = 0; instance_index < instances.length; ++instance_index )
		{
			var inst = instances[instance_index];
			debugTracker = "GM.GMDraw - " + inst.name; 
			try
			{
				if ( !inst.visible )
					continue;
				inst.Draw(); //GMDraw();
			}
			catch(e)
			{
				Caught(e);
			}
		}
		GMObject.surface_reset_target();
		
		if ( GMControl.ctrl )
			GMControl.GMDraw();
		
		if ( false && errorsCaught > 0 )
		{
			GMObject.surface_set_target( overlay );
			
			GMObject.surface_reset_target();
		}
	}
	
	/*
		Internal Functions
	*/
	
	
	
	
	
	
	// yyGraphics 
	
	public static function Graphics_GetBlendedBitmap( _bmd, _col, _alpha = null )
	{
		var _newbmd, _r, _g, _b;
		if ( g_GlobalFog[0] )
		{
			_col = g_GlobalFog[1];
			_alpha = Math.floor( _alpha * 128 ) / 128;
			if ( !_newbmd )
			{
				_r = ( ( _col >> 16 ) & 0xFF ); // 255;
				_g = ( ( _col >> 8 ) & 0xFF ); // 255;
				_b = ( ( _col ) & 0xFF ); // 255;
				_newbmd = _bmd.clone();
				_newbmd.colorTransform( _bmd.rect, new ColorTransform( 0, 0, 0, _alpha, _r, _g, _b ) );
			}
			_bmd = _newbmd;
		}
		else if ( ( _col != 0xFFFFFF ) || ( _alpha < 1 ) )
		{
			_alpha = Math.floor( _alpha * 128 ) / 128;
			if ( !_newbmd )
			{
				_r = ( ( _col >> 16 ) & 0xFF ) / 255;
				_g = ( ( _col >> 8 ) & 0xFF ) / 255;
				_b = ( ( _col ) & 0xFF ) / 255;
				_newbmd = _bmd.clone();
				_newbmd.colorTransform( _bmd.rect, new ColorTransform( _r, _g, _b, _alpha ) );
			}
			_bmd = _newbmd;
		}
		return _bmd;
	}
	
	public static function Graphics_DrawPart( _img, _left, _top, _width, _height, _x, _y, _xscale, _yscale, _col, _alpha )
	{
		var _bmd = _img.bitmapdata;
		if ( !_bmd )
			return;
		
		var _off;
		if ( _left < _img.x )
		{
			_off = _img.x - _left;
			_x += ( _off * _xscale );
			_width -= _off;
			_left = 0;
		}
		else
			_left -= _img.x;
		if ( _top < _img.y )
		{
			_off = _img.y - _top;
			_y += ( _off * _yscale );
			_height -= _off;
			_top = 0;
		}
		else
			_top -= _img.y;
		_width = Math.min( _width, _img.w - _left );
		_height = Math.min( _height, _img.h - _top );
		if ( _width <= 0 || _height <= 0 )
			return;
		
		_col &= 0xFFFFFF;
		_bmd = Graphics_GetBlendedBitmap( _bmd, _col, _alpha );
		
		var _w = ( _width * _xscale );
		var _h = ( _height * _yscale );
		g_Matrix.identity();
		g_Matrix.scale( _xscale, _yscale );
		g_Matrix.tx = _x - ( _left * _xscale );
		g_Matrix.ty = _y - ( _top * _yscale );
		graphics.beginBitmapFill( _bmd, g_Matrix, false, false );
		graphics.drawRect( _x, _y, _w, _h );
		graphics.endFill();
	}
	
	
	public static function Graphics_TextureDraw( _bmd, _xoff, _yoff, _x, _y, _xscale, _yscale, _ang, _col, _alpha )
	{
		//var _bmd = _frame.bitmapdata;
		if ( !_bmd )
			return;
		_col &= 0xFFFFFF;
		if ( ( Math.abs( _xscale ) <= 0.0001 ) || ( Math.abs( _yscale ) <= 0.0001 ) || ( _alpha <= 0.004 ) )
			return;
		
		_bmd = Graphics_GetBlendedBitmap( _bmd, _col, _alpha );
		
		var ox = 0 - _xoff;
		var oy = 0 - _yoff;
		
		// var r = Math.abs( _ang );
		var hasrot = ( Math.abs( _ang ) > 0.0001 );
		var hasscale = ( ( _xscale != 1 ) || ( _yscale != 1 ) );
		// hasrot = true;
		if ( hasrot )
		{
			var _torad = ( Math.PI / 180 );
			var _angh = -_ang * ( _torad );
			var _angv = ( -_ang + 90 ) * ( _torad );
			
			var ww;
			var hh;
			ww = _bmd.width * _xscale;
			hh = _bmd.height * _yscale;
			
			var xinc_w = ww;
			var yinc_w = 0;
			var xinc_h = 0;
			var yinc_h = hh;
			
			if ( true )
			{
				xinc_w = Math.cos( _angh ) * ww;
				yinc_w = Math.sin( _angh ) * ww;
				xinc_h = Math.cos( _angv ) * hh;
				yinc_h = Math.sin( _angv ) * hh;
			}
			
			var _x1 = _x;
			var _y1 = _y;
			
			_x1 += Math.cos(_angh ) * ox * _xscale;
			_y1 += Math.sin( _angh ) * ox * _xscale;
			_x1 += Math.cos(_angv ) * oy * _yscale;
			_y1 += Math.sin( _angv ) * oy * _yscale;
			
			var _x2 = _x1 + xinc_w;
			var _y2 = _y1 + yinc_w;
			
			var _x3 = _x2 + xinc_h;
			var _y3 = _y2 + yinc_h;
			
			var _x4 = _x1 + xinc_h;
			var _y4 = _y1 + yinc_h;
			
			
			Graphics_TextureDrawPos( _bmd, _x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4, _alpha );
		}
		else if ( hasscale )
		{
			// scale draw
			g_Matrix.identity();
			g_Matrix.scale( _xscale, _yscale );
			g_Matrix.tx = _x + ( ox * _xscale );
			g_Matrix.ty = _y + ( oy * _yscale );
			graphics.beginBitmapFill( _bmd, g_Matrix, false, false );
			graphics.drawRect( _x + ( ox * _xscale ), _y + ( oy * _yscale ), _bmd.width * _xscale, _bmd.height * _yscale );
			graphics.endFill();
		}
		else
		{
			// simple draw;
			g_Matrix.identity();
			g_Matrix.tx = _x + ( ox );
			g_Matrix.ty = _y + ( oy );
			graphics.beginBitmapFill( _bmd, g_Matrix, false, false );
			graphics.drawRect( _x + ( ox ), _y + ( oy ), _bmd.width, _bmd.height );
			graphics.endFill();
		}
	}
	
	public static function Graphics_TextureDrawSimple( _bmd, _x, _y, _alpha )
	{
		if ( !_bmd )
			return;
		if ( _alpha <= 0.004 )
			return;
		_x += 0;
		_y += 0;
		g_Matrix.identity();
		g_Matrix.tx = _x;
		g_Matrix.ty = _y;
		graphics.beginBitmapFill( _bmd, g_Matrix, false, false );
		
		graphics.endFill();
	}
	
	public static var TextureDrawPos_vertices = new <Number>[ 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5 ];
	public static var TextureDrawPos_indices = new <int>[ 0, 1, 2, 3, 4, 5 ];
	public static var TextureDrawPos_uvtData = new <Number>[ 0, 0,  1, 0,  1, 1,  1, 1,  0, 1,  0, 0 ];
	public static function Graphics_TextureDrawPos( _bmd, _x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4, _alpha )
	{
		var texelW = 1 / _bmd.width;
		var texelH = 1 / _bmd.height;
		
		g_Matrix.identity();
		graphics.beginBitmapFill( _bmd, null, false, false );
		//graphics.beginFill( 0xFF00FF, 1 );
		TextureDrawPos_vertices[0] = _x1;
		TextureDrawPos_vertices[1] = _y1;
		TextureDrawPos_vertices[2] = _x2;
		TextureDrawPos_vertices[3] = _y2;
		TextureDrawPos_vertices[4] = _x3;
		TextureDrawPos_vertices[5] = _y3;
		TextureDrawPos_vertices[6] = _x3;
		TextureDrawPos_vertices[7] = _y3;
		TextureDrawPos_vertices[8] = _x4;
		TextureDrawPos_vertices[9] = _y4;
		TextureDrawPos_vertices[10] = _x1;
		TextureDrawPos_vertices[11] = _y1;
		
		var uvX = ( 0 - ( texelW ) ) * 0.5;
		var uvY = ( 0 - ( texelH ) ) * 0.5;
		
		var u1 = uvX;
		var u2 = 1 - uvX;
		var v1 = uvY;
		var v2 = 1 - uvY;
		
		
		
		TextureDrawPos_uvtData[0] = u1;
		TextureDrawPos_uvtData[1] = v1;
		TextureDrawPos_uvtData[2] = u2;
		TextureDrawPos_uvtData[3] = v1;
		TextureDrawPos_uvtData[4] = u2;
		TextureDrawPos_uvtData[5] = v2;
		TextureDrawPos_uvtData[6] = u2;
		TextureDrawPos_uvtData[7] = v2;
		TextureDrawPos_uvtData[8] = u1;
		TextureDrawPos_uvtData[9] = v2;
		TextureDrawPos_uvtData[10] = u1;
		TextureDrawPos_uvtData[11] = v1;
		
		
		graphics.drawTriangles( TextureDrawPos_vertices, TextureDrawPos_indices, TextureDrawPos_uvtData );
		graphics.endFill();
	}
	
	
	
	
	// 
	
	
	public static function InternalSetDrawTarget( target )
	{
		if ( !target )
			target = container;
		GM.internalrendertarget = target;
		GM.graphics = internalrendertarget.graphics;
	}
	
	// Instances
	
	public static function AddInstance( _x, _y, _obj, _basis = null )
	{
		var o = _obj;
		if ( !o )
			return;
		GMObject._createx = _x;
		GMObject._createy = _y;
		trace( "adding instance " + o );
		var inst = new o();
		inst.object_index = o;
		inst.x = _x;
		inst.y = _y;
		inst.xstart = _x;
		inst.ystart = _y;
		GM.instances.splice( GM.instance_index++, 0, inst );
		return inst;
	}
	
	public static function InternalInstanceDestroy( _inst )
	{
		if ( !_inst )
			return;
		// Remove
		var pos = instances.indexOf( _inst );
		if ( pos < 0 )
			return;
		// Log( "Destroy instance " + _inst );
		_inst.Cleanup();
		_inst.exists = false;
		
		instances.splice( pos, 1 );
		--instance_index;
	}
	
	// Old - use "global.spritename" instead
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
	
	public static function InternalSpriteDraw( _sprite, _image, _x, _y, _xscale = 1, _yscale = 1, _angle = 0, _blend = 0xFFFFFF, _alpha = 1 )
	{
		// OLD. no longer used
		
		if ( !_sprite || ( _sprite < 0 ) )
			return;
		var _symbol = _sprite.symbol;
		if ( !_symbol )
			return;
		var _subimg = Math.floor( _image % _symbol.totalFrames );
		var usebitmap = true;
		var _spriteImage;
		
		if ( false && usebitmap )
		{ 
			// wip - draw straight to container
			internaldrawmatrix = new Matrix();
			internaldrawmatrix.tx = 0;
			internaldrawmatrix.ty = 0;
			internaldrawmatrix.scale( _xscale, _yscale );
			_spriteImage = _sprite.GetImage( _subimg );
			if ( _spriteImage )
			{
				var g = internalrendertarget.graphics;
				var x1 = _x - ( _sprite.x * _xscale );
				var y1 = _y - ( _sprite.y * _yscale );
				var x2 = x1 + ( _sprite.width * _xscale );
				var y2 = y1 + ( _sprite.height * _yscale );
				
				g.beginFill( 0xFFFFFF, 1 );
				
				g.endFill();
				
			}
			return;
		}
		
		if ( false && !_symbol.visible )
		{
			_tempdrawsprites.push( _symbol );
			var pos = internalrendertarget.numChildren;
			if ( pos > 0 )
			{
				--pos;
				internalrendertarget.setChildIndex( _symbol, pos );
			}
			if ( _symbol.totalFrames > 1 )
				_symbol.gotoAndStop( _subimg + 1 );
		}
		else
		{
			if ( false ) // ( _symbol.constructor != MovieClip )
			{
				_symbol = new _symbol.constructor();
				if ( _symbol.totalFrames > 1 )
					_symbol.gotoAndStop( _subimg + 1 );
			}
			//else
			{
				_spriteImage = _sprite.GetImage( _subimg );
				if ( _spriteImage.bitmapdata )
				{
					var _shape = new Bitmap( _spriteImage.bitmapdata );
					var _shapedata = _symbol.getChildAt( 0 );
					_symbol = new Sprite();
					_symbol.addChild( _shape );
					_shape.x = 0 -_sprite.x;
					_shape.y = 0 -_sprite.y;
				}
			}
			internalrendertarget.addChild( _symbol );
			_tempsymbols.push( _symbol );
			if ( _tempsymbols.length > 280 )
			{
				var _get = _tempsymbols.shift();
				_get.parent.removeChild( _get );
			}
		}
		var color;
		if ( g_GlobalFog[0] )
		{
			color = _symbol.transform.colorTransform;
			color.color = g_GlobalFog[1];
			_symbol.transform.colorTransform = color;
		}
		else
		{
			var _r = ( ( _blend >> 16 ) & 0xFF ) / 255;
			var _g = ( ( _blend >> 8 ) & 0xFF ) / 255;
			var _b = ( ( _blend ) & 0xFF ) / 255;
			color = _symbol.transform.colorTransform;
			color.redOffset = 0;
			color.greenOffset = 0;
			color.blueOffset = 0;
			color.redMultiplier = _r;
			color.greenMultiplier = _g;
			color.blueMultiplier = _b;
			color.alphaMultiplier = 1;
			_symbol.transform.colorTransform = color;
		}
		
		if ( _symbol.mask )
		{
			// _symbol.mask.parent.removeChild( _symbol.mask );
			_symbol.mask = null;
		}
		_symbol.x = _x;
		_symbol.y = _y;
		_symbol.scaleX = _xscale;
		_symbol.scaleY = _yscale;
		_symbol.rotation = -_angle;
		_symbol.alpha = _alpha;
		_symbol.visible = true;
		_symbol.blendMode = g_BlendMode;
		return _symbol;
	}
	
	public static function InternalSpriteDrawPart( _sprite, _subimg, _left, _top, _width, _height, _x, _y, _xscale, _yscale, _colour, _alpha )
	{
		// Todo - use bitmapdata cropped region
		var _symbol = GM.InternalSpriteDraw( _sprite, _subimg, _x, _y, _xscale, _yscale, 0, _colour, _alpha );
		if ( !_symbol )
			return;
		var offx = ( _left - _sprite.x );
		var offy = ( _top - _sprite.y );
		_symbol.x -= offx * _xscale;
		_symbol.y -= offy * _yscale;
		
		if ( true )
		{
			var g;// = internalrendertarget.graphics;
			var _mask = new Shape();
			internalrendertarget.addChild( _mask );
			_mask.x = 0;
			_mask.y = 0;
			g = _mask.graphics;
			g.beginFill( 0, 1 );
			g.drawRect( _x, _y, _width * _xscale, _height * _yscale );
			g.endFill();
			_symbol.mask = _mask;
			_tempsymbols.push( _mask );
		}
		
		return _symbol;
	}
	
	public static function InternalSpriteDrawPos( _sprite, _subimg, x1, y1, x2, y2, x3, y3, x4, y4, alpha )
	{
		if ( !_sprite || ( _sprite == -1 ) )
			return;
		var _subimg = Math.floor( _subimg % ( _sprite.count ) );
		var _spriteImage = _sprite.GetImage( _subimg );
		var _bitmapData = _spriteImage.bitmapdata;
		var g = internalrendertarget.graphics;
		
		g.beginBitmapFill( _bitmapData, null, false, false );
		//
		TextureDrawPos_vertices[0] = x1;
		TextureDrawPos_vertices[1] = y1;
		TextureDrawPos_vertices[2] = x2;
		TextureDrawPos_vertices[3] = y2;
		TextureDrawPos_vertices[4] = x3;
		TextureDrawPos_vertices[5] = y3;
		TextureDrawPos_vertices[6] = x3;
		TextureDrawPos_vertices[7] = y3;
		TextureDrawPos_vertices[8] = x4;
		TextureDrawPos_vertices[9] = y4;
		TextureDrawPos_vertices[10] = x1;
		TextureDrawPos_vertices[11] = y1;
		TextureDrawPos_uvtData[0] = 0;
		TextureDrawPos_uvtData[1] = 0;
		TextureDrawPos_uvtData[2] = 1;
		TextureDrawPos_uvtData[3] = 0;
		TextureDrawPos_uvtData[4] = 1;
		TextureDrawPos_uvtData[5] = 1;
		TextureDrawPos_uvtData[6] = 1;
		TextureDrawPos_uvtData[7] = 1;
		TextureDrawPos_uvtData[8] = 0;
		TextureDrawPos_uvtData[9] = 1;
		TextureDrawPos_uvtData[10] = 0;
		TextureDrawPos_uvtData[11] = 0;
		g.drawTriangles( TextureDrawPos_vertices, null, TextureDrawPos_uvtData );
		//
		g.endFill();
	}
	
	// Drawing
	
	public static function InternalTextDraw( _x, _y, _text, _xscale = 1, _yscale = 1, _angle = 0 )
	{
		var _symbol = new TextField();
		container.addChild( _symbol );
		_tempsymbols.push( _symbol );
		_symbol.x = _x;
		_symbol.y = _y;
		_symbol.scaleX = _xscale;
		_symbol.scaleY = _yscale;
		_symbol.alpha = g_GlobalAlpha;
		_symbol.textColor = g_GlobalColor;
		
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
		_sound.stop();
	}
}



}

import gamemaker.*;

import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.media.*;

import com.threerings.*;
import com.whirled.*;


class GMEvent extends Event
{
	public var value;
	public function GMEvent( type, value = null )
	{
		super( type );
		this.value = value;
	}
}

// Sound asset

class GMSound
{
	public var audio;
	public var sound;
	public var inst;
	
	public function GMSound( _audio )
	{
		audio = _audio;
		sound = new audio();
	}
	
	public function Play( _offset = 0, _loop = false, _gain = 1 )
	{
		var chan = sound.play( _offset, _loop, new SoundTransform( _gain ) );
		inst = chan;
		return chan;
	}
	
	public function stop()
	{
		if ( inst )
		{
			inst.stop();
			inst = null;
		}
	}
}

// Sprite asset
 
class GMSprite
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
	
	public var colkind = 0;
	public var bboxmode = 0;
	public var bbox_top = 0;
	public var bbox_left = 0;
	public var bbox_right = 0;
	public var bbox_bottom = 0;
	
	public var autocrop = true;
	
	public var isBitmap = true;
	
	public var bitmap_frames = null;
	
	public function GMSprite()
	{
		
	}
	
	public function Cleanup()
	{
		while ( images.length > 0 )
		{
			var frame = images.pop();
			if ( !frame || !frame.bitmapdata )
				continue;
			frame.bitmapdata.dispose();
		}
	}
	
	public function CreateFromSymbol( symbol )
	{
		this.symbol = symbol;
		name = symbol.name;
		
		symbol.x = 0;
		symbol.y = 0;
		symbol.scaleX = 1; // 5;
		symbol.scaleY = 1; // 5;
		
		var transformMatrix = symbol.transform.concatenatedMatrix;
		symbol.scaleX = Math.min( transformMatrix.a, 1 / transformMatrix.a );
		symbol.scaleY = Math.min( transformMatrix.d, 1 / transformMatrix.d );
		bounds = symbol.transform.pixelBounds;
		
		x = -bounds.x;
		y = -bounds.y;
		width = bounds.width;
		height = bounds.height;
		
		count = 0;
		
		var frames = 1;
		
		if ( symbol["totalFrames"] != null )
		{
			frames = symbol.totalFrames;
			for ( var i = 0; i < frames; ++i )
			{
				if ( !symbol["numChildren"] )
					continue;
				++count;
				var symbol = this.symbol;
				var frame = {};
				frame.index = i;
				frame.x = 0;
				frame.y = 0;
				frame.w = width;
				frame.h = height;
				images[i] = frame;
				if ( symbol )
				{
					var pre_x = symbol.x;
					var pre_y = symbol.y;
					// trace( "get bitmap data for " + name + ":" + i );
					frame.symbol = symbol;
					frame.bitmapdata = new BitmapData( this.width, this.height, true, 0x00000000 );
					symbol.gotoAndStop( i + 1 );
					var offset = new Matrix();
					offset.tx = this.x;
					offset.ty = this.y;
					frame.bitmapdata.draw( symbol, offset );
				}
				if ( autocrop )
					CropFrame( frame );
			}
		}
	}
	
	public function CreateFromBitmap( frames, notyet = false )
	{
		GM.debugTracker = "GMSprite.CreateFromBitmap";
		if ( frames.length < 1 )
			return;
		width = frames[0].bitmapData.width;
		height = frames[0].bitmapData.height;
		if ( notyet )
		{
			bitmap_frames = frames;
			count = frames.length;
			return;
		}
		count = 0;
		for each ( var bitmap in frames )
		{
			var frame = {};
			frame.index = count;
			frame.x = 0;
			frame.y = 0;
			frame.w = width;
			frame.h = height;
			images[count++] = frame;
			frame.bitmapdata = bitmap.bitmapData;
			if ( autocrop )
				CropFrame( frame );
		}
	}
	
	public function GetImage( index )
	{
		if ( bitmap_frames != null )
		{
			CreateFromBitmap( bitmap_frames );
			bitmap_frames = null;
		}
		
		var i = Math.floor( index ) % this.count;
		if ( i < 0 )
			i += this.count;
		// trace( i + "/" + this.count );
		var frame = images[i];
		return frame;
	}
	
	public function CropFrame( frame )
	{
		if ( frame.cropped != null )
			return;
		trace( "cropping " + name + "_" + frame.index );
		frame.x = 0;
		frame.y = 0;
		frame.w = 0;
		var bmd = frame.bitmapdata;
		frame.w = bmd.rect.width;
		frame.h = bmd.rect.height;
		var bounds = bmd.getColorBoundsRect( 0xFF000000, 0x00000000, false );
		if ( bounds.width <= 0 || bounds.height <= 0 )
		{
			frame.cropped = false;
		}
		else if ( bounds.width < frame.w || bounds.height < frame.h || bounds.x > 0 || bounds.y > 0 )
		{
			frame.cropped = true;
			frame.bitmapdata = new BitmapData( bounds.width, bounds.height, true, 0x00000000 );
			frame.bitmapdata.copyPixels( bmd, bounds, new Point( 0, 0 ) );
			bmd.dispose();
			frame.x = bounds.x;
			frame.y = bounds.y;
			frame.w = bounds.width;
			frame.h = bounds.height;
			
			bbox_left = Math.min( frame.x, bbox_left );
			bbox_top = Math.min( frame.y, bbox_top );
			bbox_right = Math.max( bbox_right, frame.x + frame.w );
			bbox_bottom = Math.max( bbox_bottom, frame.y + frame.h );
		}
		else
			frame.cropped = false;
		
	}
	
	public function Draw( _subimg, _x, _y, _xscale, _yscale, _ang, _col, _alpha )
	{
		if ( this.count <= 0 )
			return;
		if ( _alpha < 0 )
			_alpha = 0;
		else if ( _alpha > 1 )
			_alpha = 1;
		_subimg = ( ~~_subimg ) % this.count;
		if ( _subimg < 0 )
			_subimg += this.count;
		var image = this.GetImage( _subimg );
		var xoff = this.x;
		var yoff = this.y;
		if ( image.cropped )
		{
			xoff -= image.x;
			yoff -= image.y;
		}
		GM.Graphics_TextureDraw( image.bitmapdata, xoff, yoff, _x, _y, _xscale, _yscale, _ang, _col, _alpha );
	}
	
	public function DrawSimple( _subimg, _x, _y, _alpha )
	{
		if ( this.count <= 0 )
			return;
		if ( _alpha < 0 )
			_alpha = 0;
		else if ( _alpha > 1 )
			_alpha = 1;
		_subimg = _subimg % this.count;
		if ( _subimg < 0 )
			_subimg += this.count;
		var image = this.GetImage( _subimg );
		if ( image.cropped )
		{
			_x += image.x;
			_y += image.y;
		}
		GM.Graphics_TextureDrawSimple( image.bitmapdata, _x - this.x, _y - this.y, _alpha );
	}
	
	public function DrawSimplePos( _subimg, _x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4, _alpha )
	{
		if ( this.count <= 0 )
			return;
		if ( _alpha < 0 )
			_alpha = 0;
		else if ( _alpha > 1 )
			_alpha = 1;
		_subimg = _subimg % this.count;
		if ( _subimg < 0 )
			_subimg += this.count;
		var image = this.GetImage( _subimg );
		//var bmd = image.bitmapdata;
		GM.Graphics_TextureDrawPos( image, _x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4, _alpha );
	}
	
	public function DrawTiled(  )
	{
		
	}
}

// Surface - TBA

class GMSurface
{
	public var surface = new Sprite();
	public var mask = new Shape();
	
	public var width = 0;
	public var height = 0;
	
	public function GMSurface( ww, hh )
	{
		width = 0;
		height = 0;
		surface.addchild( mask );
		
		Resize( ww, hh );
	}
	
	public function Resize( ww, hh )
	{
		mask.graphics.clear();
		mask.graphics.beginFill( 0, 1 );
		mask.graphics.drawrect( 0, 0, ww, hh );
		mask.graphics.endFill();
		width = ww;
		height = hh;
	}
}


