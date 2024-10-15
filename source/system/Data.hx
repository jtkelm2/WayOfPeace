package system;

import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.ui.FlxButton;
import gameobjects.*;
import map.*;
import routines.*;
import routines.fellow.*;
import routines.player.*;

using Useful;

typedef Callback = Null<() -> Void>;

// ---------------- Enums ------------------

enum InputID
{
	LeftClick;
	RightClick;
	MiddleClick;
	KeyPressed(key:KeyID);
	KeyReleased(key:KeyID);
}

enum Coords
{
	Coords(q:Int, r:Int, s:Int);
}

enum Facing
{
	NE;
	E;
	SE;
	SW;
	W;
	NW;
}

enum KeyID
{
	Spacebar;
	Up;
	Down;
	Left;
	Right;
	Enter;
	Shift;
}

enum ObjectID {}

enum Tag
{
	FellowTag;
	HexTag;
	DDButtonTag;
}

// ---------------- Interfaces -----------------------

interface IDObject
{
	public var id:ObjectID;
}

interface IDSprite extends IDObject extends IFlxSprite {}

class Data
{
	public var tags = [];

	public function new() {}

	public function toSprite(idSprite:IDSprite):FlxSprite
	{
		return Type.enumParameters(idSprite.id)[0];
	}

	public function toTag(idObject:IDObject):Tag
	{
		return idToTag(idObject.id);
	}

	public function idToTag(objectID:ObjectID):Tag
	{
		var idConstructor = Type.enumConstructor(objectID);

		return Type.createEnum(Tag, idConstructor.substr(0, idConstructor.length - 2) + "Tag");
	}
}
