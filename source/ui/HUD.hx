package ui;

import flixel.FlxG;
import gadgets.*;
import routines.*;
import system.*;
import system.Data;
import ui.*;

enum WINDOW_TYPE
{
	WIRE;
	SHADED;
}

class HUD
{
	public static var ASSETPATH:Map<WINDOW_TYPE, String> = [WIRE => "assets/box.png", SHADED => "assets/shade_box.png"];

	public function new(level:Int)
	{
		init(level);
	}

	public function addWindow(x:Float, y:Float, width:Float, height:Float, type:WINDOW_TYPE = WIRE):SliceWindow
	{
		var sliceWindow = new SliceWindow(x, y, width, height, Reg.WINDOW_MARGIN);
		sliceWindow.loadGraphic(ASSETPATH[type], 36);
		sliceWindow.addToGroup(Reg.HUDGroup);
		return sliceWindow;
	}

	public function init(level:Int = 0)
	{
		switch level
		{
			case 0:
				var matrixWindowSize = FlxG.width - Reg.MAP_WIDTH;
				var belowTwoHeight = (FlxG.height - matrixWindowSize) / 2;
				var newsBoxHeight = FlxG.height - Reg.MAP_HEIGHT;
				addWindow(Reg.MAP_WIDTH, 0, matrixWindowSize, matrixWindowSize, SHADED);
				addWindow(Reg.MAP_WIDTH, Reg.MAP_HEIGHT, matrixWindowSize, newsBoxHeight, WIRE);
				addWindow(0, Reg.MAP_HEIGHT, Reg.MAP_WIDTH, newsBoxHeight, WIRE);
			case _:
		}
	}
}
