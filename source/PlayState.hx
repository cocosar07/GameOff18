package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;

class PlayState extends FlxState
{
	var map:TileMap;
	var player:Player;
	var grappling:Grappling;

	override public function create():Void
	{
		super.create();
		FlxG.camera.bgColor.setRGBFloat(108.9/255, 194.0/255, 202.0/255);

		map = new TileMap(AssetPaths.map1__tmx, this);
		add(map.backgroundLayer);
		add(map.waterLayer);
		add(map.rocksLayer);

		player = new Player(125, 150);
		add(player);
		player.launchGrapplingSignal.add(launchGrappling);

		grappling = null;

		FlxG.camera.follow(player, LOCKON, 0.3);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (!player.pulled)
		{
			map.collideWith(player, "water");
			map.collideWith(player, "rocks");
		}

		if (grappling != null && grappling.launched)
		{
			if (map.collideWith(grappling, "rocks"))
			{
				grappling.startPullingPlayer();
			}
		}
	}

	public function launchGrappling(direction:FlxPoint):Void
	{
		if (grappling != null)
			return;

		grappling = new Grappling(player.getMidpoint().x, player.getMidpoint().y, player);
		grappling.setDirection(direction);
		grappling.destroyGrappling.add(destroyGrappling);
		add(grappling);
	}

	public function destroyGrappling():Void
	{
		remove(grappling);
		grappling.kill();
		grappling = null;
	}
}
