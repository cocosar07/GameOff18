package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.group.FlxGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import entities.Entity;
import entities.Enemy;
import entities.DummyEnemy;

class MenuState extends FlxState
{
	public var map:TileMap;
	public var player:Player;
	public var grappling:Grappling;
	public var sword:Sword;
	public var enemy:DummyEnemy;

	public var rocks:FlxGroup;
	public var chains:FlxGroup;
	public var enemySwords:FlxGroup;
	public var smoke:FlxGroup;
	public var shadows:FlxGroup;

	public var soundPlayerAttack:FlxSound;
	public var soundEnemyAttack:FlxSound;
	public var soundPlayerHit:FlxSound;
	public var soundEnemyHit:FlxSound;
	public var soundGrapplingHit:FlxSound;
	public var soundEnemyDrown:FlxSound;
	public var soundEnemyDisappear:FlxSound;

	public var movementText:FlxText;
	public var attackText:FlxText;
	public var grapplingText:FlxText;

	override public function create():Void
	{
		super.create();
		FlxG.camera.bgColor.setRGBFloat(108.9/255, 194.0/255, 202.0/255);

		rocks = new FlxGroup();
		chains = new FlxGroup();
		enemySwords = new FlxGroup();
		smoke = new FlxGroup();
		shadows = new FlxGroup();

		sword = new Sword(AssetPaths.sword__png);
		sword.kill();

		map = new TileMap(AssetPaths.menu_map__tmx, this.rocks);

		player = new Player(50, 70);
		player.launchGrapplingSignal.add(launchGrappling);
		player.attackSignal.add(attack);

		var playerShadow:Shadow = new Shadow();
		playerShadow.target = player;
		playerShadow.animation.play("idle");

		grappling = null;

		createEnemy(125, 90);

		enemy = new DummyEnemy();
		enemy.facing = FlxObject.LEFT;
		enemy.kill();

		FlxG.camera.follow(player, LOCKON, 0.3);

		movementText = new FlxText(0, 0, 150, "Arrow/WASD/ZQSD: Move");
		movementText.scrollFactor.set(0, 0);
		movementText.scale.set(0.6, 0.6);
		movementText.setPosition(0, 0);
		movementText.alignment = FlxTextAlign.LEFT;
		movementText.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);

		attackText = new FlxText(0, 10, 150, "Left click: ???");
		attackText.scrollFactor.set(0, 0);
		attackText.scale.set(0.6, 0.6);
		attackText.alignment = FlxTextAlign.LEFT;
		attackText.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);

		grapplingText = new FlxText(0, 20, 150, "Right click: ???");
		grapplingText.scrollFactor.set(0, 0);
		grapplingText.scale.set(0.6, 0.6);
		grapplingText.alignment = FlxTextAlign.LEFT;
		grapplingText.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);

		add(map.backgroundLayer);
		add(map.collisionLayer);
		add(shadows);
		add(playerShadow);
		add(chains);
		add(player);
		add(enemy);
		add(rocks);
		add(enemySwords);
		add(sword);
		add(smoke);
		add(movementText);
		add(attackText);
		add(grapplingText);

		soundEnemyAttack = FlxG.sound.load(AssetPaths.attack__wav);
		soundPlayerAttack = FlxG.sound.load(AssetPaths.attack1__wav);
		soundEnemyHit = FlxG.sound.load(AssetPaths.enemy_hit__wav);
		soundPlayerHit = FlxG.sound.load(AssetPaths.player_hit__wav);
		soundGrapplingHit = FlxG.sound.load(AssetPaths.grappling_hit__wav);
		soundEnemyDrown = FlxG.sound.load(AssetPaths.enemy_drown__wav);
		soundEnemyDisappear = FlxG.sound.load(AssetPaths.enemy_disappear__wav);

		FlxG.sound.volume = 0.1;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (!player.pulled)
		{
			map.collideWithLevel(player);
			FlxG.overlap(rocks, player, null, FlxObject.separate);
			FlxG.overlap(enemy, player, null, FlxObject.separate);
		}

		var e:Entity = cast enemy;

		if (e != null && !e.pulled)
		{
			map.collideWithLevel(e);
			FlxG.overlap(rocks, e, null, FlxObject.separate);
		}

		if (grappling != null && grappling.launched)
		{
			FlxG.overlap(rocks, grappling, grapplingCollision);
			FlxG.overlap(enemy, grappling, grapplingCollision);
		}
	}

	public function launchGrappling():Void
	{
		if (grappling != null)
			return;

		grapplingText.text = "Right click: Grappling";

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

		if (entity == null || !grappling.launched)
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
		if (!map.hasBackground(Std.int(item.getMidpoint().x / 8), Std.int(item.getMidpoint().y / 8)))
		{
			item.shadow.kill();
			item.shadow = null;
			item.velocity.set(0, 0);
			FlxTween.tween(item.scale, { x: 0, y: 0 }, 0.5, { ease: FlxEase.quadIn });
			FlxTween.tween(item, { angle: new flixel.math.FlxRandom().float(-90, 90) }, 0.5, { ease: FlxEase.quadOut, onComplete: endItemFall.bind(_, item) });
			FlxTween.tween(item, { alpha: 0 }, 0.5, { ease: FlxEase.quadOut });

			soundEnemyDrown.play();
		}
	}

	public function endItemFall(_:FlxTween, item:Entity):Void
	{
		item.kill();
		FlxG.switchState(new PlayState());
	}

	public function attack():Void
	{
		attackText.text = "Left click: Attack";

		sword.revive();
		
		setupSword(sword, player, FlxG.mouse.getWorldPosition());

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

		soundPlayerAttack.play();
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
		var s:Shadow = cast shadows.recycle(Shadow);
		s.setPosition(X, Y);
		s.animation.play("fall");
        s.endFallSignal.add(endFallShadow);
	}

	function endFallShadow(s:Shadow):Void
	{
		enemy.revive();
		enemy.setPosition(s.x+4, s.y);
		enemy.deathSignal.add(killEnemy);

		s.target = enemy;
		enemy.shadow = s;
	}

	function killEnemy(enemy:Enemy):Void
	{
		var s:Smoke = cast smoke.recycle(Smoke);
		s.setPosition(enemy.getMidpoint().x, enemy.getMidpoint().y);
		s.animation.play("idle");
		s.endAnimationSignal.add(endSmoke);

		soundEnemyDisappear.play();

		enemy.kill();
		if (grappling != null && enemy == grappling.grabbedItem)
			destroyGrappling();
	}

    function endSmoke():Void
    {
        FlxG.switchState(new PlayState());
    }
}
