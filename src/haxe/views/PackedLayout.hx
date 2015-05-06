package views;

import controllers.RectanglePacker;
import models.Picture;
import models.IntegerRectangle;

class PackedLayout
{
	var packer:RectanglePacker;
	var connections:Array<Picture>
	
	public function new(width:Int, height:Int, padding:Int = 0) 
	{
		packer = new RectanglePacker( width, height, padding );
	}
	
	// Here we add as many known sized rectangles as we need
	// Here you add a picture typedef
	public function addSingle( picture:Picture, i:Int ):Void
	{
		packer.insertRectangle( picture.width, picture.height, i );
		connections.push( picture );
	}
	
	// Add multiple pictures to the system via a big loop
	public function add( pictures:Array<Picture> ):Void
	{
		for ( i in 0...pictures.length )
		{
			var picture:Picture = pictures[ i ];
			packer.insertRectangle( picture.width, picture.height, i );
			connections.push( picture );
		}
	}
	
	public function pack():Array<Picture>
	{
		// now repack the rectangles...
		packer.packRectangles();
		
		var output:Array<Picture> = [];
		
		var quantity:Int = packer.rectangleCount;
		var rectangles:Array<IntegerRectangle> = packer.rectangles;
		for ( i in 0...quantity )
		{
			// here i represents the horizontal position
			var rect:IntegerRectangle = packer.getRectangle(i, rect);
			// and p represents the original position in connections
			var p:Int = rect.id;
			var picture:Picture = connections[ p ];
			
			output[i] = picture;
		}
		
		// after packing you get an array of ordered rectangles where each one is 
		// specific to an ID that is unique to an arbitrary bit of data...
		return output;
	}
	
	
	public function resize( width:Int, height:Int, padding:Int = 0):Void
	{
		packer.reset( width, height, padding );
		pack();
	}
}