package views;

import googleAnalytics.Stats;
import js.html.AnchorElement;
import js.html.DocumentFragment;
import js.html.Element;
import js.html.DivElement;
import js.html.Event;
import js.html.ImageElement;
import js.html.Document;
import js.html.MouseEvent;
import js.html.KeyboardEvent;
import js.html.Node;
import js.Browser;
import js.html.NodeList;

import haxe.Http;
import haxe.Json;

import models.Picture;

import views.elements.MagnifyingGlass;

import controllers.EventHandler;
import controllers.WindowSize;
import controllers.Signals.Signal;

class GalleryView extends View
{
	public static inline var TEMPLATE:String 			= "./sections/gallery.html";
	public static inline var DATABASE:String 			= "./services/images.json";
	public static inline var DOWNLOAD:String 			= "./services/download.php";
	public static inline var IMAGES_LOCATION:String 	= "./services/files/";
	
	public static inline var A_CLASS_FULLSCREEN:String 	= "toggle-fullscreen";
	public static inline var DIV_ID_IMAGES:String 		= "gallery-pictures";
	
	public static inline var DIV_ID_FULL_SIZE:String 	= "gallery-full-size";
	
	public static inline var BLANK_IMAGE:String 		= "data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==";
	
	
	public var quantity(get_quantity, never):Int;
	function get_quantity():Int
	{
		return pictures.length;
	}
	
	var fullSizeElement:Element;
	var openedImage:ImageElement;
	var magnifyingGlass:MagnifyingGlass;
	var openedIndex:Int = -1;
	var fullSizeOpen:Bool = false;
	
	public var located:Signal;
	public var injected:Signal;
	
	
	var r = ~/_/g; // reegex underscore
	
	var pictures:Array<Picture> = [];
	
	// Pointers to data...
	var videos:Array<DivElement> = [];
	var images:Array<DivElement> = [];
	
	var fullscreenButtons:NodeList;
	var picturesElement:Element;
	
	var dataAvailable:Bool = false;
	var picturesAvailable:Bool = false;
	var debug:Bool = false;
	
	
	var bLazy:Dynamic;
	var videoOptions:Dynamic = { controls:false, autoplay:false, preload:'none', poster:"./images/video-8x.png", flash:{ swf:'swf/video-js.swf' } };
	var videoOptionsEncoded:String;	// JSON encoded version of above object
		
	public function new( doc:Document, debugMode:Bool=false ) 
	{
		super(doc, null, 'gallery');
		debug = debugMode;
		injected = new Signal();
		located = new Signal();
		videoOptionsEncoded = Json.stringify(videoOptions);
	}
	
	override public function initialise() 
	{
		loadTemplate( TEMPLATE );	// Transclude the gallery view
		loadDatabase( DATABASE );	// Load the JSON image database
	}
	
	override function transclude( data:String )
	{
		super.transclude( data );
		
		fullscreenButtons = doc.getElementsByClassName( A_CLASS_FULLSCREEN );
		picturesElement = doc.getElementById( DIV_ID_IMAGES );
		fullSizeElement = doc.getElementById( DIV_ID_FULL_SIZE );
		
		// http://dinbror.dk/blog/blazy/#Usage
		var options:Dynamic = { 
			//success: onImageLazyLoaded,
			error: onImageLazyLoadFailed
		};
		
		bLazy = untyped __js__("new Blazy")(options);
		onLoaded();
	}
	
	/////////////////////////////////////////////////////////////////////
	// load in the data JSON file containing pointers to all of the images
	/////////////////////////////////////////////////////////////////////	
	function loadDatabase( dataBase:String ):Void
	{  
		var loader = new Http( dataBase );  
		loader.onData = function( raw:String ) 
		{  
			try {  
				// remove last comma
				var sanitised:String = '[' + raw.substr( 0, raw.length-1) + ']';
				pictures = Json.parse(sanitised);  
				
				if (!Std.is(pictures, Array))
				{
					throw "ArgumentError: Json data is not an array";  
				} else {
					dataAvailable = true;
					onLoaded( );
				}
				
				
			} catch (err:Dynamic) {  
				
				Browser.window.console.error( 'Error Loading JSON data '+err );
			}  
		}
		loader.request();	// now load it in!
	}  
	
