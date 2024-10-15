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
	private var relationsTable:RelationsTable;
	private var tableGroup:FlxGroup;
	private var nations:Array<Nation>;
	private var diagram:RelationsDiagram;

	private var HUD:HUD;

	private var k:Float;

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

		tableGroup = new FlxGroup();
		FlxG.state.add(tableGroup);

		var relationsTableSize = Std.int(FlxG.width - Reg.MAP_WIDTH - 2 * Reg.WINDOW_MARGIN);
		relationsTableSize = relationsTableSize - Useful.modulo(relationsTableSize, nations.length + 1);
		relationsTable = new RelationsTable(Reg.MAP_WIDTH + Reg.WINDOW_MARGIN, Reg.WINDOW_MARGIN, relationsTableSize, nations, tableGroup);

		var diagramGroup = new FlxGroup();
		FlxG.state.add(diagramGroup);
		diagram = new RelationsDiagram(0, 0, Reg.MAP_WIDTH, Reg.MAP_HEIGHT, relationsTable, diagramGroup);

		k = 100;
	}

	public function handler(input:InputID)
	{
		switch input
		{
			case KeyPressed(Spacebar):
				diagram.layout(k);
			// trace(diagram.circles[0].anchor.x, diagram.circles[0].anchor.y);
			case KeyPressed(Up):
				return;
			case KeyPressed(Down):
				return;
			case KeyPressed(Left):
				return;
			case KeyPressed(Right):
				return;
			case KeyPressed(Enter):
				relationsTable.resetRelationMatrix(true);
			case KeyPressed(Shift):
				FlxG.timeScale = 30;
			case KeyReleased(Shift):
				FlxG.timeScale = 1;
			case MiddleClick:
				diagram.randomize();
			case RightClick:
				return;
			case _:
				return;
		}
	}
}
