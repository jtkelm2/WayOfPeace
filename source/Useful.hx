package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import system.Data;

using Lambda;

class Useful
{
	public static function q(coords:Coords):Int
	{
		switch coords
		{
			case Coords(q, _, _):
				return q;
		}
	}

	public static function r(coords:Coords):Int
	{
		switch coords
		{
			case Coords(_, r, _):
				return r;
		}
	}

	public static function s(coords:Coords):Int
	{
		switch coords
		{
			case Coords(_, _, s):
				return s;
		}
	}
}

function modulo(n:Int, d:Int):Int
{
	var r = n % d;
	if (r < 0)
		r += d;
	return r;
}

function sum(arr:Array<Float>):Float
{
	return arr.fold((a, b) -> a + b, 0);
}

function zipWith<A, B, C>(arr1:Array<A>, arr2:Array<B>, f:(A, B) -> C):Array<C>
{
	return [for (i in 0...FlxMath.minInt(arr1.length, arr2.length)) f(arr1[i], arr2[i])];
}

function last<T>(arr:Array<T>):T
{
	return arr[arr.length - 1];
}

function getActualScreenPosition(object:FlxObject, ?camera:FlxCamera):FlxPoint
{
	camera = camera == null ? object.camera : camera;
	return FlxPoint.get((object.x - camera.viewX) * (camera.width / camera.viewWidth), (object.y - camera.viewY) * (camera.height / camera.viewHeight));
}

function onScreen(point:FlxPoint, ?camera:FlxCamera):FlxPoint
{
	camera = camera == null ? FlxG.camera : camera;
	return FlxPoint.get((point.x - camera.viewX) * (camera.width / camera.viewWidth), (point.y - camera.viewY) * (camera.height / camera.viewHeight));
}

function inWorld(point:FlxPoint, ?camera:FlxCamera):FlxPoint
{
	camera = camera == null ? FlxG.camera : camera;
	return FlxPoint.get(point.x * (camera.viewWidth / camera.width) + camera.viewX, point.y * (camera.viewHeight / camera.height) + camera.viewY);
}

function scaleTo(sprite:FlxSprite, width:Float, height:Float):FlxSprite
{
	sprite.scale.x *= width / (sprite.scale.x * sprite.width);
	sprite.scale.y *= height / (sprite.scale.y * sprite.height);
	return sprite;
}

function centerAt(sprite:FlxSprite, x:Float, y:Float):FlxSprite
{
	sprite.x = x - sprite.scale.x * sprite.width / 2;
	sprite.y = y - sprite.scale.y * sprite.height / 2;
	return sprite;
}

function loadGraphicCropped(graphic:FlxGraphicAsset, x:Int, y:Int, width:Int, height:Int):FlxSprite
{
	var sprite = new FlxSprite(0, 0).makeGraphic(width, height, FlxColor.TRANSPARENT, true);
	var stamp = new FlxSprite(0, 0, graphic);
	sprite.stamp(stamp, -x, -y);
	stamp.destroy();
	return sprite;
}

function reluMax(t:Float, x1:Float, x2:Float, left:Float = 0, right:Float = 1):Float
{
	if (t < x1)
	{
		return left;
	}
	else if (t > x2)
	{
		return right;
	}
	else
	{
		return (t - x1) * (right - left) / (x2 - x1) + left;
	}
}

function distance(p:Array<Float>, q:Array<Float>):Float
{
	return Math.sqrt(sum(zipWith(p, q, (a, b) -> (a - b) * (a - b))));
}
