package deltarune.objects
{

import deltarune.*;
import gamemaker.*;

public class obj_overworldenemy_parent extends DeltaruneObject
{
	public var offset_x = 0;
	public var offset_y = 0;
	
    public function obj_overworldenemy_parent()
	{
		image_xscale = 2;
		image_yscale = 2;
	}
    
    override public function Step()
    {
       
    }
	
	override public function Draw()
	{
		var xpos = this.x;
		var ypos = this.y;
		this.x = xpos - ( offset_x * image_xscale );
		this.y = ypos - ( offset_y * image_yscale );
		
		if ( body && body.chaseaura )
		{
			scr_draw_chaseaura( sprite_current, image_index, x, y );
		}
		
		draw_self();
		
		this.x = xpos;
		this.y = ypos;
	}
}


}