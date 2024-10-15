package gadgets;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import gadgets.*;
import system.*;
import system.Data;

class AnchorLine extends FlxBasic
{
	private var segments:Int;

	public var start:Anchor;
	public var end:Anchor;
	public var anchors:Array<Anchor>;

	public function new(start:Anchor, end:Anchor, segments:Int = 7)
	{
		super();
		FlxG.state.add(this);

		this.start = start;
		this.end = end;
		this.segments = segments;

		anchors = [
			for (i in 0...segments + 1)
			{
				new Anchor();
			}
		];
	}

	override function update(elapsed:Float)
	{
		var dx = (end.x - start.x) / segments;
		var dy = (end.y - start.y) / segments;
		for (i in 0...segments + 1)
		{
			anchors[i].x = start.x + i * dx;
			anchors[i].y = start.y + i * dy;
		}
	}
}
