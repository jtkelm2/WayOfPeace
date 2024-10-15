package gameobjects;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gadgets.*;
import map.*;
import system.*;
import system.Data;

using Useful;

/*

	Diplomacy of nations evolves according to the interdependent evolution of three variables belonging to each nation.

	Variable one is the diplomacy vector of each nation, i.e. that nation's relationship status with each other nation, -1 to 1.
	Variable two is the culture vector of each nation, living in some high-dimensional vector space.
	Variable three is the influence vector of each nation, representing that nation's tendency to culturally evolve alongside
	(rather than independent of) each other nation.

	The influence vector may evolve according to diplomacy, or even asymmetrically, but it may also be taken as a symmetrical
	constant, proportional to the physical distance separating the nations in geography.
	The culture vector evolves stochastically, but via a process that ensures nations with close influence evolve similarly.
	The diplomacy vector evolves according to a differential equation, with derivative proportional to cultural similarity plus
	the bias of associates (maybe?).

	OR: some game gimmick around repeated averaging, fixing the issue that this always brainlessly results in homogeneity

 */
/*

	Resistance to diplomatic efforts increases proportional to animosity. It is easier to make friends than to un-make enemies.

	To un-make enemies, one must appeal to common friends. But to appeal to common friends, risks making supercoalitions that will
	bully other nations.

 */
class RelationsTable extends FlxBasic
{
	public var nations:Array<Nation>;

	private var grid:Grid;

	public var relationMatrix:Map<Nation, Map<Nation, Float>>;

	private var compatibilityMatrix:Map<Nation, Map<Nation, Float>>;
	private var relationIndicators:Map<Nation, Map<Nation, FlxSprite>>;

	private var compatibilityIndicators:Map<Nation, Map<Nation, FlxSprite>>;

	private var nationDistances:Map<Nation, Map<Nation, Float>>;

	private var x:Float;
	private var y:Float;
	private var size:Float;
	private var indicatorSize:Int;

	public var anchor:Anchor;

	public function new(x:Float, y:Float, size:Float, nations:Array<Nation>, indicatorGroup:FlxGroup)
	{
		super();
		FlxG.state.add(this);

		indicatorSize = Std.int(size / (nations.length + 1));
		anchor = new Anchor(x, y);

		initRelationMatrix(nations);
		initIndicators(x, y, size, indicatorGroup);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		updateRelationMatrix(elapsed);
		updateIndicators();
	}

	public function resetRelationMatrix(resetCompatibilities:Bool = true)
	{
		for (i in 0...nations.length)
		{
			var nation1 = nations[i];
			for (j in 0...nations.length)
			{
				var nation2 = nations[j];
				nationDistances[nation1][nation2] = Math.sqrt(nation1.loc.zipWith(nation2.loc, (a, b) -> (a - b) * (a - b)).sum());
				relationMatrix[nation1][nation2] = FlxG.random.float(-1, 1);
				if (resetCompatibilities && i > j)
				{
					compatibilityMatrix[nation1][nation2] = FlxG.random.float(-0.6, 0.6);
					compatibilityMatrix[nation2][nation1] = compatibilityMatrix[nation1][nation2];
				}
			}
		}
	}

	public function compatibility(nation1:Nation, nation2:Nation):Float
	{
		return compatibilityMatrix[nation1][nation2];
	}

	public function relationship(nation1:Nation, nation2:Nation):Float
	{
		return relationMatrix[nation2][nation1];
	}

	// -------------------------------

	private function initRelationMatrix(nations:Array<Nation>)
	{
		this.nations = nations;
		relationMatrix = new Map<Nation, Map<Nation, Float>>();
		compatibilityMatrix = new Map<Nation, Map<Nation, Float>>();
		nationDistances = new Map<Nation, Map<Nation, Float>>();
		for (i in 0...nations.length)
		{
			var nation = nations[i];
			var nationMatrix = new Map<Nation, Float>();
			var distances = new Map<Nation, Float>();
			relationMatrix[nation] = nationMatrix;
			compatibilityMatrix[nation] = new Map<Nation, Float>();
			nationDistances[nation] = distances;
		}
		resetRelationMatrix();
	}

