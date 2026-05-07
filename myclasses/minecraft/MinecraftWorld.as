package minecraft
{
import gamemaker.*;
import minecraft.*;
public class MinecraftWorld extends GMEntity
{
	public var isHost = false;
	
	public var world;
	public var background;
	public var foreground;
	public var ui;
	//
	public var xsize = 1;
	public var ysize = 1;
	public var groundlevel = 24;
	// 
	public function MinecraftWorld()
	{
		super();
	}
	// 
	public function Start_Background( xsize = 1, ysize = 1, groundlevel = 24 )
	{
		name = "MinecraftWorld_Background";
		world = instance_create_depth( 0, true ? ( ysize * ( 16 * 16 ) ) : ( GM.stageH / SCALE ), 0, World );
		world.xsize = xsize;
		world.ysize = ysize;
		world.groundlevel = Math.floor( groundlevel );
		world.columns.length = xsize;
		if ( true )
		{
			for ( var i = CHUNK_DEPTH; i > 2 ; --i )
			{
				var inst = instance_create_depth( 0, 0, i - 1, WorldLayer );
				inst.world = world;
			}
			background = instance_create_depth( 0, 0, 1, WorldLayer );
			background.world = world;
		}
		for ( var i = 0; i < world.xsize; ++i )
			world.GetChunk( i, 0 );
		
		Broadcast( "mc:announce", GMControl.entityID );
	}
	// 
	public function Start_Foreground()
	{
		name = "MinecraftWorld_Foreground";
		if ( true )
		{
			foreground = instance_create_depth( 0, 0, 0, WorldLayer );
			foreground.world = world;
		}
		
		if ( true )
			ui = instance_create_depth( 0, 0, -1024, UI );
		Broadcast( "mc:announce", GMControl.entityID );
	}
	
	//
	
	override public function Step()
	{
		isHost = ( GMControl.isControl );
		
		if ( isHost )
			Step_Host();
		else
			Step_Client();
		
	}
	
	public function Step_Host()
	{
		
	}
	
	public function Step_Client()
	{
		
	}
	
	//
	
	override public function OnProperty( key = null )
	{
		switch( key )
		{
			case "mc:world":
				return this;
		}
		return super.OnProperty( key );
	}
	
	override public function OnGetEntity( entity )
	{
		Broadcast( "log", entity.entityID + ": " + entity.name );
		if ( entity == GMControl.entity )
		{
			Broadcast( "log", "MinecraftWorld: Ignoring self from OnGetEntity" );
		}
		var other = entity.GetProperty( "mc:world" );
		if ( other == this )
		{
			Broadcast( "log", "other == self" );
			return;
		}
		
		Broadcast( "log", name + ": other = " + other.name );
		if ( other )
		{
			if ( instance_exists( other.world ) )
			{
				this.world = other.world;
				if ( instance_exists( foreground ) )
				{
					Broadcast( "log", "foreground: got background world" );
					foreground.world = this.world;
				}
			}
			if ( instance_exists( other.ui ) )
			{
				Broadcast( "log", "background: got foreground UI" );
				this.ui = other.ui;
				if ( instance_exists( other.foreground ) && ( !instance_exists( other.foreground.world ) ) )
				{
					other.foreground.world = world;
				}
			}
		}
		return super.OnGetEntity( entity );
	}
}
}

import gamemaker.*;
import minecraft.*;
import flash.display.*;

const SCALE = 5;
const BLOCK_SIZE = 16;
const CHUNK_SIZE = 16;
const CHUNK_DEPTH = 4;

const BLOCKS = [];

const BLOCK_GRASS = new Block( "Grass", "grass_block_side" );
const BLOCK_DIRT = new Block( "Dirt", "dirt" );
const BLOCK_STONE = new Block( "Stone", "stone" );
const BLOCK_BEDROCK = new Block( "Bedrock", "bedrock" );

// Block

class Block extends GMFunctions
{
	public static var blockCount = 0;
	public var name = "block";
	public var block_id = blockCount++;
	public var face_t;
	public var face_s;
	
