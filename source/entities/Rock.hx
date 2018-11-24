package entities;

class Rock extends Entity
{
	public function new(?X:Float=0, ?Y:Float=0)
	{
		super(X, Y);

		loadGraphic(AssetPaths.tileset__png, true, 8, 8);
		var r:flixel.math.FlxRandom = new flixel.math.FlxRandom();
		animation.add("0", [r.int(16, 17)], 1, false);
		animation.play("0");

		this.immovable = true;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}