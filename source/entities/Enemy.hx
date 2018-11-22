package entities;

import flixel.FlxObject;
import flixel.math.FlxVector;
import flixel.util.FlxSignal;

class Enemy extends Entity
{
    public var deathSignal:FlxTypedSignal<Enemy->Void>;
    public var attackSignal:FlxTypedSignal<Enemy->Void>;
    public var player:Player = null;
    public var speed:Float = 30;
    public var knocked:Bool = false;

    public var attackChargeTime:Float = 4/8;
    public var attackTime:Float = 2/8;

    var currentChargeTime:Float;
    var currentAttackTime:Float;
    var attacking:Bool = false;
    var chargingAttack:Bool = false;

	public function new(?X:Float=0, ?Y:Float=0, ?p:Player)
	{
		super(X, Y);

        deathSignal = new FlxTypedSignal<Enemy->Void>();
        attackSignal = new FlxTypedSignal<Enemy->Void>();
        
        player = p;
        loadGraphic(AssetPaths.enemies__png, true, 8, 8);

        setFacingFlip(FlxObject.RIGHT, false, false);
        setFacingFlip(FlxObject.LEFT, true, false);

		animation.add("idle", [1], 3, false);
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

        if (!knocked && !chargingAttack && !attacking)
        {
            if (player != null && !pulled)
            {
                flixel.math.FlxVelocity.moveTowardsObject(this, player, speed);

                if (velocity.x < 0)
                    facing = FlxObject.LEFT;
                else
                    facing = FlxObject.RIGHT;
                
                if (flixel.math.FlxMath.distanceBetween(this, player) < 10)
                {
                    chargingAttack = true;
                    currentChargeTime = 0;
                }
            }
        }
        else
        {
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
            else if (chargingAttack)
            {
                currentChargeTime += elapsed;
                if (currentChargeTime >= attackChargeTime)
                {
                    chargingAttack = false;
                    attacking = true;
                    currentAttackTime = 0;
                    attackSignal.dispatch(this);
                }
            }
            else if (attacking)
            {
                currentAttackTime += elapsed;
                if (currentAttackTime >= attackTime)
                {
                    attacking = false;
                }
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

    public function hit():Void
    {
        knocked = true;
        chargingAttack = false;
        attacking = false;
		animation.play("hit");
    }

    override public function hurt(damages:Float):Void
    {
        health -= damages;
    }
}