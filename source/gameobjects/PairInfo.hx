package gameobjects;

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
import gameobjects.RelationsDiagram;
import system.*;
import system.Reg;

class PairInfo
{
	public var sprite:FlxSprite;

	public function new(x:Float, y:Float, size:Float, group:FlxGroup)
	{
		sprite = new FlxSprite(x, y);
		sprite.makeGraphic(Std.int(size), Std.int(size), FlxColor.RED, true);
		group.add(sprite);
	}

	public function hide()
	{
		sprite.visible = false;
	}

	public function load(circle1:Null<NationCircle>, circle2:Null<NationCircle>)
	{
		sprite.visible = true;
	}

	public function show()
	{
		sprite.visible = true;
	}
}
