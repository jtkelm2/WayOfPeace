package ui;

import Useful;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import gadgets.*;
import gadgets.Anchor;
import system.*;
import system.Data;
import ui.Panel;
import ui.SliceWindow.WINDOW_TYPE;

using Useful;

var ASSETPATH:Map<WINDOW_TYPE, String> = [WIRE => "assets/box_multi.png", SHADED => "assets/shade_box_multi.png"];
var TABASSETPATH:Map<WINDOW_TYPE, String> = [WIRE => "assets/box_tab.png", SHADED => "assets/shade_box_tab.png"];

class Tab
{
	public var anchor:Anchor;
	public var num:Int;
	public var visibility:Visibility;

	private var multipanel:Multi;
	private var clicker:Clicker<FlxSprite>;
	private var sprite:FlxSprite;

	public function new(multipanel:Multi, num:Int, ?text:String)
	{
		this.multipanel = multipanel;
		this.num = num;
		initSprite(text);
		visibility = new Visibility(sprite);
		clicker = new Clicker(sprite).add(mouseDown, mouseUp, mouseOver, mouseOut);
	}

	public function toggleClicked(bool:Bool = true)
	{
		sprite.animation.frameIndex = bool ? 3 : 0;
	}

	private function initSprite(?text:String)
	{
		sprite = new FlxSprite();
		var temp = new FlxSprite(0, 0, multipanel.tabGraphic);
		sprite.loadGraphic(multipanel.tabGraphic, true, Std.int(temp.width / 4));
		temp.destroy();

		if (!Useful.floatEq(multipanel.tabWidth, sprite.width) || !Useful.floatEq(multipanel.tabHeight, sprite.height))
		{
			multipanel.setTabwidthHeight(sprite.width, sprite.height);
		}

		anchor = new Anchor().attachParent(sprite);

		if (text != null)
		{
			var textSprite = new FlxText(0, 0, sprite.frameWidth, text + " ");
			textSprite.size = Std.int(sprite.frameHeight * 0.4);
			textSprite.alignment = RIGHT;
			textSprite.alpha = 0.8;
			var textAnchor = new Anchor().attachParent(textSprite);
			anchor.add(textAnchor);
		}
	}

	private function mouseDown(sprite:FlxSprite)
	{
		switch sprite.animation.frameIndex
		{
			case 3:
				sprite.animation.frameIndex = 2;
			case _:
				sprite.animation.frameIndex = 2;
				multipanel.tabTo(this);
		}
	}

	private function mouseUp(sprite:FlxSprite)
	{
		switch sprite.animation.frameIndex
		{
			case 3:
			case 2:
				sprite.animation.frameIndex = 3;
			case _:
				sprite.animation.frameIndex = 1;
		}
	}

	private function mouseOver(sprite:FlxSprite)
	{
		switch sprite.animation.frameIndex
		{
			case 3:
			case _:
				sprite.animation.frameIndex = 1;
		}
	}

	private function mouseOut(sprite:FlxSprite)
	{
		switch sprite.animation.frameIndex
		{
			case 3:
			case 2:
				sprite.animation.frameIndex = 3;
			case _:
				sprite.animation.frameIndex = 0;
		}
	}
}

class Multi
{
	public var panel:Panel;
	public var panels:Array<Panel>;
	public var tabs:Array<Tab>;

	public var margins:Margins;

	private var height:Float;
	private var width:Float;

	private var defaultWindowType:WINDOW_TYPE;
	private var visiblePanel:Panel;

	public var tabWidth:Float;
	public var tabHeight:Float;
	public var tabGraphic:FlxGraphicAsset;

	public function new()
	{
		panels = [];
		tabs = [];
		tabWidth = 10;
		tabHeight = 10;
		width = 200;
		height = 400;
		margins = new Margins();

		panel = new Panel();
		panel.resize(0, 0, 200, 400);
		panel.splitHorizontal2(10 / 400, 0);
	}

	public function resize(x:Float, y:Float, width:Float, height:Float)
	{
		panel.resize(x, y, width, height);
		if (visiblePanel != null)
		{
			throw "Resizing multi with preexisting panels not yet implemented"; // visiblePanel.resize(panel.x(), panel.y() + tabHeight, panel.width(), panel.height() - tabHeight);
		}
		return this;
	}

	public function newPanel():Panel
	{
		var panel = new Panel();

		panel.margins.set(margins.top, margins.right, margins.bottom, margins.left);
		if (defaultWindowType != null)
		{
			panel.window.loadGraphic(ASSETPATH[defaultWindowType], 32);
		}

		addPanel(panel);
		return panel;
	}

	public function addPanel(panel:Panel)
	{
		if (visiblePanel != null)
		{
			visiblePanel.visibility.hide();
		}
		visiblePanel = panel;
		visiblePanel.visibility.show();

		panel.resize(this.panel.x(), this.panel.y() + tabHeight, this.panel.width(), this.panel.height() - tabHeight);
		panels.push(panel);
		this.panel.bottom.visibility.add(panel.visibility);

		addTab(panels.length - 1);

		this.panel.window.anchor.add(panel.window.anchor);
		return this;
	}

	public function tabTo(tab:Tab)
	{
		for (t in tabs)
		{
			if (t != tab)
				t.toggleClicked(false);
		}
		visiblePanel.visibility.hide();
		visiblePanel = panels[tab.num];
		visiblePanel.visibility.show();
	}

	public function setType(type:WINDOW_TYPE)
	{
		tabGraphic = TABASSETPATH[type];
		defaultWindowType = type;
	}

	//---------------------------------------------------------------

	private function addTab(num:Int)
	{
		for (t in tabs)
		{
			t.toggleClicked(false);
		}
		var tab = new Tab(this, num, "Tab " + Std.string(num));
		tab.toggleClicked(true);
		tabs.push(tab);
		panel.top.visibility.add(tab.visibility);
		tab.anchor.x = panel.x() + panel.width() - (tab.num + 0.5) * tabWidth;
		tab.anchor.y = panel.y() + tabHeight / 2;
		panel.window.anchor.add(tab.anchor);
	}

	public function setTabwidthHeight(tabWidth:Float, tabHeight:Float)
	{
		this.tabWidth = Math.max(this.tabWidth, tabWidth);
		this.tabHeight = Math.max(this.tabHeight, tabHeight);

		for (tab in tabs)
		{
			tab.anchor.x = panel.x() + panel.width() - (tab.num + 0.5) * this.tabWidth;
			tab.anchor.y = panel.y() + tabHeight / 2;
		}

		for (panel in panels)
		{
			panel.resize(this.panel.x(), this.panel.y() + this.tabHeight, this.panel.width(), this.panel.height() - this.tabHeight);
		}
	}
}
