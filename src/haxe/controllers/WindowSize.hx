package controllers;

import js.Browser;
import js.html.Event;

import controllers.EventHandler;


class WindowSize
{

	public function new() 
	{
		/*
		Browser.window.onresize = onResize;
		*/
		// test for events
		EventHandler.attach( 'resize', Browser.window, onResize);
	}
	
	function onResize(event:Event):Void
	{
		trace('resized ', WindowSize.getWidth(), WindowSize.getHeight() );
	}
	
	public static function getWidth():Int
	{
		return Browser.window.innerWidth ;// || Browser.document.body.offsetWidth;
	}
	
	public static function getHeight():Int
	{
		return Browser.window.innerHeight ;// || Browser.document.body.offsetHeight;
	}
	
	public static function isLandscape():Bool
	{
		return WindowSize.getHeight() < WindowSize.getWidth();
	}
	
}