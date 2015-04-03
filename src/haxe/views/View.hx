package views;

import haxe.Template;
import haxe.Http;

import js.html.Document;

class View extends Component
{
	var proxy:Mediator;
	
	public function new(document:Document, mediator:Mediator, className:String) 
	{
		super(document, className);
		proxy = mediator;
	}
	
	function loadTemplate( section:String ):Void
	{  
		var loader = new Http( section );  
		loader.onData = function(raw) 
		{  
			try {  
				//data = Json.parse(raw);  
				
				//if (!Std.is(data, Array)) throw "ArgumentError: Json data is not an array";  
				transclude( raw );  
			}  
			catch (err:Dynamic) {  
				
				untyped alert(err);  
			}  
		}  
		// now load it!
		loader.request();
	}  
	
	// transclude this raw data into the DOM
	function transclude( data:String ):Void
	{
		// get this DOM element and fill it with our template...
		view.innerHTML = data;
	}
}