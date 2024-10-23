package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import gadgets.Anchor;
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
	if (width <= 0 || height <= 0)
	{
		trace("scaleTo negative width/height");
		trace(sprite, width, height);
		sprite.visible = false;
		return sprite;
	}
	sprite.scale.x *= width / (sprite.scale.x * sprite.width);
	sprite.scale.y *= height / (sprite.scale.y * sprite.height);
	var rect = sprite.getScreenBounds();
	if (Math.abs(rect.width - width) > 0.001 || Math.abs(rect.height - height) > 0.001)
	{
		trace("scaleTo failure!");
		trace(sprite, width, height);
		throw "Goodbye";
	}
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

function transform(rect:FlxRect, scaleX:Float, scaleY:Float, offsetX:Float, offsetY:Float)
{
	rect.x += offsetX + 0.5 * (1 - scaleX) * rect.width;
	rect.y += offsetY + 0.5 * (1 - scaleY) * rect.height;
	rect.width *= scaleX;
	rect.height *= scaleY;
}

function testTween(anchor:Anchor, tweenXY:Bool = true)
{
	if (tweenXY)
	{
		var endX = anchor.x + 100;
		var endY = anchor.y + 50;
		FlxTween.tween(anchor, {angle: 360, x: endX, y: endY}, FlxG.random.float(3, 5), {
			ease: FlxEase.backInOut,
			type: PINGPONG,
			startDelay: FlxG.random.float(0, 2)
		});
	}
	else
	{
		FlxTween.tween(anchor, {angle: 360}, FlxG.random.float(3, 5), {
			ease: FlxEase.backInOut,
			type: PINGPONG,
			startDelay: FlxG.random.float(0, 2)
		});
	}
}

function floatEq(f:Float, f2:Float)
{
	return Math.abs(f - f2) < 0.01;
}

//---------------------------------------------------------------
// Computes the FlxRect corresponding to the 9-slice subrectangle of (rect,margin) relative to an alignment
function getRect(alignment:ALIGNMENT, rect:FlxRect, margin:Float):FlxRect
{
	var returnRect = new FlxRect();

	switch alignment
	{
		case TOPLEFT, CENTERLEFT, BOTTOMLEFT:
			returnRect.x = 0;
			returnRect.width = margin;
		case TOP, CENTER, BOTTOM:
			returnRect.x = margin;
			returnRect.width = rect.width - 2 * margin;
		case TOPRIGHT, CENTERRIGHT, BOTTOMRIGHT:
			returnRect.x = rect.width - margin;
			returnRect.width = margin;
	}

	switch alignment
	{
		case TOPLEFT, TOP, TOPRIGHT:
			returnRect.y = 0;
			returnRect.height = margin;
		case CENTERLEFT, CENTER, CENTERRIGHT:
			returnRect.y = margin;
			returnRect.height = rect.height - 2 * margin;
		case BOTTOMLEFT, BOTTOM, BOTTOMRIGHT:
			returnRect.y = rect.height - margin;
			returnRect.height = margin;
	}

	return returnRect;
}
