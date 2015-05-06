package views;

import controllers.EventHandler;
import js.html.AnchorElement;
import js.html.DocumentFragment;
import js.html.Element;
import js.html.Event;
import models.Picture;
import views.elements.MagnifyingGlass;
import controllers.Signals.Signal;

import js.html.Document;

class FullScreenView extends Component
{
	public static inline var DIV_ID_FULL_SIZE:String 	= "gallery-full-size";
	
	public var opened:Bool = false;
	
	var magnifyingGlass:MagnifyingGlass;
	var exitted:Signal;
	var fullSizeElement:Element;
	
	public function new(document:Document) 
	{
		super(document, 'fullscreen');
		
		exitted = new Signal();
		
		fullSizeElement = doc.getElementById( DIV_ID_FULL_SIZE );
		
		var exitBackgroundButton:AnchorElement = doc.createAnchorElement();
		var exitButton:AnchorElement = doc.createAnchorElement();
		var fragments:DocumentFragment = doc.createDocumentFragment();
		
		var onExit = function(event:Event)
		{
			event.preventDefault();
			exitted.dispatch();
			exitBackgroundButton.onclick = null;
			exitButton.onclick = null;
			return false;
		};
		
		// This exit button
		exitBackgroundButton.className 			= 'fs-exit';
		exitBackgroundButton.textContent 		= 'Close';
		exitBackgroundButton.onclick 			= onExit;
		fragments.appendChild( exitBackgroundButton );
		
		
		// This exit button
		exitButton.className 			= 'exit';
		exitButton.textContent 			= 'Close';
		exitButton.title 				= 'Close this image and go back to gallery';
		exitButton.onclick 				= onExit;
		fragments.appendChild( exitButton );
		
		openedImage = doc.createImageElement();
		fragments.appendChild( openedImage );
		
		view.appendChild( fragments );
	}
	
	
	public function show( picture:Picture ):Void
	{
		var i:String = '';
		var fullName:String = picture.name + " taken by " + picture.user;
		
		//"<img id='"+id+"' class='fs' src='"+fullSizeURL+"' alt='"+name+"' >";	
		i += "<a class='download' title='Download "+fullName+"' href='"+picture.downloadService+"'>Download "+fullName+"</a>";
		
		openedImage.id = id;
		openedImage.className = 'fs';
		openedImage.alt = fullName;
		
		if ( magnifyingGlass == null ) magnifyingGlass = new MagnifyingGlass( doc, openedImage, picture.width, picture.height );
		else magnifyingGlass.setImage(openedImage, picture.width, picture.height );
		
		exitBackgroundButton.href 		= '#' + openedImage.id;
		exitButton.href 				= '#' + openedImage.id;
		
		openedImage.src = fullSizeURL;
		
		// scroll to element
		var scrollOptions:Dynamic = { speed: 100, easing: 'easeOutCubic' };
		untyped __js__("smoothScroll.animateScroll")( null, '#' + div.id, scrollOptions );
		
		opened = true;
		
		fullSizeElement.style.display = "block";
		//EventHandler.attach( 'keydown', doc, onKeyInputted);
	}
	
	public function hide():Void
	{
		magnifyingGlass.hide();
		
		// rescroll to element
		var options:Dynamic = { speed: 600, easing: 'easeOutCubic' };
		untyped __js__("smoothScroll.animateScroll")( null, '#' + openedImage.id, options );
		
		opened = false;
		
		fullSizeElement.style.display = "none";
		
		//EventHandler.detach( 'keydown', doc, onKeyInputted);
	}
}