package system;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import gadgets.*;
import gameobjects.*;
import system.Data;

class Reg
{
	public static var SPACING:Int;
	public static var MAX_MOVE_TIME:Float;
	public static var MAP_WIDTH:Float;
	public static var MAP_HEIGHT:Float;
	public static var WINDOW_MARGIN:Float;
	public static var BG_COLOR:FlxColor;

	public static var windowGroup:FlxTypedGroup<FlxSprite>;
	public static var HUDGroup:FlxTypedGroup<FlxSprite>;
	public static var floatTextGroup:FlxTypedGroup<FlxText>;
	public static var markerGroup:FlxTypedGroup<Marker>;

	// --------- Groups -----------
	// public static var hexGroup:FlxTypedGroup<Hex>;

	public static function initReg()
	{
		SPACING = 10;
		MAX_MOVE_TIME = 0.4;
		MAP_WIDTH = 0.7 * FlxG.width;
		MAP_HEIGHT = 0.7 * FlxG.height;
		WINDOW_MARGIN = 16;
		BG_COLOR = 0xff02030C;

		windowGroup = new FlxTypedGroup<FlxSprite>();
		HUDGroup = new FlxTypedGroup<FlxSprite>();
		floatTextGroup = new FlxTypedGroup<FlxText>(8);
		markerGroup = new FlxTypedGroup<Marker>();

		initGroups();
	}

	public static function initGroups()
	{
		FlxG.state.add(windowGroup);
		FlxG.state.add(HUDGroup);
		FlxG.state.add(floatTextGroup);
		FlxG.state.add(markerGroup);
	}
}
