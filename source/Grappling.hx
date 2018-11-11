package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.util.FlxSignal;

class Grappling extends FlxSprite
{
	public var destroyGrappling:FlxSignal;
	public var speed:Float = 200;
	public var maxRange:Float = 100;
	public var minRange:Float = 5;
	public var pullForce:Float = 200;

	public var launched:Bool = true;

	var player:Player;

	public function new(?X:Float=0, ?Y:Float=0, ?p:Player=null)
	{
		super(X, Y);
		player = p;
		destroyGrappling = new FlxSignal();

		makeGraphic(4, 4, FlxColor.WHITE);

		x -= width/2;
		y -= height/2;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (player == null)
			return;

		if (launched && flixel.math.FlxMath.distanceBetween(this, player) >= maxRange)
		{
			// The grappling touched nothing and is far from the player, remove it
			destroyGrappling.dispatch();
		}
		else if (player.pulled && flixel.math.FlxMath.distanceBetween(this, player) <= minRange)
		{
			// The grappling pulled the player close enough

			destroyGrappling.dispatch();
			player.setup();
			player.pulled = false;
			FlxG.camera.followLead.set(0, 0);
		}
	}

	public function setDirection(direction:FlxPoint):Void
	{
		velocity = direction.scale(speed);
	}

	public function startPullingPlayer():Void
	{
		velocity.set(0, 0);
		launched = false;

		player.pulled = true;
		player.drag.x = player.drag.y = 0;

		var diff:FlxPoint = getMidpoint();
		diff.subtractPoint(player.getMidpoint());

		var dir:FlxVector = new FlxVector(diff.x, diff.y).normalize();

		player.velocity.set(dir.x * pullForce, dir.y * pullForce);

		FlxG.camera.followLead.set(6, 0);
	}
}