	/////////////////////////////////////////////////////////////////////
	// This gets called a few different times from asynchronous sources
	// and ensures everything gets loaded into position at the right time
	/////////////////////////////////////////////////////////////////////
	function onLoaded():Void
	{
		if (templateLoaded && dataAvailable)
		{
			// might be an empty JSON file
			if (pictures.length > 0) loadElements();  
			
			// add handlers for full screen buttons
			for ( i in  0...fullscreenButtons.length )
			{
				var button:Node = fullscreenButtons.item(i);
				EventHandler.attach( 'click', button, onFullScreenRequested );
			}
			
			//EventHandler.attach( 'resize', Browser.window, onResize);
		}
	}
	
	public function onFullScreenRequested(?event:Event):Void
	{
		untyped __js__("if (screenfull.enabled) screenfull.toggle();");
		scrollTo('gallery-pictures');
	}
	
	public function onResize(event:Event):Void
	{
		trace('resized ', WindowSize.getWidth(), WindowSize.getHeight() );
	}
	
	/////////////////////////////////////////////////////////////////////
	// Using the JSON file saved from the uploader script,
	// We can now load in this data and show it on the screen
	/////////////////////////////////////////////////////////////////////
	function loadElements() :Void
	{
		var imageFragments:DocumentFragment = doc.createDocumentFragment();  
		var videoFragments:DocumentFragment = doc.createDocumentFragment();  
		
		for (picture in pictures)
		{
			expandJson( picture );
			var div:DivElement = createElement( picture );
			picture.element = div;
			
			// check to see if it is a video element...
			if (picture.type >= 20)
			{
				// don't have to worry about order as
				// This only ever gets called once!
				videos.push( div );	
				videoFragments.appendChild( div );
			}else {
				images.push( div );
				imageFragments.appendChild( div );
			}
		}
		
		// now add our fragments to the main view via our transcluded view...
		picturesElement.appendChild(imageFragments);
		picturesElement.appendChild(videoFragments);
		
		// now instantiate the video players for each element!
		for ( video in videos ) createVideoPlayer( video );
	
		onPicturesAvailable();
		
		// lazy load the images into the DIV
		untyped bLazy.revalidate();  
	}
	
	
	function onImageLazyLoaded(ele:Element):Void
	{
		// Image has loaded
		// Do your business here
	}
	
	/////////////////////////////////////////////////////////////////////
	// ERROR! The image that was supposed to be lazy loaded is not 
	// loading as expected so let us tell the user somehow
	/////////////////////////////////////////////////////////////////////
	function onImageLazyLoadFailed( ele:Element, msg:String ):Void
	{
		if (msg == 'missing')
		{
			// Data-src is missing
			trace('Data-src is missing ',ele);
			
		} else if (msg == 'invalid') {
			
			// Data-src is invalid
			trace('Data-src is invalid ',ele);
			
		}else {
			trace('Image Failed to load ',ele);
		}
	}
	
	/////////////////////////////////////////////////////////////////////
	// ADD a picture in real-time through JS
	/////////////////////////////////////////////////////////////////////
	public function addLive( picture:Picture ):Void
	{
		// failure :(
		if (picture.success != true)
		{
			trace('Could not dynamically add '+picture.uploadName);
			return;
		}
		// now add our new image
		expandJson( picture );
		var element:DivElement = createElement( picture );
		
		if (element != null)
		{
			picture.element = element;
			pictures.push( picture );
			picturesElement.appendChild( element );
			
			// check to see if it is a video element...
			if (picture.type >= 20) createVideoPlayer( element );
		
			onPicturesAvailable();
			
			untyped bLazy.revalidate(); 
			
		} else {
			
			trace('Video DOM Element could not be manufactured');
		}
	}
	
