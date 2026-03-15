package deltarune.objects
{

import deltarune.*;
import gamemaker.*;

public class obj_basicattack extends DeltaruneObject
{
	public var damage = 100;
	public var maxindex = 3;
	public var critical = 0;
	
	public function obj_basicattack()
	{
		sprite_set( global.spr_attack_cut1 );
		image_xscale = 2;
		image_yscale = 2;
		image_speed = ( 1 / 3 );
		depth = -30;
	}
	
	override public function Create()
	{
		snd_stop( global.snd_damage );
		snd_play( global.snd_damage );
	}
	
	override public function Step()
	{
		if ( critical == 1 )
		{
			image_xscale += 0.1;
			image_yscale += 0.1;
		}

		if ( image_index >= maxindex )
			instance_destroy();

	}
}


}