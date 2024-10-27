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
	// public var anchor:Anchor;
	public var alignment:ALIGNMENT;
	public var visibility:Visibility;
	public var transform:Transform;

	private var window:SliceWindow;

	public function new(window:SliceWindow, alignment:ALIGNMENT)
	{
		super();
		this.window = window;
		this.alignment = alignment;

		visibility = new Visibility(this);
		transform = new Transform();

		refreshPositionScale();
	}

	public function loadGraphicFragment(sprite:FlxSprite, graphicMargin:Int)
	{
		var graphicRect = Useful.getRect(alignment, sprite.getRotatedBounds(), graphicMargin);

		makeGraphic(Std.int(graphicRect.width), Std.int(graphicRect.height), FlxColor.TRANSPARENT, true);
		stamp(sprite, Std.int(-graphicRect.x), Std.int(-graphicRect.y));

		graphicRect.put();

		transform.fromSprite(this);
		refreshPositionScale();
	}

	public function refreshPositionScale()
	{
		var rect = new FlxRect();
		rect.x = window.transform.x + 0.5 * window.margin;
		rect.y = window.transform.y + 0.5 * window.margin;
		rect.width = window.transform.width - window.margin;
		rect.height = window.transform.height - window.margin;

		var trueRect = Useful.getRect(alignment, window.transform.rect, window.margin);
		transform.to(trueRect);

		trueRect.put();
		rect.put();
	}
}

class SliceWindow
{
	public var margin:Float;
	public var visibility:Visibility;
	public var transform:Transform;

	private var fragments:Array<SliceWindowFragment>;

	private var alpha(default, set):Float;

	public function new(x:Float = 0, y:Float = 0, width:Float = 200, height:Float = 100, margin:Float = 16)
	{
		this.margin = margin;
		visibility = new Visibility();
		transform = new Transform(new FlxRect(x, y, width, height)).setTo(to);
		initFragments();
		alpha = 1;
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

	public function to(rect:FlxRect)
	{
		transform.rect = rect;
		for (fragment in fragments)
		{
			fragment.refreshPositionScale();
		}
	}

	public function destroy()
	{
		for (fragment in fragments)
		{
			fragment.destroy();
		}
	}

	public function setMargin(margin:Float)
	{
		this.margin = margin;
		transform.to(transform.rect);
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
