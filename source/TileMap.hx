package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.tile.FlxTilemap;

class TileMap extends TiledMap
{
	public var backgroundLayer:FlxGroup;
	public var environmentLayer:FlxGroup;

	public function new(tiledLevel:FlxTiledMapAsset, state:PlayState)
	{
		super(tiledLevel);

		backgroundLayer = new FlxGroup();
		environmentLayer = new FlxGroup();

		FlxG.camera.setScrollBoundsRect(0, 0, fullWidth, fullHeight, true);

		for (layer in layers)
		{
			if (layer.type != TiledLayerType.TILE)
				continue;

			var tileLayer:TiledTileLayer = cast layer;

			var tileSheetName:String = new String("assets/images/tileset.png");
			var tileset:TiledTileSet = null;
			tileset = tilesets.get("tileset");

			var tilemap:FlxTilemap = new FlxTilemap();
				
			tilemap.loadMapFromArray(tileLayer.tileArray, width, height, tileSheetName, tileset.tileWidth, tileset.tileHeight, OFF, tileset.firstGID, 1, 1);

			if (layer.name == "base")
				backgroundLayer.add(tilemap);
			else if (layer.name == "env")
				environmentLayer.add(tilemap);
		}
	}
	
	public function collideWithLevel(obj:FlxObject, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool
	{
		if (environmentLayer == null)
			return false;

		for (map in environmentLayer)
		{
			// IMPORTANT: Always collide the map with objects, not the other way around.
			//            This prevents odd collision errors (collision separation code off by 1 px).
			if (FlxG.overlap(map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate))
			{
				return true;
			}
		}
		return false;
	}
}