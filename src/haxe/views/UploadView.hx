package views;

import haxe.Template;
import haxe.Http;
import js.html.Element;

import js.Lib;
import js.Browser;
import js.html.Document;
import js.html.DivElement;
import js.html.ButtonElement;
import js.html.InputElement;
import js.html.LabelElement;
import js.html.Event;

// import the interface for FineUploaderBasic

class UploadView extends View
{

	//var section:String = "sections/uploader.html";
	public static inline var TEMPLATE:String = "sections/thumbnails.html";
	
	public function new( doc:Document, mediator:Mediator ) 
	{
		super( doc, mediator, 'uploader' );
		loadTemplate( TEMPLATE );	// first transclude in the upload template
	}
	
	override function transclude( data:String )
	{
		// transclude this raw data into the DOM
		var uploaderID:String = 'qq-template';
		var uploaderElement:Element = doc.getElementById( uploaderID );
		
		// get this DOM element and fill it with our template...
		uploaderElement.innerHTML = data;
		
		/*
		// update the view accordingly...
		var sample:String = "My name is <strong>::name::</strong>, <em>::age::</em> years old";
		var user = {name:"Mark", age:30};
		var template:Template = new Template(sample);
		var output:String = template.execute(user);
		//trace(data);
		//trace(output);
		
		//var div:DivElement = doc.createDivElement();
		*/
		
		var options = {
			
			debug: true,
			template:uploaderID,
			element:getView(),
			request: {
				endpoint: './services/endpoint.php'
			},
			callbacks: {
				// http://docs.fineuploader.com/branch/master/api/events.html
				onUpload: onUpload,
				onSubmitted: onSubmitted,
				onCancel: onCancel,
				onComplete: onComplete,
				onAllComplete: onAllComplete,
				onDelete: onDelete,
				onDeleteComplete: onDeleteComplete,
				onError:onError
			}
			
		};
		
		// compiles to "new qq.FineUploader(options)"
		var uploader = untyped __js__("new qq.FineUploader")(options);
		//var uploader = untyped __js__("new qq.FineUploaderBasic")(options);
	}
	
	function onUpload (id:Int, name:String):Void {
		
	}
	function onSubmitted (id:Int, name:String):Void {}
	function onCancel (id:Int, name:String):Void { }
	
	function onComplete (id:Int, name:String, responseJSON, xhr):Void 
	{
		trace('Success! ' );
		trace( responseJSON );
	}
	
	function onAllComplete (succeeded:Array<Int>, failed:Array<Int>):Void 
	{
		if ( failed.length > 0 )
		{
			// Not all images uploaded successfully...
		}
		
		// add button to go to gallery
		var galleryButton:ButtonElement = doc.createButtonElement();
		galleryButton.textContent = "Continue";  
		galleryButton.className = "uploader--continue";  
		galleryButton.onclick = onExitRequested;
		
		view.appendChild( galleryButton );
	}
	
	function onDelete(id:Int):Void { }
	function onDeleteComplete(id:Int, xhr, isError):Void { }
	
	function onError (id:Int, name:String, errorReason:String, xhr):Void
	{ 
		trace('Error in uploading this image '+errorReason );
	}
	
	function onExitRequested(event:Event):Void 
	{ 
		proxy.onUploaded( );
	}
	
}