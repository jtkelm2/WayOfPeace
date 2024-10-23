package gameobjects.diplographic;

import Math;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import gadgets.*;
import gameobjects.*;
import gameobjects.diplographic.*;
import system.*;
import system.Reg;

class RelationsDiagram extends FlxBasic
{
	private var table:RelationsTable;

	// public var x:Float;
	// public var y:Float;
	public var width:Float;
	public var height:Float;

	public var circles:Array<NationCircle>;
	public var liasons:Array<NationLiason>;
	public var anchor:Anchor;

	public function new(x:Float, y:Float, width:Float, height:Float, table:RelationsTable, group:FlxGroup)
	{
		super();
		FlxG.state.add(this);

		this.width = width;
		this.height = height;
		this.table = table;
		this.anchor = new Anchor(x + width / 2, y + height / 2);

		initCircles();
		initLiasons();
		for (liason in liasons)
		{
			group.add(liason);
		}
		for (circle in circles)
		{
			group.add(circle);
		}

		randomize();
	}

	public function x()
	{
		return anchor.x - width / 2;
	}

	public function y()
	{
		return anchor.y - height / 2;
	}

	public function makeDraggable()
	{
		for (circle in circles)
		{
			circle.clicker.makeDraggable();
		}
	}

	public function clearClickers()
	{
		for (circle in circles)
		{
			circle.clicker.clear();
		}
	}

	private function initCircles()
	{
		circles = [];
		for (nation in table.nations)
		{
			var color = FlxColor.fromHSL(FlxG.random.float(0, 360), FlxG.random.float(0, 1), FlxG.random.float(0.3, 0.7));
			var circle = new NationCircle(anchor.x, anchor.y, 15, color, nation);
			anchor.add(circle.anchor);
			circles.push(circle);
		}
	}

	private function initLiasons()
	{
		liasons = [];
		for (circle1 in circles)
		{
			for (circle2 in circles)
			{
				if (circle1.nation.num > circle2.nation.num)
				{
					var liason = new NationLiason(circle1, circle2, 4);
					liasons.push(liason);
				}
			}
		}
	}

	override function update(elapsed:Float)
	{
		for (liason in liasons)
		{
			liason.visible = areFriendly(liason.start, liason.end);
		}
	}

	public function moveNationCircleTo(circle:NationCircle, x:Float, y:Float)
	{
		circle.anchor.x = x;
		circle.anchor.y = y;
	}

	public function areFriendly(circle1:NationCircle, circle2:NationCircle):Bool
	{
		return table.relations.between(circle1.nation, circle2.nation) > 0.8;
	}

	public function layout(k:Float = 100)
	{
		GraphLayout.layout(this, k);
	}

	public function refocus()
	{
		lineUp();
		constrain();
		optimalRotate();
		constrain();
	}

	private function lineUp()
	{
		var cliques:Array<Array<NationCircle>> = getCliques();
		var length = 0.0;

		for (i in 0...cliques.length)
		{
			var clique = cliques[i];
			var size = clique.length * 100;
			constrainClique(cliques[i], length, 0, size, size);
			length += size;
		}

		// System.effects.floatText(Std.string(cliques[0][0].anchor.x));
	}

	public function getCliques()
	{
		var cliques:Array<Array<NationCircle>> = [];

		for (circle in circles)
		{
			var alreadyCollected = false;
			for (clique in cliques)
			{
				if (clique.contains(circle))
				{
					alreadyCollected = true;
					break;
				}
			}
			if (alreadyCollected)
				continue;
			cliques.push(getClique(circle));
		}

		return cliques;
	}

	public function getClique(circle:NationCircle)
	{
		var clique:Array<NationCircle> = [circle];
		var newlyAdded:Bool;

		do
		{
			newlyAdded = false;
			for (otherCircle in circles)
			{
				if (otherCircle == circle)
					continue;
				if (areFriendly(circle, otherCircle) && !clique.contains(otherCircle))
				{
					clique.push(otherCircle);
					newlyAdded = true;
				}
			}
		}
		while (newlyAdded);
		return clique;
	}

	private function constrainClique(circles:Array<NationCircle>, x:Float, y:Float, width:Float, height:Float)
	{
		var minX = circles[0].anchor.x;
		var minY = circles[0].anchor.y;
		var maxX = circles[0].anchor.x;
		var maxY = circles[0].anchor.y;
		for (circle in circles)
		{
			minX = Math.min(minX, circle.anchor.x);
			minY = Math.min(minY, circle.anchor.y);
			maxX = Math.max(maxX, circle.anchor.x);
			maxY = Math.max(maxY, circle.anchor.y);
		}

		var scaleX = Useful.floatEq(minX, maxX) ? -1 : 0.8 * width / (maxX - minX);
		var scaleY = Useful.floatEq(minY, maxY) ? -1 : 0.8 * height / (maxY - minY);
		for (circle in circles)
		{
			circle.anchor.x = scaleX < 0 ? x + 0.5 * width : scaleX * (circle.anchor.x - minX) + x + 0.1 * width;
			circle.anchor.y = scaleY < 0 ? y + 0.5 * height : scaleY * (circle.anchor.y - minY) + y + 0.1 * height;
		}
	}

