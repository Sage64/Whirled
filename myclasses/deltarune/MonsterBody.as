
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
        
		mymemories["health"] = AddMemory( "deltarune.monster.hp", -1, HealthChanged );
		myactions["damage_weak"] = AddAction( "[Hurt 50]", Action_Hurt, 50 );
		myactions["damage_strong"] = AddAction( "[Hurt 150]", Action_Hurt, 150 );
		
		mymemories["mercy"] = AddMemory( "deltarune.monster.mercy", 0, MercyChanged );
		myactions["mercy_0"] = AddAction( "[SetMercy 0%]", Action_SetMercy, 0 );
		myactions["mercy_100"] = AddAction( "[SetMercy 100%]", Action_SetMercy, 100 );
	}
	
	override public function Draw()
	{
		super.Draw();
	}
	
	public function SetUseDamage( on = 1 )
	{
		myactions["damage_weak"].hidden = !on;
		myactions["damage_strong"].hidden = !on;
	}
	
	public function SetUseMercy( on = 1 )
	{
		myactions["mercy_0"].hidden = !on;
		myactions["mercy_100"].hidden = !on;
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
			scr_spell( 1, enemy, amount );
			
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
	
	// Functions
	
	public static function scr_spell( spell = 0, target = null, damage = 100 )
	{
		switch ( spell )
		{
			case 0: // None
				break;
			case 1: // Basic Attack
				var cancelattack = 0;
				if  ( ( cancelattack == 0 ) && ( instance_exists( target ) ) )
				{
					scr_damage_enemy( target, damage );
					
					var attack = instance_create( target.x + ( gml.random( 6 ) - 3 ), target.y + ( gml.random( 6 ) - 3 ), obj_basicattack );
					if ( target.body )
						attack.y -= ( target.body.characterH / 2 );
					//attack.sprite_set( global.spr_attack_mash );
				}
				break;
				
		}
	}
	
	public static function scr_damage_enemy( target, amount )
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
			target.hurtamt = amount;
		}
	}
}
// 
}