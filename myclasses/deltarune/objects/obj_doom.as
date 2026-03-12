package deltarune.objects
{

import deltarune.*;
import gamemaker.*;

public class obj_doom extends DeltaruneObject
{
    public var target;
    public var time = 0;
    
    public function obj_doom()
	{
		
	}
    
    override public function Step()
    {
        if ( --time <= 0 )
        {
            instance_destroy( target );
            instance_destroy();
        }
    }
}


}