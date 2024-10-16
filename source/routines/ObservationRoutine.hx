package routines;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import gameobjects.*;
import routines.Routine;
import system.*;
import system.Data;
import ui.*;

class ObservationRoutine extends Routine
{
	private var graphic:Diplographic;
	private var group:FlxGroup;
	private var nations:Array<Nation>;

	private var HUD:HUD;

	public function new()
	{
		super();
	}

	override public function hello():Void
	{
		System.input.setHandler(handler);

		HUD = new HUD(0);

		nations = [
			for (i in 0...10)
			{
				new Nation(i);
			}
		];

		group = new FlxGroup();
		FlxG.state.add(group);

		var size = Std.int(FlxG.width - Reg.MAP_WIDTH - 2 * Reg.WINDOW_MARGIN);
		size -= Useful.modulo(size, nations.length + 1);
		graphic = new Diplographic(Reg.MAP_WIDTH + Reg.WINDOW_MARGIN, Reg.WINDOW_MARGIN, size, nations, group);
	}

	public function handler(input:InputID)
	{
		switch input
		{
			case KeyPressed(Spacebar):
				graphic.diagram.layout();
			// trace(diagram.circles[0].anchor.x, diagram.circles[0].anchor.y);
			case KeyPressed(Up):
				return;
			case KeyPressed(Down):
				return;
			case KeyPressed(Left):
				return;
			case KeyPressed(Right):
				FlxG.timeScale = 30;
			case KeyReleased(Right):
				FlxG.timeScale = 1;
			case KeyPressed(Enter):
				graphic.table.resetRelationMatrix(true);
			case KeyPressed(Shift):
				graphic.setMode(DRAG);
			case KeyReleased(Shift):
				graphic.setMode(SELECT);
			case MiddleClick:
				graphic.diagram.randomize();
			case RightClick:
				return;
			case _:
				return;
		}
	}
}
