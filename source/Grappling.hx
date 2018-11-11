package;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;

class Grappling extends FlxSprite
{
    public var speed:Float = 200;

	public function new(?X:Float=0, ?Y:Float=0)
	{
		super(X, Y);

		makeGraphic(4, 4, FlxColor.WHITE);

        x -= width/2;
        y -= height/2;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

    public function setDirection(direction:FlxPoint):Void
    {
        velocity = direction.scale(speed);
    }
}