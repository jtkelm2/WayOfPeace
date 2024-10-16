package gameobjects.diplographic;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import gadgets.*;
import gadgets.Geometry;
import gameobjects.*;
import gameobjects.diplographic.*;
import gameobjects.diplographic.RelationsDiagram;
import system.*;
import system.Reg;

class NationInfo
{
	var bars:Array<FlxBar>;
	var anchor:Anchor;

	public function new(x:Float, y:Float, size:Float, group:FlxGroup)
	{
		anchor = new Anchor(x + size / 2, y + size / 2);
		var barsWidth = size;
		var barsHeight = 0.8 * size;

		var segments = 3 * (3 - 1) + 2;
		var barWidth = Std.int(size / segments * 2);

		var line = new Line().start(x, y + barsHeight / 2).end(x + barsWidth, y + barsHeight / 2).segments(segments);

		bars = [];
		var i = 1;
		for (j in 0...3)
		{
			var midpoint = line.atSegment(i);
			var bar = new FlxBar(0, 0, BOTTOM_TO_TOP, barWidth, Std.int(barsHeight), null, "", -1, 1, true);
			bar.value = 0;
			bar.createFilledBar(FlxColor.WHITE, FlxColor.CYAN, true, FlxColor.PURPLE);
			var barAnchor = new Anchor(midpoint.x, midpoint.y);
			barAnchor.attachParent(bar);
			bars.push(bar);
			group.add(bar);

			var text = new FlxText();
			var textAnchor = new Anchor(barAnchor.x, barAnchor.y);
			textAnchor.y += size / 2;
			text.fieldWidth = Std.int(barWidth * 1.4);
			text.alignment = CENTER;
			text.size = 20;
			text.text = ["Gay", "Furry", "Hacker"][j];
			textAnchor.attachParent(text);
			group.add(text);

			anchor.add(textAnchor);
			anchor.add(barAnchor);

			i += 3; // Constant in loc.length!
			midpoint.put();
		}
	}

	public function hide()
	{
		anchor.propagate(sprite -> sprite.visible = false);
	}

	public function load(circle1:Null<NationCircle>)
	{
		var loc = circle1.nation.loc;
		for (i in 0...loc.length)
		{
			bars[i].value = loc[i];
			bars[i].updateBar();
		}
	}

	public function show()
	{
		anchor.propagate(sprite -> sprite.visible = true);
	}
}
