package system;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.mouse.FlxMouseEvent;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import system.Data;
import system.System;

typedef EffectsProfile =
{
	?transparing:FlxTween
}

class Effects
{
	private var effectRegistry:Map<FlxSprite, EffectsProfile>;

	public function new()
	{
		effectRegistry = [];
	}

	public function toggleTransparing(sprite:FlxSprite, bool:Bool)
	{
		registerSprite(sprite);

		if (effectRegistry[sprite].transparing != null)
		{
			effectRegistry[sprite].transparing.cancel();
		}
		sprite.alpha = 1;

		if (bool)
		{
			effectRegistry[sprite].transparing = FlxTween.tween(sprite, {alpha: 0.5}, 1, {type: PINGPONG});
		}
	}

	public function transpare(sprite:FlxSprite)
	{
		toggleTransparing(sprite, false);
		sprite.alpha = 0.5;
	}

	public function detranspare(sprite:FlxSprite)
	{
		toggleTransparing(sprite, false);
		sprite.alpha = 1;
	}

	public function fadeOut(sprite:FlxSprite, duration:Float = 1, startingAlpha:Float = 1, endingAlpha:Float = 0)
	{
		toggleTransparing(sprite, false);
		sprite.alpha = startingAlpha;
		effectRegistry[sprite].transparing = FlxTween.tween(sprite, {alpha: endingAlpha}, duration);
	}

	public function fadeIn(sprite:FlxSprite, duration:Float = 1, startingAlpha:Float = 0, endingAlpha:Float = 1)
	{
		fadeOut(sprite, duration, startingAlpha, endingAlpha);
	}

	public function quadMove(sprite:Dynamic, destX:Float, destY:Float, callback:Callback = null)
	{
		// movable.isMoving = true;

		var distance:Float = Math.pow(sprite.x - destX, 2) + Math.pow(sprite.y - destY, 2);
		var duration = FlxMath.bound(distance / 10000, 0.01, Reg.MAX_MOVE_TIME);

		var onComplete = _ ->
		{
			// movable.isMoving = false;
			if (callback != null)
				callback();
		};

		FlxTween.tween(sprite, {x: destX, y: destY}, duration, {ease: FlxEase.quadInOut, onComplete: onComplete});
	}

	public function instantMove(sprite:Dynamic, destX:Float, destY:Float, callback:Callback = null)
	{
		sprite.x = destX;
		sprite.y = destY;
		if (callback != null)
		{
			callback();
		}
	}

	public function quadRotate(sprite:Dynamic, angleDiff:Float, callback:Callback = null)
	{
		// movable.isMoving = true;

		var duration = FlxMath.bound(Math.abs(angleDiff) / 360, 0.01, Reg.MAX_MOVE_TIME);

		var onComplete = _ ->
		{
			// movable.isMoving = false;
			if (callback != null)
				callback();
		};

		FlxTween.tween(sprite, {angle: sprite.angle + angleDiff}, duration, {ease: FlxEase.quadInOut, onComplete: onComplete});
	}

	public function smash(sprite:FlxSprite, callback:Callback = null)
	{
		var curY = sprite.y;
		var height = 2 * 100;
		var onComplete = callback == null ? _ -> {} : _ -> callback();
		FlxTween.tween(sprite, {scale_x: 1.8, scale_y: 1.8, y: curY - height}, 0.3)
			.then(FlxTween.tween(sprite, {scale_x: 1, scale_y: 1, y: curY}, 0.5, {ease: FlxEase.expoIn, onComplete: onComplete}));
	}

	public function rumble(sprite:FlxSprite, intensity:Float = 0.05, duration:Float = 1, callback:Callback = null)
	{
		var onComplete = callback == null ? _ -> {} : _ -> callback();
		FlxTween.shake(sprite, intensity, duration, FlxAxes.XY, {onComplete: onComplete});
	}

	// HERE
	public function spin(movable:Dynamic, angle:Float, callback:Callback = null)
	{
		var onComplete = callback == null ?() -> {} : callback;
		var upAngle = FlxG.random.floatNormal(angle, angle / 5);
		var downAngle = 2 * FlxG.random.floatNormal(angle, angle / 5);
		movable.rotate(-upAngle, () -> movable.rotate(downAngle, () -> movable.rotate(upAngle - downAngle, onComplete)));
	}

	public function fidget(movable:Dynamic, angle:Float, callback:Callback = null)
	{
		var onComplete = callback == null ?() -> {} : callback;
		var upAngle = FlxG.random.floatNormal(angle, angle / 5);
		var downAngle = 2 * FlxG.random.floatNormal(angle, angle / 5);
		movable.rotate(-upAngle, () -> movable.rotate(downAngle, () -> movable.rotate(upAngle - downAngle, onComplete)));
	}

	/* public function flash(sprite:FlxSprite, duration:Float = 1, callback:Callback = null) {
		var onComplete = callback == null ? _ -> {} : _ -> callback();
		var loops:Int = Math.round(duration / 0.2);
		FlxTween.color(sprite, 0.1, FlxColor.TRANSPARENT, FlxColor.WHITE, {onComplete: onComplete, type: PINGPONG});
	}*/
	public function floatText(message:String, color:FlxColor = FlxColor.BLACK, size:Int = 24)
	{
		var text = Reg.floatTextGroup.recycle(FlxText);
		Reg.floatTextGroup.add(text);
		// text.camera = System.misc.hud.hudCamera;
		text.text = message;
		text.color = color;
		text.setBorderStyle(OUTLINE, color.brightness > 0.5 ? FlxColor.BLACK : FlxColor.WHITE, 3);
		text.size = size;
		text.screenCenter(X);
		// text.x += Reg.HUD_X;
		text.y = FlxG.height - text.height;
		text.alpha = 1;
		var curY = text.y;
		var onComplete = _ -> text.kill;
		FlxTween.cancelTweensOf(text);
		FlxTween.tween(text, {y: curY - FlxG.height / 4, alpha: 0}, 4, {onComplete: onComplete});
	}

	// -----------------------------------------------

	private function registerSprite(sprite:FlxSprite)
	{
		if (!effectRegistry.exists(sprite))
		{
			effectRegistry[sprite] = {};
		}
	}
}
