package;

import flixel.FlxSprite;
import flixel.util.FlxSignal;

class Smoke extends FlxSprite
{
    public var endAnimationSignal:FlxSignal;

	public function new(?X:Float=0, ?Y:Float=0)
	{
		super(X, Y);

        loadGraphic(AssetPaths.smoke__png, true, 8, 8);

        animation.add("idle", [0, 1, 2, 3], 10, false);
        animation.finishCallback = finishCallback;

        endAnimationSignal = new FlxSignal();
	}

    public function finishCallback(anim:String):Void
    {
        if (anim == "idle")
        {
            kill();
            endAnimationSignal.dispatch();
        }
    }

    override function setPosition(X:Float = 0, Y:Float = 0):Void
	{
		super.setPosition(X, Y);

		x -= width/2;
		y -= height/2;
	}
}