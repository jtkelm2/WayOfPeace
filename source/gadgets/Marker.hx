package gadgets;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import system.*;

class Marker extends FlxSprite
{
	private var parent:Dynamic;

	public function new(parent:Null<Dynamic> = null, x:Float = 0, y:Float = 0)
	{
		super();
		this.parent = parent;
		makeGraphic(5, 5, FlxColor.RED, true);
		alpha = 0.5;
		Reg.markerGroup.add(this);
		Useful.centerAt(this, x, y);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (parent != null)
		{
			Useful.centerAt(this, parent.x, parent.y);
		}
	}
}
