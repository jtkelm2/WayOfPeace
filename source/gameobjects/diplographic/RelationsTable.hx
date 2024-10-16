package gameobjects.diplographic;

import Useful;
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
import gadgets.Geometry;
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
	public var relations:Relations;
	public var compatibility:Compatibility;
	public var anchor:Anchor;

	// public var relationMatrix:Map<Nation, Map<Nation, Float>>;
	// private var compatibilityMatrix:Map<Nation, Map<Nation, Float>>;
	// private var relationIndicators:Map<Nation, Map<Nation, FlxSprite>>;
	// private var compatibilityIndicators:Map<Nation, Map<Nation, FlxSprite>>;
	private var grid:Grid;
	private var distances:Map<Nation, Map<Nation, Float>>;

	public function new(x:Float, y:Float, size:Float, nations:Array<Nation>, group:FlxGroup)
	{
		super();
		FlxG.state.add(this);

		this.nations = nations;

		grid = new Grid().origin(x, y).fromFinite(size, size, nations.length + 1, nations.length + 1).centerAlign();
		anchor = new Anchor(x, y);

		initDistances();
		compatibility = new Compatibility(nations, distances);
		relations = new Relations(nations, compatibility, distances);
		initIndicators(x, y, size, group);
	}

	public function show()
	{
		anchor.propagate(sprite -> sprite.visible = true);
	}

	public function hide()
	{
		anchor.propagate(sprite -> sprite.visible = false);
	}

	public function reset(resetDistances:Bool = false)
	{
		if (resetDistances)
		{
			for (nation in nations)
			{
				nation.resetLoc();
			}
			initDistances();
		}

		relations.distances = distances;
		compatibility.distances = distances;
		relations.reset();
		compatibility.refresh();
	}

	override public function update(elapsed:Float)
	{
		relations.update(elapsed);
		updateIndicators();
	}

	public static function valueColor(value:Float):FlxColor
	{
		return FlxColor.fromHSL((100 * value + 100) * 0.6, 0.82, 0.56);
	}

	private function initDistances()
	{
		distances = [];
		for (nation1 in nations)
		{
			distances[nation1] = new Map<Nation, Float>();
			for (nation2 in nations)
			{
				if (nation1 == nation2)
					continue;
				distances[nation1][nation2] = Useful.distance(nation1.loc, nation2.loc);
			}
		}
	}

	private function initIndicators(x:Float, y:Float, size:Float, group:FlxGroup)
	{
		var indicatorSize = Std.int(grid.dx);

		relations.indicators = [];
		compatibility.indicators = [];

		for (i in 0...nations.length)
		{
			var nation1 = nations[i];
			relations.indicators[nation1] = new Map<Nation, FlxSprite>();
			compatibility.indicators[nation1] = new Map<Nation, FlxSprite>();

			for (j in 0...nations.length)
			{
				if (i == j)
				{
					continue;
				}
				var nation2 = nations[j];

				var relationsIndicator = new FlxSprite();
				relationsIndicator.makeGraphic(indicatorSize, indicatorSize, FlxColor.WHITE, true);
				var pos = grid.getXY(i + 1, j + 1);
				var otherAnchor = new Anchor(pos.x, pos.y).attachParent(relationsIndicator);
				anchor.add(otherAnchor);
				group.add(relationsIndicator);

				var compatibilityIndicator = new FlxSprite();
				compatibilityIndicator.makeGraphic(indicatorSize, indicatorSize, FlxColor.WHITE, true);
				otherAnchor = new Anchor(pos.x, pos.y).attachParent(compatibilityIndicator);
				anchor.add(otherAnchor);
				group.add(compatibilityIndicator);

				compatibilityIndicator.scale.x *= 0.5;
				compatibilityIndicator.scale.y *= 0.5;

				relations.indicators[nation1][nation2] = relationsIndicator;
				compatibility.indicators[nation1][nation2] = compatibilityIndicator;

				pos.put();
			}
		}

		for (i in 0...nations.length)
		{
			var rowText = new FlxText();
			rowText.size = Math.round(indicatorSize * 0.5);
			rowText.text = Std.string(i + 1);
			var pos = grid.getXY(i + 1, 0);
			var otherAnchor = new Anchor(pos.x, pos.y).attachParent(rowText);
			anchor.add(otherAnchor);
			group.add(rowText);

			var colText = new FlxText();
			colText.size = Math.round(indicatorSize * 0.5);
			colText.text = Std.string(i + 1);
			pos = grid.getXY(0, i + 1);
			otherAnchor = new Anchor(pos.x, pos.y).attachParent(colText);
			anchor.add(otherAnchor);
			group.add(colText);

			pos.put();
		}

		updateIndicators();
	}

	// private function updateRelationMatrix(elapsed:Float)
	// {
	// 	for (i in 0...nations.length)
	// 	{
	// 		var nation1 = nations[i];
	// 		for (j in 0...nations.length)
	// 		{
	// 			if (i == j)
	// 			{
	// 				continue;
	// 			}
	// 			var nation2 = nations[j];
	// 			var relationDelta = frenemyBias(nation1, nation2) / 2;
	// 			var compatibilityDelta = compatibility(nation1, nation2);
	// 			relationMatrix[nation1][nation2] = FlxMath.bound(relationMatrix[nation1][nation2] + elapsed * (0.5 * relationDelta + 0.5 * compatibilityDelta),
	// 				-1, 1);
	// 		}
	// 	}
	// }

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
				var relationsIndicator = relations.indicators[nation1][nation2];
				var compatibilityIndicator = compatibility.indicators[nation1][nation2];
				relationsIndicator.color = valueColor(relations.between(nation1, nation2));
				compatibilityIndicator.color = valueColor(compatibility.between(nation1, nation2));
			}
		}
	}
}

