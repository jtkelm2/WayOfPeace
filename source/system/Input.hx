package system;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouseEvent;
import system.*;
import system.Data;

class Input
{
	public var mouse:Mouse;
	public var keys:Keys;

	public var handler:InputID->Void;

	private var handlers:Array<InputID->Void>;

	public function new()
	{
		mouse = new Mouse();
		keys = new Keys();
		handlers = [];

		System.signals.newInput.add(inputID -> handler(inputID));
	}

	public function setHandler(handler:InputID->Void)
	{
		this.handler = handler;
		handlers.push(handler);
	}

	public function revertHandler()
	{
		handlers.pop();
		handler = handlers[handlers.length - 1];
	}
}

class Mouse extends FlxBasic
{
	public var hovered:Null<IDSprite>;

	private var clickableRegistry:Map<Tag, Array<FlxSprite>>;
	private var suspended:Bool;

	public function new()
	{
		super();
		hovered = null;
		clickableRegistry = [];
		suspended = false;
	}

	override public function update(elapsed:Float)
	{
		if (!suspended)
		{
			if (FlxG.mouse.justPressedMiddle)
			{
				System.signals.newInput.dispatch(MiddleClick);
			}
			if (FlxG.mouse.justPressed)
			{
				System.signals.newInput.dispatch(LeftClick);
			}
			if (FlxG.mouse.justPressedRight)
			{
				System.signals.newInput.dispatch(RightClick);
			}
		}
	}

	// public function initClickable(clickable:IDSprite, pixelPerfect:Bool = true)
	// {
	// 	var clickableID = clickable.id;
	// 	var clickableSprite = System.data.toSprite(clickable);
	// 	var tag = System.data.toTag(clickable);
	// 	if (clickableRegistry[tag] == null)
	// 	{
	// 		clickableRegistry[tag] = [];
	// 	}
	// 	FlxMouseEvent.add(clickableSprite, (_) ->
	// 	{
	// 		System.signals.newInput.dispatch(MouseDown(clickableID));
	// 	}, (_) ->
	// 		{
	// 			System.signals.newInput.dispatch(MouseUp(clickableID));
	// 		}, (_) ->
	// 		{
	// 			hovered = clickable;
	// 			System.signals.newInput.dispatch(MouseOver(clickableID));
	// 		}, (_) ->
	// 		{
	// 			if (hovered == clickable)
	// 			{
	// 				hovered = null;
	// 			}
	// 			System.signals.newInput.dispatch(MouseOut(clickableID));
	// 		}, false, true, pixelPerfect);
	// 	FlxMouseEvent.setMouseWheelCallback(clickableSprite, _ ->
	// 	{
	// 		System.signals.newInput.dispatch(MouseWheel(clickableID));
	// 	});
	// 	clickableRegistry[tag].push(clickableSprite);
	// }

	private function clickableToggle(tag:Tag, bool:Bool)
	{
		for (clickable in clickableRegistry[tag])
		{
			FlxMouseEvent.setObjectMouseEnabled(clickable, bool);
		}
	}

	public function setActive(activeTags:Array<Tag>)
	{
		suspended = false;
		for (tag in clickableRegistry.keys())
		{
			var bool = activeTags.contains(tag);
			clickableToggle(tag, bool);
		}
	}

	public function plusActive(activeTags:Array<Tag>)
	{
		suspended = false;
		for (tag in activeTags)
		{
			clickableToggle(tag, true);
		}
	}

	public function minusActive(inactiveTags:Array<Tag>)
	{
		for (tag in inactiveTags)
		{
			clickableToggle(tag, false);
		}
	}
	/* public function toggleSuspend(bool:Bool)
		{
			if (bool)
			{
				setActive([]);
			}
			suspended = bool;
	}*/
}

class Keys extends FlxBasic
{
	private var suspended:Bool;

	private static var keys:Array<FlxKey> = [
		65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 33,
		34, 36, 35, 45, 27, 189, 187, 46, 8, 219, 221, 220, 20, 145, 144, 186, 222, 13, 16, 188, 190, 191, 192, 17, 18, 32, 38, 40, 37, 39, 9, 15, 302, 301,
		19, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 109, 107, 110, 106, 111
	];

	public function new()
	{
		super();
		suspended = false;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		for (key in keys)
		{
			if (FlxG.keys.anyJustPressed([key]))
				System.signals.newInput.dispatch(KeyPressed(key));

			if (FlxG.keys.anyJustReleased([key]))
				System.signals.newInput.dispatch(KeyReleased(key));
		}

		if (FlxG.mouse.justPressedMiddle)
		{
			System.signals.newInput.dispatch(MiddleClick);
		}
		if (FlxG.mouse.justPressed)
		{
			System.signals.newInput.dispatch(LeftClick);
		}
		if (FlxG.mouse.justPressedRight)
		{
			System.signals.newInput.dispatch(RightClick);
		}
	}

	public function toggleSuspend(bool:Bool)
	{
		suspended = bool;
	}
}
