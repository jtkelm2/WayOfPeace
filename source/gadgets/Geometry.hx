package gadgets;

import flixel.math.FlxPoint;
import flixel.math.FlxPoint;

class Line
{
	public var startX:Float;
	public var startY:Float;
	public var endX:Float;
	public var endY:Float;
	public var dx:Float;
	public var dy:Float;
	public var segmentCount:Int;

	public function new() {}

	public function start(x:Float, y:Float)
	{
		startX = x;
		startY = y;
		return this;
	}

	public function end(x:Float, y:Float)
	{
		endX = x;
		endY = y;
		return this;
	}

	public function segments(n:Int)
	{
		segmentCount = n;
		dx = (endX - startX) / segmentCount;
		dy = (endY - startY) / segmentCount;
		return this;
	}

	public function getAlong(t:Float):FlxPoint
	{
		return FlxPoint.get(startX + t * (endX - startX), startY + t * (endY - startY));
	}

	public function atSegment(n:Int):FlxPoint
	{
		return getAlong(n / segmentCount);
	}
}

class Grid
{
	public var x:Float;
	public var y:Float;
	public var dx:Float;
	public var dy:Float;
	public var rows:Int;
	public var cols:Int;

	public var offsetX:Float;
	public var offsetY:Float;
	public var center:Bool;

	public function new()
	{
		dx = 0;
		dy = 0;
		offsetX = 0;
		offsetY = 0;
	}

	public function dxdy(dx:Float, dy:Float)
	{
		this.dx = dx;
		this.dy = dy;
		return this;
	}

	public function centerAlign(bool:Bool = true)
	{
		offsetX = bool ? 0.5 * dx : 0;
		offsetY = bool ? 0.5 * dy : 0;
		return this;
	}

	public function origin(x:Float, y:Float)
	{
		this.x = x;
		this.y = y;
		return this;
	}

	public function fromFinite(width:Float, height:Float, rows:Int, cols:Int)
	{
		this.rows = rows;
		this.cols = cols;
		dx = width / cols;
		dy = height / rows;
		return this;
	}

	/* Get center point of the rowth row and colth col */
	public function getXY(row:Int, col:Int):FlxPoint
	{
		return FlxPoint.get(x + row * dx + offsetX, y + col * dy + offsetY);
	}
}
