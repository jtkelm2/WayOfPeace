package system;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;
import gadgets.*;
import routines.*;
import system.*;
import system.Data;
import system.Input;

class System
{
	public static var dragger:Dragger;
	public static var effects:Effects;
	public static var input:Input;
	public static var mouse:Mouse;
	public static var keys:Keys;
	public static var data:Data;
	public static var signals:Signals;

	public static var misc:Misc;

	public static var routine:Routine;

	public static function initGlobalSystems(ps:PlayState)
	{
		Reg.initReg();

		FlxG.camera.bgColor = Reg.BG_COLOR;

		signals = new Signals();
		data = new Data();
		effects = new Effects();
		dragger = new Dragger();
		ps.add(dragger);
		input = new Input();
		mouse = input.mouse;
		keys = input.keys;
		ps.add(mouse);
		ps.add(keys);

		routine = new ObservationRoutine(); // EditorRoutine();
		routine.run();
	}
}

class Signals
{
	public var newInput:FlxTypedSignal<InputID->Void>;

	public function new()
	{
		newInput = new FlxTypedSignal<InputID->Void>();
	}
}

class Misc
{
	// public var hud:HUD;
	public function new() {}

	public function init() // misc (consequently, hud, etc.) isn't available until new() completes, so we need this separate init method
	{}
}
