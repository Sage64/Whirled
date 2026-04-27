// UndertaleBody
package undertale
{
import gamemaker.*;
import undertale.*;
public class UndertaleBody extends GMBody
{
	public var flip = null;
	
	public function UndertaleBody()
	{
		// Init
		if ( !global.undertale )
		{
			global.undertale = 1;
			global.flag = new Array( 100 );
			global.interact = 0;
		}
		
		super( 30 );
		SetScale( 3 );
		SetMoveSpeed( 2 );
		
		if ( SetNameTag() )
		{
			var _size = 20;
			nametag.SetBaseColor( 0xFFFFFF );
			nametag.SetBaseOutline( 0x000000 );
			nametag.SetFont( "8bitoperator JVE", true );
			//nametag.SetFont( "Determination Sans", true );
			nametag.SetSize( _size * 1 );
			nametag.textInit.outlineWidth = _size / 3.75;
			nametag.textInit.sharpness = 400;
			nametag.Apply();
		}
	}
	
	public function UTState( statename, sprite = null, image_speed = null )
	{
		state = super.AddState( statename );
		state.sprite = sprite;
		state.image_speed = image_speed;
		return state; 
	}
	
	public function BattleState( statename, ...data )
	{
		state = UTState( statename );
		state.battle = 1;
		state.data = data;
	}
	
	override public function OnStateChanged()
	{
		super.OnStateChanged();
		flip = ( state ) ? state.flip : null;
	}
	
	override public function OnUpdateLook()
	{
		global.facing = ( Math.round( ( 360 + 90 + direction ) / 90 ) ) % 4;
		super.OnUpdateLook();
		// 
		UpdateFlipped();
	}
	
	public function UpdateFlipped()
	{
		if ( ( flip != null ) && ( flip != 0 ) )
		{
			flipped = ( ( hDir * flip ) < 0 ) ? true : false;
		}
		else
			flipped = false;
	}
}
}
import gamemaker.*;
import undertale.*;
