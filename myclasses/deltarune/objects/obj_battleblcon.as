package deltarune.objects
{

import deltarune.*;
import gamemaker.*;

public class obj_battleblcon extends DeltaruneObject
{
	public var mywriter;
	public var auto_length = 0;
	public var side = 1;
	public var init = 0;
	public var creator;
	
	public function obj_battleblcon()
	{
		super();
		
		sprite_set( global.spr_battleblcon );
		
		
	}
	
	override public function Step()
	{
		if ( !i_ex( mywriter ) )
			instance_destroy();
	}
}


}