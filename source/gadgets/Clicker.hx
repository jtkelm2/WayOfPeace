package gadgets;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.mouse.FlxMouseButton.FlxMouseButtonID;
import flixel.input.mouse.FlxMouseEvent;
import flixel.math.FlxRect;
import system.*;

class Clicker<T:FlxSprite>
{
	public var enabled:Bool;
	public var sprite:T;
	public var anchor:Null<Anchor>;

	public function new(sprite:T, anchor:Null<Anchor> = null, enabled:Bool = true)
	{
		this.sprite = sprite;
		this.anchor = anchor;
		this.enabled = enabled;
	}

	public function add(?onMouseDown:T->Void, ?onMouseUp:T->Void, ?onMouseOver:T->Void, ?onMouseOut:T->Void, mouseChildren:Bool = false,
			mouseEnabled:Bool = true, pixelPerfect:Bool = true, ?mouseButtons:Array<FlxMouseButtonID>)
	{
		FlxMouseEvent.add(sprite, onMouseDown, onMouseUp, onMouseOver, onMouseOut, mouseChildren, mouseEnabled, pixelPerfect, mouseButtons);
	}

	public function makeDraggable()
	{
		add(drag);
	}

	public function clear()
	{
		if (System.dragger.dragged != null && System.dragger.dragged.parent == sprite)
		{
			System.dragger.dragged = null;
		}
		FlxMouseEvent.remove(sprite);
	}

	private function drag(sprite:T)
	{
		System.dragger.dragged = anchor;
	}
}
