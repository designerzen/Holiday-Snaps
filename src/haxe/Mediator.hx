/*

	1. A Password (hard coded and specific to site - mango)
	2. Photos homepage with an Add Your Photos / Videos button at the bottom
	3. Upload page with name at the top, then a drag-n-drop ui for adding photos, upload button at bottom
	4. Tags / Locations / Exif data etc done on server side

*/

package;

import views.PasswordView;
import views.UploadView;
import views.GalleryView;
//import views.Upload;

import js.Lib;
import js.Browser;
import js.html.Document;
import js.html.Element;

class Mediator
{
	// Different State Based Views
	var passwordView:PasswordView;
	var uploadView:UploadView;
	var galleryView:GalleryView;
	
	var doc:Document = Browser.document;  
	var body:Element;
	var dynamicElement:Element;
	
	var dynamicID:String = 'qq-template';
	
	public function new() 
	{
		/*
		// track some page views
        Stats.trackPageview('/page.html','Page Title!');
        Stats.trackPageview('/untitled.html');

        // track some events
        Stats.trackEvent('play','stage-1/level-3','begin');
        Stats.trackEvent('play', 'stage-2/level-4', 'win');
		*/
		
		// fetch and set the DOM elements where our application is
		// injected into to prepare it for transclusions
		body = doc.body;
		dynamicElement = doc.getElementById( dynamicID );
		dynamicElement = body;
		
		// first, hide the loader class
		body.className = 'loaded';
		
		// secondly display the password selector (pass in document)
		//showPasswordView();
		showUploadView();
	}
	
	// Password ============================================
	function showPasswordView():Void
	{
		passwordView = new PasswordView( doc, this );
		// add the view to the screen...
		dynamicElement.appendChild( passwordView.getView() ); 
	}
	
	// see when the button was pressed...
	public function onPassword( password:String ):Void
	{
		trace(password);
		if (password != "mango")
		{
			passwordView.onPasswordIncorrect();
			
		} else {
			
			// now remove from the screen...
			dynamicElement.removeChild( passwordView.getView() ); 
			passwordView.destroy();
			
			// now show the next view!
			showUploadView();
		}
	}
	
	// Uploader ============================================
	function showUploadView():Void
	{
		uploadView = new UploadView( doc, this );
		
		// add the view to the screen...
		dynamicElement.appendChild( uploadView.getView() ); 
	}
	
	public function onUploaded( ):Void
	{
		dynamicElement.removeChild( uploadView.getView() ); 
		showGalleryView();
	}
	
	// Thumbnails ===========================================
	function showGalleryView():Void
	{
		galleryView = new GalleryView( doc, this );
		
		// add the view to the screen...
		dynamicElement.appendChild( galleryView.getView() ); 
	}
	
	// upload vie is no longer needed
	public function onExit( quantityUploaded:Int ):Void
	{
		dynamicElement.removeChild( galleryView.getView() ); 
	}
	
}