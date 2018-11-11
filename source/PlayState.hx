package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.math.FlxPoint;

class PlayState extends FlxState
{
	var map:TileMap;
	var player:Player;
	var grappling:Grappling;

	override public function create():Void
	{
		super.create();

		map = new TileMap(AssetPaths.map1__tmx, this);
		add(map.backgroundLayer);
		add(map.waterLayer);
		add(map.rocksLayer);

		player = new Player(50, 50);
		add(player);
		player.launchGrapplingSignal.add(launchGrappling);

		grappling = null;

		FlxG.camera.follow(player, TOPDOWN, 1);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		map.collideWith(player, "water");
		map.collideWith(player, "rocks");

		if (map.collideWith(grappling, "rocks"))
		{
			remove(grappling);
			grappling.kill();
			grappling = null;
		}
	}

	public function launchGrappling(direction:FlxPoint):Void
	{
		if (grappling != null)
			return;

		grappling = new Grappling(player.x + player.width/2, player.y + player.height/2, player);
		add(grappling);
		grappling.setDirection(direction);
		grappling.destroyGrappling.add(destroyGrappling);
	}

	public function destroyGrappling():Void
	{
		remove(grappling);
		grappling.kill();
		grappling = null;
	}
}
