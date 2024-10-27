package gadgets;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import gadgets.Anchor;
import system.System;

class Transform
{
	public var rect:FlxRect;

	private var children:Map<Transform, FlxRect>;

	private var toCallback:FlxRect->Void;

	public var x(get, set):Float;
	public var y(get, set):Float;
	public var width(get, set):Float;
	public var height(get, set):Float;

	public function new(?rect:FlxRect)
	{
		this.rect = rect == null ? new FlxRect() : rect;
		children = [];
		toCallback = (_) -> {};
	}

	public function to(newRect:FlxRect)
	{
		toCallback(newRect);

		for (child in children.keys())
		{
			child.to(analogousRectUnit(children[child], newRect));
		}

		rect = newRect;

		return this;
	}

	public function by(scaleX:Float, scaleY:Float, offsetX:Float, offsetY:Float)
	{
		return to(scaledRect(rect, scaleX, scaleY, offsetX, offsetY));
	}

	public function scaleBy(scaleX:Float, scaleY:Float)
	{
		return by(scaleX, scaleY, 0, 0);
	}

	public function setTo(toCallback:FlxRect->Void)
	{
		this.toCallback = toCallback;
		return this;
	}

	public function fromSprite(sprite:FlxSprite)
	{
		rect = sprite.getRotatedBounds();
		toCallback = (target) ->
		{
			sprite.scale.x = target.width / sprite.width;
			sprite.scale.y = target.height / sprite.height;
			sprite.x += (target.x + target.width / 2) - (sprite.x + sprite.width / 2);
			sprite.y += (target.y + target.height / 2) - (sprite.y + sprite.height / 2);
		}
		return this;
	}

	public function add(child:Transform, ?subRect:FlxRect)
	{
		children[child] = subRect == null ? getUnitSubRect(child.rect) : subRect;
		child.to(analogousRectUnit(children[child], rect));
		return this;
	}

	// -------------------------------------------------------------------------

	public static function scaledRect(rect:FlxRect, scaleX:Float, scaleY:Float, offsetX:Float, offsetY:Float)
	{
		return new FlxRect(rect.x + (1 - scaleX) * (rect.width / 2) + offsetX, rect.y + (1 - scaleY) * (rect.height / 2) + offsetY, rect.width * scaleX,
			rect.height * scaleY);
	}

	// A is to B as C is to...  (A resizes to C; what should the child rect B resize to?)
	public static function analogousRect(A:FlxRect, B:FlxRect, C:FlxRect):FlxRect
	{
		if (A.isEmpty)
			throw "A empty!";
		var mx = C.width / A.width;
		var my = C.height / A.height;
		var bx = C.x - mx * A.x;
		var by = C.y - my * A.y;
		return new FlxRect(mx * B.x + bx, my * B.y + by, B.width * mx, B.height * my);
	}

	public static var unitRect:FlxRect = new FlxRect(0, 0, 1, 1);

	public static function analogousRectUnit(child:FlxRect, target:FlxRect):FlxRect
	{
		return analogousRect(unitRect, child, target);
	}

	private function getUnitSubRect(childRect:FlxRect):FlxRect
	{
		return analogousRect(rect, childRect, unitRect);
	}

	function set_x(x:Float):Float
	{
		to(new FlxRect(x, rect.y, rect.width, rect.height));
		return x;
	}

	function get_x():Float
	{
		return rect.x;
	}

	function set_y(y:Float):Float
	{
		to(new FlxRect(rect.x, y, rect.width, rect.height));
		return y;
	}

	function get_y():Float
	{
		return rect.y;
	}

	function set_width(width:Float):Float
	{
		to(new FlxRect(rect.x, rect.y, width, rect.height));
		return width;
	}

	function get_width():Float
	{
		return rect.width;
	}

	function set_height(height:Float):Float
	{
		to(new FlxRect(rect.x, rect.y, rect.width, height));
		return height;
	}

	function get_height():Float
	{
		return rect.height;
	}
}

class TransformTest extends FlxSprite
{
	public var transform:Transform;

	public function new(rect:FlxRect)
	{
		super(rect.x, rect.y);
		makeGraphic(Std.int(rect.width), Std.int(rect.height),
			FlxColor.fromHSL(FlxG.random.float(0, 360), FlxG.random.float(0, 1), FlxG.random.float(0.3, 0.7)), true);
		transform = new Transform().fromSprite(this);
		FlxG.state.add(this);
	}

	public function makeKids(n:Int)
	{
		if (n == 0)
			return;
		for (alignment in Type.allEnums(ALIGNMENT))
		{
			var rect = Useful.getRect(alignment, transform.rect, transform.rect.width / 4);
			if (rect.width >= 1 && rect.height >= 1)
			{
				var child = new TransformTest(rect);
				transform.add(child.transform);
				child.makeKids(n - FlxG.random.int(1, n));
			}
			rect.put();
		}
	}
}
