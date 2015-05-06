package views;

import controllers.Signals.Signal;
import haxe.Template;
import haxe.Http;
import js.html.Element;
import js.html.NodeList;

import js.Lib;
import js.Browser;
import js.html.Document;
import js.html.DivElement;
import js.html.ButtonElement;
import js.html.InputElement;
import js.html.LabelElement;
import js.html.Event;

import models.Picture;

// import the interface for FineUploaderBasic

class UploadView extends View
{
	public static inline var TEMPLATE:String 	= '<div id="upload-ui"></div><ol id="upload-list"></ol><a href="#gallery" id="gallery-shortcut" class="gallery--shortcut" data-scroll><span>View Gallery</span></a>';// "sections/thumbnails.html";
	public static inline var UPLOAD:String 		= "./services/endpoint.php";

	var endpoint:String;
	var debug:Bool;
	
	public var uploaded:Signal;
	public var allLoaded:Signal;
	
	public function new( doc:Document, user:String, debugMode:Bool=false ) 
	{
		super( doc, null, 'uploader' );
		debug = debugMode;
		endpoint = UPLOAD + '?user=' + user;
		
		uploaded = new Signal();
		allLoaded = new Signal();
	}
	
	override public function initialise() 
	{
		transclude( TEMPLATE );
	}
	
	override function transclude( data:String )
	{
		// transclude this raw data into the DOM
		super.transclude(data);
		
		var uploaderID:String = 'qq-template';
		var upload:Element = doc.getElementById( "upload-ui" );
		var list:Element = doc.getElementById( "upload-list" );
		
		var options = {
			
			debug: debug,
			template:uploaderID,
			element:upload,
			listElement:list,
			
			includeExif:true,
			
			// acceptFiles:'',
			allowedExtensions:['jpg','jpeg','png','tiff','mp3','mp4','m4a','mov','flv'],
			
			request: {
				endpoint: endpoint
			},
			chunking: {
				enabled: true,
				mandatory: false,	// true here might help
				concurrent: {
					enabled: false
				},
				success: {
					endpoint:endpoint +"&done"
				}
			},
			deleteFile: {
				enabled: false
			},
			retry: {
			   enableAuto:false
			},
			showButton:true,
			waitingPath:'../images/waiting-generic.png',
			notAvailablePath:'../images/not_available-generic.png',
			callbacks: {
				// http://docs.fineuploader.com/branch/master/api/events.html
				onUpload: onUploadBegin,
				//onSubmitted: onSubmitted,
				//onCancel: onCancel,
				onComplete: onComplete,
				onAllComplete: onAllComplete,
				onError:onError
			}
		};
		
		// compiles to "new qq.FineUploader(options)"
		var uploader = untyped __js__("new qq.FineUploader")(options);
		//var uploader = untyped __js__("new qq.FineUploaderBasic")(options);
	}
	
	public function hideUploadStatus( e:Event ):Void
	{
		// simply removes all of the successful uploads from the list...
		var uploads:NodeList = doc.getElementsByClassName('upload-success');
	}
	
	function onUploadBegin (id:Int, name:String):Void 
	{
		trace('Uploaded : '+id+' called '+name );
	}
	
	function onSubmitted (id:Int, name:String):Void 
	{
		// uploading commenced
	}
	
	function onCancel (id:Int, name:String):Void 
	{
		// user cancelled!
	}
	
	function onComplete (id:Int, name:String, responseJSON:Picture, xhr):Void 
	{
		trace( responseJSON );
		uploaded.dispatch( responseJSON );
	}
	
	function onAllComplete ( succeeded:Array<Int>, failed:Array<Int> ):Void 
	{
		if ( failed.length > 0 )
		{
			// Not all images uploaded successfully...
		}
		/*
		// add button to hide the uploads
		var hideButton:ButtonElement = doc.createButtonElement();
		hideButton.textContent = "hide";  
		hideButton.className = "uploader--hide";  
		hideButton.onclick = hideUploadStatus;
		
		view.appendChild( hideButton );
		*/
		allLoaded.dispatch( succeeded, failed );
	}
	
	// issue occurred
	function onError (id:Int, name:String, errorReason:String, xhr):Void
	{ 
		Browser.window.console.error('Error in uploading this image '+errorReason );
	}
}