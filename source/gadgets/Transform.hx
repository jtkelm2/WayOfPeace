package gadgets;

class Transform
{
	public var anchor:Anchor;
	public var width:Float;
	public var height:Float;

	public var to:(Float, Float, Float, Float) -> Void;

	// public var by:Float->Float->Float->Float->Void;

	public function new()
	{
		anchor = new Anchor();
		width = 0;
		height = 0;
		to = (_, _, _, _) -> {};
	}

	public function by(scaleX:Float, scaleY:Float, offsetX:Float, offsetY:Float)
	{
		width *= scaleX;
		height *= scaleY;
		anchor.x += offsetX;
		anchor.y += offsetY;

		to(anchor.x - width / 2, anchor.y - height / 2, width, height);
	}
}
