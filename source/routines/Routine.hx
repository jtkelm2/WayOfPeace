package routines;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxSignal;
import system.*;
import system.Data;

using StringTools;

class Routine extends FlxBasic
{
	public var running:Bool;
	public var parent:Routine;

	private var subroutines:Array<Routine>;

	private var concluding:Bool;

	public function new()
	{
		super();
		subroutines = [];
		concluding = false;
		running = false;
	}

	public function queue(subroutine:Routine)
	{
		subroutine.parent = this;
		subroutines.push(subroutine);
	}

	public function conclude()
	{
		concluding = true;
	}

	public function hello() {}

	public function idle(elapsed:Float) {}

	public function goodbye() {}

	public function interrupt()
	{
		if (subroutines.length > 0)
		{
			for (subroutine in subroutines.slice(1))
			{
				subroutine.destroy();
			}
			subroutines = [subroutines[0]];
			subroutines[0].interrupt();
		}
	}

	public function run()
	{
		FlxG.state.add(this);
		hello();
		running = true;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (running)
		{
			if (subroutines.length > 0)
			{
				var subroutine = subroutines[0];
				if (!subroutine.running)
				{
					subroutine.run();
				}
				if (subroutine.concluding && subroutine.subroutines.length == 0)
				{
					subroutine.goodbye();
					subroutines.shift();
					subroutine.destroy();
				}
			}
			else
			{
				if (!concluding)
					idle(elapsed);
			}
		}
	}

	override public function toString():String
	{
		var output = Type.getClassName(Type.getClass(this));
		if (subroutines.length == 0)
		{
			if (!running)
			{
				output += " (inactive)";
			}
			return output;
		}
		for (subroutine in subroutines)
		{
			output += "\n  " + subroutine.toString().replace("\n", "\n  ");
		}
		return output;
	}

	override public function destroy()
	{
		for (subroutine in subroutines)
		{
			subroutine.destroy();
		}
		FlxG.state.remove(this);
		super.destroy();
	}
}
/*

	package routines;

	import gadgets.*;
	import gameobjects.*;
	import routines.*;
	import system.*;
	import system.Data;
	import ui.*;

	class ObservationRoutine extends Routine
	{

	public function new()
	{
		super();
	}

	override public function hello()
	{
		System.input.setHandler(handler);
	}

	public function handler(input:InputID)
	{
		switch input
		{
			case _:
				return;
		}
	}
	}

 */
