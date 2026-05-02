// GM Entity

/*
	Entity base (Avatar, Pet, Furniture, Backdrop, etc)
	Base class for whirled entities to include memory functions, property getters
	and similar functions
*/

package gamemaker
{
import gamemaker.*;
import com.whirled.*;
import com.threerings.*;
import com.threerings.util.*;
public class GMEntity extends GMObject
{
	public var gm = GM;
	public var media = GMControl.ctrl;
	public var container = GMControl.container;
	public var ctrl = GMControl.ctrl;
	
	public var scale = 1;
	
	public var _eventlisteners = {
		list: [],
		func: {}
	};
	public var _eventqueue :Array = [];
	
	public var secure = false; // if true, don't share body ref through property getter
	public var customProps = {};

	public var mymemories = {};
	public var memories = {};
	public var memoryList = [];
	public var memory; // the current memory that caused the event or is being created
	
	public function GMEntity()
	{
		super();
		AddMemory( "gm", 1 ); // is a "GM" entity
		AddMemory( "gm.version", 0 );
		AddMemory( "gm.purchase_version", -1 );
	}
	
	// 
	
	public function GMControlEvent( event )
	{
		GMControl.Log( "Event: " + event.type + ": \"" + event.name + "\", " + event.value );
		_eventqueue.push( event );
	}
	
	public function GMProcessEvents()
	{
		GM.debugTracker = "GMBody.GMProcessEvents";
		for ( var i = 0; i < _eventqueue.length; ++i )
		{
			var event = _eventqueue.shift();
			if ( !event )
				continue;
			GM.debugTracker = "GMBody.GMProcessEvents ( event )";
			var func = _eventlisteners.func[event.type];
			if ( !func )
				continue;
			try
			{
				func( event );
			}
			catch(e)
			{
				GMControl.Caught(e);
			}
		}
	}
	
	public function SetScale ( amount )
	{
		scale = amount;
		return GMControl.SetScale( amount );
	}
	
	public function GetName()
	{
		if ( GMControl.entityID == null )
			GMControl.entityID == ctrl.getMyEntityId();
		if ( GMControl.entityID != null )
		{
			var _get = ctrl.getEntityProperty( EntityControl.PROP_NAME, GMControl.entityID )
			if ( _get != null )
			{
				name = String( _get );
				return name;
			}
		}
		return name + ".GetName()Failed";
	}
	
	public function SetVersion( version = 0 )
	{
		var _current = GetMemory( "gm.version" );
		var _bought = GetMemory( "gm.purchase_version" );
		
		if ( _bought == -1 )
		{
			SetMemory( "gm.purchase_version", version );
			_bought = version;
		}
		
		if ( version > _current )
		{
			GMControl.Log( "new version!" );
		}
		if ( version > _bought )
		{
			GMControl.Log( "you own version " + _bought );
		}
		
		GMControl.Log( "purchase_version: " + _bought );
		GMControl.Log( "current: " + _current );
		GMControl.Log( "release: " + version );
		SetMemory( "gm.version", version );
	}
	
	// return custom data from getEntityProperty 
	public function OnProperty( key = null )
	{
		return customProps[key];
	}
	
	// 
	
	public function GMEntityMoved( event )
	{
		GMControl.debugTracker = "+GMEntityMoved";
		if ( event == null )
			return;
		if ( event.name == GMControl.entityID )
			return;
		GMControl.debugTracker = "GMEntityMoved - Other";
		var res = ( event.value == null ) ? OnOtherMoveStop( event.name ) : OnOtherMoveStart( event.name, event.value );
		GMControl.debugTracker = "-GMEntityMoved";
	}
	
	public function OnOtherMoveStart( _id, _dest ) {}
	public function OnOtherMoveStop( _id ) {}
	
	// Memories
	
	public function AddMemory( key, defaultval = null, func = null )
	{
		GM.debugTracker = "GMBody.AddMemory"
		memory = {}
		memory.name = key;
		var memval;
		if ( ctrl )
		{
			memval = ctrl.getMemory( key, null );
		}
		else
		{
			GMControl.Warn( "AddMemory: NO CTRL!" );
		}
		
		if ( memval == null )
		{
			memval = defaultval;
			GMControl.Log( "Adding memory \"" + key + "\", value: " + memval );
		}
		else
		{
			// defaultval = memval;
			GMControl.Log( "Adding memory \"" + key + "\", value: " + memval + " (default: " + defaultval + ")" );
		}
		
		
		memory.value = memval;
		memory.func = func;
				
		memories[key] = memory;
		memoryList.push( memory );
		
		var event = {};
		event.type = ControlEvent.MEMORY_CHANGED;
		event.name = memory.name;
		event.value = memory.value;
		
		GMControl.GMControlEvent( event );
		
		GM.debugTracker = "After GMBody.AddMemory"
		return memory;
	}
	
	// Set a memory via its AddMemory name
	public function SetMemory( name, value )
	{
		if ( name is String )
		{}
		else
			name = name.name;
		memory = memories[name];
		if ( !memory )
		{
			GMControl.Log( "memory " + name + " not found" );
			return;
		}
		if ( !memory.dontlog )
			GMControl.Log( memory.name + " = " + memory.value );
		if ( memory.value == value )
		{
			
		}
		//ctrl.SetMemory( memory.name, value );
		if ( ctrl.isConnected() )
		{
			ctrl.setMemory( memory.name, value );
		}
		else
		{
			memory.value = value;
			var event = {};
			event.type = ControlEvent.MEMORY_CHANGED;
			event.name = memory.name;
			event.value = memory.value;
			GMControl.GMControlEvent( event );
		}
	}
	
	// Retrieve a memory from its AddMemory name
	public function GetMemory( name, defaultval = 0 )
	{
		memory = memories[name];
		if ( memory )
			return memory.value;
	}
	
	public function OnMemoryChanged( key, value )
	{
		memory = memories[key];
		//GM.Log( "Memory \"" + key + "\" set to \"" + value + "\"" );
		if ( memory )
		{
			memory.value = value;
			if ( memory.func )
			{
				if ( memory.func.length == 0 )
					memory.func();
				else
					memory.func( value );
			}
		}
	}
	
	public function BroadcastMessage( message = "", data = null )
	{
		ctrl.sendMessage( message, data );
	}
	
	public function OnReceiveMessage( message )
	{
		
	}
	
	public function OnReceiveSignal( message )
	{
		
	}
}
}