class Relations
{
	public var indicators:Map<Nation, Map<Nation, FlxSprite>>;

	private var nations:Array<Nation>;
	private var matrix:Map<Nation, Map<Nation, Float>>;
	private var compatibility:Compatibility;

	public var distances(null, default):Map<Nation, Map<Nation, Float>>;

	public function new(nations:Array<Nation>, compatibility:Compatibility, distances:Map<Nation, Map<Nation, Float>>)
	{
		this.nations = nations;
		this.compatibility = compatibility;
		this.distances = distances;

		matrix = [];
		reset();
	}

	public function reset()
	{
		for (nation1 in nations)
		{
			matrix[nation1] = new Map<Nation, Float>();
			for (nation2 in nations)
			{
				if (nation1.num > nation2.num)
				{
					matrix[nation1][nation2] = FlxG.random.float(-1, 1);
				}
			}
		}
	}

	public function update(elapsed:Float)
	{
		for (nation1 in nations)
		{
			for (nation2 in nations)
			{
				if (nation1.num <= nation2.num)
					continue;
				var relationDelta = frenemyBias(nation1, nation2) / 2;
				var compatibilityDelta = compatibility.between(nation1, nation2);
				matrix[nation1][nation2] = FlxMath.bound(matrix[nation1][nation2] + elapsed * (0.5 * relationDelta + 0.5 * compatibilityDelta), -1, 1);
			}
		}
	}

	public function between(nation1:Nation, nation2:Nation):Float
	{
		return nation1.num > nation2.num ? matrix[nation1][nation2] : matrix[nation2][nation1];
	}

	private function likeness(a:Float, b:Float):Float
	{
		// Given that two nations have relations a and b with a third nation, how should that impact their own relation?
		// var c = Math.min(a, b); // (a + b) / 2;
		var importance = (Math.abs(a) + Math.abs(b)) / 2;
		var c = FlxMath.bound(importance * (1 - Math.abs(a - b) / 0.6), -1, 1);
		return c; // c > 0 ? Math.sqrt(c) : -Math.sqrt(-c);
	}

	private function frenemyBias(nation1:Nation, nation2:Nation):Float
	{
		var sum:Float = 0;
		var importanceSum:Float = 0;
		for (associate in nations)
		{
			if (associate != nation1 && associate != nation2)
			{
				var importance = 1; // / (distance(nation1, associate) + distance(nation2, associate));
				sum += importance * likeness(between(nation1, associate), between(nation2, associate));
				importanceSum += importance;
			}
		}
		return sum / importanceSum;
	}
}

class Compatibility
{
	public var indicators:Map<Nation, Map<Nation, FlxSprite>>;

	private var nations:Array<Nation>;
	private var matrix:Map<Nation, Map<Nation, Float>>;

	public var distances(null, default):Map<Nation, Map<Nation, Float>>;

	public function new(nations:Array<Nation>, distances:Map<Nation, Map<Nation, Float>>)
	{
		this.nations = nations;
		this.distances = distances;

		matrix = [];
		refresh();
	}

	public function refresh()
	{
		for (nation1 in nations)
		{
			matrix[nation1] = new Map<Nation, Float>();
			for (nation2 in nations)
			{
				if (nation1.num <= nation2.num)
					continue;
				matrix[nation1][nation2] = reluMax(distances[nation1][nation2], Reg.C_THRESHOLD_LOWER, Reg.C_THRESHOLD_UPPER, 1, -1);
			}
		}
	}

	public function between(nation1:Nation, nation2:Nation):Float
	{
		return nation1.num > nation2.num ? matrix[nation1][nation2] : matrix[nation2][nation1];
	}
}