	public function Block( name, face_s )
	{
		super();
		BLOCKS[block_id] = this;
		this.name = name;
		this.face_s = global["block/" + face_s];
		GM.Log( "Adding block " + block_id + ": " + name );
	}
}

// World

class World extends GMObject // Default world - Superflat
{
	public var xsize = 0;
	public var ysize = 0;
	public var groundlevel = 0;
	public var columns = [];
	
	public var tick = 0;
	public var tick_rate = 20;
	public var tick_time = ( 1000 / tick_rate );
	public var tick_next = 0;
	
	public function World()
	{
		super();
		// container_blend( bg_container, merge_color( c_white, c_black, 0.35 ) );
		
	}
	
	override public function Cleanup()
	{
		
	}
	
	// 
	
	override public function Draw()
	{
		DrawSky();
	}
	
	public function DrawSky()
	{
		draw_set_color( 0x0099FF );
		draw_rectangle( 0, 0, GM.stageW / SCALE, GM.stageH / SCALE, false );
	}
	
	public function DrawChunks()
	{
		for ( var i = 0; i < columns.length; ++i )
			columns[i].Draw();
	}
	
	//
	
	override public function Step()
	{
		var _time = current_time;
		var _ticks = 0;
		while ( _time >= tick_next )
		{
			_ticks++;
			tick_next += ( tick_time );
			if ( _ticks < 2 )
				Tick();
		}
	}
	
	public function Tick()
	{
		++tick;
		
	}
	
	//
	
	public function GetChunk( xx, yy )
	{
		var _x = Math.floor( xx );
		if ( _x < 0 )
			return;
		if ( _x >= xsize )
			return;
		var _column = ( columns[_x] );
		if ( !_column )
		{
			columns[_x] = new ChunkColumn( this, _x );
		}
		if ( _column )
			return _column.GetChunk( yy );
	}
	
	public function GenerateBlockAt( xx, yy, zz = 0 )
	{
		var _y = yy; //= ( ysize * CHUNK_SIZE ) - ( yy );
		var groundlevel = this.groundlevel;
		var dirtlevel = 1;
		if ( zz > 0 )
		{
			groundlevel += 1;
			dirtlevel += 1;
			
			groundlevel += ( zz );
			dirtlevel += ( zz );
		}
		_y -= 0;
		if ( _y > groundlevel )
		{
			
			return;
		}
		if ( _y < 0 )
			return;
		if ( _y < 1 )
			return BLOCK_BEDROCK;
		if ( _y < ( groundlevel - dirtlevel ) )
			return BLOCK_STONE;
		if ( _y < groundlevel )
			return BLOCK_DIRT;
		if ( _y == groundlevel )
			return BLOCK_GRASS;
		return;
	}
}

class WorldLayer extends GMObject
{
	public var z = 0;
	public var world;
	public var block_container;
	
	public function WorldLayer()
	{
		super();
		block_container = container_create();
		this.z = depth;
		depth = ( z * BLOCK_SIZE );
		container_blend( block_container, merge_color( c_white, c_black, 0.05 + ( ( z > 0 ) ? ( 0.25 + ( z * 0.15 ) ) : 0 ) ) );
		trace( "WorldLayer - z = " + z );
	}
	
	override public function Cleanup()
	{
		container_destroy( block_container );
		super.Cleanup();
	}
	
	override public function Draw()
	{
		if ( !instance_exists( world ) )
		{
			return;
		}
		DrawChunks();
	}
	
	public function DrawChunks()
	{
		for ( var i = 0, amnt = world.columns.length; i < amnt; ++i )
		{
			var column = world.columns[i];
			if ( !column )
				continue;
			column.Draw( this );
		}
	}
}

class LayerChunk extends GMFunctions
{
	public var x = 0;
	public var y = 0;
	public var z = 0;
	public var worldlayer;
	public var block_container;
	
	public function LayerChunk( worldlayer = null, z = 0 )
	{
		super();
		this.worldlayer = worldlayer;
		this.z = z;
		block_container = container_create( worldlayer.block_container )
		block_container.cacheAsBitmap = true;
	}
	
