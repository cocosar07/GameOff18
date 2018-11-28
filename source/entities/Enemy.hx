package entities;

import flixel.FlxObject;
import flixel.math.FlxVector;
import flixel.util.FlxSignal;

class Enemy extends Entity
{
    public var deathSignal:FlxTypedSignal<Enemy->Void>;
    public var knocked:Bool = false;

	public function new(?X:Float=0, ?Y:Float=0, ?p:Player)
	{
		super(X, Y);

        deathSignal = new FlxTypedSignal<Enemy->Void>();

        setFacingFlip(FlxObject.RIGHT, false, false);
        setFacingFlip(FlxObject.LEFT, true, false);

        pullable = true;

        drag.x = drag.y = 400;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

        if (knocked)
        {
            var v:FlxVector = new FlxVector(velocity.x, velocity.y);
            if (v.length < 2)
            {
                if (health > 0)
                {
                    knocked = false;
                    animation.play("run");
                }
                else
                {
                    deathSignal.dispatch(this);
                }
            }
        }
	}

    override public function revive():Void
    {
        super.revive();

        velocity.set(0, 0);
        pulled = false;
        scale.set(1, 1);
        angle = 0;
        alpha = 1;

        animation.play("run");
    }

    public function hit():Void
    {
        knocked = true;
		animation.play("hit");
    }

    override public function hurt(damages:Float):Void
    {
        health -= damages;
    }
}