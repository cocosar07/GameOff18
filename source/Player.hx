package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxVector;
import flixel.math.FlxPoint;
import flixel.util.FlxSignal;

class Player extends FlxSprite
{
	public var launchGrapplingSignal:FlxSignal;
	public var attackSignal:FlxSignal;
	public var pulled:Bool = false;
	public var attackTime:Float = 2/8;

	var speed:Float = 100;

	var attacking:Bool = false;
	var currentAttackTime:Float;

	public function new(?X:Float=0, ?Y:Float=0)
	{
		super(X, Y);
		launchGrapplingSignal = new FlxSignal();
		attackSignal = new FlxSignal();

		loadGraphic(AssetPaths.player__png, true, 8, 8);

		setFacingFlip(FlxObject.RIGHT, false, false);
		setFacingFlip(FlxObject.LEFT, true, false);

		animation.add("idle", [1], 3, false);
		animation.add("run", [0, 1], 6, true);

		setup();
	}

	public function setup():Void
	{
		drag.x = drag.y = 1600;
		angle = 0;
	}

	override public function update(elapsed:Float):Void
	{
		if (!pulled)
		{
			if (!attacking)
			{
				move();

				if (FlxG.mouse.justPressed)
				{
					if (!attacking)
					{
						currentAttackTime = 0;
						attacking = true;
						attackSignal.dispatch();
					}
				}
				if (FlxG.mouse.justPressedRight)
				{
					launchGrapplingSignal.dispatch();
				}
			}
			else
			{
				currentAttackTime += elapsed;
				if (currentAttackTime >= attackTime)
				{
					attacking = false;
				}
			}
		}

		super.update(elapsed);
	}

	function move():Void
	{
		var direction:FlxVector = new FlxVector(0, 0);

		var up:Bool = FlxG.keys.anyPressed([UP, W, Z]);
		var down:Bool = FlxG.keys.anyPressed([DOWN, S]);
		var left:Bool = FlxG.keys.anyPressed([LEFT, A, Q]);
		var right:Bool = FlxG.keys.anyPressed([RIGHT, D]);

		if (up)
		{
			direction.y -= 1;
		}
		if (down)
		{
			direction.y += 1;
		}
		if (left)
		{
			direction.x -= 1;
		}
		if (right)
		{
			direction.x += 1;
		}

		if (up || down || left || right)
		{
			velocity = new flixel.math.FlxPoint(direction.normalize().x * speed, direction.normalize().y * speed);
			animation.play("run");

			if (velocity.x < 0)
				facing = FlxObject.LEFT;
			else
				facing = FlxObject.RIGHT;
		}
		else
		{
			animation.play("idle");
		}
	}
}