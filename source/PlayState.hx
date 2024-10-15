package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import gadgets.Anchor;
import gameobjects.*;
import gameobjects.RelationsTable;
import system.*;
import system.System;
import ui.*;

using Useful;

class PlayState extends FlxState
{
	private var debug:Int;
	private var anchor:Anchor;

	public var HUD:HUD;

	override public function create()
	{
		super.create();
		System.initGlobalSystems(this);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.pressed.LEFT) {}
		if (FlxG.keys.pressed.RIGHT) {}

		if (FlxG.keys.justPressed.SPACE) {}

		if (FlxG.keys.justReleased.SPACE) {}
	}
}
