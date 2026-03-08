package deltarune.objects
{

import deltarune.*;
import gamemaker.*;

public class obj_afterimage extends DeltaruneObject
{
    
    public var fadespd = 0.04;
    
    public function obj_afterimage()
	{
		depth = 1;
	}
    
    override public function Step()
    {
        if ( !body )
            return;
        //
        x += body.roomHMove;
        y += body.roomVMove;
        x += ( hspeed * body.timescale );
        y += ( vspeed * body.timescale );
        //
        image_alpha -= fadespd *( body.timescale );
        depth += 0.1;
        if ( image_alpha <= 0 )
        {
            instance_destroy();
            return;
        }
    }
}


}