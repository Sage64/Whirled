package deltarune.objects
{

import deltarune.*;
import gamemaker.*;

public class obj_animation extends DeltaruneObject
{
    public function obj_animation()
	{
        name = "obj_animation";
		super();
	}
    
    override public function Step()
    {
       
    }
    
    override public function OnAnimationEnd()
    {
        instance_destroy();
    }
}


}