package gadgets;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.mouse.FlxMouseEvent;
import flixel.math.FlxRect;
import system.*;

class Clicker
{
	public var enabled:Bool;
	public var sprite:FlxSprite;
	public var anchor:Null<Anchor>;

	public function new(sprite:FlxSprite, anchor:Null<Anchor> = null, enabled:Bool = true)
	{
		this.sprite = sprite;
		this.anchor = anchor;
		this.enabled = enabled;
	}

	public function makeDraggable()
	{
		FlxMouseEvent.add(sprite, drag);
	}

	public function clear()
	{
		FlxMouseEvent.remove(sprite);
	}

	private function drag(sprite:FlxSprite)
	{
		System.dragger.dragged = anchor;
	}
}
