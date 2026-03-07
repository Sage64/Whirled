
// 
// 
// 

package deltarune
{

import gamemaker.*;

import flash.display.*;
import flash.events.*;
import flash.utils.*;

import com.threerings.util.*
import com.whirled.*


/* 
	Monster Body
	Note: In the dark world, most things are scaled up 2x
*/
public class MonsterBody extends DeltaruneBody
{
    public static var idlesprite;
    public static var hurtsprite;
    public static var sparedsprite;
	
    public var monster = null;
    
	public function MonsterBody()
	{
		super();
        
		// Base properties
		
		characterH = 40;
		
        darkmode = true;
        
		SetMoveSpeed( 5 );
        
		// Avatar
		
		// Deltarune
		
		darkmode = true;

		if ( darkmode )
		{
			SetScale ( darkscale );
			image_xscale = 2;
			image_yscale = 2;
			characterH *= darkscale;
		}
        
		// States
	}
}
// 
}