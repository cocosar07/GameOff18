package;

import flixel.FlxSprite;
import flixel.FlxObject;

class Sword extends FlxSprite
{
	public function new(?X:Float=0, ?Y:Float=0, ?filename:String=AssetPaths.enemy_sword__png)
	{
		super(X, Y);

        loadGraphic(filename, true, 8, 16);

        animation.add("attack", [0, 1], 8, false);
        animation.finishCallback = finishCallback;
	}

    public function finishCallback(anim:String):Void
    {
        if (anim == "attack")
            kill();
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
}