package deltarune.objects
{

import deltarune.*;
import gamemaker.*;

public class obj_script_delayed extends DeltaruneObject
{
	public var script = -1;
	public var target = -1;
	public var rate = 1;
	public var script_arg = new Array( 13 );
	public var arg_count = 0;
	public var constant = 0;
	public var max_time = 0;
	public var timer = 999;
	public var totaltimer = 0;
	
	public function obj_script_delayed()
	{
		
	}
	
	override public function Create()
	{
		alarm[0] = 1;
	}
	
	override public function Step()
	{
		if ( alarm[0] > 0 )
		{
			--alarm[0];
			if ( alarm[0] == 0 )
			{
				alarm[0] = -1;
				EventUser0();
				instance_destroy();
				return;
			}
		}
		
		if (constant == 1)
		{
			if (max_time == -1)
				totaltimer = -10;
			timer++;
			if (timer >= rate)
			{
				if (i_ex(target) && totaltimer < max_time)
				{
					EventUser0();
					timer = 0;
				}
				else
					instance_destroy();

			}
			totaltimer++;
		}
	}
	
	public function EventUser0()
	{
		var i;
		if (i_ex(target))
		{
			var __script = script;
			var __script_arg = new Array( arg_count );
			for (i = 0; i < arg_count; i++)
			{
				__script_arg[i] = script_arg[i];
			}
			target.script_execute( __script, __script_arg );
		}

	}
}


}