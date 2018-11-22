package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.group.FlxGroup;
import flixel.system.FlxSound;
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
	public var enemySwords:FlxGroup;

	public var soundPlayerAttack:FlxSound;
	public var soundEnemyAttack:FlxSound;
	public var soundPlayerHit:FlxSound;
	public var soundEnemyHit:FlxSound;
	public var soundGrapplingHit:FlxSound;
	public var soundEnemyDrown:FlxSound;

	override public function create():Void
	{
		super.create();
		FlxG.camera.bgColor.setRGBFloat(108.9/255, 194.0/255, 202.0/255);

		rocks = new FlxGroup();
		enemies = new FlxGroup();
		chains = new FlxGroup();
		enemySwords = new FlxGroup();

		sword = new Sword(AssetPaths.sword__png);
		sword.kill();

		map = new TileMap(AssetPaths.map1__tmx, this);

		player = new Player(125, 150);
		player.launchGrapplingSignal.add(launchGrappling);
		player.attackSignal.add(attack);
		player.deathSignal.add(playerDeath);

		grappling = null;

		createEnemy(150, 150);

		FlxG.camera.follow(player, LOCKON, 0.3);

		add(map.backgroundLayer);
		add(map.collisionLayer);
		add(chains);
		add(player);
		add(enemies);
		add(rocks);
		add(enemySwords);
		add(sword);

		soundEnemyAttack = FlxG.sound.load(AssetPaths.attack__wav);
		soundPlayerAttack = FlxG.sound.load(AssetPaths.attack1__wav);
		soundEnemyHit = FlxG.sound.load(AssetPaths.enemy_hit__wav);
		soundPlayerHit = FlxG.sound.load(AssetPaths.player_hit__wav);
		soundGrapplingHit = FlxG.sound.load(AssetPaths.grappling_hit__wav);
		soundEnemyDrown = FlxG.sound.load(AssetPaths.enemy_drown__wav);
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

		soundGrapplingHit.play();
	}

	public function endPullItem(item:Entity):Void
	{
		if (map.collideWithLevel(item, null, FlxObject.updateTouchingFlags))
		{
			item.kill();
			soundEnemyDrown.play();

			createEnemy(150, 150);
		}
	}

	public function attack():Void
	{
		sword.revive();
		
		setupSword(sword, player, FlxG.mouse.getWorldPosition());

		for (e in enemies)
		{
			var enemy:Enemy = cast e;
			if (FlxG.pixelPerfectOverlap(sword, enemy))
			{
				enemy.hit();
				var diff:FlxPoint = enemy.getMidpoint().subtractPoint(player.getMidpoint());
				var v:FlxVector = new FlxVector(diff.x, diff.y).normalize().scale(100);
				enemy.velocity.set(v.x, v.y);

				enemy.hurt(1);
				soundEnemyHit.play();
			}
		}

		soundPlayerAttack.play();
	}

	public function enemyAttack(e:Enemy):Void
	{
		var s:Sword = cast enemySwords.recycle(Sword);
		setupSword(s, e, player.getMidpoint());

		if (FlxG.pixelPerfectOverlap(s, player))
		{
			player.hit();
			var diff:FlxPoint = player.getMidpoint().subtractPoint(e.getMidpoint());
			var v:FlxVector = new FlxVector(diff.x, diff.y).normalize().scale(250);
			player.velocity.set(v.x, v.y);

			player.hurt(1);
			soundPlayerHit.play();
		}

		soundEnemyAttack.play();
	}

	public function setupSword(s:Sword, origin:FlxSprite, target:FlxPoint):Void
	{
		s.animation.play("attack");

		var dir:FlxPoint = new FlxPoint(target.x, target.y).subtractPoint(origin.getMidpoint());
		var v:FlxVector = new FlxVector(dir.x, dir.y).normalize();

		s.setPosition(origin.getMidpoint().x + v.x * 6, origin.getMidpoint().y + v.y * 6);
		s.angle = flixel.math.FlxAngle.angleBetweenPoint(origin, target, true);

		s.flipY = v.x > 0;
	}

	function createEnemy(?X:Float, ?Y:Float):Void
	{
		var e:Enemy = cast enemies.recycle(Enemy);
		e.setPosition(Std.int(X/8)*8, Std.int(Y/8)*8);
		e.player = player;
		e.deathSignal.add(killEnemy);
		e.attackSignal.add(enemyAttack);
	}

	function killEnemy(enemy:Enemy):Void
	{
		enemy.kill();
		if (grappling != null && enemy == grappling.grabbedItem)
			destroyGrappling();

		createEnemy(150, 150);
	}

	function playerDeath():Void
	{
		FlxG.resetState();
	}
}
