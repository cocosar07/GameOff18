package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;

class GrapplingChain extends FlxSprite
{
    public var distanceFromGrappling:Float;
    public var player:Player;
    public var grappling:Grappling;

	public function new(?X:Float=0, ?Y:Float=0)
	{
		super(X, Y);

        makeGraphic(3, 3, flixel.util.FlxColor.fromRGBFloat(222.0/255, 238.0/255, 214.0/255));
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

        if (player == null || grappling == null)
            return;
        
        var diff:FlxPoint = player.getMidpoint().subtractPoint(grappling.getMidpoint());
        var v:FlxVector = new FlxVector(diff.x, diff.y);

        if (!grappling.launched && v.length < getMidpoint().distanceTo(grappling.getMidpoint()))
        {
            kill();
            return;
        }

        v.normalize().scale(distanceFromGrappling);

        setPosition(grappling.x + v.x, grappling.y + v.y);
	}
}