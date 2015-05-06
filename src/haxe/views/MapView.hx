/*

Coordinates of Havana in decimal degrees

Latitude: 23.1330200	
Longitude: -82.3830400
 
*/

package views;

import controllers.EventHandler;
import js.html.KeyboardEvent;
import models.GPS;

import js.html.DivElement;
import js.html.Document;

class MapView extends View
{
	public static inline var TEMPLATE:String = '<div id="map"></div>';
	public static inline var ZOOM:Float 	= 6;
	
	public var styles:Array<String> = [
		"OpenStreetMap.HOT", 
		//"OpenTopoMap", 
		"Thunderforest.OpenCycleMap", 
		"Thunderforest.Transport",
		"Thunderforest.TransportDark",
		"Thunderforest.Landscape", 
		"Thunderforest.Outdoors",
		"OpenMapSurfer.Roads", 
		"OpenMapSurfer.Grayscale", 
		"Hydda.Full", "Hydda.Base", 
		"MapQuestOpen.OSM", 
		"MapQuestOpen.Aerial",			// *
		// "MapBox", 
		"Stamen.Toner", 
		"Stamen.TonerBackground", 
		"Stamen.TonerLite", 
		"Stamen.Watercolor", 
		"Stamen.Terrain", 
		"Stamen.TerrainBackground",
		//"Stamen.TopOSMRelief", 
		"Esri.WorldStreetMap", 
		"Esri.DeLorme", 
		"Esri.WorldTopoMap", 
		"Esri.WorldImagery", 
		"Esri.WorldTerrain", 
		"Esri.WorldShadedRelief", 
		"Esri.WorldPhysical", 
		"Esri.OceanBasemap", 
		"Esri.NatGeoWorldMap",
		"Esri.WorldGrayCanvas", 
		
		// "HERE.normalDay", 
		//"HERE.normalDayCustom", 
		//"HERE.normalDayGrey", 
		//"HERE.normalDayMobile", 
		//"HERE.normalDayGreyMobile", 
		// "HERE.normalDayTransit", 
		//"HERE.normalDayTransitMobile",
		//"HERE.normalNight",
		//"HERE.normalNightMobile", 
		// "HERE.normalNightGrey", 
		// "HERE.normalNightGreyMobile",
		//"HERE.carnavDayGrey",
		//"HERE.hybridDay", 
		//"HERE.hybridDayMobile", 
		//"HERE.pedestrianDay",
		//"HERE.pedestrianNight",
		//"HERE.satelliteDay", 
		//"HERE.terrainDay", 
		//"HERE.terrainDayMobile",
		
		"Acetate.basemap", 
		"Acetate.terrain", 
		"Acetate.all", 
		// "Acetate.hillshading",
		// "Acetate.foreground",
		// "Acetate.roads",
		// "Acetate.labels", 
		
		// "FreeMapSK", 
		"MtbMap",
		"CartoDB.Positron",
		"CartoDB.PositronNoLabels",
		"CartoDB.DarkMatter",
		//"CartoDB.DarkMatterNoLabels",
		"HikeBike", 
		
		//"BasemapAT.basemap",
		//"BasemapAT.highdpi",
		//"BasemapAT.grau",
		// "BasemapAT.overlay",
		// "BasemapAT.orthofoto",
		// "OpenSeaMap",
		"OpenMapSurfer.AdminBounds",
		// "Hydda.RoadsAndLabels",
		//"MapQuestOpen.HybridOverlay",
		//"Stamen.TonerHybrid",
		//"Stamen.TonerLines",
		//"Stamen.TonerLabels", 
		// "Stamen.TopOSMFeatures",
		
		// These work but are best used as overlays for others
		// "OpenWeatherMap.Clouds",
		// "OpenWeatherMap.CloudsClassic", 
		//"OpenWeatherMap.Precipitation",
		//"OpenWeatherMap.PrecipitationClassic",
		//"OpenWeatherMap.Rain",
		//"OpenWeatherMap.RainClassic",
		//"OpenWeatherMap.Pressure", 
		//"OpenWeatherMap.PressureContour",
		//"OpenWeatherMap.Wind",
		//"OpenWeatherMap.Temperature",
		// "OpenWeatherMap.Snow",
		
		
		// "NASAGIBS.ModisTerraLSTDay", 
		"NASAGIBS.ModisTerraTrueColorCR", 
		"NASAGIBS.ModisTerraBands367CR",
		"NASAGIBS.ViirsEarthAtNight2012",
		"NASAGIBS.ModisTerraSnowCover"
		//"NASAGIBS.ModisTerraAOD",
		//"NASAGIBS.ModisTerraChlorophyll"
	];
	
	var tileID:Int = 0;
	var tile:Dynamic;
	var map:Dynamic;
	
	public function new( document:Document ) 
	{
		super(document, null, 'maps');
	}

	override public function initialise() 
	{
		// loadTemplate( TEMPLATE );
		transclude( TEMPLATE );	// first transclude in the upload template
	}
	
	function getRandomStyle():String
	{
		var random:Float = styles.length * Math.random();
		var style:Int = Std.int( random );
		return styles[ style ];
	}
	