	public function constrain()
	{
		constrainClique(circles, x(), y(), width, height);
	}

	public function optimalRotate()
	{
		var points:Array<{y:Float, x:Float}> = [];
		for (circle in circles)
		{
			points.push({x: circle.anchor.x, y: circle.anchor.y});
		}
		var pc = PCAHelper.computePrincipalComponent(points);
		// var sumX:Float = 0;
		// var sumY:Float = 0;
		// for (circle in circles)
		// {
		// 	sumX += circle.anchor.x - anchor.x;
		// 	sumY += circle.anchor.y - anchor.y;
		// }

		var ang = Math.atan2(pc.y, pc.x) * 180 / Math.PI;
		// System.effects.floatText(Std.string(sumX) + ", " + Std.string(sumY));
		anchor.angle -= ang;
		for (circle in circles)
		{
			circle.anchor.angle += ang;
		}
	}

	public function randomize()
	{
		for (circle in circles)
		{
			var randomX = FlxG.random.float(x(), x() + width);
			var randomY = FlxG.random.float(y(), y() + height);
			moveNationCircleTo(circle, randomX, randomY);
		}
		refocus();
	}
}

class NationCircle extends FlxSprite
{
	public var nation:Nation;

	private var radius:Float;
	private var circleColor:FlxColor;

	public var clicker:Clicker<NationCircle>;
	public var anchor:Anchor;

	public function new(x:Float, y:Float, radius:Float, circleColor:FlxColor, nation:Nation)
	{
		super();

		this.radius = radius;
		this.circleColor = circleColor;
		this.nation = nation;

		makeGraphic(Std.int(2 * radius), Std.int(2 * radius), circleColor, true);

		var text = new FlxText();
		text.size = Std.int(1.5 * radius);
		text.fieldWidth = 4 * radius;
		text.alignment = CENTER;
		text.text = Std.string(nation.num + 1);
		stamp(text, -Std.int(radius), 0);

		anchor = new Anchor(x, y).attachParent(this, true, false, false);
		clicker = new Clicker(this, anchor);
	}
}

class NationLiason extends FlxSprite
{
	public var start:NationCircle;
	public var end:NationCircle;

	public function new(start:NationCircle, end:NationCircle, radius:Float)
	{
		super();
		this.start = start;
		this.end = end;

		makeGraphic(FlxG.width, FlxG.height, 0, true);

		visible = false;
	}

	override function update(elapsed:Float)
	{
		FlxSpriteUtil.fill(this, 0);
		if (visible)
		{
			FlxSpriteUtil.drawLine(this, start.anchor.x, start.anchor.y, end.anchor.x, end.anchor.y, {
				thickness: 3,
				color: 0xFF00FF00
			});
		}
	}
}

class GraphLayout
{
	public static function layout(diagram:RelationsDiagram, k:Float = 100):Void
	{
		var circles = diagram.circles;
		var forces = new Map<NationCircle, {fx:Float, fy:Float}>();

		var maxIterations = Std.int(k);
		var coolingFactor = 0.99;

		var edges:Array<{node1:NationCircle, node2:NationCircle}> = [];
		for (node1 in circles)
		{
			for (node2 in circles)
			{
				if (node1 != node2 && diagram.areFriendly(node1, node2))
				{
					edges.push({node1: node1, node2: node2});
				}
			}
		}

		// Iteratively update node positions based on forces
		for (i in 0...5)
		{
			var K = k;
			for (j in 0...maxIterations)
			{
				// Initialize forces to zero for each node
				for (node in circles)
				{
					forces.set(node, {fx: 0, fy: 0});
				}

				// Compute repulsive forces between all pairs of circles

				for (node1 in circles)
				{
					for (node2 in circles)
					{
						if (node1 != node2)
						{
							applyRepulsiveForce(node1, node2, diagram, forces, K);
						}
					}
				}

				// Compute attractive forces between adjacent circles
				for (edge in edges)
				{
					applyAttractiveForce(edge.node1, edge.node2, diagram, forces, K);
				}

				// Move circles according to net forces and apply cooling
				for (node in circles)
				{
					var force = forces.get(node);
					var newX = node.anchor.x + force.fx;
					var newY = node.anchor.y + force.fy;
					diagram.moveNationCircleTo(node, newX, newY);
				}

				K *= coolingFactor;
			}

			diagram.refocus();
		}
	}

