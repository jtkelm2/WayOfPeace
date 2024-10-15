package system;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
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
			if (FlxG.keys.justPressed.UP)
			{
				System.signals.newInput.dispatch(KeyPressed(Up));
			}
			if (FlxG.keys.justPressed.LEFT)
			{
				System.signals.newInput.dispatch(KeyPressed(Left));
			}
			if (FlxG.keys.justPressed.RIGHT)
			{
				System.signals.newInput.dispatch(KeyPressed(Right));
			}
			if (FlxG.keys.justPressed.DOWN)
			{
				System.signals.newInput.dispatch(KeyPressed(Down));
			}
			if (FlxG.keys.justPressed.ENTER)
			{
				System.signals.newInput.dispatch(KeyPressed(Enter));
			}
			if (FlxG.keys.justReleased.ENTER)
			{
				System.signals.newInput.dispatch(KeyReleased(Enter));
			}
			if (FlxG.keys.justPressed.SHIFT)
			{
				System.signals.newInput.dispatch(KeyPressed(Shift));
			}
			if (FlxG.keys.justReleased.SHIFT)
			{
				System.signals.newInput.dispatch(KeyReleased(Shift));
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

	public function new()
	{
		super();
		suspended = false;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.SPACE && !suspended)
		{
			System.signals.newInput.dispatch(KeyPressed(Spacebar));
		}
		/*
			if (FlxG.keys.justPressed.N && !suspended)
			{
				System.signals.newInput.dispatch(KeyPressed(NKey));
			}
			if (FlxG.keys.justPressed.SPACE && !suspended)
			{
				System.signals.newInput.dispatch(KeyPressed(Spacebar));
		}*/
	}

	public function toggleSuspend(bool:Bool)
	{
		suspended = bool;
	}
}
