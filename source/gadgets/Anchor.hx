package gadgets;

import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import gadgets.*;
import system.*;
import system.Data;

class Anchor
{
	public var x(default, set):Float;
	public var y(default, set):Float;
	public var scale_x(default, set):Float;
	public var scale_y(default, set):Float;
	public var angle(default, set):Float;

	public var parent:Null<FlxSprite>;

	private var shouldScaleX:Bool;
	private var shouldScaleY:Bool;

	public var anchored:Array<Anchor>;

	private var marker:Marker;

	public function new(x:Float = 0, y:Float = 0, parent:Null<FlxSprite> = null, shouldScaleX:Bool = true, shouldScaleY:Bool = true)
	{
		this.parent = parent;
		this.shouldScaleX = shouldScaleX;
		this.shouldScaleY = shouldScaleY;
		this.anchored = [];
		this.x = x;
		this.y = y;
		scale_x = 1;
		scale_y = 1;
		angle = 0;

		// drawMarker();
	}

	public function attachParent(parent:FlxSprite, center:Bool = true, shouldScaleX:Bool = true, shouldScaleY:Bool = true):Anchor
	{
		this.parent = parent;
		if (center)
		{
			Useful.centerAt(parent, x, y);
		}
		this.shouldScaleX = shouldScaleX;
		this.shouldScaleY = shouldScaleY;
		return this;
	}

	public function drawMarker(bool:Bool = true)
	{
		if (marker == null)
		{
			marker = new Marker(this);
		}
		marker.visible = bool;
	}

	public function add(anchor:Anchor, callback:Callback = null)
	{
		anchored.push(anchor);
		if (callback != null)
			callback();
	}

	public function remove(anchor:Anchor, callback:Callback = null)
	{
		anchored.remove(anchor);
		if (callback != null)
			callback();
	}

	public function relativize(point:FlxPoint):FlxPoint
	{
		var home = FlxPoint.get(x, y);
		var displacement = point - home;
		displacement.degrees += angle;
		displacement.x *= scale_x;
		displacement.y *= scale_y;
		displacement += home;
		home.put();
		return displacement;
	}

	public function moveTo(x:Float, y:Float, callback:Callback = null)
	{
		System.effects.quadMove(this, x, y, callback);
	}

	public function rotate(angleDiff:Float, callback:Callback = null)
	{
		System.effects.quadRotate(this, angleDiff, callback);
	}

	public function destroy()
	{
		for (anchor in anchored)
		{
			anchor.destroy();
			anchor = null;
		}
		anchored = null;
		if (marker != null)
		{
			Reg.markerGroup.remove(marker);
			marker.destroy();
			marker = null;
		}
	}

	// ---------------------------

	private function set_x(newX:Float)
	{
		if (x == null)
		{
			x = newX;
			return x;
		}

		var diffX = newX - x;
		for (anchor in anchored)
		{
			anchor.x += diffX;
		}

		if (parent != null)
		{
			parent.x += diffX;
		}

		x = newX;
		return x;
	}

	private function set_y(newY:Float)
	{
		if (y == null)
		{
			y = newY;
			return y;
		}

		var diffY = newY - y;
		for (anchor in anchored)
		{
			anchor.y += diffY;
		}

		if (parent != null)
		{
			parent.y += diffY;
		}

		y = newY;
		return y;
	}

	private function set_scale_x(newScale_x:Float)
	{
		if (scale_x == null)
		{
			scale_x = newScale_x;
			return scale_x;
		}

		var scaleQuotient = newScale_x / scale_x;
		for (anchor in anchored)
		{
			var displacement = FlxPoint.get(anchor.x - x, anchor.y - y);
			displacement.degrees -= angle;
			displacement.x *= scaleQuotient;
			displacement.degrees += angle;
			anchor.x = x + displacement.x;
			anchor.y = y + displacement.y;
			anchor.scale_x *= scaleQuotient;

			displacement.put();
			// var displacementX = anchor.x - x;
			// displacementX *= scaleQuotient;
			// anchor.x = x + displacementX;

			// anchor.scale_x *= scaleQuotient;
		}

		if (parent != null && shouldScaleX)
		{
			var displacementX = parent.x + parent.width / 2 - x;
			displacementX *= scaleQuotient;
			parent.x = x - parent.width / 2 + displacementX;
			parent.scale.x *= scaleQuotient;
		}
		scale_x = newScale_x;
		return newScale_x;
	}

	private function set_scale_y(newScale_y:Float)
	{
		if (scale_y == null)
		{
			scale_y = newScale_y;
			return scale_y;
		}

		var scaleQuotient = newScale_y / scale_y;
		for (anchor in anchored)
		{
			var displacement = FlxPoint.get(anchor.x - x, anchor.y - y);
			displacement.degrees -= angle;
			displacement.y *= scaleQuotient;
			displacement.degrees += angle;
			anchor.x = x + displacement.x;
			anchor.y = y + displacement.y;
			anchor.scale_y *= scaleQuotient;

			displacement.put();
			// var displacementY = anchor.y - y;
			// displacementY *= scaleQuotient;
			// anchor.y = y + displacementY;
			// anchor.scale_y *= scaleQuotient;
		}

		if (parent != null && shouldScaleY)
		{
			var displacementY = parent.y + parent.height / 2 - y;
			displacementY *= scaleQuotient;
			parent.y = y - parent.height / 2 + displacementY;
			parent.scale.y *= scaleQuotient;
		}

		scale_y = newScale_y;
		return newScale_y;
	}

	private function set_angle(newAngle:Float)
	{
		if (angle == null)
		{
			angle = newAngle;
			return newAngle;
		}
		var angleDiff = newAngle - angle;
		var anchorPoint = FlxPoint.get(x, y);
		// trace("AnchorPoint: " + anchorPoint);
		for (anchor in anchored)
		{
			var oldMidpoint = FlxPoint.get(anchor.x, anchor.y);
			var newMidpoint = FlxPoint.get(anchor.x, anchor.y);
			newMidpoint.pivotDegrees(anchorPoint, angleDiff);
			anchor.x += newMidpoint.x - oldMidpoint.x;
			anchor.y += newMidpoint.y - oldMidpoint.y;
			anchor.angle += angleDiff;
			// trace("Old: " + oldMidpoint);
			// trace("New: " + newMidpoint);
			oldMidpoint.put();
			newMidpoint.put();
		}

		if (parent != null)
		{
			var oldMidpoint = FlxPoint.get(parent.x + parent.width / 2, parent.y + parent.height / 2);
			var newMidpoint = FlxPoint.get(parent.x + parent.width / 2, parent.y + parent.height / 2);
			newMidpoint.pivotDegrees(anchorPoint, angleDiff);
			parent.x += newMidpoint.x - oldMidpoint.x;
			parent.y += newMidpoint.y - oldMidpoint.y;
			parent.angle += angleDiff;
			// trace("Old: " + oldMidpoint);
			// trace("New: " + newMidpoint);
			oldMidpoint.put();
			newMidpoint.put();
		}

		anchorPoint.put();
		angle = newAngle;
		return newAngle;
	}
}
