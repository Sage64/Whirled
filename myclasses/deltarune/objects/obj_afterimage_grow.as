package deltarune.objects
{

import deltarune.*;
import gamemaker.*;

public class obj_afterimage_grow extends DeltaruneObject
{
    public var xrate = 0.2;
    public var yrate = 0.2;
    public var fade = 0.1;
    
    public function obj_afterimage_grow ()
	{
		
	}
    
    override public function Step()
    {
        image_alpha -= fade;
        image_xscale += xrate;
        image_yscale += yrate;

        if (image_alpha < 0)
            instance_destroy();

    }
}


}