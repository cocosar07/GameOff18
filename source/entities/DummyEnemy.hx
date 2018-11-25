package entities;

import flixel.FlxObject;
import flixel.math.FlxVector;
import flixel.util.FlxSignal;

class DummyEnemy extends Enemy
{
	public function new(?X:Float=0, ?Y:Float=0, ?p:Player)
	{
		super(X, Y);
        
        loadGraphic(AssetPaths.enemies__png, true, 8, 8);

		animation.add("idle", [1], 3, false);
        animation.add("run", [0, 1], 6, true);
        animation.add("hit", [2], 3, false);
        animation.add("charging_attack", [3], 3, false);

        animation.play("run");

        pullable = true;

        drag.x = drag.y = 400;
        health = 3;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
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