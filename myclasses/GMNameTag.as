
// GM Name Tag
// by sage [ https://github.com/Sage64/Whirled ]
// Designed for my GMBody.as originally, converted into its own class

/*

Example usage of "just sticking it in main"

var nametag = new GMNameTag( _ctrl, this );
nametag.SetBaseColor( 0xFFFFFF );   // White text
nametag.SetBaseOutline( 0x000000 ); // Black outline
nametag.SetSleepColor( -1 );        // no sleep text
nametag.SetSize( 16 );              // default is 12
nametag.SetFont( "The /Font Name/ of a Font" ); // default is "_sans"
nametag.MainCode();

if you want to force certain text rather than your name
	nametag.SetText( "My Other, Cooler Name" );
	
if you change the nametag in any way after "creating" it:
	nametag.Apply();

for regular windows fonts
	use nametag.SetFont( "Font Name" );

for custom fonts
	import it into the libray ( right click, "New Font...")
	check Export for ActionScript (and Export in frame 1) under the ActionScript tab
	make sure the second argument of SetFont is true e.g
	nametag.SetFont( "My Font", true );

for the scale:
	use nametag.SetScale( 0.5 ); 
	set to 0 for automatic scaling
	set to -1 for automatic scaling that shrinks with the avatar to avoid cropping issues
*/

