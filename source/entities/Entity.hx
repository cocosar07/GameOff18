package entities;

import flixel.FlxSprite;

class Entity extends FlxSprite
{
    public var pullable:Bool = false;
	public var pulled:Bool = false;
	public var shadow:Shadow = null;
	public var falling:Bool = false;

	public function new(?X:Float=0, ?Y:Float=0)
	{
		super(X, Y);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

	override function setPosition(X:Float = 0, Y:Float = 0):Void
	{
		super.setPosition(X, Y);

		x -= width/2;
		y -= height/2;
	}

	override function revive():Void
	{
		super.revive();
		falling = false;
		pulled = false;
	}
}