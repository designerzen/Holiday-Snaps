/*

	1. A Password (hard coded and specific to site - mango)
	2. Photos homepage with an Add Your Photos / Videos button at the bottom
	3. Upload page with name at the top, then a drag-n-drop ui for adding photos, upload button at bottom
	4. Tags / Locations / Exif data etc done on server side

*/

package;

import etc.Config;

import models.Picture;
import models.Cookies;

import views.MapView;
import views.PasswordView;
import views.UploadView;
import views.GalleryView;
import views.View;

import controllers.EventHandler;
import controllers.Signals;

import js.Lib;
import js.Browser;
import js.html.Event;
import js.html.Document;
import js.html.Element;
import js.html.DivElement;
import js.html.AnchorElement;

import haxe.crypto.Md5;

import googleAnalytics.Stats;

class Mediator
{
	var passwordView:PasswordView;
	var uploadView:UploadView;
	var galleryView:GalleryView;
	var mapView:MapView;
	
	var doc:Document = Browser.document;  
	var body:Element;
	var dynamicElement:Element;
	var cookies:Cookies;
	
	var isLoaded:Bool 	= false;			// Have the assets loaded?
	var hasImages:Bool 	= false;			// Have we got any images in the database?
	
	var debug:Bool 		= Config.DEBUG;		// print to screen the issues!
	
	public function new() 
	{
		// Initialise Google Analytics with this Site Property
		// And track default page view
		Stats.init( Config.GOOGLE_ID, Config.DOMAIN );
		Stats.trackPageview('/index.html','Main Page');
		
		// fetch and set the DOM elements where our application is
		// injected into to prepare it for transclusions
		cookies = new Cookies();
		body = doc.body;
		dynamicElement = doc.getElementById( Config.DYNAMIC_ID );
		
		// secondly display the password selector 
		// or jump straight to the main views if saved by user
		// on a previous visit
		if (cookies.skip) 
		{
			showMainView();
		} else {
			showPasswordView();
		}
	}
	
	
	// Password ============================================
	
	function showPasswordView():Void
	{
		passwordView = new PasswordView( doc, cookies );
		passwordView.transcluded.addOnce( onTranscluded );
		passwordView.passwordReceived.add( onPassword );
		passwordView.initialise();
		
		Stats.trackPageview('/password.html','Password');
	}
	
	function hidePasswordView():Void
	{
		dynamicElement.removeChild( passwordView.getView() ); // now remove from the screen...
		
		passwordView.destroy();
		passwordView = null;
		
		showMainView();
	}
	
	// see when the button was pressed...
	public function onPassword( password:String ):Void
	{
		//trace( Config.PASSWORD, Md5.encode( Config.PASSWORD ) );
		
		// MD5 this thing...
		if (password.toLowerCase() != Config.PASSWORD )
		{
			passwordView.onPasswordIncorrect();
			Stats.trackEvent('error', 'login', passwordView.getUserName() );
		
		} else {
			onPasswordCorrect( );
		}
	}
	
	// Password is incorrect, make sure there is a limit on how many
	// times a password can be entered as well as UI feedback
	public function onPasswordCorrect( ):Void
	{
		// set cookie for next time!
		cookies.name = passwordView.getUserName();
		
		if ( passwordView.getRememberOption() )
		{
			cookies.skip = true;
			cookies.save();
		}else {
			trace('Forgetting Password and username');
		}
		Stats.trackEvent('login', 'success', passwordView.getUserName() );
		
		hidePasswordView();
	}
	
	// Views ============================================
	
	function showMainView():Void
	{
		var user:String = cookies.name;
		showUploadView( user );
		showMap();
		showGalleryView();
		Stats.trackPageview('/gallery.html','Gallery');
	}
	
	function hideMainView():Void
	{
		galleryView.destroy();
		dynamicElement.removeChild( galleryView.getView() ); 
		mapView.destroy();
		dynamicElement.removeChild( mapView.getView() ); 
		hideUploadView();
	}
		
