package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.math.FlxVector;
import flixel.math.FlxPoint;
import flixel.util.FlxSignal;

class Player extends FlxSprite
{
	public var launchGrapplingSignal:FlxTypedSignal<FlxPoint->Void>;

	var speed:Float = 100;

	public function new(?X:Float=0, ?Y:Float=0)
	{
		super(X, Y);
		launchGrapplingSignal = new FlxTypedSignal<FlxPoint->Void>();

		makeGraphic(8, 8, FlxColor.BLUE);

		drag.x = drag.y = 1600;
	}

	override public function update(elapsed:Float):Void
	{
		move();

		if (FlxG.mouse.justPressed)
		{
			trace("Attack");
		}
		if (FlxG.mouse.justPressedRight)
		{
			var diff:FlxPoint = FlxG.mouse.getWorldPosition();
			diff.subtractPoint(getPosition());

			var direction:FlxVector = new FlxVector(diff.x, diff.y);
			launchGrapplingSignal.dispatch(direction.normalize());
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
			velocity = new flixel.math.FlxPoint(direction.normalize().x * speed, direction.normalize().y * speed);
	}
}