
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
	
	public function CreateFromBitmaps( sprname:String, _x = 0, _y = 0 )
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
		
		return GM.AddSprite_Bitmap( sprname, _x, _y, frames );
	}
	
	
	public static function GenerateEmbedCode( source_file = "" )
	{
		var maxFiles = 65535;
		
		
	}
}

}