	function onPicturesAvailable():Void
	{
		if (!picturesAvailable)
		{
			picturesAvailable = true;
			injected.dispatch( pictures );
			
			EventHandler.attach( 'keyup', doc, onKeyInputted);
			//EventHandler.detach( 'keyup', doc, onKeyInputted);
			
			untyped smoothScroll.init();
		}
	}
	
	function expandJson( picture:Picture) 
	{
		picture.thumbnailURL = createURL(picture);
		picture.name = extractName( picture.uploadName ) ;
		picture.fullSizeURL = picture.resized ? convertThumbailToFullSize(picture) : picture.thumbnailURL;
		picture.downloadService = DOWNLOAD + "?file="+picture.fullSizeURL;
	}
	
	/////////////////////////////////////////////////////////////////////
	// Create a DIV element containing all the neccessary bits and pieces
	// to be injected directly into the DOM with functionality
	/////////////////////////////////////////////////////////////////////
	function createElement( picture:Picture ):DivElement
	{
		// Determines whether this is a picture or a video!
		if ( picture.type < 20 ) return createPicture(picture);
		else return createVideo(picture);
	}
	
	function extractName( fileName:String ):String
	{
		// split off the extension...
		var name:String = fileName.substr(0, fileName.lastIndexOf('.'));
		name = r.replace( name, " ");	// replace underscores and stuff with spaces
		return name;
	}
	
	/////////////////////////////////////////////////////////////////////
	// Create canonical URL for injecting into the html relative to ./
	/////////////////////////////////////////////////////////////////////
	function createURL( picture:Picture ):String
	{
		return IMAGES_LOCATION + picture.uuid + '/' + picture.uploadName;
	}
	
	/////////////////////////////////////////////////////////////////////
	// Create canonical URL for injecting into the html relative to ./
	/////////////////////////////////////////////////////////////////////
	function convertThumbailToFullSize( picture:Picture ):String
	{
		var fullSize:String =  picture.uploadName.substr(1);
		return IMAGES_LOCATION + picture.uuid + '/' + fullSize;
	}
	
	/////////////////////////////////////////////////////////////////////
	// This creates the DOM Element by cloning an existing image 
	/////////////////////////////////////////////////////////////////////
	function createPicture( picture:Picture ):DivElement
	{
		var fullName:String = picture.name + " <span>taken by</span> " + picture.user;
		
		var fullSizeURL:String = picture.resized ? convertThumbailToFullSize(picture) : picture.thumbnailURL;
		
		var div:DivElement = doc.createDivElement();
		div.className = 'picture';
		div.id = picture.uuid;
		
		/*
		// add an image...
		var img:ImageElement = doc.createImageElement();
		img.setAttribute('data-src', url );
		img.src = BLANK_IMAGE;
		img.className = 'b-lazy';
		img.alt = picture.name;
		img.width = picture.width;
		img.height = picture.height;
		*/
		var retinaFilename:String = picture.resized ? picture.thumbnailURL + '|' + fullSizeURL : picture.thumbnailURL;
		var i:String = "<img id='i-"+picture.uuid+"' class='b-lazy' data-src='"+retinaFilename+"' src='"+BLANK_IMAGE+"' alt='"+picture.name+"' width='"+picture.width+"' height='"+picture.height+"' >";
		var noscript:String = "<img src='"+picture.thumbnailURL+"' alt='"+picture.uploadName+"' width='"+picture.width+"' height='"+picture.height+"' >";
		var t:String = "Download";
		
		var p:String = "<figure>";
		p += i;
		p += "<figcaption>";
		p += "<h4>"+fullName+"</h4>";
		p += "</figcaption>";
		p += '<noscript>' + noscript + '</noscript>';
		p += "</figure>";
		p += "<a class='download' href='"+picture.downloadService+"'>"+t+"</a>";
		//p += "<a class='fullscreen' href='"+fullSizeURL+"'>Show "+name+" Fullscreen</a>";
		
		// create element for full screen and immediately add the on click listener
		var fullSizeLink:AnchorElement 	= doc.createAnchorElement();
		fullSizeLink.className 			= 'fullscreen';
		fullSizeLink.href 				= fullSizeURL;
		fullSizeLink.title 				= "View "+picture.name+" in Full Screen Mode";
		
		EventHandler.attach( 'click', fullSizeLink, function(event:Event)
		{
			event.preventDefault();
			onImageFullSizeRequested( picture );
			return false;
		});
	
		div.innerHTML = p;
		div.appendChild( fullSizeLink );
		
		// check for GPS
		if ((picture.long != null) && (picture.lat != null))
		{
			located.dispatch( picture , div );
		}
		
		Browser.window.console.error( picture );
		
		return div;
	}
	
