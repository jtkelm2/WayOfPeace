package ui;

import Useful;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import gadgets.*;
import gadgets.Anchor;
import system.*;
import system.Data;
import ui.SliceWindow.WINDOW_TYPE;

using Useful;

class Panel
{
	// public var anchor:Anchor;
	// public var rect:FlxRect;
	// public var conspaceRect:FlxRect;
	public var alignment(default, set):ALIGNMENT;
	public var window:SliceWindow;
	public var margins:Margins;
	public var visibility:Visibility;

	public var left:Panel;
	public var right:Panel;
	public var top:Panel;
	public var bottom:Panel;
	public var H:Array<Panel>;
	public var V:Array<Panel>;

	public var subpanels:Array<Panel>;

	private var buffer:Buffer;

	public function new()
	{
		window = new SliceWindow();
		alignment = CENTER;

		buffer = new Buffer(this);
		margins = new Margins();
		visibility = new Visibility();
		visibility.add(window.visibility);

		subpanels = [];
	}

	// x(), y(), width(), and height() all refer to the conspaceRect() values, not the window values!
	public function x():Float
	{
		return window.x() + margins.left;
	}

	public function y():Float
	{
		return window.y() + margins.top;
	}

	public function width():Float
	{
		return window.width - margins.left - margins.right;
	}

	public function height():Float
	{
		return window.height - margins.top - margins.bottom;
	}

	// FlxRect corresponding to the content space, i.e. window.rect() minus (this panel's) margins
	public function conspaceRect():FlxRect
	{
		var rect = new FlxRect();
		rect.x = x();
		rect.y = y();
		rect.width = width();
		rect.height = height();
		return rect;
	}

	public function addTo(group:FlxGroup)
	{
		window.anchor.propagate(sprite -> group.add(sprite));
		return this;
	}

	public function resize(x:Float, y:Float, width:Float, height:Float)
	{
		// Affine class for transformations?
		if (height <= margins.top + margins.bottom || width <= margins.left + margins.right)
		{
			visibility.hide();
			trace("Resizing made panel invisible");
			trace(x, y, width, height);
			trace(this);
			return this;
		}
		var scaleX = width / window.width;
		var scaleY = height / window.height;
		var offsetX = (x - window.x()) + 0.5 * (width - window.width);
		var offsetY = (y - window.y()) + 0.5 * (height - window.height);

		transform(scaleX, scaleY, offsetX, offsetY);
		return this;
	}

	public function transform(scaleX:Float = 1, scaleY:Float = 1, offsetX:Float = 0, offsetY:Float = 0)
	{
		window.transform(scaleX, scaleY, offsetX, offsetY);

		var childrenScaleX = (window.width - margins.left - margins.right) / width();
		var childrenScaleY = (window.height - margins.top - margins.bottom) / height();
		for (panel in subpanels)
		{
			panel.transform(childrenScaleX, childrenScaleY);
		}

		return this;
	}

	// public function show()
	// {
	// 	window.anchor.propagate(sprite -> sprite.visible = true);
	// 	return this;
	// }
	// public function hide()
	// {
	// 	window.anchor.propagate(sprite -> sprite.visible = false);
	// 	return this;
	// }

	public function pad(padding:Float)
	{
		margins.set(padding, padding, padding, padding);
		return this;
	}

	public function splitVertical(columns:Int = 2, separationWidth:Float = null)
	{
		var gap:Float = separationWidth == null ? margins.left : separationWidth;
		var subwidth:Float = (width() - gap * (columns - 1)) / columns;

		H = [];

		for (column in 0...columns)
		{
			var subpanel = new Panel().resize(x() + (subwidth + gap) * column, y(), subwidth, height());
			window.anchor.add(subpanel.window.anchor);
			subpanels.push(subpanel);
			visibility.add(subpanel.visibility);
			H.push(subpanel);
		}

		if (columns == 2)
		{
			left = H[0];
			right = H[1];
		}
	}

	public function splitHorizontal(rows:Int = 2, separationHeight:Float = null)
	{
		var gap:Float = separationHeight == null ? margins.top : separationHeight;
		var subheight:Float = (height() - gap * (rows - 1)) / rows;

		V = [];

		for (row in 0...rows)
		{
			var subpanel = new Panel().resize(x(), y() + (subheight + gap) * row, width(), subheight);
			window.anchor.add(subpanel.window.anchor);
			subpanels.push(subpanel);
			visibility.add(subpanel.visibility);
			V.push(subpanel);
		}

		if (rows == 2)
		{
			top = V[0];
			bottom = V[1];
		}
	}

	public function splitHorizontal2(topBias:Float = 0.5, separationHeight:Float = null)
	{
		var gap:Float = separationHeight == null ? margins.top : separationHeight;
		var totalHeight:Float = height() - gap;
		var topHeight = topBias * totalHeight;
		var bottomHeight = (1 - topBias) * totalHeight;

		V = [];

		top = new Panel().resize(x(), y(), width(), topHeight);
		window.anchor.add(top.window.anchor);
		subpanels.push(top);
		visibility.add(top.visibility);
		V.push(top);

		bottom = new Panel().resize(x(), y() + topHeight + gap, width(), bottomHeight);
		window.anchor.add(bottom.window.anchor);
		subpanels.push(bottom);
		visibility.add(bottom.visibility);
		V.push(bottom);
	}

