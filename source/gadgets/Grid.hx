package gadgets;

import flixel.math.FlxPoint;

class Grid
{
	public var anchor:Anchor;

	public var x:Float;
	public var y:Float;
	public var height:Float;
	public var width:Float;
	public var dx:Float;
	public var dy:Float;
	public var rows:Int;
	public var cols:Int;

	public function new(x:Float, y:Float, width:Float, height:Float, rows:Int, cols:Int)
	{
		this.x = x;
		this.y = y;
		this.height = height;
		this.width = width;
		this.rows = rows;
		this.cols = cols;

		this.dx = width / cols;
		this.dy = height / rows;

		anchor = new Anchor(x + width / 2, y + height / 2);
	}

	/* Get center point of the rowth row and colth col */
	public function getXY(row:Int, col:Int):FlxPoint
	{
		return FlxPoint.get(x + (row + 0.5) * dx, y + (col + 0.5) * dy);
	}

	public function addAnchor(anchor:Anchor, row:Int, col:Int)
	{
		var xy = getXY(row, col);
		anchor.x = xy.x;
		anchor.y = xy.y;
		xy.put();
		this.anchor.add(anchor);
	}
}
