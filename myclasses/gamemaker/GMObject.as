
// GM Object
// by sage [ https://github.com/Sage64/Whirled ]
// Part of GMBody.as


package gamemaker
{

import flash.display.*;
import flash.events.*;
import flash.filters.*;
import flash.geom.*;
import flash.text.*;

import com.threerings.text.TextFieldUtil;
import com.whirled.*;

public class GMObject extends Sprite
{
	public var body;
	
	public var id = 0;
	
	public var xstart;
	public var ystart;
	
	public var depth = 0;
	
	public var sprite_index = null;
	public var sprite_current = null;
	
	public var image_number = 1;
	public var image_index = 0;
	public var image_speed = 0;
	public var image_xscale = 1;
	public var image_yscale = 1;
	public var image_angle = 0;
	public var image_blend = 0xFFFFFF;
	public var image_alpha = 1;
	
	public var hspeed = 0;
	public var vspeed = 0;
	
	public function GMObject()
	{
		GMControl.debugTracker = "GMObject";
		this.body = GMControl.body;
	}
	
	public function Cleanup() {}
	
	public function GMStep()
	{
		Step();
		
		if ( image_speed != 0 )
		{
			
		}
		
	}
	
	public function Step() {}
	
	public function GMDraw()
	{
		Draw();
	}
	
	public function Draw()
	{
		draw_self();
	}
	
	/*
		GM Functions
	*/
	
	// Sprite
	
	public function draw_self()
	{
		return GMControl.InternalSpriteDraw( sprite_current, image_index, x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha  );
	}
	
	public static function draw_sprite( _sprite, _image = null, _x = null, _y = null )
	{
		return GMControl.InternalSpriteDraw( _sprite, _image, _x, _y, 1, 1, 0, 0xFFFFFF, 1 );
	}
	
	public static function draw_sprite_ext( _sprite, _image = null,
	_x = null, _y = null, _xscale = 1, _yscale = 1,
	_rot = 0, _col = -1, _alpha = 1 )
	{
		return GMControl.InternalSpriteDraw( _sprite, _image, _x, _y, _xscale, _yscale, _rot, _col, _alpha  );
	}
	
	public function sprite_set( sprite_ref )
	{
		if ( sprite_ref == -1 )
			sprite_ref = null;
		if ( sprite_ref == sprite_current )
			return;
		
		if ( sprite_current )
		{
			sprite_current.visible = false;
			sprite_current = null;
			image_number = 1;
		}
		
		if ( sprite_ref )
		{
			sprite_current = sprite_ref;
			image_number = sprite_current.totalFrames;
		}
	}
	
	public static function sprite_get( sprite_name )
	{
		return GMControl.InternalSpriteGet( sprite_name );
	}
	
	// Instance
	
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
}



} // package



