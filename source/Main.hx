package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		stage.showDefaultContextMenu = false;
		addChild(new FlxGame(0, 0, PlayState, 60, 60, true));
	}
}
