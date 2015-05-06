package views;

import controllers.Signals.Signal;
import haxe.Template;
import haxe.Http;
import js.html.Element;
import js.html.Node;

import js.html.Document;
import js.Browser;

class View extends Component
{
	public var transcluded:Signal;
	
	var templateLoaded:Bool = false;
	
	public function new(document:Document, mediator:Mediator, className:String) 
	{
		super(document, className);
		transcluded = new Signal();
	}
	
	public function initialise() 
	{
		
	}
	
	public function destroy( ):Void
	{
		
	}
	function loadTemplate( section:String ):Void
	{  
		var loader = new Http( section );  
		loader.onData = function(raw) 
		{  
			try {  
				transclude( raw );  
			}  
			catch (err:Dynamic) {  
				
				Browser.window.console.error(err);  
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
		templateLoaded = true;
		transcluded.dispatch( this );
	}
	
	public function inject( element:Node ):Void
	{
		element.appendChild( getView() ); 
	}
}