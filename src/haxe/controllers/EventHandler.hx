package controllers;

import js.html.Element;
import js.html.Event;
import js.html.EventTarget;

// This is the bridge to Event.js by Mark Rolich - https://github.com/mark-rolich/Event.js

@:native('Event')
extern class EventExtern
{
	public function new():Void;
	
	/*
	The first parameter is event name, one of the "mousedown", "click", "mouseover" etc.
	
	The second is DOM element attached to event.

	The third is listener which will be executed when event will occur.
	Listener receives two parameters: e (event object) and src (DOM element).

	The last parameter is boolean telling to use event capturing (true - default) or bubbling (false)
	*/
	public function attach(evtName:String, element:EventTarget, listener:Dynamic, ?capture:Bool ):Dynamic;
    public function detach(evtName:String, element:EventTarget, listener:Dynamic, ?capture:Bool ):Void;

    public function stop(evt:Event):Void;
    
    public function prevent(evt:Event):Void; 
}

// A static method of interacting with the Event Class
// Simply contains one statically instantiated version of Event with exposed public methods
class EventHandler
{
	public static var instance:EventExtern = new EventExtern();
	
	public static function attach(evtName:String, element:EventTarget, listener:Dynamic, ?capture:Bool ):Dynamic
	{
		return instance.attach(evtName, element, listener, capture );
	}
	
    public static function detach(evtName:String, element:EventTarget, listener:Dynamic, ?capture:Bool ):Void
	{
		return instance.detach(evtName, element, listener, capture );
	}
}