package entities;

class Enemy extends Entity
{
    public var player:Player = null;
    public var speed:Float = 30;

	public function new(?X:Float=0, ?Y:Float=0, ?p:Player)
	{
		super(X, Y);
        
        player = p;
        makeGraphic(8, 8, flixel.util.FlxColor.RED);

        pullable = true;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

        if (player != null && !pulled)
        {
            flixel.math.FlxVelocity.moveTowardsObject(this, player, speed);
        }
	}
}