	// Uploader ============================================
	function showUploadView( user:String ):Void
	{
		uploadView = new UploadView( doc, user, debug );
		uploadView.transcluded.addOnce( onTranscluded );
		uploadView.uploaded.add( onUploaded, this );
		uploadView.allLoaded.add( onAllUploaded );
		uploadView.initialise();
	}
	function hideUploadView() 
	{
		uploadView.destroy();
		dynamicElement.removeChild( uploadView.getView() ); 
	}
	
	// One image uploaded
	public function onUploaded( picture:Picture ):Void
	{
		galleryView.addLive( picture );
	}
	
	// Whole Queue uploaded!
	public function onAllUploaded( succeeded:Array<Int>, failed:Array<Int> ):Void
	{
		// dynamicElement.removeChild( uploadView.getView() ); 
		// rather than delete it, how bout we just minimise it?
		trace( 'completed : ' + succeeded.length +' success / ' + failed.length + ' failed' );
		// galleryView.quantity;
		if (failed.length > 0) Stats.trackEvent('upload', 'failed', failed.length+' items' );
	}
	
	// Thumbnails ===========================================
	function showGalleryView():Void
	{
		galleryView = new GalleryView( doc, debug );
		galleryView.transcluded.addOnce( onTranscluded );
		galleryView.located.add( onGPSImage );
		galleryView.injected.addOnce( onPictureInjected );
		galleryView.initialise();
	}

	function showGalleryShortcut():Void
	{
		// fetch ID from transcluded view and register it to this method
		var shortcut:Element = doc.getElementById("gallery-shortcut");  
		shortcut.onclick = function(event:Event)
		{
			untyped __js__("smoothScroll.animateScroll")( null, '#gallery' );
			event.preventDefault();
			return false;
		}
		
		// var anchor:String = "<a href='#gallery' id='gallery-shortcut' class='gallery--shortcut' data-scroll>Jump to Gallery</a>";
		// happens only ever once!
		body.className += ' not-empty';
	}
	
	// when images have loaded...
	public function onPictureInjected( images:Array<Picture> ):Void
	{
		if (!hasImages)
		{
			hasImages = true;
			showGalleryShortcut();
		}
	}
	
	// an image with GPS coords has been encountered
	public function onGPSImage( picture:Picture, div:DivElement ):Void
	{
		if (mapView != null)
		{
			//mapView.addMarker( picture.lat, picture.long );
			var message:String = picture.name+' by ' + picture.user;
			
			var onPress:Dynamic = "smoothScroll.animateScroll(null,#"+picture.uuid+",{ speed:600, updateURL: false, easing: 'easeOutCubic' });";
			var link:String = '<a href="#'+picture.uuid+'" onclick="'+onPress+'">'+ message +'</a>';
			mapView.addAssociation( picture.lat, picture.long, link, div );
			//trace('GPS Coords ',picture.lat, picture.long );
		}
	}
	
	// Map =================================================
	function showMap():Void
	{
		mapView = new MapView( doc );
		mapView.transcluded.addOnce( onTranscluded );
		mapView.initialise();
	}
	
	
	// Shared ===============================================
	
	// A View has been created and injected with Data!
	public function onTranscluded( view:View ):Void
	{
		// hide the loader class
		if ( !isLoaded )
		{
			isLoaded = true;
			dynamicElement.innerHTML = '';
			dynamicElement.setAttribute( 'aria-busy', 'false' );
		}
		switch( view.getView().className )
		{
			case "password":
				body.className = 'loaded '+'view-'+ view.getView().className;
			default:
				body.className = 'loaded '+' view-'+ view.getView().className ;
		}
		// Clean up a bit
		view.transcluded.dispose();
		//view.inject( dynamicElement );
		dynamicElement.appendChild( view.getView() );
	}
	
	
	
}