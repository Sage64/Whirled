package deltarune.objects
{

import deltarune.*;
import gamemaker.*;

public class obj_lerpvar extends DeltaruneObject
{
	public var variable = 0;
	public var varname = "variable";
	public var pointa = 0;
	public var pointb = 0;
	public var time = 0;
	public var maxtime = 30;
	public var target = -1;
	public var init = 0;
	public var easetype = 0;
	public var easeinout = "out";
	public var respectglobalinteract = false;

	public function obj_lerpvar()
	{
		
	}
	
	override public function Step()
	{
		if (i_ex(target))
		{
			if (init == 0)
			{
				if (is_string(pointa))
					pointa = variable_instance_get(target, varname);
				init = 1;
			}
			var cont = 1;
			if (respectglobalinteract == true)
			{
				if (global.interact != 0)
					cont = 0;
			}
			if (cont)
				time++;
			
			var amnt = time / maxtime;
			if ( amnt > 1 )
				amnt = 1;
			if (easetype == 0)
			{
				variable_instance_set(target, varname, lerp(pointa, pointb, amnt));
			}
			else
			{
				if (easeinout == "out")
					variable_instance_set(target, varname, lerp_ease_out(pointa, pointb, amnt, easetype));
				if (easeinout == "in")
					variable_instance_set(target, varname, lerp_ease_in(pointa, pointb, amnt, easetype));
				if (easeinout == "inout")
					variable_instance_set(target, varname, lerp_ease_inout(pointa, pointb, amnt, easetype));
			}
			if (time >= maxtime)
				instance_destroy();
		}
		else
		{
			instance_destroy();
		}
	}
}
}


