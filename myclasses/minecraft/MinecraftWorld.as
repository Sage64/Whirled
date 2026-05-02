package minecraft
{
import gamemaker.*;
public class MinecraftWorld extends GMEntity
{
	public var world;
	public var ui;
	
	public function MinecraftWorld()
	{
		super();
	}
	
	public function Start( xsize = 1, ysize = 1, groundlevel = 24 )
	{
		this.world = instance_create_depth( 0, 0, 0, World );
		world.xsize = xsize;
		world.ysize = ysize;
		world.groundlevel = Math.floor( groundlevel );
		world.columns.length = xsize;
		for ( var i = 0; i < world.xsize; ++i )
			world.GetChunk( i, 0 );
	}
	
	public function Start_UI()
	{
		this.ui = instance_create_depth( 0, 0, 0, UI );
	}
	
	
	
}
}

import gamemaker.*;
import minecraft.*;

internal const SCALE = 5;

internal const CHUNK_SIZE = 16;
internal const BLOCK_SIZE = 16;

// World

class World extends GMObject // Superflat
{
	public var xsize = 0;
	public var ysize = 0;
	public var groundlevel = 0;
	public var columns = [];
	
	public var isHost = false;
	
	public function World()
	{
		super();
		
	}
	
	// 
	
	override public function Draw()
	{
		DrawSky();
		
		DrawChunks();
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
			columns[_x] = new Column( this, _x );
		}
		if ( _column )
			return _column.GetChunk( yy );
	}
	
	public function GenerateBlockAt( xx, yy )
	{
		var _y = ( ysize * CHUNK_SIZE ) - ( yy );
		_y -= 0;
		if ( _y < 0 )
			return;
		if ( _y <= 1 )
			return global["block/bedrock"];
		if ( _y < ( groundlevel - 1 ) )
			return global["block/stone"];
		if ( _y < groundlevel )
			return global["block/dirt"]
		if ( _y == groundlevel )
			return global["block/grass_block_side"]
		return;
	}
}

class Column extends GMFunctions
{
	public var x = 0;
	public var y = 0;
	
	public var world;
	public var rows = [];
	
	public var chunkx = 0;
	public var chunky = 0;
	
	public function Column( world, chunkx )
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
	
	public function Draw()
	{
		for ( var i = 0; i < rows.length; ++i )
		{
			if ( !rows[i] )
				continue;
			rows[i].Draw();
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

class Chunk extends GMFunctions
{
	public var x = 0;
	public var y = 0;
	
	public var world = null;
	public var blocks = [];
	
	public var chunkx = 0;
	public var chunky = 0;
	
	
	public var bg_container;
	public var fg_container;
	
	public function Chunk( world, chunkx, chunky )
	{
		super();
		this.world = world;
		this.x = chunkx * ( CHUNK_SIZE * BLOCK_SIZE );
		this.y = chunky * ( CHUNK_SIZE * BLOCK_SIZE );
		this.chunkx = chunkx;
		this.chunky = chunky;
		for ( var i = 0; i < CHUNK_SIZE; ++i )
			blocks[i] = new Array( CHUNK_SIZE );
	}
	
	public function Generate()
	{
		for ( var xx = 0; xx < CHUNK_SIZE; ++xx )
		{
			for ( var yy = 0; yy < CHUNK_SIZE; ++yy )
			{
				blocks[xx][yy] = 0;
				blocks[xx][yy] = world.GenerateBlockAt( ( chunkx * CHUNK_SIZE ) + xx, ( chunky * CHUNK_SIZE ) + yy );
				// trace( blocks[xx][yy] );
			}
		}
	}
	
	public function Draw()
	{
		// draw_set_color( c_yellow );
		// draw_line( this.x, this.y, this.x + ( BLOCK_SIZE * CHUNK_SIZE ), this.y );
		// draw_set_color( c_lime );
		for ( var yy = 0; yy < CHUNK_SIZE; ++yy )
		{
			var y1 = this.y + ( yy * BLOCK_SIZE );
			if ( y1 >= ( GM.stageH / 5 ) )
				continue;
			for ( var xx = 0; xx < CHUNK_SIZE; ++xx )
			{
				var x1 = this.x + ( xx * BLOCK_SIZE );
				var _block = blocks[xx][yy];
				if ( !_block )
					continue;
				var spr = _block;
				draw_sprite_ext( spr, 0, x1, y1, 1, 1, 0, c_white, 1 );
			}
		}
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
		hotbar = instance_create_depth( 0, 0, 0, UI_Hotbar );
	}
	
	override public function Cleanup()
	{
		instance_destroy( hotbar );
	}
	
	override public function Draw()
	{
		
	}
}

class UI_Hotbar extends GMObject
{
	public var slot = 4;
	
	public var spr_hotbar_selection = global["gui/sprites/hud/hotbar_selection"];
	
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
		
		xx += ( ( 1 + ( 20 * slot ) ) * image_xscale );
		yy += ( 24 );
		
		draw_sprite_ext( spr_hotbar_selection, 0, xx - ( image_xscale * 2 ), yy - ( image_yscale ), image_xscale, -image_yscale, image_angle, image_blend, image_alpha );
	}
	
	//
	
	override public function Step()
	{
		var mx = mouse_x;
		var my = mouse_y;
		
		if ( mx < x )
		{
			x = mx;
		}
		else if ( mx > ( x + sprite_width ) )
		{
			x = ( mx - sprite_width );
		}
		
		if ( ( my <= ( y + sprite_height ) ) && mouse_check_button( mb_left ) )
		{
			slot = Math.floor( ( mx - this.x - 1 ) / 20 );
			if ( slot < 0 )
				slot = 0;
			else if ( slot > MAX_SLOT )
				slot = MAX_SLOT;
		}
		
		for ( var i = 49; i < 58; ++i )
		{
			if ( keyboard_check_pressed( i ) )
				slot = i - 49;
		} 
	}
}













