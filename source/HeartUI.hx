package;

import flixel.FlxSprite;
import flixel.util.FlxTimer;

class HeartUI extends FlxSprite
{
    public var falling:Bool = false;
	public var timer:FlxTimer;

	public function new(X:Float = 0, Y:Float = 0)
	{
		super(X, Y);

        loadGraphic(AssetPaths.heart__png, false, 7, 7);
        scrollFactor.set(0, 0);
        scale.set(0.8, 0.8);

        timer = new FlxTimer();
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

    public function startFalling():Void
    {
        falling = true;
        acceleration.y = 300;
        timer.start(1, timerCallback);
    }

    function timerCallback(_:FlxTimer):Void
    {
        kill();
    }
}