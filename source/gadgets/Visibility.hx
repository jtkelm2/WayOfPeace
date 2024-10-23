package gadgets;

import flixel.FlxSprite;

class Visibility
{
	public var hidden:Bool;
	public var ancestorHidden:Bool;

	private var parent:FlxSprite;

	public var children:Array<Visibility>;

	public function new(?parent:FlxSprite)
	{
		hidden = ancestorHidden = false;
		this.parent = parent;
		children = [];
	}

	public function show()
	{
		hidden = false;
		if (ancestorHidden)
			return;

		if (parent != null)
			parent.visible = true;
		for (child in children)
			child.propagate(true);
	}

	public function hide()
	{
		hidden = true;
		if (parent != null)
			parent.visible = false;

		for (child in children)
			child.propagate(false);
	}

	public function add(child:Visibility)
	{
		child.ancestorHidden = hidden || ancestorHidden;
		children.push(child);
	}

	public function addSprite(childSprite:FlxSprite)
	{
		var visibility = new Visibility(childSprite);
		add(visibility);
	}

	//-------------------------
	private function propagate(bool:Bool)
	{
		ancestorHidden = !bool;
		if (bool)
		{
			if (!hidden)
			{
				show();
			}
		}
		else
		{
			if (parent != null)
				parent.visible = false;
			for (child in children)
				child.propagate(false);
		}
	}
}
