package;

import flixel.text.FlxText;
import flixel.util.FlxTimer;

class TimerText extends FlxText
{
	var timer:FlxTimer;
	var seconds:Int;
	var minutes:Int;

	public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0)
	{
		super(X, Y, FieldWidth, "0:00");
		scale.set(0.8, 0.8);
		centerOrigin();
		scrollFactor.set(0, 0);

		timer = new FlxTimer();
		timer.start(1, onTimerComplete, 0);

		seconds = minutes = 0;
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