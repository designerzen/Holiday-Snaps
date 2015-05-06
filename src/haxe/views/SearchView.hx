package views;

import js.html.Document;

import models.Picture;

class SearchView extends View
{
	var images:Array<Picture>;
	
	public function new(document:Document, mediator:Mediator, pictures:Array<Picture> ) 
	{
		super(document, mediator,'search');
		// as each picture has it's own ID set as the UUID,
		// this class simply searches the JSON file and returns the uuid of 
		// any picture that matches the search criteria
		// only searches for file names!
		setData();
	}
	
	public function setData( pictures:Array<Picture> ):Void
	{
		images = pictures;
	}
	
		/*
		// update the view accordingly...
		var sample:String = "My name is <strong>::name::</strong>, <em>::age::</em> years old";
		var user = {name:"Mark", age:30};
		var template:Template = new Template(sample);
		var output:String = template.execute(user);
		//trace(data);
		//trace(output);
		*/
		
		//var div:DivElement = doc.createDivElement();
	// TO SHOW SEARCH RESULTS...
	// simply loop through *all* of the images and add a 
	// 'hidden' class to those nor in thr array...
	public function search( term:String ):Array<String>
	{
		var output:Array<String> = [];
		// loop through all items...
		for ( image in images )
		{
			if ( image.uploadName.indexOf( term ) > -1 )
			{
				output.push( image.uuid ); 
			}
		}
		return output;
	}
}