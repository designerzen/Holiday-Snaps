package models;

import js.html.DivElement;

typedef Picture = {
	
	var success:Bool;
	var uuid:String;
	var type:Int;
	var uploadName:String;
	var user:String;
	
	var width:Int;
	var height:Int;
	
	var originalWidth:Int;
	var originalHeight:Int;
	
	var lat:Float;
	var long:Float;
	
	var resized:Bool;
	
	// injected dynamically
	var element:DivElement;
	var name:String;
	var fullSizeURL:String;
	var thumbnailURL:String;
	var downloadService:String;
		
	var tags:Array<String>;
}