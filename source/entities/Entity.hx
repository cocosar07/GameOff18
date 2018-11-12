package entities;

import flixel.FlxSprite;

class Entity extends FlxSprite
{
    public var pullable:Bool = false;

	public function new(?X:Float=0, ?Y:Float=0)
	{
		super(X, Y);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}