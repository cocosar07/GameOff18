package entities;

import flixel.FlxObject;

class Enemy extends Entity
{
    public var player:Player = null;
    public var speed:Float = 30;

	public function new(?X:Float=0, ?Y:Float=0, ?p:Player)
	{
		super(X, Y);
        
        player = p;
        loadGraphic(AssetPaths.enemies__png, true, 8, 8);

        setFacingFlip(FlxObject.RIGHT, false, false);
        setFacingFlip(FlxObject.LEFT, true, false);

        animation.add("run", [0, 1], 6, true);
        animation.add("hit", [2], 3, false);

        animation.play("run");

        pullable = true;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

        if (player != null && !pulled)
        {
            flixel.math.FlxVelocity.moveTowardsObject(this, player, speed);

            if (velocity.x < 0)
                facing = FlxObject.LEFT;
            else
                facing = FlxObject.RIGHT;
        }
	}

    override public function revive():Void
    {
        super.revive();

        velocity.set(0, 0);
        pulled = false;

        animation.play("run");
    }
}