	public function Cleanup()
	{
		container_destroy( block_container );
	}
}


// 16 block wide column
class ChunkColumn extends GMFunctions
{
	public var x = 0;
	public var y = 0;
	
	public var world;
	public var rows = [];
	public var ground_top = []; // Highest block Y, for rain, etc
	
	
	public var chunkx = 0; 
	public var chunky = 0;
	
	public function ChunkColumn( world, chunkx )
	{
		this.y = 0;
		this.x = ( chunkx * ( CHUNK_SIZE * BLOCK_SIZE ) );
		
		this.world = world;
		this.chunkx = chunkx;
		
		rows.length = world.ysize;
		
		Generate();
	}
	
	public function Cleanup()
	{
		
	}
	
	public function Draw( worldlayer )
	{
		for ( var i = 0, amnt = rows.length; i < amnt; ++i )
		{
			if ( !rows[i] )
				continue;
			rows[i].Draw( worldlayer );
		}
		// draw_set_color( c_yellow );
		// draw_line( x, y, x, y + ( world.ysize * ( CHUNK_SIZE ) * ( BLOCK_SIZE ) ) );
	}
	
	public function GetChunk( yy )
	{
		var _y = yy;
		if ( _y < 0 )
			return;
		if ( _y >= world.ysize )
			return;
		var _chunk = rows[_y];
		if ( !_chunk )
		{
			_chunk = new Chunk( this.world, this.chunkx, _y );
			_chunk.Generate();
			rows[_y] = _chunk;
		}
		return _chunk;
	}
	
	public function Generate()
	{
		for ( var i = 0; i < rows.length; ++i )
		{
			GetChunk( i );
		}
	}
}

// 16x16 chunk
class Chunk extends GMFunctions
{
	public var x = 0;
	public var y = 0;
	
	public var world = null;
	public var layers = new Array( CHUNK_DEPTH );
	public var blocks = [];
	
	public var ready = false;
	
	public var chunkx = 0;
	public var chunky = 0;
	
	public var redraw = true;
	
	public function Chunk( world, chunkx, chunky )
	{
		super();
		this.world = world;
		this.x = chunkx * ( CHUNK_SIZE * BLOCK_SIZE );
		this.y = world.y - ( chunky * ( CHUNK_SIZE * BLOCK_SIZE ) );
		this.chunkx = chunkx;
		this.chunky = chunky;
		for ( var i = 0; i < CHUNK_SIZE; ++i )
		{
			blocks[i] = new Array( CHUNK_SIZE );
			for ( var j = 0; j < CHUNK_SIZE; ++j )
			{
				blocks[i][j] = new Array( CHUNK_DEPTH );
			}
		}
		// background tiles
		// bg_container = container_create( world.bg_container );
		// bg_container.x = this.x;
		// bg_container.y = this.y;
		// bg_container.visible = false;
		// foreground tiles
		// fg_container = container_create( world.fg_container );
		// fg_container.x = this.x;
		// fg_container.y = this.y;
		// fg_container.visible = false;
	}
	
	public function Cleanup()
	{
		
	}
	
	public function Generate()
	{
		var xx = 0, yy = 0, zz = 0;
		for ( xx = 0; xx < CHUNK_SIZE; ++xx )
		{
			for ( yy = 0; yy < CHUNK_SIZE; ++yy )
			{
				for ( zz = 0; zz < CHUNK_DEPTH; ++zz )
					blocks[xx][yy][zz] = world.GenerateBlockAt( ( chunkx * CHUNK_SIZE ) + xx, ( chunky * CHUNK_SIZE ) + yy, zz );
			}
		}
		redraw = true;
		ready = true;
	}
	
