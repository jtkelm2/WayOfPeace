package gameobjects.diplographic;

import Useful.reluMax;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import gadgets.*;
import gameobjects.*;
import gameobjects.diplographic.*;
import gameobjects.diplographic.RelationsDiagram;
import system.*;
import system.Reg;

using Useful;

class PairInfo
{
	public var sprite:FlxSprite;
	public var text:FlxText;

	public var anchor:Anchor;

	public var visibility:Visibility;

	public function new(x:Float, y:Float, size:Float, group:FlxGroup)
	{
		visibility = new Visibility();

		sprite = new FlxSprite();
		sprite.makeGraphic(Std.int(size), Std.int(size), FlxColor.GRAY, true);
		var spriteAnchor = new Anchor().attachParent(sprite);
		visibility.addSprite(sprite);
		group.add(sprite);

		text = new FlxText();
		text.fieldWidth = Std.int(size);
		text.size = 24;
		text.alignment = CENTER;
		text.color = FlxColor.WHITE;
		var textAnchor = new Anchor().attachParent(text);
		visibility.addSprite(text);
		group.add(text);

		anchor = new Anchor().add(textAnchor).add(spriteAnchor);
		anchor.x = x + size / 2;
		anchor.y = y + size / 2;
	}

	public function load(circle1:Null<NationCircle>, circle2:Null<NationCircle>)
	{
		var nation1 = circle1.nation;
		var nation2 = circle2.nation;
		var distance = Math.sqrt(nation1.loc.zipWith(nation2.loc, (a, b) -> (a - b) * (a - b)).sum());
		text.text = Std.string(FlxMath.roundDecimal(distance, 3));
		text.text += " -> ";
		text.text += Std.string(FlxMath.roundDecimal(reluMax(distance, Reg.C_THRESHOLD_LOWER, Reg.C_THRESHOLD_UPPER, 1, -1), 3));
	}
}