	/////////////////////////////////////////////////////////////////////
	// Somehow take the LARGE image and either inject 
	// it into an overlaying DIV or AJAX it into an iFrame...
	// For now Let us just create an invisible overlay and stick it in there...
	/////////////////////////////////////////////////////////////////////
	function onImageFullSizeRequested( picture:Picture ):Void
	{
		if ( openedImage == null )
		{
			var div:DivElement = picture.element;
			if ( magnifyingGlass == null ) magnifyingGlass = new MagnifyingGlass( doc, debug );
			
			var fullName:String = picture.name + " taken by " + picture.user;
			var id:String = "f-" + picture.uuid;
			var i:String = '';
			//"<img id='"+id+"' class='fs' src='"+fullSizeURL+"' alt='"+name+"' >";
			i += "<a class='download' title='Download "+fullName+"' href='"+picture.downloadService+"'>Download "+fullName+"</a>";
			
			openedImage = doc.createImageElement();
			openedImage.id = id;
			openedImage.className = 'fs';
			openedImage.alt = fullName;
			
			/*
			 var loaded = false;
			function loadHandler() {
				if (loaded) return;
				loaded = true;
				.
			}
			var img = document.getElementById('FULL_SRC');
			img.onload = loadHandler;
			img.src = fimage;
			img.style.display = 'block';
			if (img.complete) {
				loadHandler();
			}
			*/
			
			var exitBackgroundButton:AnchorElement = doc.createAnchorElement();
			var exitButton:AnchorElement = doc.createAnchorElement();
			
			var onExit = function(event:Event)
			{
				event.preventDefault();
				onCloseFullSizeImage( div.id );
				return false;
			};
			
			// This exit button
			exitBackgroundButton.className 			= 'fs-exit';
			exitBackgroundButton.textContent 		= 'Close';
			exitBackgroundButton.href 				= '#' + picture.uuid;
			exitBackgroundButton.onclick 			= onExit;
			
			// This exit button
			exitButton.className 			= 'exit';
			exitButton.textContent 			= 'Close';
			exitButton.title 				= 'Close this image and go back to gallery';
			exitButton.href 				= '#' + picture.uuid;
			exitButton.onclick 				= onExit;
			
			var uiFragments:DocumentFragment = doc.createDocumentFragment();  
			uiFragments.appendChild( exitButton );
			uiFragments.appendChild( openedImage );
			uiFragments.appendChild( exitBackgroundButton );
			uiFragments.appendChild( magnifyingGlass.getView() );	// now attach the magnifying glass to the mousemove of the image
			fullSizeElement.innerHTML = i;
			fullSizeElement.appendChild( uiFragments );
		}
		
		// find the index of this div as we can't be sure of it
		openedIndex = pictures.indexOf(picture);
		showFullScreen( picture );
		
		//untyped screenfull.request(fullSizeElement);
	}
	
