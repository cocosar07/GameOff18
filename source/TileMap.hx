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
	public var waterLayer:FlxGroup;
	public var rocksLayer:FlxGroup;

	public function new(tiledLevel:FlxTiledMapAsset, state:PlayState)
	{
		super(tiledLevel);

		backgroundLayer = new FlxGroup();
		waterLayer = new FlxGroup();
		rocksLayer = new FlxGroup();

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

			if (layer.name == "background")
				backgroundLayer.add(tilemap);
			else if (layer.name == "water")
				waterLayer.add(tilemap);
			else if (layer.name == "rocks")
				rocksLayer.add(tilemap);
		}
	}
	
	public function collideWith(obj:FlxObject, layerName:String, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool
	{
		var layer:FlxGroup = null;

		if (layerName == "water")
			layer = waterLayer;
		if (layerName == "rocks")
			layer = rocksLayer;

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