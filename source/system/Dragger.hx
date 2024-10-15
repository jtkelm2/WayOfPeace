package system;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.mouse.FlxMouseEvent;
import gadgets.*;
import system.Data;
import system.System;

class Dragger extends FlxBasic
{
	public var dragged(default, set):Null<Anchor>;

	public function new()
	{
		super();
		dragged = null;
	}

	override public function update(elapsed:Float)
	{
		if (dragged != null)
		{
			dragged.x += FlxG.mouse.deltaScreenX;
			dragged.y += FlxG.mouse.deltaScreenY;
			if (FlxG.mouse.justReleased)
			{
				dragged = null;
			}
		}
	}

	private function set_dragged(newDragged:Null<Anchor>)
	{
		if (newDragged != null)
		{
			dragged = newDragged;
			dragged.x = FlxG.mouse.x;
			dragged.y = FlxG.mouse.y;
			if (dragged.parent != null)
			{
				System.effects.transpare(dragged.parent);
			}
			return dragged;
		}
		else
		{
			if (dragged != null)
			{
				if (dragged.parent != null)
				{
					System.effects.detranspare(dragged.parent);
					// System.events.handle(DraggerDropped(dragged.parent.id));
				}
				dragged = null;
			}
			return null;
		}
	}
}