	public function showFullScreen( picture:Picture ):Void
	{
		var windowOrientation:String = WindowSize.isLandscape() ? 'window-landscape' : 'window-portrait';
		var imageOrientation:String = picture.width > picture.height ? 'image-landscape' : 'image-portrait';
		var classes:String = 'opened' + ' ' + imageOrientation + ' ' + windowOrientation;
		
		fullSizeElement.className = classes;
		
		magnifyingGlass.setImage(openedImage, picture.width, picture.height );
		
		openedImage.src = picture.fullSizeURL;
		//Browser.window.console.error( openedImage );
		
		// scroll to element
		scrollTo( picture.uuid , 100 );
		
		fullSizeOpen = true;
		
		//Stats.trackEvent('viewed',picture.fullSizeURL, picture.user);
		Stats.trackPageview(picture.fullSizeURL, picture.name );
		
	}
	
	public function previous():Void
	{
		openedIndex = openedIndex + 1 >= pictures.length ? 0 : openedIndex + 1;
		
	}
	public function next():Void
	{
		openedIndex = openedIndex - 1 < 0 ? pictures.length - 1 : openedIndex - 1;
	}
	
	public function previousFullScreen():Void
	{
		previous();
		showFullScreen( pictures[ openedIndex ] );	
	}
	public function nextFullScreen():Void
	{
		next();
		showFullScreen( pictures[ openedIndex ] );	
	}
	
	public function hideFullScreen( ?scrollToID:String ):Void
	{
		magnifyingGlass.disable();
		magnifyingGlass.hide();
		fullSizeElement.className = '';
		fullSizeOpen = false;
		
		//untyped screenfull.exit();
		
		scrollTo( scrollToID );		// rescroll to element
	}
	
	function scrollTo( ID:String, speed:Int=600 ):Void
	{
		var options:Dynamic = { speed: speed, updateURL: false, easing: 'easeOutCubic' };
		untyped __js__("smoothScroll.animateScroll")( null, '#' + ID, options );
	}
	
	/////////////////////////////////////////////////////////////////////
	// EVENT : Key has been pressed & released
	/////////////////////////////////////////////////////////////////////
	public function onKeyInputted( event:KeyboardEvent ):Void
	{
		if ( fullSizeOpen )
		{
			// find out the key pressed...
			switch ( event.keyIdentifier )
			{
				// Previous
				case 'Left' :
					nextFullScreen();
					event.preventDefault();
					trace( 'FS Opened Index ' + openedIndex );
				
				// Next
				case 'Right' :
					previousFullScreen();
					event.preventDefault();
					trace( 'FS Opened Index '+openedIndex );
				// F
				case 'U+0046' :
					onFullScreenRequested();
					
				// Close
				default:
					hideFullScreen( pictures[ openedIndex ].uuid );
					event.preventDefault();
					trace( openedIndex+': key - '+event.keyIdentifier );
			}
		}else {
			// full size is closed, so let us 
			switch ( event.keyIdentifier )
			{
				// Previous
				case 'Left' :
					next();
					scrollTo( pictures[ openedIndex ].uuid );
					event.preventDefault();
					trace( 'Opened Index ' + openedIndex );
				
				// Next
				case 'Right' :
					previous();
					scrollTo( pictures[ openedIndex ].uuid );
					event.preventDefault();
					trace( 'Opened Index ' + openedIndex );
				
				// F
				case 'U+0046' :
					onFullScreenRequested();
			}
		}
	}
	
	/////////////////////////////////////////////////////////////////////
	// Full Size Image Closing...
	// Scroll back to original image location and do a fancy transition
	/////////////////////////////////////////////////////////////////////
	function onCloseFullSizeImage( id:String ):Void
	{
		//hideFullScreen( id );
		hideFullScreen( pictures[ openedIndex ].uuid );
	}
	
