package entities;

import flixel.FlxObject;
import flixel.math.FlxVector;

class Enemy extends Entity
{
    public var player:Player = null;
    public var speed:Float = 30;
    public var knocked:Bool = false;

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

        drag.x = drag.y = 400;
        health = 3;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

        if (!knocked)
        {
            if (player != null && !pulled)
            {
                flixel.math.FlxVelocity.moveTowardsObject(this, player, speed);

                if (velocity.x < 0)
                    facing = FlxObject.LEFT;
                else
                    facing = FlxObject.RIGHT;
            }
        }
        else
        {
            var v:FlxVector = new FlxVector(velocity.x, velocity.y);
            if (v.length < 2)
            {
                knocked = false;
                animation.play("run");
            }
        }
	}

    override public function revive():Void
    {
        super.revive();

        velocity.set(0, 0);
        pulled = false;
        health = 3;

        animation.play("run");
    }
}