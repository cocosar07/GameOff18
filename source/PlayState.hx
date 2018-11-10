package;

import flixel.FlxState;
import flixel.FlxG;

class PlayState extends FlxState
{
	override public function create():Void
	{
		super.create();

		var player:Player = new Player(50, 50);
		add(player);

		FlxG.camera.follow(player, TOPDOWN, 1);
		FlxG.camera.setScale(2, 2);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
