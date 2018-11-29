package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.math.FlxRandom;
import flixel.group.FlxGroup;
import flixel.system.FlxSound;
import flixel.util.FlxTimer;
import flixel.tile.FlxTilemap;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import entities.Entity;
import entities.Enemy;
import entities.FollowingEnemy;
import entities.WalkingEnemy;
import entities.GhostEnemy;

class PlayState extends FlxState
{
	public var map:TileMap;
	public var player:Player;
	public var grappling:Grappling;
	public var sword:Sword;

	public var rocks:FlxGroup;
	public var enemies:FlxGroup;
	public var ghosts:FlxGroup;
	public var chains:FlxGroup;
	public var enemySwords:FlxGroup;
	public var smoke:FlxGroup;
	public var shadows:FlxGroup;
	public var hearts:FlxGroup;

	public var soundPlayerAttack:FlxSound;
	public var soundEnemyAttack:FlxSound;
	public var soundPlayerHit:FlxSound;
	public var soundEnemyHit:FlxSound;
	public var soundGrapplingHit:FlxSound;
	public var soundEnemyDrown:FlxSound;
	public var soundEnemyDisappear:FlxSound;
	public var soundGhostGrabbed:FlxSound;

	public var timerText:TimerText;

	public var enemySpawnTimer:FlxTimer;
	public var enemySpawnPoints:Array<FlxPoint>;
	public var enemyKilledCount:Int = 0;

	public var rand:FlxRandom;

	override public function create():Void
	{
		super.create();
		FlxG.camera.bgColor.setRGBFloat(108.9/255, 194.0/255, 202.0/255);

		rocks = new FlxGroup();
		enemies = new FlxGroup();
		ghosts = new FlxGroup();
		chains = new FlxGroup();
		enemySwords = new FlxGroup();
		smoke = new FlxGroup();
		shadows = new FlxGroup();
		hearts = new FlxGroup();

		sword = new Sword(AssetPaths.sword__png);
		sword.kill();

		map = new TileMap(AssetPaths.map1__tmx, this.rocks);
		setupEnemySpawnPoints();

		player = new Player(125, 150);
		player.launchGrapplingSignal.add(launchGrappling);
		player.attackSignal.add(attack);
		player.deathSignal.add(playerDeath);

		var playerShadow:Shadow = new Shadow();
		playerShadow.target = player;
		playerShadow.animation.play("idle");

		grappling = null;

		spawnEnemy(150, 150);

		FlxG.camera.follow(player, LOCKON, 0.3);

		add(map.backgroundLayer);
		add(map.collisionLayer);
		add(shadows);
		add(playerShadow);
		add(chains);
		add(player);
		add(enemies);
		add(rocks);
		add(enemySwords);
		add(sword);
		add(ghosts);
		add(smoke);

		soundEnemyAttack = FlxG.sound.load(AssetPaths.attack__wav);
		soundPlayerAttack = FlxG.sound.load(AssetPaths.attack1__wav);
		soundEnemyHit = FlxG.sound.load(AssetPaths.enemy_hit__wav);
		soundPlayerHit = FlxG.sound.load(AssetPaths.player_hit__wav);
		soundGrapplingHit = FlxG.sound.load(AssetPaths.grappling_hit__wav);
		soundEnemyDrown = FlxG.sound.load(AssetPaths.enemy_drown__wav);
		soundEnemyDisappear = FlxG.sound.load(AssetPaths.enemy_disappear__wav);
		soundGhostGrabbed = FlxG.sound.load(AssetPaths.ghost_grabbed__wav);

		// UI
		timerText = new TimerText(0, 0, 0);
		add(timerText);

		for (i in 1...Std.int(player.health)+1)
		{
			var h:HeartUI = cast hearts.insert(0, new HeartUI());
			var side:Int = (i%2) == 0 ? -1 : 1;
			var p:Int = (i%2) == 0 ? i : i-1;
			h.setPosition(80 + side * p * 5, 110);
		}
		add(hearts);

		enemySpawnTimer = new FlxTimer();
		enemySpawnTimer.start(5, spawnEnemies, 0);

		rand = new FlxRandom();
	}

	function setupEnemySpawnPoints():Void
	{
		enemySpawnPoints = new Array<FlxPoint>();
		var tilemap:FlxTilemap = cast map.backgroundLayer.getFirstAlive();

		for (i in 1...tilemap.totalTiles)
		{
			var a = tilemap.getTileCoords(i, true);
			if (a != null)
				enemySpawnPoints = enemySpawnPoints.concat(a);
		}
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
			FlxG.overlap(ghosts, grappling, grapplingCollision);
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

		if (entity == null || !grappling.launched || entity.falling)
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

		if (Std.is(entity, GhostEnemy))
		{
			var e = createEnemy(entity.getMidpoint().x, entity.getMidpoint().y);
			e.shadow = entity.shadow;
			entity.shadow.target = e;
			if (!map.hasBackground(Std.int(e.getMidpoint().x / 8), Std.int(e.getMidpoint().y / 8)))
			{
				itemFall(e);
			}

			soundGhostGrabbed.play();
		}
	}

