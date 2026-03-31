
// GM Control Panel
// by sage [ https://github.com/Sage64/Whirled ]
// Part of GMBody.as

// Debug panel to be created via ctrl.showPopup();
// 
// 

package gamemaker
{

import flash.display.*;
import flash.events.*;
import flash.filters.*;
import flash.geom.*;
import flash.text.*;

import com.threerings.text.TextFieldUtil;
import com.whirled.*;

public class GMControlPanel extends Sprite
{
	public var media;
	public var ctrl;
	public var body;
	
	public var container;
	
	public var hasParent = false;
	
	public var rootPanel = null;
	
	public var panelW;
	public var panelH;
	public var needsLayout = true;
	public var needsRedraw = true;
	
	public var textFormat;
	public var logText;
	
	
	public function GMControlPanel( width = 480, height = 270 )
	{
		this.name = "GMControlPanel";
		this.panelW = width;
		this.panelH = height;
		
		rootPanel = new ControlPanel();
		
		// debug init
		if ( false ) //GM.debug )
		{
			
			media = GM.media;
			if ( media )
				media.addChild( this );
			x = 600;
			y = 0;
		}
		
		
		this.container = new Sprite();
		container.opaqueBackground = 0x282C34;
		container.width = width;
		container.height = height;
		
		this.addChild( container );
		
		// Panel
		this.opaqueBackground = 0x282C34;
		
		textFormat = new TextFormat();
		textFormat.align = "left";
		textFormat.color = 0xC0C0C0;
		textFormat.font = "Consolas";
		textFormat.kerning = false;
		textFormat.size = 12;
		textFormat.bold = true;
		
		logText = new TextField();
		logText.multiline = true;
		logText.wordWrap = true;
		logText.text = ( "Debug Log Text " );
		logText.setTextFormat( textFormat );
		
		container.addChild( logText );
		
		OnLayout();
	}
	
	public function Step()
	{
		if ( needsLayout )
		{
			needsLayout = false;
			OnLayout();
		}
		
		if ( !rootPanel )
			return;
		rootPanel.x = 0;
		rootPanel.y = 0;
		rootPanel.SetSize( panelW, panelH );
	}
	
	public function Draw()
	{
		if ( !rootPanel )
			return;
		rootPanel.PanelDraw();
	}
	
	
	public function Relayout()
	{
		needsLayout = true;
	}
	
	public function OnLayout()
	{
		rootPanel.x = 0;
		rootPanel.y = 0;
		rootPanel.SetSize( panelW, panelH );
		
		logText.x = 0;
		logText.y = 0;
		
		logText.text = "LOG";
		var len = GM.debug_log.length;
		for ( var i = 0; i < len; ++i )
		{
			logText.appendText( "\n" + GM.debug_log[i]);
		}
		
		logText.setTextFormat( textFormat );
		
		logText.width = panelW;
		logText.height = panelH;
		
		logText.scrollV = logText.maxScrollV;
		
		container.width = panelW;
		container.height = panelH;
	}
	
	//
	
	public function SetSize( ww, hh )
	{
		if ( ww == panelW && hh == panelH )
			return;
		width = ww;
		height = hh;
		panelW = ww;
		panelH = hh;
		container.width = ww;
		container.height = hh;
		Relayout();
	}
}



}

import flash.display.*
//
import flash.events.*;
// 
import flash.filters.*;
// 
import flash.geom.*;
// 

import com.threerings.util.*
import com.whirled.*;

// Base panels

class Panel extends Sprite 
{ 
	
	public var panelW;
	public var panelH;
	
	public var needsLayout = true;
	public var needsRedraw = true;
	
	public function Panel( _parent = null )
	{
		this.cacheAsBitmap = true;
		
		if ( _parent )
		{
			_parent.addChild( this );
		}
	}
	
	public function Cleanup()
	{
		if ( parent )
		{
			parent.removeChild( this );
		}
	}
	
	// Layout
	
	public function Relayout( now = false )
	{
		needsLayout = true;
		if ( now )
			PanelLayout();
	}
	
	private function PanelLayout()
	{
		
	}
	
	public function OnLayout()
	{
		
	}
	
	// Draw
	
	private function PanelDraw()
	{
		Draw();
	}
	
	public function Draw()
	{
		
	}
	
	// Position
	
	public function SetSize( ww, hh )
	{
		if ( ww == panelW && hh == panelH )
			return;
		width = ww;
		height = hh;
		panelW = ww;
		panelH = hh;
		Relayout();
	}
}

// 

class ControlPanel extends Panel
{
	
	public function ControlPanel( _parent = null )
	{
		super( _parent );
		
	}
}

class DebugLog extends Panel
{
	public var logText = null;
	public var atBottom = false;
	
	public function DebugLog( _parent )
	{
		super( _parent );
		
	}
	
	override public function OnLayout()
	{
		atBottom = logText.scrollV == logText.maxScrollV;
		
		
		
		if ( atBottom )
			logText.scrollV = logText.maxScrollV;
	}
	
	override public function Draw()
	{
		
	}
}