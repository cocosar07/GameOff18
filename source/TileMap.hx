package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.tile.FlxTilemap;

import entities.Rock;

class TileMap extends TiledMap
{
	public var backgroundLayer:FlxGroup;
	public var collisionLayer:FlxGroup;

	public function new(tiledLevel:FlxTiledMapAsset, rocks:FlxGroup)
	{
		super(tiledLevel);

		backgroundLayer = new FlxGroup();
		collisionLayer = new FlxGroup();

		FlxG.camera.setScrollBoundsRect(0, 0, fullWidth, fullHeight, true);

		for (layer in layers)
		{
			if (layer.type == TiledLayerType.TILE)
			{
				var tileLayer:TiledTileLayer = cast layer;

				var tileSheetName:String = new String("assets/images/tileset.png");
				var tileset:TiledTileSet = null;
				tileset = tilesets.get("tileset");

				var tilemap:FlxTilemap = new FlxTilemap();
					
				tilemap.loadMapFromArray(tileLayer.tileArray, width, height, tileSheetName, tileset.tileWidth, tileset.tileHeight, OFF, tileset.firstGID, 1, 1);

				if (layer.name == "background")
					backgroundLayer.add(tilemap);
				else if (layer.name == "collision")
					collisionLayer.add(tilemap);
			}
			else if (layer.type == TiledLayerType.OBJECT)
			{
				var objectLayer:TiledObjectLayer = cast layer;
				for (o in objectLayer.objects)
				{
					var r:Rock = cast rocks.recycle(Rock);
					r.setPosition(o.x + r.width/2, o.y - r.height/2);
				}
			}
		}
	}
	
	public function collideWithLevel(obj:FlxObject, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool
	{
		var layer:FlxGroup = collisionLayer;

		if (layer == null)
			return false;

		for (map in layer)
		{
			if (FlxG.overlap(map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate))
			{
				return true;
			}
		}
		return false;
	}
}