	function createMap():Void
	{
		
		// create tiles
		var baseLayersNames:Dynamic = {};
		/*
		var baseLayers:Array<String> = new Array();
		
		for ( style in styles )
		{
			var layer:Dynamic = untyped __js__("L.tileLayer.provider")(style);
			//baseLayersNames.set( style , tile );
			baseLayers.push( layer );
		}
		*/
		
		// Set Options
		var options:Dynamic = {};
		//options.maxZoom = 18;
		options.scrollWheelZoom = false;
		options.attributionControl  = false;
		options.zoomControl = false;
		//options.layers = baseLayers;
		
		// This is our map and co-ordinates, here set to Cuba...
		var control = untyped __js__("L.control.zoom")( { position:'bottomleft' } );
		untyped __js__("L.Icon.Default.imagePath = './images/'");
		map = untyped __js__("L.map")('map', options ).setView([21.8042, -79.9848], ZOOM).addControl(control);
		//untyped __js__("L.control.layers")(baseLayersNames).addTo(map);
		
		//map.on('layeradd', onLayerAdded );
		//map.on('layerremoved', onLayerRemoved );
		
		var style:String = getRandomStyle();
		addTiles( style );
	
		EventHandler.attach( 'keyup', doc, onKeyInputted);
	}
	
	
	public function addTiles(style:String):Dynamic
	{
		var newTile = untyped __js__("L.tileLayer.provider")(style).addTo(map);
		
		// check if previous...
		if ( tile != null )
		{
			untyped map.removeLayer(tile);
		}
		trace('Trying to add Layer ' + style);
			
		tile = newTile;
		// 
		return tile;
		//var tiles = untyped __js__('L.tileLayer')( tileLayer, options ).addTo(map);
	}
	
	override function transclude( data:String )
	{
		// get this DOM element and fill it with our template...
		super.transclude( data );
		
		createMap();
		
		var havana:GPS 			= { lat:23.1330200, lon:-82.3830400 };
		var santiago:GPS 		= { lat:20.0289, lon:-75.829 };
		var trinidad:GPS 		= { lat:21.8042, lon:-79.9848 };
		var holguin:GPS 		= { lat:20.8886, lon:-76.2572 };
		var sanctiSpiritus:GPS 	= { lat:21.9938, lon:-79.4704 };
		var pinar:GPS 			= { lat:22.4253, lon:-83.6875 };
		var cienfuegos:GPS 		= { lat:22.15, lon:-80.4437 };
		var path:Array<GPS> 	= [ havana, holguin, santiago, sanctiSpiritus, trinidad, cienfuegos, pinar, havana ];
		
		// Havana
		addMarker( havana, '<h3>Havana</h3><p>Plaza Hotel &amp; Hotel Nacional</p>' );
		// Holguin
		addMarker( holguin, '<h3>Holguin</h3><p>Hotel Brisas</p>' );
		// Santiago de Cuba
		addMarker( santiago, '<h3>Santiago de Cuba</h3><p>Melia Hotel</p>' );
		// Sancti Spiritus
		addMarker( sanctiSpiritus, '<h3>Sancti Spiritus</h3><p>Colon Hotel</p>' );
		// Trinidad
		addMarker( trinidad, '<h3>Trinidad</h3><p>Brisas Hotel</p>' );
		// Pinar Del Rio
		addMarker( pinar, '<h3>Pinar Del Rio</h3><p>Hotel Los Jasmines</p>' );
		// Cienfuegos
		addMarker( cienfuegos, '<h3>Cienfuegos</h3><p>Jagua Hotel</p>' );
		
		// Now draw the path travelled
		// In the following order
		addPath( path );
	}
	
	/////////////////////////////////////////////////////////////////////
	// Show a marker on the map at coords...
	/////////////////////////////////////////////////////////////////////
	public function addMarker( coord:GPS, ?popup:String, ?custom:Bool ):Dynamic
	{
		var marker:Dynamic;
		
		if (custom)
		{
			var options = {
				className: 'svg-marker',
				html: ''+popup,
				iconSize: null,
				iconAnchor: null
			};

			var icon = untyped __js__("L.divIcon")( options );
			marker = untyped __js__("L.marker")([coord.lat, coord.lon], {icon:icon} ).addTo(map);
		
		}else {
			marker = untyped __js__("L.marker")([coord.lat, coord.lon] ).addTo(map);
		}
		
		// add a popup marker :P
		if (popup != null) untyped __js__("marker.bindPopup")( popup );
		return marker;
	}
	
	/////////////////////////////////////////////////////////////////////
	// draw a Path from one point to the next
	/////////////////////////////////////////////////////////////////////
	public function addPath( latlngs:Array<GPS> ):Void
	{
		var polyline = untyped __js__("L.polyline")(latlngs, {color:'red' }).addTo(map);
	}
	
	/////////////////////////////////////////////////////////////////////
	// Show a marker on the map at coords...
	
	public function addAssociation( latitude:Float, longitude:Float, message:String , div:DivElement ):Void
	{
		var gps:GPS = { lat:latitude, lon:longitude };
		addMarker( gps, message, false );
	}
	
	/*
	public function onLayerAdded( event:Dynamic ):Void
	{
		trace('Layer added');
	}
	
	public function onLayerRemoved( event:Dynamic ):Void
	{
		trace('Layer removed');
	}
	*/
	/////////////////////////////////////////////////////////////////////
	// EVENT : Key has been pressed & released
	/////////////////////////////////////////////////////////////////////
	public function onKeyInputted( event:KeyboardEvent ):Void
	{
		// find out the key pressed...
		switch ( event.keyIdentifier )
		{
			case 'Enter' :
				
				// increment
				tileID = tileID + 1 >= styles.length ? 0 : tileID + 1;
				addTiles( styles[ tileID ] );
				trace('Adding Tile : '+ styles[ tileID ] );
				event.preventDefault();
		}
	}
}