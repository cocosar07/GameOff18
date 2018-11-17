package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.group.FlxGroup;
import entities.Entity;
import entities.Enemy;

class PlayState extends FlxState
{
	public var map:TileMap;
	public var player:Player;
	public var grappling:Grappling;
	public var sword:Sword;

	public var rocks:FlxGroup;
	public var enemies:FlxGroup;
	public var chains:FlxGroup;

	override public function create():Void
	{
		super.create();
		FlxG.camera.bgColor.setRGBFloat(108.9/255, 194.0/255, 202.0/255);

		rocks = new FlxGroup();
		enemies = new FlxGroup();
		chains = new FlxGroup();

		sword = new Sword();

		map = new TileMap(AssetPaths.map1__tmx, this);

		player = new Player(125, 150);
		player.launchGrapplingSignal.add(launchGrappling);
		player.attackSignal.add(attack);

		grappling = null;

		var e:Enemy = cast enemies.recycle(Enemy);
		e.setPosition(Std.int(150/8)*8, Std.int(150/8)*8);
		e.player = player;

		FlxG.camera.follow(player, LOCKON, 0.3);

		add(map.backgroundLayer);
		add(map.collisionLayer);
		add(chains);
		add(player);
		add(enemies);
		add(rocks);
		add(sword);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (!player.pulled)
		{
			map.collideWithLevel(player);
			FlxG.overlap(rocks, player, null, FlxObject.separate);
			FlxG.overlap(enemies, player, null, FlxObject.separate);
		}

		for (e in enemies)
		{
			var enemy:Entity = cast e;
			if (!enemy.pulled)
			{
				map.collideWithLevel(enemy);
				FlxG.overlap(rocks, enemy, null, FlxObject.separate);
			}
		}

		if (grappling != null && grappling.launched)
		{
			FlxG.overlap(rocks, grappling, grapplingCollision);
			FlxG.overlap(enemies, grappling, grapplingCollision);
		}
	}

	public function launchGrappling():Void
	{
		if (grappling != null)
			return;

		grappling = new Grappling(0, 0, player);
		grappling.setPosition(player.getMidpoint().x, player.getMidpoint().y);
		flixel.math.FlxVelocity.moveTowardsMouse(grappling, grappling.speed);

		grappling.angle = flixel.math.FlxAngle.angleBetweenMouse(grappling, true);

		if (grappling.velocity.x < 0)
			grappling.facing = FlxObject.LEFT;
		else
			grappling.facing = FlxObject.RIGHT;

		grappling.destroyGrappling.add(destroyGrappling);
		grappling.createChain.add(createChain);
		grappling.endPullItem.add(endPullItem);
		add(grappling);
	}

	public function destroyGrappling():Void
	{
		remove(grappling);
		grappling.kill();
		grappling = null;

		for (c in chains)
		{
			c.kill();
		}
	}

	public function createChain():Void
	{
		var c:GrapplingChain = cast chains.recycle(GrapplingChain);
		c.setPosition(player.getMidpoint().x - c.width/2, player.getMidpoint().y - c.height/2);
		c.distanceFromGrappling = grappling.getMidpoint().distanceTo(c.getMidpoint());
		c.player = player;
		c.grappling = grappling;
		c.revive();
	}

	public function grapplingCollision(other:FlxObject, _:FlxObject):Void
	{
		var entity:Entity = cast other;

		if (entity == null)
			return;
	
		grappling.setPosition(other.getMidpoint().x, other.getMidpoint().y);	
		grappling.grabbedItem = entity;

		grappling.launched = false;
		grappling.velocity.set(0, 0);
		
		if (!entity.pullable)
		{
			grappling.startPullingPlayer();
		}
		else
		{
			// Pull object
			entity.pulled = true;
			entity.animation.play("hit");
		}
	}

	public function endPullItem(item:Entity):Void
	{
		if (map.collideWithLevel(item, null, FlxObject.updateTouchingFlags))
		{
			item.kill();

			var e:Enemy = cast enemies.recycle(Enemy);
			e.setPosition(Std.int(150/8)*8, Std.int(150/8)*8);
			e.player = player;

		}
	}

	public function attack():Void
	{
		sword.revive();
		sword.animation.play("attack");

		var dir:FlxPoint = FlxG.mouse.getWorldPosition().subtractPoint(player.getMidpoint());
		var v:FlxVector = new FlxVector(dir.x, dir.y).normalize();

		sword.setPosition(player.getMidpoint().x + v.x * 6, player.getMidpoint().y + v.y * 6);

		sword.angle = flixel.math.FlxAngle.angleBetweenPoint(player, FlxG.mouse.getWorldPosition(), true);

		for (enemy in enemies)
		{
			var e:FlxSprite = cast enemy;

			if (FlxG.pixelPerfectOverlap(sword, e))
			{
				trace("collision");
				e.kill();
				if (grappling != null && e == grappling.grabbedItem)
					grappling.grabbedItem = null;

				var e:Enemy = cast enemies.recycle(Enemy);
				e.setPosition(Std.int(150/8)*8, Std.int(150/8)*8);
				e.player = player;
			}
		}
	}
}
