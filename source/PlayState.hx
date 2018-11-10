package;

import flixel.FlxState;

class PlayState extends FlxState
{
	override public function create():Void
	{
		super.create();

		var player:Player = new Player(50, 50);
		add(player);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
