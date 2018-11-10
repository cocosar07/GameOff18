package;

import flixel.FlxState;
import flixel.FlxG;

class PlayState extends FlxState
{
	var map:TileMap;
	var player:Player;

	override public function create():Void
	{
		super.create();

		map = new TileMap(AssetPaths.map1__tmx, this);
		add(map.backgroundLayer);
		add(map.environmentLayer);

		player = new Player(50, 50);
		add(player);

		FlxG.camera.follow(player, TOPDOWN, 1);
		//FlxG.camera.setScale(2, 2);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		map.collideWithLevel(player);
	}
}
