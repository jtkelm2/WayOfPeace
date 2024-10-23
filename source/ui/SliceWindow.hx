package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import gadgets.*;
import gadgets.Anchor;
import system.Reg;
import ui.HUD;

using Useful;

var ASSETPATH:Map<WINDOW_TYPE, String> = [WIRE => "assets/box.png", SHADED => "assets/shade_box.png"];

enum WINDOW_TYPE
{
	WIRE;
	SHADED;
}

class SliceWindowFragment extends FlxSprite
{
	public var anchor:Anchor;
	public var alignment:ALIGNMENT;
	public var visibility:Visibility;

	private var window:SliceWindow;

	public function new(window:SliceWindow, alignment:ALIGNMENT)
	{
		super();
		this.window = window;
		this.alignment = alignment;

		visibility = new Visibility(this);
		visibility.hide(); // Necessary so refreshPositionScale() doesn't try to scale this

		anchor = new Anchor().attachParent(this);
		window.anchor.add(anchor);

		refreshPositionScale();
	}

	public function loadGraphicFragment(sprite:FlxSprite, graphicMargin:Int)
	{
		visibility.show();

		var graphicRect = Useful.getRect(alignment, sprite.getRotatedBounds(), graphicMargin);

		makeGraphic(Std.int(graphicRect.width), Std.int(graphicRect.height), FlxColor.TRANSPARENT, true);
		stamp(sprite, Std.int(-graphicRect.x), Std.int(-graphicRect.y));

		graphicRect.put();

		anchor.center(this);
		refreshPositionScale();
	}

	public function refreshPositionScale()
	{
		var rect = new FlxRect();
		rect.x = window.x() + 0.5 * window.margin;
		rect.y = window.y() + 0.5 * window.margin;
		rect.width = window.width - window.margin;
		rect.height = window.height - window.margin;

		var pos = Anchor.getAlignmentPoint(alignment, rect);
		anchor.x = pos.x;
		anchor.y = pos.y;

		if (visible)
		{
			var trueRect = Useful.getRect(alignment, window.rect(), window.margin);
			// trace(alignment);
			// trace(getScreenBounds(), anchor.x, anchor.y);
			Useful.scaleTo(this, trueRect.width, trueRect.height);
			// trace(getScreenBounds(), trueRect);
			trueRect.put();
			// trace(pos);
			// trace(rect);
		}

		pos.put();
		rect.put();
	}

	override public function destroy()
	{
		window.anchor.remove(anchor);
		anchor.destroy();
		super.destroy();
	}
}

class SliceWindow
{
	public var width:Float;
	public var height:Float;
	public var margin:Float;
	public var visibility:Visibility;
	public var anchor:Anchor; // Only to be used for rotations

	private var fragments:Array<SliceWindowFragment>;

	private var alpha(default, set):Float;

	public function new(x:Float = 0, y:Float = 0, width:Float = 200, height:Float = 100, margin:Float = 16)
	{
		this.width = width;
		this.height = height;
		this.margin = margin;
		anchor = new Anchor(x + width / 2, y + height / 2);
		visibility = new Visibility();
		initFragments();
		alpha = 1;
	}

	public function x():Float
	{
		return anchor.x - 0.5 * width;
	}

	public function y():Float
	{
		return anchor.y - 0.5 * height;
	}

	public function rect():FlxRect
	{
		var rect = new FlxRect();
		rect.x = x();
		rect.y = y();
		rect.width = width;
		rect.height = height;
		return rect;
	}

	public function addTo(group:FlxGroup)
	{
		for (fragment in fragments)
		{
			group.add(fragment);
		}
	}

	public function setType(type:WINDOW_TYPE = WIRE):SliceWindow
	{
		loadGraphic(ASSETPATH[type], 32);
		return this;
	}

	public function transform(scaleX:Float = 1, scaleY:Float = 1, offsetX:Float = 0, offsetY:Float = 0)
	{
		width *= scaleX;
		height *= scaleY;
		anchor.x += offsetX;
		anchor.y += offsetY;

		if (width <= 2 * margin || height <= 2 * margin)
		{
			visibility.hide();
			trace("Resizing made SliceWindow invisible");
			trace(width, height, margin);
			return this;
		}

		for (fragment in fragments)
		{
			fragment.refreshPositionScale();
		}

		return this;
	}

	public function resize(x:Float, y:Float, width:Float, height:Float, ?margin:Float):SliceWindow
	{
		this.margin = margin == null ? this.margin : margin;
		var scaleX = width / this.width;
		var scaleY = height / this.height;
		var offsetX = (x - this.x()) + 0.5 * (width - this.width);
		var offsetY = (y - this.y()) + 0.5 * (height - this.height);

		transform(scaleX, scaleY, offsetX, offsetY);
		return this;
	}

	// public function show()
	// {
	// 	visibility.show();
	// 	// for (fragment in fragments)
	// 	// {
	// 	// 	fragment.visible = true;
	// 	// }
	// }
	// public function hide()
	// {
	// 	visibility.hide();
	// 	// for (fragment in fragments)
	// 	// {
	// 	// 	fragment.visible = false;
	// 	// }
	// }

	public function destroy()
	{
		for (fragment in fragments)
		{
			fragment.destroy();
		}

		anchor.destroy();
	}

	public function setMargin(margin:Float)
	{
		this.margin = margin;
		resize(x(), y(), width, height, margin);
		return margin;
	}

	//---------------------------------------------------------------

	private function initFragments()
	{
		fragments = [];
		for (alignment in Type.allEnums(ALIGNMENT))
		{
			var fragment = new SliceWindowFragment(this, alignment);
			fragments.push(fragment);
			visibility.add(fragment.visibility);
		}
	}

	private function set_alpha(alpha:Float)
	{
		for (fragment in fragments)
		{
			fragment.alpha = alpha;
		}
		this.alpha = alpha;
		return alpha;
	}

	public function loadGraphic(graphic:FlxGraphicAsset, graphicMargin:Int)
	{
		var sprite = new FlxSprite(0, 0, graphic);
		for (fragment in fragments)
		{
			fragment.loadGraphicFragment(sprite, graphicMargin);
		}
		sprite.destroy();
	}
}
