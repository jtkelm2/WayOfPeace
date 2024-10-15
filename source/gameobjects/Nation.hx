package gameobjects;

import flixel.FlxG;

class Nation
{
	public var num:Int;
	public var loc:Array<Float>;

	public function new(num:Int)
	{
		this.num = num;
		resetLoc();
	}

	public function resetLoc()
	{
		loc = [for (_ in 0...3) FlxG.random.float(-1, 1)];
	}
}
