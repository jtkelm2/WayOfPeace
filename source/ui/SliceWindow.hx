package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import flixel.tweens.FlxTween;
import gadgets.*;
import system.Reg;

using Useful;

class SliceWindow
{
	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;
	public var margin:Float;

	public var anchor:Anchor;

	// private var group:FlxTypedGroup<FlxSprite>;
	public var sprites:Array<FlxSprite>;

	private var horizontalTile:Bool;
	private var verticalTile:Bool;

	public function new(x:Float, y:Float, width:Float, height:Float, margin:Float, horizontalTile:Bool = false, verticalTile:Bool = false)
	{
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.margin = margin;
		this.horizontalTile = horizontalTile;
		this.verticalTile = verticalTile;
		this.sprites = [];
		// this.group = new FlxTypedGroup(9);
		this.anchor = new Anchor(x + width / 2, y + height / 2);
	}

	public function loadGraphic(graphic:FlxGraphicAsset, graphicMargin:Int)
	{
		var sprite = new FlxSprite(0, 0, graphic);
		var graphicWidth = Std.int(sprite.width);
		var graphicHeight = Std.int(sprite.height);
		sprite.destroy();

		// Corners
		sprites[0] = Useful.loadGraphicCropped(graphic, 0, 0, graphicMargin, graphicMargin);
		Useful.centerAt(sprites[0], x + margin / 2, y + margin / 2);
		Useful.scaleTo(sprites[0], margin, margin);

		sprites[2] = Useful.loadGraphicCropped(graphic, graphicWidth - graphicMargin, 0, graphicMargin, graphicMargin);
		Useful.centerAt(sprites[2], x + width - margin / 2, y + margin / 2);
		Useful.scaleTo(sprites[2], margin, margin);

		sprites[6] = Useful.loadGraphicCropped(graphic, 0, graphicHeight - graphicMargin, graphicMargin, graphicMargin);
		Useful.centerAt(sprites[6], x + margin / 2, y + height - margin / 2);
		Useful.scaleTo(sprites[6], margin, margin);

		sprites[8] = Useful.loadGraphicCropped(graphic, graphicWidth - graphicMargin, graphicHeight - graphicMargin, graphicMargin, graphicMargin);
		Useful.centerAt(sprites[8], x + width - margin / 2, y + height - margin / 2);
		Useful.scaleTo(sprites[8], margin, margin);

		// Edges
		sprites[1] = Useful.loadGraphicCropped(graphic, graphicMargin, 0, graphicWidth - 2 * graphicMargin, graphicMargin);
		Useful.centerAt(sprites[1], x + width / 2, y + margin / 2);
		Useful.scaleTo(sprites[1], width - 2 * margin, margin);

		sprites[3] = Useful.loadGraphicCropped(graphic, 0, graphicMargin, graphicMargin, graphicHeight - 2 * graphicMargin);
		Useful.centerAt(sprites[3], x + margin / 2, y + height / 2);
		Useful.scaleTo(sprites[3], margin, height - 2 * margin);

		sprites[5] = Useful.loadGraphicCropped(graphic, graphicWidth - graphicMargin, graphicMargin, graphicMargin, graphicHeight - 2 * graphicMargin);
		Useful.centerAt(sprites[5], x + width - margin / 2, y + height / 2);
		Useful.scaleTo(sprites[5], margin, height - 2 * margin);

		sprites[7] = Useful.loadGraphicCropped(graphic, graphicMargin, graphicHeight - graphicMargin, graphicWidth - 2 * graphicMargin, graphicMargin);
		Useful.centerAt(sprites[7], x + width / 2, y + height - margin / 2);
		Useful.scaleTo(sprites[7], width - 2 * margin, margin);

		// Center
		sprites[4] = Useful.loadGraphicCropped(graphic, graphicMargin, graphicMargin, graphicWidth - 2 * graphicMargin, graphicHeight - 2 * graphicMargin);
		Useful.centerAt(sprites[4], x + width / 2, y + height / 2);
		Useful.scaleTo(sprites[4], width - 2 * margin, height - 2 * margin);

		for (sprite in sprites)
		{
			anchor.add(new Anchor(sprite.x + sprite.width / 2, sprite.y + sprite.height / 2, sprite, false, false));
		}
	}

	public function resize(width:Float, height:Float, margin:Float)
	{
		anchor.scale_x *= (width - margin) / (this.width - this.margin);
		anchor.scale_y *= (height - margin) / (this.height - this.margin);
		for (i in [0, 2, 6, 8])
		{
			Useful.scaleTo(sprites[i], margin, margin);
		}
		for (i in [1, 7])
		{
			Useful.scaleTo(sprites[i], width - 2 * margin, margin);
		}
		for (i in [3, 5])
		{
			Useful.scaleTo(sprites[i], margin, height - 2 * margin);
		}
		Useful.scaleTo(sprites[4], width - 2 * margin, height - 2 * margin);

		this.width = width;
		this.height = height;
		this.margin = margin;
	}

	public function addToGroup(group:FlxTypedGroup<FlxSprite>)
	{
		for (sprite in sprites)
		{
			group.add(sprite);
		}
	}

	public function toggleVisibility(bool:Bool = true)
	{
		for (sprite in sprites)
		{
			sprite.visible = bool;
		}
	}

	public function setAlpha(alpha:Float)
	{
		for (sprite in sprites)
		{
			sprite.alpha = alpha;
		}
	}

	public function destroy()
	{
		for (sprite in sprites)
		{
			sprite.destroy();
		}

		anchor.destroy();
	}
}