	private function initIndicators(x:Float, y:Float, size:Float, indicatorGroup:FlxGroup)
	{
		grid = new Grid(x, y, size, size, nations.length + 1, nations.length + 1);
		anchor.add(grid.anchor);

		relationIndicators = new Map<Nation, Map<Nation, FlxSprite>>();
		compatibilityIndicators = new Map<Nation, Map<Nation, FlxSprite>>();

		for (i in 0...nations.length)
		{
			var nation1 = nations[i];
			relationIndicators[nation1] = new Map<Nation, FlxSprite>();
			compatibilityIndicators[nation1] = new Map<Nation, FlxSprite>();

			for (j in 0...nations.length)
			{
				if (i == j)
				{
					continue;
				}
				var nation2 = nations[j];
				var relationIndicator = new FlxSprite();
				relationIndicator.makeGraphic(indicatorSize, indicatorSize, FlxColor.WHITE, true);
				grid.addAnchor(new Anchor(0, 0).attachParent(relationIndicator), i + 1, j + 1);
				indicatorGroup.add(relationIndicator);

				var compatibilityIndicator = new FlxSprite();
				compatibilityIndicator.makeGraphic(indicatorSize, indicatorSize, FlxColor.WHITE, true);
				grid.addAnchor(new Anchor(0, 0).attachParent(compatibilityIndicator), i + 1, j + 1);
				indicatorGroup.add(compatibilityIndicator);

				compatibilityIndicator.scale.x *= 0.5;
				compatibilityIndicator.scale.y *= 0.5;

				relationIndicators[nation1][nation2] = relationIndicator;
				compatibilityIndicators[nation1][nation2] = compatibilityIndicator;

				// trace(nation1);
				// trace(nation2);
				// trace(compatibilityMatrix);
				// for (key1 in compatibilityMatrix.keys())
				// {
				// 	trace("Nation:\n");
				// 	trace(key1.num);
				// 	for (key2 in compatibilityMatrix[key1].keys())
				// 	{
				// 		trace(key2.num);
				// 	}
				// }
				compatibilityIndicator.color = FlxColor.fromHSL((100 * compatibility(nation1, nation2) + 100) * 0.6, 0.82, 0.56);
			}
		}

		for (i in 0...nations.length)
		{
			var rowText = new FlxText();
			rowText.size = Math.round(indicatorSize * 0.5);
			rowText.text = Std.string(i + 1);
			grid.addAnchor(new Anchor().attachParent(rowText), i + 1, 0);
			indicatorGroup.add(rowText);

			var colText = new FlxText();
			colText.size = Math.round(indicatorSize * 0.5);
			colText.text = Std.string(i + 1);
			grid.addAnchor(new Anchor().attachParent(colText), 0, i + 1);
			indicatorGroup.add(colText);
		}

		updateIndicators();
	}

	private function updateRelationMatrix(elapsed:Float)
	{
		for (i in 0...nations.length)
		{
			var nation1 = nations[i];
			for (j in 0...nations.length)
			{
				if (i == j)
				{
					continue;
				}
				var nation2 = nations[j];
				var relationDelta = frenemyBias(nation1, nation2) / 2;
				var compatibilityDelta = compatibility(nation1, nation2);
				relationMatrix[nation1][nation2] = FlxMath.bound(relationMatrix[nation1][nation2] + elapsed * (0.5 * relationDelta + 0.5 * compatibilityDelta),
					-1, 1);
			}
		}
	}

	private function updateIndicators()
	{
		for (i in 0...nations.length)
		{
			var nation1 = nations[i];
			for (j in 0...nations.length)
			{
				if (i == j)
					continue;
				var nation2 = nations[j];
				var indicator = relationIndicators[nation1][nation2];
				var compatibilityIndicator = compatibilityIndicators[nation1][nation2];
				var relValue = relationship(nation1, nation2);
				indicator.color = FlxColor.fromHSL((100 * relValue + 100) * 0.6, 0.82, 0.56);
				compatibilityIndicator.color = FlxColor.fromHSL((100 * compatibility(nation1, nation2) + 100) * 0.6, 0.82, 0.56);
			}
		}
	}

	private function borderMultiplier(nation1:Nation, nation2:Nation):Float
	{
		return 1;
	}

	private function frenemyBias(nation1:Nation, nation2:Nation):Float
	{
		function likeness(a:Float, b:Float):Float
		{
			// Given that two nations have relations a and b with a third nation, how should that impact their own relation?
			// var c = Math.min(a, b); // (a + b) / 2;
			var importance = (Math.abs(a) + Math.abs(b)) / 2;
			var c = FlxMath.bound(importance * (1 - Math.abs(a - b) / 0.6), -1, 1);
			return c; // c > 0 ? Math.sqrt(c) : -Math.sqrt(-c);
		}

		function distance(nation1:Nation, nation2:Nation):Float
		{
			return nationDistances[nation1][nation2];
			// var c = a - b < 0 ? b - a : a - b;
			// return 2 * c > nations.length ? nations.length - c : c;
		}

		var sum:Float = 0;
		var importanceSum:Float = 0;
		for (associate in nations)
		{
			if (associate != nation1 && associate != nation2)
			{
				var importance = 1; // / (distance(nation1, associate) + distance(nation2, associate));
				sum += importance * likeness(relationship(nation1, associate), relationship(nation2, associate));
				importanceSum += importance;
			}
		}
		return sum / importanceSum;
	}
}
