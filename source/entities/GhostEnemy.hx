package entities;

import flixel.FlxObject;
import flixel.math.FlxVector;
import flixel.util.FlxSignal;

class GhostEnemy extends FollowingEnemy
{
	public function new(?X:Float=0, ?Y:Float=0, ?p:Player)
	{
		super(X, Y);

        attackSignal = new FlxTypedSignal<Enemy->Void>();
        
        player = p;
        loadGraphic(AssetPaths.ghost_enemy__png, true, 8, 8);

		animation.add("idle", [0, 1, 2, 3], 6, true);
        animation.add("run", [0, 1, 2, 3], 6, true);
        animation.add("hit", [4], 3, false);
        animation.add("charging_attack", [0], 3, false);

        animation.play("run");

        pullable = true;

        drag.x = drag.y = 400;
        health = 3;
        speed = 25;
	}

    override public function revive():Void
    {
        super.revive();

        health = 3;
    }
}