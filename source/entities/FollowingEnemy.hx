package entities;

import flixel.FlxObject;
import flixel.math.FlxVector;
import flixel.util.FlxSignal;

class FollowingEnemy extends Enemy
{
    public var attackSignal:FlxTypedSignal<Enemy->Void>;
    public var player:Player = null;
    public var speed:Float = 30;

    public var attackChargeTime:Float = 4/8;
    public var attackTime:Float = 2/8;

    var currentChargeTime:Float;
    var currentAttackTime:Float;
    var attacking:Bool = false;
    var chargingAttack:Bool = false;

	public function new(?X:Float=0, ?Y:Float=0, ?p:Player)
	{
		super(X, Y);

        attackSignal = new FlxTypedSignal<Enemy->Void>();
        
        player = p;

        pullable = true;

        drag.x = drag.y = 400;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

        if (!knocked && !chargingAttack && !attacking && !falling)
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
                    animation.play("charging_attack");
                }
            }
        }
        else
        {
            if (chargingAttack)
            {
                currentChargeTime += elapsed;
                if (currentChargeTime >= attackChargeTime)
                {
                    chargingAttack = false;
                    if (pulled)
                    {
                        animation.play("run");
                    }
                    else
                    {
                        attacking = true;
                        currentAttackTime = 0;
                        attackSignal.dispatch(this);
                        animation.play("idle");
                    }
                }
            }
            else if (attacking)
            {
                currentAttackTime += elapsed;
                if (currentAttackTime >= attackTime)
                {
                    attacking = false;
                    animation.play("run");
                }
            }
        }
	}

    override public function revive():Void
    {
        super.revive();

        velocity.set(0, 0);
        pulled = false;

        animation.play("run");
        attacking = chargingAttack = false;
    }

    override public function hit():Void
    {
        super.hit();
        chargingAttack = false;
        attacking = false;
    }
}