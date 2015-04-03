package views;

import js.html.DivElement;
import js.html.Document;

class Component
{
	var view:DivElement;
	var doc:Document;
	
	public function new( document:Document , className:String ) 
	{
		//super();
		doc = document;
		view = doc.createDivElement();
		view.className = className;  
	}
	
	public function getView():DivElement
	{
		return view;
	}
}