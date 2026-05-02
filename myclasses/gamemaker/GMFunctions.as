// Gamemaker
package gamemaker
{
import gamemaker.*;
import flash.display.*;
import flash.events.*;
public class GMFunctions extends EventDispatcher
{
	public static const global = {};
	// Color consants
	public static const c_white = 0xFFFFFF;
	public static const c_black = 0x000000;
	//
	public static const c_aqua = c_white;
	public static const c_blue = 0x0000FF;
	public static const c_lime = 0x00FF00;
	public static const c_ltgray = 0xCCCCCC;
	public static const c_purple = 0x800080;
	public static const c_red = 0xFF0000;
	public static const c_yellow = 0xFFFF00;
	
	// Function constants
	public static const string = String;
	
	// Text constants
	public static const fa_left = 0;
	public static const fa_center = 1;
	public static const fa_right = 2;
	public static const fa_top = 0;
	public static const fa_middle = 1;
	public static const fa_bottom = 2;
	
	
	// Draw constants
	public static const bm_add = BlendMode.ADD;
	public static const bm_normal = BlendMode.NORMAL;
	
	
	public function GMFunctions()
	{
		super();
		
	}
	
	
	// Function_Font
	{
		public static function draw_set_font( _fnt )
		{
			GM.internaldrawfont = _fnt;
		}
		
		public static function draw_set_halign( _h = fa_left )
		{
			GM.internaldrawhalign = _h;
		}
		public static function draw_set_valign( _v = fa_top )
		{
			GM.internaldrawvalign = _v;
		}
		
		public static function draw_text( _x, _y, _text, _alpha = null )
		{
			draw_text_transformed( _x, _y, _text, 1, 1, 0, _alpha );
		}
		
		public static function draw_text_transformed( _x, _y, _text, _xscale = 1, _yscale = 1, _angle = 0, _alpha = null )
		{
			
			//GM.InternalTextDraw( _x, _y, _text, _xscale, _yscale, _angle, _alpha );
		}
		
		public static function font_add_sprite( _spr, _first, _prop, _sep )
		{
			
		}
	}
	
	// Function_Graphics
	{
		public static function gpu_set_blendmode( bm )
		{
			if ( bm == GM.g_BlendMode )
				return;
			var _newcont = new Sprite();
			_newcont.blendMode = bm;
			GM._tempsymbols.push( _newcont );
			GM.internalrendertarget.addChild( _newcont );
			GM.graphics = _newcont.graphics;
			GM.g_BlendMode = bm;
			//if ( bm == BlendMode.NORMAL )
			//	_newcont.cacheAsBitmap = true;
		}
		
		public static function gpu_set_fog( on, col = c_white, _start = 0, _end = 0 )
		{
			if ( on )
			{
				GM.g_GlobalFog[0] = true;
				GM.g_GlobalFog[1] = col;
				GM.g_GlobalFog[2] = _start;
				GM.g_GlobalFog[3] = _end;
			}
			else
				GM.g_GlobalFog[0] = false;
		}
		
		public static function merge_color( cola, colb, amnt )
		{
			if ( amnt > 0 )
			{
				if ( amnt < 1 )
				{
					var r = ( ( cola >> 16 ) & 0xFF );
					var b = ( ( cola >> 8 ) & 0xFF );
					var g = ( ( cola ) & 0xFF );
					r = lerp( r, ( ( colb >> 16 ) & 0xFF ), amnt );
					b = lerp( b, ( ( colb >> 8 ) & 0xFF ), amnt );
					g = lerp( g, ( ( colb ) & 0xFF ), amnt );
					colb = g | ( b << 8 ) | ( r << 16 );
				}
				return colb;
			}
			return cola;
		}
		
		public function draw_clear_alpha( col, a )
		{
			var g = GM.internalrendertarget.graphics;
			g.clear();
			if ( a > 0 )
			{
				g.beginFill( col, a );
				g.drawRect( 0, 0, g.width, g.height );
				g.endFill();
			}
		}
		
		public static function draw_set_alpha( alpha )
		{
			GM.g_GlobalAlpha = alpha;
		}
		
		public static function draw_get_alpha()
		{
			return GM.g_GlobalAlpha;
		}
		
		public static function draw_set_color( col )
		{
			GM.g_GlobalColor = col;
			//return GM.InternalSetColor( col );
		}
		
		public static function draw_get_color()
		{
			return GM.g_GlobalColor;
		}
		
		public static function draw_line( x1, y1, x2, y2 )
		{
			return draw_line_width( x1, y1, x2, y2, 1, null );
		}
		
		public static function draw_line_width( x1, y1, x2, y2, w = 1, a = null )
		{
			with ( GM )
			{
				var g = internalrendertarget.graphics;
				if ( a == null )
					a = g_GlobalAlpha;
				g.beginFill( g_GlobalColor, a );
				g.lineStyle( w, g_GlobalColor, a );
				g.moveTo( x1, y1 );
				g.lineTo( x2, y2 );
				g.endFill();
				g.lineStyle(0, 0, 0);
			}
		}
		
		public static function draw_rectangle( x1, y1, x2, y2, outline = false )
		{
			with ( GM )
			{
				var g = graphics;
				if ( outline )
				{
					var a = 1;
					g.beginFill( g_GlobalColor, a );
					g.lineStyle( w, g_GlobalColor, a );
					g.moveTo( x1, y1 );
					g.lineTo( x2, y1 );
					g.lineTo( x2, y2 );
					g.lineTo( x1, y2 );
					g.lineTo( x1, y1 );
					g.endFill();
					g.lineStyle(0, 0, 0);
					return;
				}
				g.beginFill( g_GlobalColor, g_GlobalAlpha );
				g.drawRect( x1, y1, x2 - x1, y2 - y1 );
				g.endFill();
			}
		}
		
	}
	
	// Function_Instance
	{
		public function instance_destroy( _inst = null )
		{
			if ( _inst == null )
				_inst = this;
			return GM.InternalInstanceDestroy( _inst );
		}
		
		public static function instance_exists( _obj )
		{
			if ( !_obj )
				return false;
			if ( _obj == 1 )
				return true;
			if ( _obj )
			{
				return _obj.exists;
			}
			return false;
		}
	}
	
	// Function_IO
	{
		public static const vk_none = 0;
		public static const mb_left = 1;
		public static const mb_right = 2;
		public static const mb_middle = 4;
		public static const mb_side1 = 5;
		public static const mb_side2 = 6;
		// 
		public static const vk_escape = 27;
		public static const vk_space = 32;
		public static const vk_pageup = 33;
		public static const vk_pagedown = 34;
		public static const vk_left = 37;
		public static const vk_up = 38;
		public static const vk_right = 39;
		public static const vk_down = 40;
		
		public static const vk_anykey = 255;
		
		public static function io_clear()
		{
			return ( GM.g_pIOManager.IO_Clear() );
		}
		
		public static function keyboard_check( key = 0 )
		{
			return ( GM.g_pIOManager.KeyDown[key] );
		}
		
		public static function keyboard_check_pressed( key = 0 )
		{
			return ( GM.g_pIOManager.KeyPressed[key] );
		}
		
		public static function keyboard_check_released( key = 0 )
		{
			return ( GM.g_pIOManager.KeyUp[key] );
		}
		
		public static function keyboard_check_direct( key = 0 )
		{
			return ( GM.g_pIOManager.KeyDown[key] );
		}
		
		public static const mouse_check_button = keyboard_check;
		public static const mouse_check_button_pressed = keyboard_check_pressed;
		public static const mouse_check_button_released = keyboard_check_released;
		
		public static function get mouse_x()
		{
			if ( GM.internalrendertarget )
				return GM.internalrendertarget.mouseX;
			return GM.container.mouseX;
		}
		
		public static function get mouse_y()
		{
			if ( GM.internalrendertarget )
				return GM.internalrendertarget.mouseY;
			return GM.container.mouseY;
		}
		
		public static function window_has_focus()
		{
			try
			{
				if ( GM.media && GM.media.stage )
				{
					var focus = GM.media.stage.focus;
					if ( focus == GMControl.popup_surface )
						return true;
					if ( focus == GM.media.stage )
						return true;
				}
			}
			catch(e)
			{
				return null;
			}
			return false;
		}
		
		public static function window_mouse_get_x()
		{
			
		}
		
		public static function window_mouse_get_y()
		{
			
		}
	}
	
	// Function_Layer
	{
		public static function instance_create( _x, _y, _obj, _basis = null )
		{
			var inst = GM.AddInstance( _x, _y, _obj, _basis );
			inst.Create();
			return inst;
		}
		
		public static function instance_create_depth( _x = 0, _y = 0, _depth = 0, _obj = -1, _basis = null )
		{
			var inst = GM.AddInstance( _x, _y, _obj, _basis );
			inst.depth = _depth;
			inst.Create();
			return inst;
		}
		
		public static function instance_create_layer( _x = 0, _y = 0, _layer = 0, _obj = -1, _basis = null )
		{
			var inst = GM.AddInstance( _x, _y, _obj, _basis );
			inst.Create();
			return inst;
		}
	}
	
	// Function_Maths
	{
		public static const pi = Math.PI;
		public static const abs = Math.abs;
		public static const arccos = Math.acos;
		public static const arcsin = Math.asin;
		public static const ceil = Math.ceil;
		public static const clamp = gml.clamp;
		public static const cos = Math.cos;
		public static const dcos = gml.dcos;
		public static const dsin = gml.dsin;
		public static const floor = Math.floor;
		public static const lengthdir_x = gml.lengthdir_x;
		public static const lengthdir_y = gml.lengthdir_y;
		public static const lerp = gml.lerp;
		public static const min = Math.min;
		public static const max = Math.max;
		public static const power = Math.pow;
		public static const round = Math.round;
		public static const sin = Math.sin;
		public static const sqrt = Math.sqrt;
		
		public static function irandom( val )
		{
			return Math.round( Math.random() * val );
		}
		
		public static function is_string( val )
		{
			return ( typeof val == "String" );
		}
		
		public static function point_direction( _x1, _y1, _x2, _y2 )
		{
			var xx = _x2 - _x1;
			var yy = _y1 - _y2;
			return Math.floor( ( Math.round( Math.atan2( yy, xx ) / ( 2 * Math.PI / 360 ) ) + 360) % 360 );
		}
		
		public static function point_distance( _x1, _y1, _x2, _y2 )
		{
			var dx = _x2 - _x1;
			var dy = _y2 - _y1;
			return Math.sqrt( ( dx*dx ) + ( dy*dy ) );
		}
		
		public static function random( val )
		{
			return Math.random() * val;
		}
		
		public static function random_range( a, b )
		{
			return gml.lerp( a, b, Math.random() );
		}
		
		public static function sign( val )
		{
			if ( val == 0 )
				return 0;
			else
				return ( val > 0 ) ? 1 : -1;
		}
		
		public static function sqr( val )
		{
			return val * val;
		}
	}
	
	// Function_Sprite
	{
		public static function sprite_get_name( _spr )
		{
			if ( _spr != null )
				return _spr.name;
			return "undefined";
		}
		
		public static function sprite_get_width( _spr )
		{
			if ( _spr != null )
				return _spr.width;
			return 0;
		}
		
		public static function sprite_get_height( _spr )
		{
			if ( _spr != null )
				return _spr.height;
			return 0;
		}
		
		public static function sprite_get_number( _spr )
		{
			if ( _spr != null )
				return _spr.count;
			return 0;
		}
		
		public static function sprite_get_xoffset( _spr )
		{
			if ( _spr != null )
				return _spr.x;
			return 0;
		}
		
		public static function sprite_get_yoffset( _spr )
		{
			if ( _spr != null )
				return _spr.y;
			return 0;
		}
		
		public static function sprite_create_from_surface( _surf, _x, _y, _w, _h, _removeback = false, _smooth = false, _xoff = 0, _yoff = 0 )
		{
			return;
			var spr = {};
			//var _spr = new GMSprite();
			_spr.width = _w;
			_spr.height = _h;
			_spr.x = _xoff;
			_spr.y = _yoff;
			
		}
		
		// If this sprite exists but I don't have it, clone it (e.g remote sprite, added wrongly, etc)
		public static function sprite_verify( _spr )
		{
			if ( !_spr )
				return -1;
			var sprname = sprite_get_name( _spr );
			if ( global[sprname] )
				return global[sprname];
			GM.Log( "sprite_verify: cloning sprite " + sprname );
			return GM.AddSprite_Sprite( sprname, _spr );
		}
	}
	
	// Function_String
	{
		public function ord( _str )
		{
			if ( !_str || _str == "" )
				return 0;
			var code = _str.charCodeAt( 0 );
			return code;
		}
	}
	
	// Function_Texture
	{
		public function draw_self()
		{
			var _inst = this;
			var _spr = _inst.sprite_current;
			if ( _spr == null || _spr < 0 )
				return;
			var _subimg = ( Math.floor( _inst.image_index ) % _spr.count );
			if ( _subimg < 0 )
				_subimg += _spr.count;
			_spr.Draw( _subimg, _inst.x, _inst.y, _inst.image_xscale, _inst.image_yscale, _inst.image_angle, _inst.image_blend, _inst.image_alpha );
		}
		
		public function draw_sprite( _spr, _subimg, _x, _y )
		{
			if ( _spr == null || _spr < 0 )
				return;
			var _subimg = ( _subimg % _spr.count );
			if ( _subimg < 0 )
				_subimg += _spr.count;
			_spr.DrawSimple( _subimg, _x, _y, GM.g_GlobalAlpha );
		}
		
		public function draw_sprite_ext( _spr, _subimg, _x, _y, _xscale = 1, _yscale = 1, _ang = 0, _col = 0xFFFFFF, _alpha = null )
		{
			if ( _spr == null || _spr < 0 )
				return;
			_subimg = ( _subimg % _spr.count );
			if ( _subimg < 0 )
				_subimg += _spr.count;
			if ( _alpha == null )
				_alpha = GM.g_GlobalAlpha;
			_spr.Draw( _subimg, _x, _y, _xscale, _yscale, _ang, _col, _alpha );
		}
		
		public function draw_sprite_pos( _spr, _subimg, _x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4, _alpha = null )
		{
			if ( _spr == null || _spr < 0 )
				return;
			_subimg = ( _subimg % _spr.count );
			if ( _subimg < 0 )
				_subimg += _spr.count;
			if ( _alpha == null )
				_alpha = GM.g_GlobalAlpha;
			_spr.DrawSimplePos( _subimg, _x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4, _alpha );
		}
		
		public function draw_sprite_part_ext( _spr, _subimg, _left, _top, _width, _height, _x, _y, _xscale = 1, _yscale = 1, _col = 0xFFFFFF, _alpha = null )
		{
			if ( _spr == null || _spr < 0 )
				return;
			var _subimg = ( _subimg % _spr.count );
			if ( _subimg < 0 )
				_subimg += _spr.count;
			if ( _alpha == null )
				_alpha = GM.g_GlobalAlpha;
			var _img = _spr.GetImage( _subimg );
			var _bmd = _img.bitmapdata;
			if ( !_bmd )
				return;
			GM.Graphics_DrawPart( _img, _left, _top, _width, _height, _x, _y, _xscale, _yscale, _col, _alpha );
		}
	}
	
	
}
}