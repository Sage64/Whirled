package deltarune.objects
{

import deltarune.*;
import gamemaker.*;

public class obj_heroparent extends DeltaruneObject
{
	public var myself = 0;
	
	public var state = 0;
	public var hurt = 0;
	
	public var thissprite;
	public var index = 0;
	
	public var idlesprite;
	public var hurtsprite;
	public var attackreadysprite;
	public var attacksprite;
	public var attacktimer;
	public var actreadysprite;
	public var actsprite;
	public var acttimer;
	public var itemsprite;
	public var itemreadysprite;
	public var itemtimer;
	public var defendsprite;
	public var defendtimer;
	
	public function obj_heroparent()
	{
		super();
		sprite_index = global.spr_krisb_idle;
		image_speed = 0;
		
		image_xscale = 2;
		image_yscale = 2;
		
	}
	
	override public function Create()
	{
		
	}
	
	override public function Step()
	{
		
	}
	
	override public function Draw()
	{
		
	}
}


}