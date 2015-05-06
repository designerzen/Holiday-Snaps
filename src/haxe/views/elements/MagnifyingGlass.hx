package views.elements;

import js.html.ClientRect;
import js.html.DivElement;
import js.html.Element;
import js.html.ImageElement;
import js.html.Document;
import js.html.CSSStyleDeclaration;
import js.html.Event;
import js.html.MouseEvent;
import js.Browser;
import js.html.ParagraphElement;

import views.Component;
import controllers.EventHandler;
/*

Feed this an image and the full sized image dimensions
a DIV will be created with the background set to the image URL
at 100% full size (or zoom size)

The zoom is then a mathematically chosen background-position

*/
class MagnifyingGlass extends Component
{
	var openedImage:ImageElement;
	var style:CSSStyleDeclaration;
	
	var size:Float = 300;
	var halfSize:Float = 150; //200 / 2;
	
	var smallWidth:Int;
	var smallHeight:Int;
	
	var largeWidth:Int;
	var largeHeight:Int;
	
	var debug:Bool = false;
	var debugText:ParagraphElement;
	
	public var zoom( get_zoom, set_zoom ):Float;
	function get_zoom ():Float { return size; }
	function set_zoom ( value:Float ):Float 
	{ 
		size = value;
		halfSize = size / 2;
		
		style.width 			= size+"px";
		style.height 			= size+"px";
		style.marginLeft		= "-"+halfSize+"px";
		style.marginTop			= "-" + halfSize+"px";
		
		return size; 
	}

	public function new( document:Document, debugMode:Bool=false ) 
	{
		super( document , 'magnifier' );
		style = view.style;
		if ( debugMode )
		{
			debug = true;
			debugText = doc.createParagraphElement();
			debugText.className = 'debug';
			view.appendChild( debugText );
		}
		
		zoom = size;
		
		//setImage( image, pictureWidth, pictureHeight );
		hide( );
	}
	
	public function setImage( image:ImageElement, pictureWidth:Int, pictureHeight:Int ):Void
	{
		// detach events if new image...
		if ( openedImage != image )
		{
			openedImage = image;
			var updateImage = function( event:Event ) :Void
			{
				// fetch height and width...
				trace('Magnifier loaded image ');
				
				smallWidth = openedImage.width;
				smallHeight = openedImage.height;
				
				largeWidth = openedImage.naturalWidth;
				largeHeight = openedImage.naturalHeight;
				
				style.background 		= 'url("' + image.src +'") no-repeat';
				openedImage.className = 'loaded';
			};
			if ( openedImage.complete ) updateImage(null);
			else openedImage.onload = updateImage;
		}
		enable();
	}
	
	function update( event:MouseEvent ):Void
	{
		var x:Int = event.x;
		var y:Int = event.y;
		
		// GAH! x and y contain the margin or flex spacing!
		// such as margins and shit sadly
		var box:ClientRect = openedImage.getBoundingClientRect();
		
		var imageX:Float = event.x - box.left;
		var imageY:Float = event.y - box.top;
		
		//update( event.x, event.y );
		//update( event.clientX, event.clientY );
		// update( event.movementX, event.movementY );
		//update( event.offsetX, event.offsetY );
		
		// fetch dimensions of the small version...
		//var percentageX:Float = imageX / openedImage.width;
		//var percentageY:Float = imageY / openedImage.height;
		var percentageX:Float = imageX / box.width;
		var percentageY:Float = imageY / box.height;
		
		//var ratioX:Float = openedImage.naturalWidth / openedImage.width;
		//var ratioY:Float = openedImage.naturalHeight / openedImage.height;
		
		//var offsetX:Float = halfSize * ratioX;
		//var offsetY:Float = halfSize * ratioY;
		
		//var destinationX:Float = (percentageX * (openedImage.naturalWidth - openedImage.width ));// - halfSize;
		//var destinationY:Float = (percentageY * (openedImage.naturalHeight - openedImage.height));// - halfSize;
		
		//var destinationX:Float = (percentageX * (openedImage.naturalWidth - size ));// - halfSize;
		//var destinationY:Float = (percentageY * (openedImage.naturalHeight - size));// - halfSize;
	
		var destinationX:Float = (percentageX * (largeWidth - size ));
		var destinationY:Float = (percentageY * (largeHeight - size));
		
		style.backgroundPosition = '-'+destinationX+'px -'+destinationY+'px';
		
		style.left = (x)+ 'px';
		//style.left = (x - halfSize)+ 'px';
		style.top = (y)+ 'px';
		//style.top = (y - halfSize)+ 'px';
		
		if ( debug )
		{
			//Browser.window.console.error( x, y, box );
			debugText.innerHTML = 'x:'+Std.int( percentageX * 100) + '%' +' y:'+ Std.int( percentageY * 100) + '%';
		}
		
	}
	
	public function enable():Void
	{
		//EventHandler.attach( 'mousedown', openedImage, onFullSizeImageMouseDown );
		EventHandler.attach( 'mousemove', openedImage, onFullSizeImageMouseMove );
		EventHandler.attach( 'mouseover', openedImage, onFullSizeImageMouseDown );
		EventHandler.attach( 'mouseout', openedImage, onFullSizeImageMouseUp );	
		EventHandler.attach( 'mousewheel', openedImage, onFullSizeImageMouseWheel );
	}
	
	public function disable():Void
	{
		if (openedImage != null) openedImage.className = '';
		
		EventHandler.detach( 'mousemove', openedImage, onDocumentImageMouseMove );
		EventHandler.detach( 'mouseover', openedImage, onFullSizeImageMouseDown );
		EventHandler.detach( 'mouseout', openedImage, onFullSizeImageMouseUp );
		EventHandler.detach( 'mousewheel', openedImage, onFullSizeImageMouseWheel );	
	}
	
	public function show():Void
	{
		style.display = 'block';
	}
	public function hide(  ):Void
	{
		style.display = 'none';
	}
	
	// == Events ==
	public function onFullSizeImageMouseMove( event:MouseEvent ):Void
	{
		// event.x does *not* factor in some of the variations
		// such as margins and shit sadly
		update( event );
	}
	
	public function onDocumentImageMouseMove( event:MouseEvent ):Void
	{
		// this is for outside the area! cripes!
	}
	
	public function onFullSizeImageMouseWheel( event ):Void
	{
		var quantity:Float =  (event.wheelDelta > 0 || event.detail < 0) ? 1 : -1;
		zoom += quantity;
		
		onFullSizeImageMouseMove( cast event );
		
		// may have to disable ...
		event.preventDefault();
	}
	
	public function onFullSizeImageMouseDown( event:MouseEvent ):Void
	{
		//trace('mouse over fs');
		show();
	}
	
	public function onFullSizeImageMouseUp( event:MouseEvent ):Void
	{
		//trace('mouse out fs');
		hide();
	}
}