	public function splitVertical2(leftBias:Float = 0.5, separationWidth:Float = null)
	{
		var gap:Float = separationWidth == null ? margins.left : separationWidth;
		var totalWidth:Float = width() - gap;
		var leftWidth = leftBias * totalWidth;
		var rightWidth = (1 - leftBias) * totalWidth;

		H = [];

		left = new Panel().resize(x(), y(), leftWidth, height());
		window.anchor.add(left.window.anchor);
		subpanels.push(left);
		visibility.add(left.visibility);
		H.push(left);

		right = new Panel().resize(x() + leftWidth + gap, y(), rightWidth, height());
		window.anchor.add(right.window.anchor);
		subpanels.push(right);
		visibility.add(right.visibility);
		H.push(right);
	}

	public function setType(type:WINDOW_TYPE)
	{
		window.setType(type);
		margins.setAll(window.margin);
	}

	public function add(anchor:Anchor, ?width:Float, ?height:Float)
	{
		var contentWidth:Float;
		var contentHeight:Float;

		if (width != null)
		{
			contentWidth = width;
		}
		else
		{
			if (anchor.parent != null)
			{
				contentWidth = anchor.parent.width;
			}
			else
			{
				contentWidth = 0;
			}
		}

		if (height != null)
		{
			contentHeight = height;
		}
		else
		{
			if (anchor.parent != null)
			{
				contentHeight = anchor.parent.height;
			}
			else
			{
				contentHeight = 0;
			}
		}

		buffer.add(anchor, contentWidth, contentHeight);
		return this;
	}

	private function set_alignment(alignment:ALIGNMENT)
	{
		if (this.alignment != null)
		{
			buffer.alignment = alignment;
		}

		this.alignment = alignment;
		return alignment;
	}
}

enum STACKMODE
{
	DOWN;
	UP;
	RIGHT;
	LEFT;
	VERTICAL;
	HORIZONTAL;
}

class Buffer
{
	public var alignment(default, set):ALIGNMENT;
	public var panel:Panel;
	public var length:Float;

	public var stackmode(default, set):STACKMODE;

	private var anchorHV:Anchor; // Only used for offsets in the case stackmode is HORIZONTAL or VERTICAL

	public function new(panel:Panel)
	{
		this.panel = panel;
		length = 0;
		anchorHV = new Anchor();
		alignment = panel.alignment;
	}

	public function add(anchor:Anchor, width:Float, height:Float)
	{
		anchor.setAlignment(alignment);

		panel.window.anchor.add(anchor);

		var pos = Anchor.getAlignmentPoint(alignment, panel.conspaceRect());
		anchor.x = pos.x;
		anchor.y = pos.y;
		pos.put();

		switch stackmode
		{
			case DOWN:
				anchor.y += length;
				length += height;
			case UP:
				anchor.y -= length;
				length += height;
			case LEFT:
				anchor.x -= length;
				length += width;
			case RIGHT:
				anchor.x += length;
				length += width;
			case VERTICAL:
				anchor.y += length / 2 + height / 2;
				length += height;
				anchorHV.add(anchor);
				anchorHV.y -= height / 2;
			case HORIZONTAL:
				anchor.x += length / 2 + width / 2;
				length += width;
				anchorHV.add(anchor);
				anchorHV.x -= width / 2;
		}
	}

	private static var defaultStackmode:Map<ALIGNMENT, STACKMODE> = [
		TOPLEFT => DOWN,
		TOP => DOWN,
		TOPRIGHT => DOWN,
		CENTERLEFT => RIGHT,
		CENTER => VERTICAL,
		CENTERRIGHT => LEFT,
		BOTTOMLEFT => UP,
		BOTTOM => UP,
		BOTTOMRIGHT => UP
	];

	private function set_alignment(alignment:ALIGNMENT)
	{
		this.alignment = alignment;
		length = 0;
		stackmode = defaultStackmode[alignment];
		return alignment;
	}

	private function set_stackmode(stackmode:STACKMODE)
	{
		anchorHV.removeAll();
		this.stackmode = stackmode;
		return stackmode;
	}
}

class Margins
{
	public var top:Float;
	public var right:Float;
	public var bottom:Float;
	public var left:Float;
	public var inherited:Bool;

	public function new()
	{
		top = right = bottom = left = 0;
		inherited = false;
	}

	public function set(top:Float, right:Float, bottom:Float, left:Float)
	{
		this.top = top;
		this.right = right;
		this.bottom = bottom;
		this.left = left;
	}

	public function setAll(margin:Float)
	{
		set(margin, margin, margin, margin);
	}
}