package
{

import flash.display.*;
import flash.events.*;
import flash.filters.*;
import flash.geom.*;
import flash.text.*;

import com.threerings.text.TextFieldUtil;
import com.whirled.*;

public class GMNameTag extends Sprite
{
	public var ctrl;
	public var container;
	public var show = true;
	
	public var baseColor = 0x99BFFF;
	public var baseOutline = 0x000000;
	
	public var sleepColor = 0x74797D;
	public var sleepOutline = 0x000000;
	
	public var glowFilter;
	public var outlineStrength = 40;
	
	public var customFont = false;
	public var upper = false;
	
	public var surf; // for surface_set_target
	
	public var textInit = {
		textColor: baseColor,
		selectable: false,
		autoSize: TextFieldAutoSize.CENTER,
		outlineColor: baseOutline,
		outlineWidth: 3.25
	};
	
	public var textFormat = new TextFormat();
	public var textObj;
	public var textW = 0;
	public var textH = 0;
	public var textScale = -1;
	
	public var alignH = 0;
	public var alignV = 1;
	
	public var gotName = false;
	
	public function GMNameTag( ctrl, container )
	{
		this.visible = false;
		this.ctrl = ctrl;
		this.container = container;
		
		this.textFormat.font = "_sans";
		this.textFormat.size = 12.25;
		this.textFormat.bold = false;
		this.textFormat.italic = false;
		this.textFormat.letterSpacing = 1;
		
		this.name = "Retrieving Name...";
		
		this.textObj = TextFieldUtil.createField( name, textInit, textFormat );
		
		this.addChild( textObj );
		this.container.addChild( this );
	}
	
	public function Cleanup()
	{
		removeChild( surf );
		removeChild( textObj );
		textObj = null;
		container.removeChild( this );
	}
	
	public function UpdatePosition()
	{
		var transformMatrix = container.transform.concatenatedMatrix;
		this.scaleX = 1 / transformMatrix.a;
		this.scaleY = 1 / transformMatrix.d;
		
		if ( textScale > 0 )
		{
			this.scaleX = textScale * ( this.scaleX > 0 ? 1 : -1 );
			this.scaleY = textScale * ( this.scaleY > 0 ? 1 : -1 );
		}
		else if ( ( textScale < 0 ) && ( this.scaleX > 1 || this.scaleY > 1 ) )
		{
			this.scaleX = 1;
			this.scaleY = 1;
		}
	}
	
	public function UpdateLook()
	{
		if ( !ctrl )
			return;
		if ( !gotName )
			SetText( GetName() );
		
		var outw = textInit.outlineWidth;
		if ( ctrl.isSleeping() )
		{
			if ( sleepColor == -1 )
				visible = false;
			else
			{
				visible = show && true;
				textObj.textColor = sleepColor;
				
				if ( outw > 0 )
				{
					glowFilter = new GlowFilter( uint( sleepOutline ), 1, outw, outw, outlineStrength );
					this.filters = [ glowFilter ];
				}
			}
		}
		else
		{
			if ( baseColor == -1 )
				visible = false
			else
			{
				visible = show && true;
				textObj.textColor = baseColor;
				if ( outw > 0 )
				{
					glowFilter = new GlowFilter( uint( baseOutline ), 1, outw, outw, outlineStrength );
					this.filters = [ glowFilter ];
				}
			}
		}
		if ( true )
		{
			textW = textObj.width / 2;
			textH = textObj.height;
			textObj.x = 0 - ( textW );
			textObj.y = 0 - ( textH );
			container.setChildIndex( this, container.numChildren - 1 );
		}
	}
	
	public function Show()
	{
		show = true;
		UpdateLook();
		//GetName();
		// Apply();
	}
	
	public function Hide()
	{
		show = false;
		UpdateLook();
	}
	
	// This nametag is designed to work with my GM base
	// but this should let it just work with anything
	public function MainCode()
	{
		if ( !ctrl )
			return;
		var ent = ctrl.getMyEntityId();
		var hotspot = ctrl.getEntityProperty( EntityControl.PROP_HOTSPOT, ent );
		if ( hotspot )
		{
			trace( hotspot );
			ctrl.setHotSpot( hotspot[0], hotspot[1], 1<<31 );
		}
		else
			trace( "Whirled entity: " + ent );
		ctrl.addEventListener( ControlEvent.APPEARANCE_CHANGED, MainCodeAppearance );
		container.addEventListener( Event.EXIT_FRAME, MainCodeFrame );
		Apply();
	}
	
	public function MainCodeFrame( event )
	{
		UpdatePosition();
	}
	public function MainCodeAppearance( event )
	{
		UpdateLook();
	}
	
	// 
	
	public function GetName()
	{
		// Get name
		var entity_id = ctrl.getMyEntityId();
		if ( entity_id != null )
		{
			var _get = ctrl.getEntityProperty( EntityControl.PROP_NAME, entity_id )
			if ( _get != null )
			{
				this.name = _get;
				this.gotName = true;
			}
		}
		return this.name;
	}
	
	//
	
	public function SetText( text = null )
	{
		if ( upper && text != null )
			text = text.toUpperCase();
		this.gotName = true;
		this.textInit.text = String( text );
		if ( this.textObj )
			this.textObj.text = this.textInit.text;
	}
	
	public function Apply()
	{
		var text = name;
		var embed = false;
		if ( this.textObj )
		{
			text = this.textObj.text;
			embed = this.textObj.embedFonts;
			this.removeChild( this.textObj );
			this.textObj = null;
		}
		this.textObj = TextFieldUtil.createField( text, this.textInit, this.textFormat );
		this.textObj.filters = [];
		if ( embed )
			this.textObj.embedFonts = true;
		this.addChild( textObj );
		if ( !this.surf )
		{
			this.surf = new Sprite();
			this.addChild( surf );
		}
		surf.x = 0;
		surf.y = 0;
		this.textObj.embedFonts = this.customFont;
		this.textObj.setTextFormat( this.textFormat );
		this.textObj.antiAliasType = AntiAliasType.ADVANCED;
		// 
		UpdateLook();
		UpdatePosition();
	}
	
	public function SetBaseColor( color )
	{
		this.baseColor = color;
		UpdateLook();
	}
	
	public function SetBaseOutline( color )
	{
		this.baseOutline = color;
		UpdateLook();
	}
	
	public function SetSleepColor( color )
	{
		this.sleepColor = color;
		UpdateLook();
	}
	
	public function SetSleepOutline( color )
	{
		this.sleepOutline = color;
		UpdateLook();
	}
	
	public function SetFont( _font, _isCustom = false )
	{
		this.customFont = _isCustom ? true : false;
		if ( this.textObj )
			this.textObj.embedFonts = this.customFont;
		this.textFormat.font = _font;
	}
	
	public function SetSize( _size )
	{
		this.textFormat.size = _size;
	}
	
	public function SetScale( _scale )
	{
		this.textScale = _scale;
	}
	
}

} // package