	public function Draw( worldlayer )
	{
		if ( !ready )
			return;
		
		var zz = worldlayer.z;
		var layer = layers[zz];
		if ( !layer )
		{
			layer = new LayerChunk( worldlayer, zz );
			layers[zz] = layer;
			layer.x = this.x;
			layer.y = this.y;
			layer.block_container.x = layer.x;
			layer.block_container.y = layer.y;
			redraw = true;
		}
		
		if ( redraw )
		{
			redraw = false;
			if ( y > ( GM.stageH / SCALE ) )
				return;
			for ( var i = 0; i < layers.length; ++i )
			{
				layer = layers[i];
				if ( !layer )
					continue;
				RedrawChunk( layer.block_container, zz );
			}
		}
	}
	
	public function RedrawChunk( container, zz = 0 )
	{
		var _x = 0; // this.x;
		var _y = 0; // this.y;
		var _z = 0; //
		var xx = 0, yy = 0;
		surface_set_target( container );
		//container_clear( container );
		container.visible = true;
		for ( yy = 0; yy < CHUNK_SIZE; ++yy )
		{
			var y1 = _y - ( yy * BLOCK_SIZE );
			y1 -= BLOCK_SIZE;
			for ( xx = 0; xx < CHUNK_SIZE; ++xx )
			{
				var x1 = _y + ( xx * BLOCK_SIZE );
				var _block = blocks[xx][yy][zz];
				if ( !_block )
					continue;
				var spr = _block.face_s;
				draw_sprite_ext( spr, 0, x1, y1, 1, 1, 0, c_white, 1 );
			}
		}
		surface_reset_target();
	}
}

// UI

internal const MAX_SLOT = 8;

class UI extends GMObject
{
	public var hotbar;
	
	public function UI()
	{
		super();
		image_speed = 0;
	}
	
	override public function Create()
	{
		hotbar = instance_create_depth( 0, 0, depth, UI_Hotbar );
	}
	
	override public function Cleanup()
	{
		instance_destroy( hotbar );
	}
	
	override public function Draw()
	{
		
	}
	
	override public function Step()
	{
		if ( false )
		{
			
		}
		else if ( instance_exists( hotbar ) )
		{
			hotbar.DoInput();
		}
		
	}
}

class UI_Hotbar extends GMObject
{
	public var slot = 4;
	public var edge = -8;
	
	public var spr_hotbar_selection = global["gui/sprites/hud/hotbar_selection"];
	
	public var slot_items = new Array( MAX_SLOT );
	
	public function UI_Hotbar()
	{
		sprite_index = global["gui/sprites/hud/hotbar"];
		image_speed = 0;
	}
	
	override public function Draw()
	{
		draw_self();
		
		var xx = this.x;
		var yy = this.y;
		
		xx += ( ( 1 + ( 20 * slot ) ) * image_xscale ) - ( image_xscale * 2 );
		yy += ( 24 );
		
		draw_sprite_ext( spr_hotbar_selection, 0, xx, yy - ( image_yscale ), image_xscale, -image_yscale, image_angle, image_blend, image_alpha );
	}
	
	//
	
	override public function Step()
	{
		var mx = mouse_x, my = mouse_y;
		
		if ( mx < ( x - edge ) )
		{
			x = mx + edge;
		}
		else if ( mx > ( x + sprite_width + edge ) )
		{
			x = ( mx - sprite_width ) - edge;
		}
	}
	
	public function DoInput()
	{
		var mx = mouse_x, my = mouse_y;
		if ( ( my <= ( y + sprite_height ) ) && ( mouse_check_button_pressed( mb_left ) || mouse_check_button_pressed( mb_middle ) ) )
		{
			SetSlot( Math.floor( ( mx - this.x - 1 ) / 20 ) );
			if ( true )
			{
				// GMControl.DoPopup(  );
			}
		}
		for ( var i = 49; i < 58; ++i )
		{
			if ( keyboard_check_pressed( i ) )
				SetSlot( i - 49 );
		}
		if ( mouse_wheel_up() )
			SetSlot( slot - 1 );
		if ( mouse_wheel_down() )
			SetSlot( slot + 1 );
	}
	
	public function SetSlot( i )
	{
		if ( i < 0 )
			i = 0;
		if ( i > MAX_SLOT )
			i = MAX_SLOT;
		if ( i == slot )
			return;
		slot = i;
	}
}













