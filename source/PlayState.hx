package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import entities.Entity;

class PlayState extends FlxState
{
	public var map:TileMap;
	public var player:Player;
	public var grappling:Grappling;

	public var rocks:FlxGroup;

	override public function create():Void
	{
		super.create();
		FlxG.camera.bgColor.setRGBFloat(108.9/255, 194.0/255, 202.0/255);

		rocks = new FlxGroup();

		map = new TileMap(AssetPaths.map1__tmx, this);
		add(map.backgroundLayer);
		add(map.collisionLayer);

		player = new Player(125, 150);
		add(player);
		player.launchGrapplingSignal.add(launchGrappling);

		grappling = null;

		add(rocks);

		FlxG.camera.follow(player, LOCKON, 0.3);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (!player.pulled)
		{
			map.collideWithLevel(player);
			FlxG.overlap(rocks, player, null, FlxObject.separate);
		}

		if (grappling != null && grappling.launched)
		{
			FlxG.overlap(rocks, grappling, grapplingCollision);
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

	public function grapplingCollision(other:FlxObject, _:FlxObject):Void
	{
		grappling.setPosition(other.getMidpoint().x, other.getMidpoint().y);
		var entity:Entity = cast other;

		if (entity == null)
			return;
		
		if (!entity.pullable)
		{
			grappling.startPullingPlayer();
		}
		else
		{
			// Pull object
			destroyGrappling();
		}
	}
}
