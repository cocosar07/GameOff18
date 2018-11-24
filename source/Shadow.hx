package;

import flixel.FlxSprite;
import flixel.util.FlxSignal;

class Shadow extends FlxSprite
{
    public var target:FlxSprite;
    public var endFallSignal:FlxTypedSignal<Shadow->Void>;

	public function new(?X:Float=0, ?Y:Float=0)
	{
		super(X, Y);

        loadGraphic(AssetPaths.shadow__png, true, 8, 8);

        animation.add("fall", [0, 1, 2],  6, false);
        animation.add("idle", [2],  6, false);
        animation.finishCallback = finishCallback;

        endFallSignal = new FlxTypedSignal<Shadow->Void>();
	}

    public function finishCallback(anim:String):Void
    {
        if (anim == "fall")
        {
            endFallSignal.dispatch(this);
        }
    }

	override public function update(elapsed:Float):Void
	{
        super.update(elapsed);

        if (animation.finished)
        {
            if (target.exists == false)
            {
                kill();
                return;
            }

            setPosition(target.getMidpoint().x, target.getMidpoint().y + 4);
        }
    }

    override function setPosition(X:Float = 0, Y:Float = 0):Void
	{
		super.setPosition(X, Y);

		x -= width/2;
		y -= height/2;
	}
}