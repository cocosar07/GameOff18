package;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.util.FlxSignal;

class Grappling extends FlxSprite
{
	public var destroyGrappling:FlxSignal;
	public var speed:Float = 200;
	public var maxRange:Float = 150;

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

		if (flixel.math.FlxMath.distanceBetween(this, player) >= maxRange)
		{
			destroyGrappling.dispatch();
		}
	}

	public function setDirection(direction:FlxPoint):Void
	{
		velocity = direction.scale(speed);
	}
}