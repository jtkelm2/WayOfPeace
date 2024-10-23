package gameobjects;

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
import gameobjects.diplographic.RelationsDiagram;
import system.*;
import system.Reg;

enum Mode
{
	DRAG;
	SELECT;
}

class Inspector
{
	public var anchor:Anchor;
	public var visibility:Visibility;

	public var table:RelationsTable;
	public var info:NationInfo;
	public var pair:PairInfo;

	public function new(x:Float, y:Float, size:Float, nations:Array<Nation>, group:FlxGroup)
	{
		anchor = new Anchor(x + size / 2, y + size / 2);
		visibility = new Visibility();

		info = new NationInfo(x, y, size, group);
		pair = new PairInfo(x, y, size, group);
		table = new RelationsTable(x, y, size, nations, group);

		anchor.add(info.anchor);
		anchor.add(pair.anchor);
		anchor.add(table.anchor);

		visibility.add(info.visibility);
		visibility.add(pair.visibility);
		visibility.add(table.visibility);
	}
}

class Diplographic
{
	public var x:Float;
	public var y:Float;
	public var size:Float;
	public var nations:Array<Nation>;

	public var diagram:RelationsDiagram;
	public var inspector:Inspector;

	public var circle1:Null<NationCircle>;
	public var circle2:Null<NationCircle>;

	public var number1:FlxText;
	public var number2:FlxText;

	public function new(x:Float, y:Float, size:Float, nations:Array<Nation>, group:FlxGroup)
	{
		this.x = x;
		this.y = y;
		this.size = size;
		this.nations = nations;

		inspector = new Inspector(x, y, size, nations, group);
		diagram = new RelationsDiagram(0, 0, Reg.MAP_WIDTH, Reg.MAP_HEIGHT, inspector.table, group);

		number1 = new FlxText();
		number1.fieldWidth = 30;
		number1.alignment = CENTER;
		number1.size = 30;
		number1.text = "A";
		number1.color = FlxColor.RED;
		number1.alpha = 0.8;
		number2 = new FlxText();
		number2.fieldWidth = 30;
		number2.alignment = CENTER;
		number2.size = 30;
		number2.text = "B";
		number2.color = FlxColor.RED;
		number2.alpha = 0.8;

		group.add(number1);
		group.add(number2);

		setMode(SELECT);
	}

	public function party()
	{
		for (nation1 in nations)
		{
			for (nation2 in nations)
			{
				if (nation1.num > nation2.num)
				{
					inspector.table.relations.delta(nation1, nation2, 0.1);
				}
			}
		}
		inspector.table.refresh();
	}

	public function lowerRelations()
	{
		if (circle1 == null || circle1 == null)
			return;
		inspector.table.relations.delta(circle1.nation, circle2.nation, -0.1);
		inspector.table.refresh();
	}

	public function raiseRelations()
	{
		if (circle1 == null || circle1 == null)
			return;
		inspector.table.relations.delta(circle1.nation, circle2.nation, 0.1);
		inspector.table.refresh();
	}

	public function setMode(mode:Mode)
	{
		switch mode
		{
			case DRAG:
				diagram.makeDraggable();
				deselectAll();
			case SELECT:
				diagram.clearClickers();
				for (circle in diagram.circles)
				{
					circle.clicker.add(select);
				}
				refresh();
		}
	}

	public function select(circle:NationCircle)
	{
		if (circle1 == null)
		{
			circle1 = circle;
		}
		else
		{
			if (circle2 == null)
			{
				if (circle1 == circle)
				{
					circle1 = null;
				}
				else
				{
					circle2 = circle;
				}
			}
			else
			{
				if (circle2 == circle)
				{
					circle2 = null;
				}
				else
				{
					if (circle1 == circle)
					{
						circle1 = null;
						circle2 = null;
					}
					else
					{
						circle2 = circle;
					}
				}
			}
		}
		refresh();
	}

	public function deselectAll()
	{
		circle1 = circle2 = null;
		refresh();
	}

	private function refresh()
	{
		refreshText();
		inspector.info.visibility.hide();
		inspector.pair.visibility.hide();
		inspector.table.visibility.hide();

		if (circle2 == null)
		{
			if (circle1 == null)
			{
				inspector.table.visibility.show();
			}
			else
			{
				inspector.info.load(circle1);
				inspector.info.visibility.show();
			}
		}
		else
		{
			inspector.pair.load(circle1, circle2);
			inspector.pair.visibility.show();
		}
	}

	private function refreshText()
	{
		number1.visible = number2.visible = false;

		if (circle1 != null)
		{
			number1.visible = true;
			circle1.anchor.center(number1);
		}
		if (circle2 != null)
		{
			number2.visible = true;
			circle2.anchor.center(number2);
		}
	}
}
