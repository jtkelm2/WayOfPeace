// package ui;
// import Useful;
// import flixel.FlxBasic;
// import flixel.FlxSprite;
// import flixel.group.FlxGroup;
// import flixel.math.FlxMath;
// import flixel.math.FlxPoint;
// import flixel.math.FlxRect;
// import flixel.system.FlxAssets.FlxGraphicAsset;
// import flixel.text.FlxText;
// import flixel.ui.FlxButton;
// import gadgets.*;
// import gadgets.Anchor;
// import system.*;
// import system.Data;
// import ui.Panel;
// import ui.SliceWindow.WINDOW_TYPE;
// using Useful;
// // import Useful;
// // import flixel.FlxBasic;
// // import flixel.FlxSprite;
// // import flixel.group.FlxGroup;
// // import flixel.math.FlxMath;
// // import flixel.math.FlxPoint;
// // import flixel.math.FlxRect;
// // import flixel.system.FlxAssets.FlxGraphicAsset;
// // import flixel.text.FlxText;
// // import flixel.ui.FlxButton;
// // import gadgets.*;
// // import gadgets.Anchor;
// // import system.*;
// // import system.Data;
// // import ui.Panel;
// // import ui.SliceWindow.WINDOW_TYPE;
// // using Useful;
// var ASSETPATH:Map<WINDOW_TYPE, String> = [WIRE => "assets/box_multi.png", SHADED => "assets/shade_box_multi.png"];
// var TABASSETPATH:Map<WINDOW_TYPE, String> = [WIRE => "assets/box_tab.png", SHADED => "assets/shade_box_tab.png"];
// class Tab
// {
// 	public var anchor:Anchor;
// 	public var num:Int;
// 	private var multipanel:Multipanel;
// 	private var clicker:Clicker<FlxSprite>;
// 	private var sprite:FlxSprite;
// 	public function new(multipanel:Multipanel, num:Int, ?text:String)
// 	{
// 		this.multipanel = multipanel;
// 		this.num = num;
// 		initSprite(text);
// 		clicker = new Clicker(sprite);
// 		clicker.add(mouseDown, mouseUp, mouseOver, mouseOut);
// 	}
// 	public function toggleClicked(bool:Bool = true)
// 	{
// 		sprite.animation.frameIndex = bool ? 3 : 0;
// 	}
// 	private function initSprite(?text:String)
// 	{
// 		sprite = new FlxSprite();
// 		var temp = new FlxSprite(0, 0, multipanel.tabGraphic);
// 		sprite.loadGraphic(multipanel.tabGraphic, true, Std.int(temp.width / 4));
// 		temp.destroy();
// 		multipanel.tabWidth = Math.max(multipanel.tabWidth, sprite.width);
// 		multipanel.tabHeight = Math.max(multipanel.tabHeight, sprite.height);
// 		anchor = new Anchor().attachParent(sprite);
// 		if (text != null)
// 		{
// 			var textSprite = new FlxText(0, 0, sprite.frameWidth, text + " ");
// 			textSprite.size = Std.int(sprite.frameHeight * 0.4);
// 			textSprite.alignment = RIGHT;
// 			textSprite.alpha = 0.8;
// 			var textAnchor = new Anchor().attachParent(textSprite);
// 			anchor.add(textAnchor);
// 		}
// 	}
// 	private function mouseDown(sprite:FlxSprite)
// 	{
// 		switch sprite.animation.frameIndex
// 		{
// 			case 3:
// 				sprite.animation.frameIndex = 2;
// 			case _:
// 				sprite.animation.frameIndex = 2;
// 				multipanel.tabTo(this);
// 		}
// 	}
// 	private function mouseUp(sprite:FlxSprite)
// 	{
// 		switch sprite.animation.frameIndex
// 		{
// 			case 3:
// 			case 2:
// 				sprite.animation.frameIndex = 3;
// 			case _:
// 				sprite.animation.frameIndex = 1;
// 		}
// 	}
// 	private function mouseOver(sprite:FlxSprite)
// 	{
// 		switch sprite.animation.frameIndex
// 		{
// 			case 3:
// 			case _:
// 				sprite.animation.frameIndex = 1;
// 		}
// 	}
// 	private function mouseOut(sprite:FlxSprite)
// 	{
// 		switch sprite.animation.frameIndex
// 		{
// 			case 3:
// 			case 2:
// 				sprite.animation.frameIndex = 3;
// 			case _:
// 				sprite.animation.frameIndex = 0;
// 		}
// 	}
// }
// class Multipanel
// {
// 	public var panels:Array<Panel>;
// 	public var tabs:Array<Tab>;
// 	public var anchor:Anchor;
// 	public var margins:Margins;
// 	private var forcedWidth:Float;
// 	private var forcedHeight:Float;
// 	private var defaultWindowType:WINDOW_TYPE;
// 	private var visiblePanel:Panel;
// 	public var tabWidth:Float;
// 	public var tabHeight:Float;
// 	public var tabGraphic:FlxGraphicAsset;
// 	public function new()
// 	{
// 		panels = [];
// 		tabs = [];
// 		tabWidth = 0;
// 		tabHeight = 0;
// 		anchor = new Anchor();
// 		margins = new Margins();
// 	}
// 	public function resize(x:Float, y:Float, width:Float, height:Float)
// 	{
// 		anchor.x = x + width / 2;
// 		anchor.y = y + height / 2;
// 		forcedWidth = width;
// 		forcedHeight = height - tabHeight;
// 		resizeRefresh();
// 		return this;
// 	}
// 	public function x():Float
// 	{
// 		if (forcedWidth != null)
// 		{
// 			return anchor.x - forcedWidth / 2;
// 		}
// 		if (visiblePanel != null)
// 			return visiblePanel.window.x();
// 		return anchor.x;
// 	}
// 	public function y():Float
// 	{
// 		if (forcedHeight != null)
// 		{
// 			return anchor.y - forcedHeight / 2;
// 		}
// 		if (visiblePanel != null)
// 			return visiblePanel.window.y();
// 		return anchor.y;
// 	}
// 	public function width():Float
// 	{
// 		if (forcedWidth != null)
// 			return forcedWidth;
// 		if (visiblePanel != null)
// 			return visiblePanel.window.width;
// 		return 0;
// 	}
// 	public function height():Float
// 	{
// 		if (forcedHeight != null)
// 			return forcedHeight + tabHeight;
// 		if (visiblePanel != null)
// 			return visiblePanel.window.height + tabHeight;
// 		return 0;
// 	}
// 	public function addTo(group:FlxGroup)
// 	{
// 		anchor.propagate(sprite -> group.add(sprite));
// 		return this;
// 	}
// 	public function newPanel(?width:Float, ?height:Float):Panel
// 	{
// 		var panel = new Panel();
// 		var trueWidth = forcedWidth != null ? forcedWidth : width != null ? width : 100;
// 		var trueHeight = forcedHeight != null ? forcedHeight : height != null ? height : 200;
// 		panel.margins.set(margins.top, margins.right, margins.bottom, margins.left);
// 		panel.resize(x(), y() + tabHeight, trueWidth, trueHeight);
// 		if (defaultWindowType != null)
// 		{
// 			panel.window.loadGraphic(ASSETPATH[defaultWindowType], 32);
// 		}
// 		addPanel(panel);
// 		return panel;
// 	}
// 	public function addPanel(panel:Panel)
// 	{
// 		if (visiblePanel != null)
// 		{
// 			visiblePanel.hide();
// 		}
// 		visiblePanel = panel;
// 		visiblePanel.show();
// 		panel.window.anchor.x = anchor.x;
// 		panel.window.anchor.y = y() + tabHeight + panel.window.height / 2;
// 		addTab(panels.length);
// 		panels.push(panel);
// 		anchor.add(panel.window.anchor);
// 		return this;
// 	}
// 	public function tabTo(tab:Tab)
// 	{
// 		for (t in tabs)
// 		{
// 			if (t != tab)
// 				t.toggleClicked(false);
// 		}
// 		visiblePanel.hide();
// 		visiblePanel = panels[tab.num];
// 		visiblePanel.show();
// 	}
// 	public function setType(type:WINDOW_TYPE)
// 	{
// 		tabGraphic = TABASSETPATH[type];
// 		defaultWindowType = type;
// 	}
// 	//---------------------------------------------------------------
// 	private function addTab(num:Int)
// 	{
// 		for (t in tabs)
// 		{
// 			t.toggleClicked(false);
// 		}
// 		var tab = new Tab(this, num, "Tab " + Std.string(num));
// 		tab.toggleClicked(true);
// 		tabs.push(tab);
// 		anchor.add(tab.anchor);
// 		resizeRefresh();
// 	}
// 	private function resizeRefresh()
// 	{
// 		// This anchor is holding up the entire multipanel... it probably shouldn't be moving while pinned
// 		if (forcedWidth == null)
// 			anchor.x = x() + width() / 2;
// 		if (forcedHeight == null)
// 			anchor.y = y() + height() / 2;
// 		for (tab in tabs)
// 		{
// 			tab.anchor.x = x() + width() - (tab.num + 0.5) * tabWidth;
// 			tab.anchor.y = y() + tabHeight / 2;
// 		}
// 		if (visiblePanel != null)
// 		{
// 			visiblePanel.resize(x(), y() + tabHeight, forcedWidth == null ? visiblePanel.window.width : forcedWidth,
// 				forcedHeight == null ? visiblePanel.window.height : forcedHeight);
// 		}
// 	}
// }