	public function endPullItem(item:Entity):Void
	{
		if (Std.is(item, GhostEnemy))
		{
			item.kill();
			return;
		}

		if (!map.hasBackground(Std.int(item.getMidpoint().x / 8), Std.int(item.getMidpoint().y / 8)))
		{
			itemFall(item);
		}
	}

	public function itemFall(item:Entity):Void
	{
		if (item.shadow != null)
			item.shadow.kill();
		item.velocity.set(0, 0);
		item.shadow = null;
		item.falling = true;
		FlxTween.tween(item.scale, { x: 0, y: 0 }, 0.5, { ease: FlxEase.quadIn });
		FlxTween.tween(item, { angle: rand.float(-90, 90) }, 0.5, { ease: FlxEase.quadOut, onComplete: endItemFall.bind(_, item) });
		FlxTween.tween(item, { alpha: 0 }, 0.5, { ease: FlxEase.quadOut });

		soundEnemyDrown.play();
	}

	public function endItemFall(_:FlxTween, item:Entity):Void
	{
		item.kill();
		enemyKilledCount += 1;
		item.setPosition(0, 0);
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
				FlxG.camera.shake(0.01, 0.08);
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
			FlxG.camera.shake(0.03, 0.1);
			if (player.health <= 0)
				FlxG.camera.flash(flixel.util.FlxColor.RED, 0.2);
			
			hearts.getFirstAlive().kill();
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

	function spawnEnemy(?X:Float, ?Y:Float):Void
	{
		var s:Shadow = cast shadows.recycle(Shadow);
		s.setPosition(X, Y);
		s.animation.play("fall");
		s.endFallSignal.add(endFallShadow);
	}

	function endFallShadow(s:Shadow):Void
	{
		s.target = createEnemy(s.x + 4, s.y, 90);
		s.target.shadow = s;
	}

	function createEnemy(X:Float, Y:Float, ?normalEnemyChance:Float = 100):Enemy
	{
		var e:FollowingEnemy;

		if (rand.bool(normalEnemyChance))
			e = cast enemies.recycle(WalkingEnemy);
		else
			e = cast ghosts.recycle(GhostEnemy);
			
		e.setPosition(X, Y);
		e.player = player;
		e.deathSignal.add(killEnemy);
		e.attackSignal.add(enemyAttack);

		return e;
	}

	function killEnemy(enemy:Enemy):Void
	{
		var s:Smoke = cast smoke.recycle(Smoke);
		s.setPosition(enemy.getMidpoint().x, enemy.getMidpoint().y);
		s.animation.play("idle");

		soundEnemyDisappear.play();

		enemy.kill();
		enemy.setPosition(0, 0);
		if (grappling != null && enemy == grappling.grabbedItem)
			destroyGrappling();
		
		enemyKilledCount += 1;
	}

	function spawnEnemies(_:FlxTimer):Void
	{
		for (i in 0...3)
		{
			var p:FlxPoint = rand.getObject(enemySpawnPoints);
			spawnEnemy(p.x, p.y);
		}
	}

	function playerDeath():Void
	{
		enemySpawnTimer.cancel();
		enemies.active = false;
		ghosts.active = false;

		var endText:FlxText = new FlxText(0, 0, 0, "Your survived for:");
		endText.scrollFactor.set(0, 0);
		endText.screenCenter();
		endText.y -= 40;
		endText.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);

		add(endText);

		timerText.timer.cancel();
		timerText.screenCenter();
		timerText.y -= 20;

		var killsText:FlxText = new FlxText(0, 0, 0, "(" + enemyKilledCount + "  kills)");
		killsText.scrollFactor.set(0, 0);
		killsText.scale.set(0.8, 0.8);
		killsText.screenCenter();
		killsText.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);

		add(killsText);

		var restartButton:FlxButton = new FlxButton(0, 0, "Restart", FlxG.resetState);
		restartButton.scale.set(0.4, 0.4);
		restartButton.updateHitbox();
		restartButton.screenCenter();
		restartButton.y += 30;

		restartButton.label.scale.set(0.4, 0.4);
		restartButton.label.updateHitbox();
		restartButton.label.centerOffsets();
		restartButton.label.offset.y += 2;

		add(restartButton);
	}
}
