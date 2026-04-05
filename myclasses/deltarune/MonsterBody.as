
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
	
	Use "enemy" for the monster instance
	e.g enemy = instance_create( x, y, obj_monster );
*/
public class MonsterBody extends DeltaruneBody
{
	public var enemy;
    
	public var use_mercy = true;
	public var use_damage = true;
	
	public var chaseaura = 0;
	
	public function MonsterBody()
	{
		super();
		
		// Base properties
		
		characterH = 40;
		
        darkmode = true;
        
		SetMoveSpeed( 5 );
        
		// Avatar
		
		// Deltarune
		
		SetMemory( "deltarune.forcedarkzone", 1 );
		
		global.darkzone = 1;
		
		darkmode = true;
		if ( darkmode )
		{
			darkmode = true;
			SetScale ( darkscale );
			image_xscale = 2;
			image_yscale = 2;
			characterH *= darkscale;
		}
        
		mymemories["chase_aura"] = AddMemory( "deltarune.monster.chasing", 0, SetChaseAura );
		myactions["toggle_chaseaura"] = AddAction_ToggleMemory( "[Toggle NPC Chase Aura]", "deltarune.monster.chasing" );
		
		mymemories["monsterhp"] = AddMemory( "deltarune.monster.hp", -1, HealthChanged );
		myactions["damage_weak"] = AddAction( "[Hurt 50]", Action_Hurt, 50 );
		myactions["damage_strong"] = AddAction( "[Hurt 150]", Action_Hurt, 150 );
		
		mymemories["mercy"] = AddMemory( "deltarune.monster.mercy", 0, SetMercy );
		myactions["mercy_0"] = AddAction( "[SetMercy 0%]", Action_SetMercy, 0 );
		myactions["mercy_100"] = AddAction( "[SetMercy 100%]", Action_SetMercy, 100 );
		
		mystates["enemy_idle"] = EnemyState( "Enemy - Idle" );
		mystates["enemy_spared"] = EnemyState( "Enemy - Spared" );
		mystates["enemy_defeated"] = EnemyState( "Enemy - Defeated" );
		mystates["enemy_dead"] = EnemyState( "Enemy - Dead" );
		mystates["enemy_frozen"] = EnemyState( "Enemy - Frozen" );
		
		mystates["enemy_idle"].hidden = true;
		mystates["enemy_spared"].hidden = true;
		mystates["enemy_defeated"].hidden = true;
		mystates["enemy_dead"].hidden = true;
		mystates["enemy_frozen"].hidden = true;
		
	}
	
	public function EnemyState( statename )
	{
		var State = DWState( statename );
		State.hidden = false;
		State.enemy = 1;
			
		return State; 
	}
	
	// If they already exist, doing this will push
	// them to the bottom of the state list
	public function AddEnemyStates()
	{
		mystates["enemy_idle"] = EnemyState( "Enemy - Idle" );
		mystates["enemy_spared"] = EnemyState( "Enemy - Spared" );
		mystates["enemy_defeated"] = EnemyState( "Enemy - Defeated" );
		mystates["enemy_dead"] = EnemyState( "Enemy - Dead" );
		mystates["enemy_frozen"] = EnemyState( "Enemy - Frozen" );
	}
	
	// 
	
	override public function OnStateChanged()
	{
		super.OnStateChanged();
		
	}
	
	override public function OnUpdateLook()
	{
		super.OnUpdateLook();
		
		if ( instance_exists( enemy ) )
		{
			enemy.mercymod = GetMemory( "deltarune.monster.mercy" );
		}
	}
	
	// 
	
	override public function Step()
	{
		super.Step();
		StepEnemy();
	}
	
	public function StepEnemy()
	{
		if ( curState && instance_exists( enemy ) )
		{
			switch ( curState )
			{
				case mystates["enemy_idle"]:
					break;
				case mystates["enemy_spared"]:
					enemy.scr_spare();
					break;
				case mystates["enemy_defeated"]:
					enemy.hurt_fatal = 0;
					enemy.hurt_frozen = 0;
					enemy.monsterhp = 0;
					enemy.scr_monsterdefeat();
					enemy.scr_defeatrun();
					break;
				case mystates["enemy_dead"]:
					enemy.hurt_fatal = 1;
					enemy.hurt_frozen = 0;
					enemy.monsterhp = 0;
					enemy.scr_monsterdefeat();
					enemy.scr_defeatrun();
					break;
				case mystates["enemy_frozen"]:
					enemy.hurt_fatal = 1;
					enemy.hurt_frozen = 1;
					enemy.monsterhp = 0;
					enemy.scr_monsterdefeat();
					enemy.scr_defeatrun();
					break;
			}
		}
	}
	
	override public function Draw()
	{
		super.Draw();
	}
	
	// 
	
	public function SetUseDamage( on = 1 )
	{
		use_damage = on;
		myactions["damage_weak"].hidden = !use_damage;
		myactions["damage_strong"].hidden = !use_damage;
	}
	
	public function SetUseMercy( on = 1 )
	{
		use_mercy = on;
		myactions["mercy_0"].hidden = !use_mercy;
		myactions["mercy_100"].hidden = !use_mercy;
	}
	
	//
	
	public function Action_Hurt( data )
	{
		var damage = 0;
		if ( data )
			damage = data;
		
		OnHurt( damage );
	}
	
	public function OnHurt( amount = 0 )
	{
		if ( instance_exists( enemy ) )
		{
			scr_basicattack( enemy, amount );
			
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
	
	public function SetMercy( val = 0 )
	{
		OnMercy( val );
	}
	
	public function OnMercy( val = 0 )
	{
		
	}
	
	// Chasing
	public function SetChaseAura( val = 0 )
	{
		chaseaura = val;
	}
	
	public function Action_ToggleChaseAura( data = null )
	{
		SetMemory( "deltarune.monster.chasing", chaseaura ? 0 : 1 );
	}
	
	
	public static function scr_basicattack( target = null, damage = 100 )
	{
		var cancelattack = 0;
		if  ( ( cancelattack == 0 ) && ( instance_exists( target ) ) )
		{
			scr_damage_enemy( target, damage );
			
			var attack = instance_create( target.x + ( gml.random( 6 ) - 3 ), target.y + ( gml.random( 6 ) - 3 ), obj_basicattack );
			if ( target.body )
				attack.y -= ( target.body.characterH / 2 );
			//attack.sprite_set( global.spr_attack_mash );
		}
	}
	
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
					attack.sprite_set( global.spr_attack_mash );
				}
				break;
				
		}
	}
	
	public static function scr_damage_enemy( target, amount )
	{
		if ( !instance_exists( target ) )
			return;
		// Damage indicator
		if ( false )
		{
			var dmgx = target.x;
			var dmgy = target.y - 20;
			var dmg = instance_create( dmgx, dmgy, obj_dmgwriter );
		
		}
		// Damage target
		target.shakex = 9;
		target.state = 3;
		target.hurttimer = 30;
		target.hurtamt = amount;
		
		if ( false )
		{
			if ( target.monsterhp > 0 )
				target.monsterhp = max( 0, target.monsterhp - amount );
			trace( "monsterhp = " + target.monsterhp );
			if ( target.monsterhp <= 0 )
			{
				target.scr_monsterdefeat();
			}
		}
	}
	
	
}
// 
}