package;

import flixel.FlxSprite;

class Smoke extends FlxSprite
{
	public function new(?X:Float=0, ?Y:Float=0)
	{
		super(X, Y);

        loadGraphic(AssetPaths.smoke__png, true, 8, 8);

        animation.add("idle", [0, 1, 2, 3], 10, false);
        animation.finishCallback = finishCallback;
	}

    public function finishCallback(anim:String):Void
    {
        if (anim == "idle")
            kill();
    }

    override function setPosition(X:Float = 0, Y:Float = 0):Void
	{
		super.setPosition(X, Y);

		x -= width/2;
		y -= height/2;
	}
}