
// 
// 
// 

package deltarune
{

import gamemaker.*;
import deltarune.objects.*;

import flash.display.*;
import flash.events.*;
import flash.utils.*;

import com.threerings.util.*
import com.whirled.*


/* 
	Monster Body
	Note: In the dark world, most things are scaled up 2x
*/
public class MonsterBody extends DeltaruneBody
{
    public var idlesprite;
    public var hurtsprite;
    public var sparedsprite;
	
	public var shakex = 0;
	public var state = 0;
	public var hurttimer = 0;
    
	public function MonsterBody()
	{
		super();
        
		// Base properties
		
		characterH = 40;
		
        darkmode = true;
        
		SetMoveSpeed( 5 );
        
		// Avatar
		
		// Deltarune
		
		darkmode = true;

		if ( darkmode )
		{
			SetScale ( darkscale );
			image_xscale = 2;
			image_yscale = 2;
			characterH *= darkscale;
		}
        
		// States
		
		myactions["damage_weak"] = AddAction( "Damage (weak)", Action_Hurt, 30 );
		myactions["damage_strong"] = AddAction( "Damage (strong)", Action_Hurt, 100 );
	}
	
	override public function Draw()
	{
		super.Draw();
	}
	
	public function Action_Hurt( data )
	{
		trace( "oof!" );
		var damage = 0;
		if ( data )
			damage = data;
		
		OnHurt( damage );
	}
	
	public function OnHurt( amount = 0 ) {}
	
	
	
	public function scr_damage_enemy( target, amount )
	{
		var dmgx = target.x;
		var dmgy = target.y - 20;
		
		// var dmg = instance_create( dmgx, dmgy, obj_dmgwriter );
		
		if ( target == 0 )
		{
			
		}
		else if ( instance_exists( target ) )
		{
			target.shakex = 9;
			target.state = 3;
			target.hurttimer = 30;
		}
	}
}
// 
}