package;

import flixel.FlxSprite;

class HeartUI extends FlxSprite
{
	public function new(X:Float = 0, Y:Float = 0)
	{
		super(X, Y);

        loadGraphic(AssetPaths.heart__png, false, 7, 7);
        scrollFactor.set(0, 0);
        scale.set(0.8, 0.8);
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