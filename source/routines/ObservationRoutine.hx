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
	private var panel:Panel;

	public function new()
	{
		super();
	}

	override public function hello():Void
	{
		System.input.setHandler(handler);

		nations = [
			for (i in 0...10)
			{
				new Nation(i);
			}
		];

		HUD = new HUD(0, nations);
		graphic = HUD.graphic;

		// panel = new Panel();
		// panel.resize(500, 100, 100, 200);
		// panel.window.loadAsset(WIRE);
		// panel.addTo(group);
		// var panels = panel.splitVertical();
		// panels[0].window.load()
		// panel.addTo(group);
	}

	public function handler(input:InputID)
	{
		switch input
		{
			case KeyPressed(SPACE):
				graphic.diagram.layout();
			case KeyPressed(UP):
				graphic.raiseRelations();
			case KeyPressed(DOWN):
				graphic.lowerRelations();
			case KeyPressed(LEFT):
				graphic.inspector.table.advance(10);
			case KeyPressed(RIGHT):
				graphic.inspector.table.advance(1);
			case KeyPressed(ENTER):
				graphic.inspector.table.reset(true);
			case KeyPressed(SHIFT):
				graphic.setMode(DRAG);
			case KeyPressed(QUOTE):
				// graphic.diagram.anchor.angle -= 5;
				// for (circle in graphic.diagram.circles)
				// {
				// 	circle.anchor.angle += 5;
				// }
			case KeyPressed(PERIOD):
				// graphic.diagram.anchor.angle += 5;
				// for (circle in graphic.diagram.circles)
				// {
				// 	circle.anchor.angle -= 5;
				// }
			case KeyReleased(SHIFT):
				graphic.setMode(SELECT);
			case KeyPressed(C):
				// graphic.diagram.constrain();
			case KeyPressed(R):
				// graphic.diagram.refocus();
			case MiddleClick:
				graphic.diagram.randomize();
			case RightClick:
				graphic.party();
			case _:
				return;
		}
	}
}
