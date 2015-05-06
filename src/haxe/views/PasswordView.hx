package views;

import haxe.Http;
import js.html.ParagraphElement;

import js.Lib;
import js.Browser;
import js.html.Document;
import js.html.Element;
import js.html.DivElement;
import js.html.ButtonElement;
import js.html.InputElement;
import js.html.LabelElement;
import js.html.Event;
import js.html.KeyboardEvent;

import models.Cookies;

import controllers.EventHandler;
import controllers.Signals.Signal;

class PasswordView extends View
{
	var passwordInput:InputElement;
	var nameInput:InputElement;
	var nameLabel:LabelElement;
	var passwordLabel:LabelElement;
	var checkBox:InputElement;
	var button:ButtonElement;
	var section:Element;
	var errorParagraph:ParagraphElement;
	var cookies:Cookies;
	
	var attempts:Int = 0;
	
	public var passwordReceived:Signal = new Signal();
	
	public static inline var TEMPLATE = "sections/password.html";
	
	public function new( doc:Document, cookie:Cookies ) 
	{
		super( doc, null, "password" );
		cookies = cookie;
	}
	
	override public function initialise() 
	{
		super.initialise();
		// check if cookie exists! If not, or it has expired...
		loadTemplate( TEMPLATE );
	}
	
	public function getRememberOption():Bool 
	{
		return checkBox.checked;
	}
	public function getUserName():String 
	{
		//  make sure it is NOT an email
		var parts:Array<String> = nameInput.value.split('@');
		return parts[0];
	}

	/////////////////////////////////////////////////////////////////////
	// transclude this raw data into the DOM
	/////////////////////////////////////////////////////////////////////
	override function transclude( data:String ) :Void
	{
		// get this DOM element and fill it with our template...
		super.transclude( data );
		
		// now activate some of the parts
		section = doc.getElementById( 'password' );
		
		passwordInput = cast doc.getElementById('password-input');
		passwordInput.focus();
		
		passwordLabel = cast doc.getElementById('password-label');
		errorParagraph = cast doc.getElementById('login-error');
		
		nameInput = cast doc.getElementById('name-input');
		if ( cookies.name.length > 0 ) nameInput.value = cookies.name;
		nameLabel = cast doc.getElementById('name-label');
		
		checkBox = cast doc.getElementById('login-checkbox');
		
		// Submit button
		button = cast doc.getElementById('password-submit');
		button.onclick = onSubmit;
		
		// Browser.document.onkeyup = onKeyInputted;
		EventHandler.attach( 'keyup', doc, onKeyInputted);
	}
	
	/////////////////////////////////////////////////////////////////////
	// EVENT : Key has been pressed & released
	/////////////////////////////////////////////////////////////////////
	public function onKeyInputted( event:KeyboardEvent ):Void
	{
		// find out the key pressed...
		switch ( event.keyIdentifier )
		{
			case 'Enter' :
				onSubmit( null );
				event.preventDefault();
		}
	}
	
	/////////////////////////////////////////////////////////////////////
	// EVENT : 
	// - Submit Button has been pressed
	// - Key ENTER has been pressed and released
	/////////////////////////////////////////////////////////////////////
	function onSubmit( event:Event ):Void
	{
		// prevent JS submitting the form
		if (event != null) event.preventDefault();
		
		// make sure that a password has been entered...
		if ( nameInput.value.length < 2 ) 
		{
			nameLabel.textContent = "Please enter your name!";  
			nameLabel.focus();
			
		}else if ( passwordInput.value.length < 2 ) {
			
			passwordLabel.textContent = "Please enter a password before clicking the button!"; 
			passwordInput.focus();
			
		}else {
			
			section.className = 'checking';
			passwordLabel.textContent = "Checking...";  
			
			// send out an event
			passwordReceived.dispatch( passwordInput.value );
			
			attempts++;			
		}
	}
	
	public function onPasswordIncorrect():Void
	{
		var copy:Array<String> = [
			"Sorry, this password is not correct. Please try again",
			"Sorry, this password is not correct. Please try again, attempt " + attempts,
			"Sorry, still incorrect : Password Hint - A good looking guy" ,
			"You have tried " + attempts + " times, you have one last try"
		];
		
		if (attempts < copy.length )
		{
			passwordLabel.textContent = copy[ attempts ];
			//section.className = 'try-again';
			passwordInput.focus();
			Browser.window.setTimeout( onTimeOut, 100 );
		}else {
			passwordLabel.textContent = "Sorry, the password isn't that!";
			//section.className = 'disabled';
			
			errorParagraph.innerHTML = "It seems you are having problems. Use a short name perhaps?";
		}
		
	}	
	// Animate html
	public function onTimeOut():Void
	{
		section.className = 'try-again';
	}
	
	// Kill & Clean up
	override public function destroy():Void
	{
		passwordReceived.removeAll();
		EventHandler.detach( 'keyup', Browser.document, onKeyInputted );
	}
	
}