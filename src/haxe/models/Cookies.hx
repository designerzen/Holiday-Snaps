package models;


import js.Cookie;

class Cookies
{
	//public static var instance:Cookies = new Cookies();
	public static inline var COOKIE_NAME = "cubancookiecollectives";
	
	public var good:Bool = false;
	public var skip:Bool = false;
	public var name:String = '';
	public var duration:Int =  60 * 60 * 24 * 30;

	public function new() 
	{
		load();
	}
	
	public function load():Void
	{
		// Simply a | seperated list of things
		// skip | username
		if ( Cookie.exists(COOKIE_NAME) )
		{
			// check validity
			var cookie = Cookie.get(COOKIE_NAME);
			var parts:Array<String> = cookie.split('|');
			// check values!
			for ( part in parts )
			{
				switch( part )
				{
					case '_skip_':
						skip = true;
					default:
						name = part;
				}
			}
			if ( name.length > 0 ) good = true;	// set good
		}
	}
	
	public function save() :Void
	{
		var output:String = skip ? '_skip_|'+name : name;
		Cookie.set( COOKIE_NAME, output, duration );	
	}
	
	public function kill():Void
	{
		Cookie.remove( COOKIE_NAME );
	}
}