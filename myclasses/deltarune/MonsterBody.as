
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
	public var enemy;
	
    public var idlesprite;
    public var hurtsprite;
    public var sparedsprite;
	
	public var shakex = 0;
	public var state = 0;
	public var hurttimer = 0;
    
	public var use_mercy = true;
	public var use_damage = true;
	
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
        
		
		if ( use_damage )
		{
			mymemories["health"] = AddMemory( "deltarune.monster.hp", -1, HealthChanged );
			myactions["damage_weak"] = AddAction( "Damage 30", Action_Hurt, 30 );
			myactions["damage_strong"] = AddAction( "Damage 120", Action_Hurt, 120 );
		}
		
		if ( use_mercy )
		{
			mymemories["mercy"] = AddMemory( "deltarune.monster.mercy", 0, MercyChanged );
			myactions["mercy_set_0"] = AddAction( "SetMercy 0%", Action_SetMercy, 0 );
			myactions["mercy_0"] = AddAction( "SetMercy 100%", Action_SetMercy, 100 );
		}
	}
	
	override public function Draw()
	{
		super.Draw();
	}
	
	//
	
	public function Action_Hurt( data )
	{
		trace( "oof!" );
		var damage = 0;
		if ( data )
			damage = data;
		
		OnHurt( damage );
	}
	
	public function OnHurt( amount = 0 )
	{
		if ( instance_exists( enemy ) )
		{
			scr_damage_enemy( enemy, amount );
		}
	}
	
	public function HealthChanged( val = 0 )
	{
		OnHealthChanged( val );
	}
	
	public function OnHealthChanged( val = 0 )
	{
		
	}
	
	// 
	
	public function Action_SetMercy( data )
	{
		if ( !data || data < 0 )
			data = 0;
		if ( data > 100 )
			data = 100;
		SetMemory( mymemories["mercy"].name, data );
	}
	
	
	
	public function MercyChanged( val = 0 )
	{
		OnMercy( val );
	}
	
	public function OnMercy( val = 0 )
	{
		
	}
	
	
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