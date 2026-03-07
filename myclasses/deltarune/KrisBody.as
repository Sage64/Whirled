
package deltarune
{

import gamemaker.*;

import flash.display.*;
import flash.events.*;
import flash.utils.*;

import com.threerings.util.*
import com.whirled.*


public class KrisBody extends DeltarunePlayerBody
{
	
	public function KrisBody()
	{
		super();
		
		bheight = 40;
		heroname = "Kris";
		herocolor = 0x8DEDFE;
			
		var spr;
		var state;
		
		// Light world
		spr = [ "spr_krisd", "spr_krisr", "spr_krisu", "spr_krisl" ];
		LWState( "Default", spr );
		LWState( "Default (Run)", spr ).run = true;

		// Light world - church
		spr = [ "spr_kris_walk_down_church", "spr_kris_walk_right_church", "spr_krisu", "spr_kris_walk_left_church" ];
		LWState( "Church", spr );
		LWState( "Church (Run)", spr ).run = true;

		// Dark world
		spr = [ "spr_krisd_dark", "spr_krisr_dark", "spr_krisu_dark", "spr_krisl_dark" ];
		DWState( "Dark", spr);
		DWState( "Dark (Run)", spr ).run = true;

		// Board
		spr = [ "spr_board_kris_walk_down", "spr_board_kris_walk_right", "spr_board_kris_walk_up", "spr_board_kris_walk_left" ];
		BoardState( "Board", spr );
	}
	
}

}