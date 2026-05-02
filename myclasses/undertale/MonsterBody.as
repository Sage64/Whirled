// MonsterBody
package undertale
{
import gamemaker.*;
import undertale.*;
internal class MonsterBody extends UndertaleBody
{
	public var npc; // npc instance
	public var enemy; // battle instance
	
	public function MonsterBody()
	{
		super();
		
		// AddAction( "NPC - []", Action_ );
		// AddAction( "Enemy - [Hurt 50]", Action_Hurt, 50 );
	}
	
	
	
	override public function OnStateChanged()
	{
		
	}
	
	override public function OnUpdateLook()
	{
		super.OnUpdateLook();
		
	}
	
	// 
	
	
	
	
	public function Action_Hurt( data = null )
	{
		var damage = ( data ) ? data : 0;	
	}
}
}

import gamemaker.*;
import undertale.*;

