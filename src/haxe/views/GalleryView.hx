package views;

import js.html.DivElement;
import js.html.Document;
import haxe.Http;
import haxe.Json;
import js.html.ImageElement;

typedef Picture = {
	var url:String;
	var name:String;
	var width:Int;
	var height:Int;
	var tags:Array<String>;
}
				
class GalleryView extends View
{
	public static inline var TEMPLATE:String 	= "sections/gallery.html";
	public static inline var DATABASE:String 	= "services/images.json";
	public static inline var IMAGES:String 		= "services/files/";
	
	public static inline var BLANK_IMAGE:String = "data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==";
	
	public function new( doc:Document, mediator:Mediator ) 
	{
		super(doc, mediator, 'gallery');
		
		loadTemplate( TEMPLATE );	// transclude the gallery view
		
		// load in the data JSON file containing pointers to all of the images
		loadDatabase( DATABASE );
		
		// attach the upload more button to the password view
	}
	
	function loadDatabase( dataBase:String ):Void
	{  
		var loader = new Http( dataBase );  
		loader.onData = function( raw:String ) 
		{  
			try {  
				var sanitised:String = '[' + raw.substr( 0, raw.length-1) + ']';
				
				trace(sanitised);
				
				var json:Array<Picture> = Json.parse(sanitised);  
				if (!Std.is(json, Array)) throw "ArgumentError: Json data is not an array";  
				else loadPictures( json );  
			}  
			catch (err:Dynamic) {  
				
				untyped alert('Haxe '+err);  
			}  
		}  
		// now load it!
		loader.request();
	}  
	
	// Using the JSON file saved from the uploader script,
	// We can now load in this data and show it on the screen
	function loadPictures( images:Array<Picture> ) :Void
	{
		// lazy load the images into the DIV
		var fragments = doc.createDocumentFragment();  
		
		for (i in 0...images.length)
		{
			var image:Picture = images[i];
			fragments.appendChild( createPicture( image ) );
		}
		
		// now add our fragments to the main view
		view.appendChild(fragments);
		
		// http://dinbror.dk/blog/blazy/#Usage
		var options:Dynamic = {};
		var bLazy = untyped __js__("new Blazy")(options);
	}
	
	// This creates the DOM Eleent by cloning an existing image 
	function createPicture( picture:Picture ):DivElement
	{
		var url:String = IMAGES + picture.url;
		var div:DivElement = doc.createDivElement();
		div.className = 'picture';
		
		// add an image...
		var img:ImageElement = doc.createImageElement();
		img.setAttribute('data-src', url );
		img.src = BLANK_IMAGE;
		img.className = 'b-lazy';
		img.alt = 'Summary for roll ower';
		img.width = picture.width;
		img.height = picture.height;
		
		trace( url, picture.width, picture.height );
				
		div.appendChild(img);
		
		return div;
	}
	
}