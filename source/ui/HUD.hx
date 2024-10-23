package ui;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween.FlxTweenManager;
import flixel.tweens.FlxTween;
import gadgets.*;
import gameobjects.Diplographic;
import gameobjects.Nation;
import routines.*;
import system.*;
import system.Data;
import ui.*;
import ui.SliceWindow;

class HUD
{
	public var graphic:Diplographic;
	public var nations:Array<Nation>;

	public var inspectorContentSize:Int;

	public function new(level:Int, nations:Array<Nation>)
	{
		this.nations = nations;

		inspectorContentSize = Std.int(FlxG.width - Reg.MAP_WIDTH - 2 * Reg.WINDOW_MARGIN);
		inspectorContentSize -= Useful.modulo(inspectorContentSize, nations.length + 1);
		// graphic = new Diplographic(-50000, -50000, size, nations, Reg.HUDGroup);
		graphic = new Diplographic(Reg.MAP_WIDTH + Reg.WINDOW_MARGIN, Reg.WINDOW_MARGIN, inspectorContentSize, nations, Reg.HUDGroup);

		init(level);
	}

	public function addWindow(x:Float, y:Float, width:Float, height:Float, type:WINDOW_TYPE = WIRE):SliceWindow
	{
		var window = new SliceWindow();
		window.setType(type);
		window.resize(x, y, width, height);

		window.addTo(Reg.windowGroup);

		// Useful.testTween(window.anchor);
		return window;
	}

	public function addPanel(x:Float, y:Float, width:Float, height:Float, type:WINDOW_TYPE = WIRE):Panel
	{
		var panel = new Panel();
		panel.window.setType(type);
		return panel;
	}

	public function init(level:Int = 0)
	{
		switch level
		{
			case 0:
				var inspectorSize = FlxG.width - Reg.MAP_WIDTH;
				var newsBoxHeight = FlxG.height - Reg.MAP_HEIGHT;

				// addWindow(Reg.MAP_WIDTH, 0, inspectorSize, inspectorSize, SHADED);
				addWindow(Reg.MAP_WIDTH, Reg.MAP_HEIGHT, inspectorSize, newsBoxHeight, WIRE);
				addWindow(0, Reg.MAP_HEIGHT, Reg.MAP_WIDTH, newsBoxHeight, WIRE);
				var inspector = new Multi();
				inspector.setType(SHADED);
				inspector.margins.setAll(Reg.WINDOW_MARGIN);
				inspector.resize(Reg.MAP_WIDTH, 0, inspectorSize, inspectorSize + Reg.TAB_HEIGHT);

				var textPanel = inspector.newPanel();

				var text = new FlxText(0, 0, 0, "My boyfriend is cute <3");
				text.size = 20;
				var visibility = new Visibility(text);
				var anchor = new Anchor().attachParent(text);

				textPanel.add(anchor);
				textPanel.visibility.add(visibility);
				textPanel.alignment = BOTTOMRIGHT;

				text = new FlxText(0, 0, 0, "...both of them");
				text.size = 12;
				visibility = new Visibility(text);
				anchor = new Anchor().attachParent(text);

				textPanel.add(anchor);
				textPanel.visibility.add(visibility);

				var graphicPanel = inspector.newPanel();
				// graphicPanel.add(graphic.inspector.table.anchor, 0, 0);
				// graphicPanel.add(graphic.inspector.info.anchor, 0, 0);
				// graphicPanel.add(graphic.inspector.pair.anchor, 0, 0);
				graphicPanel.add(graphic.inspector.anchor);
				graphicPanel.visibility.add(graphic.inspector.visibility);

				inspector.panel.addTo(Reg.windowGroup);

			// var multi = new Multi();

			// multi.setType(SHADED);
			// multi.margins.setAll(20);
			// multi.resize(FlxG.width / 2 - 200, 0, 400, 600);

			// var panel1 = multi.newPanel();
			// panel1.splitVertical();
			// for (subpanel in panel1.H)
			// {
			// 	subpanel.setType(SHADED);
			// 	subpanel.splitHorizontal(3);
			// 	for (subsubpanel in subpanel.V)
			// 	{
			// 		subsubpanel.setType(WIRE);
			// 	}
			// }

			// var panel2 = multi.newPanel();
			// panel2.splitVertical();
			// var max:Int = 1;
			// for (subpanel in panel2.H)
			// {
			// 	subpanel.setType(SHADED);
			// 	subpanel.splitHorizontal(4, 10);
			// 	for (subsubpanel in subpanel.V)
			// 	{
			// 		subsubpanel.setType(WIRE);
			// 		subsubpanel.alignment = TOPLEFT;

			// 		for (i in 0...max)
			// 		{
			// 			var str = ["Hello", "world", "this", "is", "a", "message", "to", "everybody"][i];
			// 			var text = new FlxText(0, 0, 0, str);
			// 			var anchor = new Anchor().attachParent(text);
			// 			subsubpanel.add(anchor);
			// 		}
			// 		max += 1;
			// 	}
			// }

			// multi.panel.addTo(Reg.HUDGroup);

			case _:
		}
	}
}
