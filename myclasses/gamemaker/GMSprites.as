
package gamemaker
{

import gamemaker.*;
import flash.display.*;
import flash.utils.*;

/*
	Helper class for embedding images as sprites
	Should either create symbols as children
	or embed and use the CreateFromBitmaps method
*/

public class GMSprites extends Sprite
{
	
	public function GMSprites()
	{
		
	}
	
	public function CreateFromBitmaps( sprname:String, _x = 0, _y = 0, data = null )
	{
		var maxFrames = 65535;
		var frames = [];
		var i = 0;
		for ( i = 0; i < maxFrames; ++i )
		{
			var _class = null;
			try
			{
				_class = this[sprname + "_" + i];
			}
			catch(e)
			{
				_class = null;
			}
			if ( _class == null )
				break;
			frames.push( new _class() );
		}
		
		if ( i < 1 )
			return;
		
		var sprite = GM.AddSprite_Bitmap( sprname, _x, _y, frames );
		
		if ( data != null )
		{
			AddData( sprite, data, "type" );
			AddData( sprite, data, "colkind" );
			AddData( sprite, data, "coltolerance" );
			AddData( sprite, data, "sepmasks" );
			AddData( sprite, data, "bboxmode" );
			AddData( sprite, data, "bbox_left" );
			AddData( sprite, data, "bbox_top" );
			AddData( sprite, data, "bbox_right" );
			AddData( sprite, data, "bbox_bottom" );
		}
		return sprite;
	}
	
	public function AddData( dest, source, key )
	{
		try
		{
			if ( dest[key] != null )
				source[key] = dest[key];
		}
		catch(e){}
	}
}

}