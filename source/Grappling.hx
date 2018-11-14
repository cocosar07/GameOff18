package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.util.FlxSignal;
import entities.Entity;

class Grappling extends FlxSprite
{
	public var destroyGrappling:FlxSignal;
	public var endPullItem:FlxTypedSignal<Entity->Void>;
	public var speed:Float = 200;
	public var maxRange:Float = 60;
	public var minRange:Float = 10;
	public var pullForce:Float = 200;

	public var launched:Bool = true;
	public var grabbedItem:Entity;

	var player:Player;

	public function new(?X:Float=0, ?Y:Float=0, ?p:Player=null)
	{
		super(X, Y);
		player = p;
		destroyGrappling = new FlxSignal();
		endPullItem = new FlxTypedSignal<Entity->Void>();

		makeGraphic(4, 4, FlxColor.WHITE);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (player != null)
		{
			if (launched)
			{
				if (flixel.math.FlxMath.distanceBetween(this, player) >= maxRange)
				{
					// The grappling touched nothing and is far from the player, remove it
					destroyGrappling.dispatch();
				}
			}
			else
			{
				if (!player.pulled)
				{
					if (grabbedItem != null && flixel.math.FlxMath.distanceBetween(this, player) <= minRange)
					{
						grabbedItem.pulled = false;
						endPullItem.dispatch(grabbedItem);
						grabbedItem = null;

						destroyGrappling.dispatch();
					}
				}
				else
				{
					var dist1:Float = player.getMidpoint().distanceTo(getMidpoint());
					var dist2:Float = player.getMidpoint().add(player.velocity.x * elapsed, player.velocity.y * elapsed).distanceTo(getMidpoint());

					if (dist2 > dist1 && flixel.math.FlxMath.distanceBetween(this, player) >= minRange)
					{
						// The grappling pulled the player close enough
						player.setup();
						player.velocity.set(0, 0);
						player.pulled = false;
						FlxG.camera.followLead.set(0, 0);

						destroyGrappling.dispatch();
					}
				}
			}
		}
		if (grabbedItem != null)
		{
			setPosition(grabbedItem.getMidpoint().x, grabbedItem.getMidpoint().y);

			if (grabbedItem.pulled)
				flixel.math.FlxVelocity.moveTowardsObject(grabbedItem, player, pullForce);
		}
	}

	public function setDirection(direction:FlxPoint):Void
	{
		velocity = direction.scale(speed);
	}

	public function startPullingPlayer():Void
	{
		player.pulled = true;
		player.drag.x = player.drag.y = 0;
		player.angle = flixel.math.FlxAngle.asDegrees(flixel.math.FlxAngle.angleBetweenPoint(player, getMidpoint())) + 90;

		flixel.math.FlxVelocity.moveTowardsPoint(player, getMidpoint(), pullForce);

		FlxG.camera.followLead.set(6, 0);
	}

	override function setPosition(X:Float = 0, Y:Float = 0):Void
	{
		super.setPosition(X, Y);

		x -= width/2;
		y -= height/2;
	}
}