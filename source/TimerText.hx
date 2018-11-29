package;

import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;

class TimerText extends FlxText
{
	public var timer:FlxTimer;
	var seconds:Int;

	public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0)
	{
		super(X, Y, FieldWidth, "0:00");
		scale.set(0.8, 0.8);
		centerOrigin();
		scrollFactor.set(0, 0);
		setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);
		screenCenter(flixel.util.FlxAxes.X);

		timer = new FlxTimer();
		timer.start(1, onTimerComplete, 0);

		seconds = 0;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

	function onTimerComplete(_:FlxTimer)
	{
		seconds += 1;

		text = flixel.util.FlxStringUtil.formatTime(seconds);
	}
}