	/////////////////////////////////////////////////////////////////////
	// This creates the DOM Eleent by cloning an existing image 
	/////////////////////////////////////////////////////////////////////
	function createVideo( picture:Picture ):DivElement
	{
		var name:String = extractName( picture.uploadName ) + " <span>taken by</span> " + picture.user;
		var extension:String = picture.uploadName.substr( picture.uploadName.lastIndexOf('.')+1 ).toLowerCase();
		
		var div:DivElement = doc.createDivElement();
		div.className = 'video '+extension;
		div.id = picture.uuid;
		
		/*
		<video id="'+picture.uuid+'" class="video-js vjs-default-skin vjs-big-play-centered" controls preload="auto" width="640" height="264" poster="http://video-js.zencoder.com/oceans-clip.png">
			<source src="http://video-js.zencoder.com/oceans-clip.mp4" type='video/mp4' />
			<source src="http://video-js.zencoder.com/oceans-clip.webm" type='video/webm' />
			<source src="http://video-js.zencoder.com/oceans-clip.ogv" type='video/ogg' />
			<p class="vjs-no-js">To view this video please enable JavaScript, and consider upgrading to a web browser that <a href="http://videojs.com/html5-video-support/" target="_blank">supports HTML5 video</a></p>
		</video>
		*/
		
		var p:String = '';
		p += "<h4>"+name+"</h4>";
		//  width="'+picture.width+'" height="'+picture.height+'" 
		p += '<video id="v-'+picture.uuid+'" class="video-js vjs-default-skin vjs-big-play-centered" poster="./images/video.svg" controls preload="none" width="480" height="270">';
		p += '<source src="'+picture.thumbnailURL+'" type="video/'+extension+'" />';
		p += '<p class="vjs-no-js">To view this video please consider upgrading to a web browser that <a href="http://videojs.com/html5-video-support/" target="_blank">supports HTML5 video</a></p>';
		p += '</video>';
		p += "<a class='download' href='"+picture.downloadService+"'>Download</a>";
		
		//trace( p );
		div.innerHTML = p;
		return div;
	}
	
	function createVideoPlayer( element:Element ):Dynamic
	{
		var videoPlayer = untyped __js__("videojs")( 'v-'+element.id, videoOptionsEncoded, onVideoInitialised );
		videoPlayer.on('play', onVideoPlaying);
		// add play / stop events to determine a single exclusive player for all...
		//videoPlayer
		return videoPlayer;
	}
	
	public function onVideoInitialised( ele:Element, msg:String ):Void
	{
		trace('Video Initialised! ' );
	}
	
	/*
	
	{
		path : [object NodeList], 
		cancelBubble : false, 
		srcElement : [object HTMLVideoElement], 
		defaultPrevented : false, 
		timeStamp : 1429017293828, 
		cancelable : true, 
		bubbles : false, 
		eventPhase : 2, 
		currentTarget : [object HTMLVideoElement], 
		target : [object HTMLVideoElement], 
		type : play, 
		stopPropagation : <function>, 
		preventDefault : <function>, 
		initEvent : <function>, 
		stopImmediatePropagation : <function>, 
		NONE : 0, 
		CAPTURING_PHASE : 1, 
		AT_TARGET : 2, 
		BUBBLING_PHASE : 3, 
		MOUSEDOWN : 1, 
		MOUSEUP : 2, 
		MOUSEOVER : 4, 
		MOUSEOUT : 8, 
		MOUSEMOVE : 16, 
		MOUSEDRAG : 32, 
		CLICK : 64, 
		DBLCLICK : 128, 
		KEYDOWN : 256, 
		KEYUP : 512, 
		KEYPRESS : 1024, 
		DRAGDROP : 2048, 
		FOCUS : 4096, 
		BLUR : 8192, 
		SELECT : 16384, 
		CHANGE : 32768, 
		relatedTarget : null, 
		ie : <function>, 
		Vb : <function>, 
		Rc : <function>, 
		which : null
	}
	
	*/
	public function onVideoPlaying( e:Dynamic ):Void
	{
		var caller:Element = cast e.srcElement;
		trace( caller.id + ' Video Playing! ', e );
		// currentVideo = 
		
	}
}