	// Function to compute repulsive force between two circles
	static function applyRepulsiveForce(node1:NationCircle, node2:NationCircle, diagram:RelationsDiagram, forces:Map<NationCircle, {fx:Float, fy:Float}>,
			k:Float):Void
	{
		var dx = node1.anchor.x - node2.anchor.x;
		var dy = node1.anchor.y - node2.anchor.y;
		var distSq = dx * dx + dy * dy;
		var dist = Math.sqrt(distSq);

		if (dist > 0)
		{
			var forceMagnitude = k / dist; // Repulsive force is proportional to k^2 / distance
			var fx = forceMagnitude * (dx / dist);
			var fy = forceMagnitude * (dy / dist);

			forces.get(node1).fx += fx;
			forces.get(node1).fy += fy;
			forces.get(node2).fx -= fx;
			forces.get(node2).fy -= fy;
		}
	}

	// Function to compute attractive force between two adjacent circles
	static function applyAttractiveForce(node1:NationCircle, node2:NationCircle, diagram:RelationsDiagram, forces:Map<NationCircle, {fx:Float, fy:Float}>,
			k:Float):Void
	{
		var dx = node1.anchor.x - node2.anchor.x;
		var dy = node1.anchor.y - node2.anchor.y;
		var distSq = dx * dx + dy * dy;
		var dist = Math.sqrt(distSq);

		var forceMagnitude = dist / k; // Attractive force is proportional to distance^2 / k
		var fx = forceMagnitude * (dx / dist);
		var fy = forceMagnitude * (dy / dist);

		forces.get(node1).fx -= fx;
		forces.get(node1).fy -= fy;
		forces.get(node2).fx += fx;
		forces.get(node2).fy += fy;
	}

	// Utility function to ensure circles stay within bounds
	static function clampPosition(value:Float, min:Float, max:Float):Float
	{
		return Math.min(Math.max(value, min), max);
	}
}

class PCAHelper
{
	public static function computePrincipalComponent(points:Array<{x:Float, y:Float}>):{x:Float, y:Float}
	{
		// Step 1: Compute the mean of the points
		var meanX = 0.0;
		var meanY = 0.0;

		for (p in points)
		{
			meanX += p.x;
			meanY += p.y;
		}

		meanX /= points.length;
		meanY /= points.length;

		// Step 2: Center the points by subtracting the mean
		var centeredPoints = points.map(function(p) return {x: p.x - meanX, y: p.y - meanY});

		// Step 3: Compute the covariance matrix
		var covXX = 0.0;
		var covXY = 0.0;
		var covYY = 0.0;
		for (p in centeredPoints)
		{
			covXX += p.x * p.x;
			covXY += p.x * p.y;
			covYY += p.y * p.y;
		}
		covXX /= points.length;
		covXY /= points.length;
		covYY /= points.length;

		// Covariance matrix:
		// | covXX   covXY |
		// | covXY   covYY |

		// Step 4: Compute the eigenvalues and eigenvectors of the covariance matrix
		var delta = Math.sqrt(4 * covXY * covXY + (covXX - covYY) * (covXX - covYY));

		var eigenValue1 = (covXX + covYY + delta) / 2;
		// var eigenValue2 = (covXX + covYY - delta) / 2;

		// Step 5: Compute the eigenvectors
		// For the first principal component (largest eigenvalue):
		// var pc1 = computeEigenvector(covXX, covXY, covYY, eigenValue1);
		// For the second principal component (smallest eigenvalue):
		// var pc2 = computeEigenvector(covXX, covXY, covYY, eigenValue2);

		// return {pc1: pc1, pc2: pc2};

		var x = covXX - covYY + delta;
		var y = 2 * covXY;

		var d = Math.sqrt(x * x + y * y);

		return {x: (covXX - covYY + delta) / d, y: (2 * covXY) / d};
	}

	public static function example()
	{
		var points = [
			{x: 2.5, y: 2.4}, {x: 0.5, y: 0.7}, {x: 2.2, y: 2.9}, {x: 1.9, y: 2.2}, {x: 3.1, y: 3.0}, {x: 2.3, y: 2.7}, {x: 2.0, y: 1.6}, {x: 1.0, y: 1.1},
			{x: 1.5, y: 1.6}, {x: 1.1, y: 0.9}];

		var result = PCAHelper.computePrincipalComponent(points);
		var str:String = 'x: ' + Std.string(result.x) + ' y: ' + Std.string(result.y);
		System.effects.floatText(str);
	}
}
