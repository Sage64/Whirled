
// GML Common Functions
// 
// 

package gamemaker
{

public class gml
{
	/*
		Math
	*/
	
	public static function lerp( _val1, _val2, _amount )
	{
		return _val1 + ( ( _val2 - _val1 ) * _amount );
	}
	
	public static function clamp( _val, _min, _max )
	{
		if ( _val < _min )
			return _min;
		if ( _val > _max )
			return _max;
		return _val;
	}
	
	public static function random( amnt )
	{
		return Math.random() * amnt;
	}
	
    public static function degtorad( rads )
	{
		return rads * ( Math.PI / 180 );
	}
	
	public static function radtodeg( degs )
	{
		return degs * ( 180 / Math.PI );
	}
	
	public static function dcos( dir )
	{
		return Math.cos( dir * ( Math.PI / 180 ) )
	}
	
	public static function dsin( dir )
	{
		return Math.sin( dir * ( Math.PI / 180 ) );
	}
	
	public static function lengthdir_x( dis, dir )
	{
		return dcos( dir ) * dis;
	}
	
	public static function lengthdir_y( dis, dir )
	{
		return dsin( dir ) * dis;
	}
	
	public static function point_direction( x1, y1, x2, y2 )
	{
		var xx = x2 - x1;
		var yy = y2 - y1;
		return Math.floor( ( Math.round( Math.atan2( yy, xx ) / (2 * Math.PI / 360 ) ) + 360) % 360 );
	}
	
	public static function point_distance( x1, y1, x2, y2 )
	{
		var dx = x2 - x1;
    	var dy = y2 - y1;
    	return Math.sqrt( ( dx*dx ) + ( dy*dy ) );
	}
	
}

}// 