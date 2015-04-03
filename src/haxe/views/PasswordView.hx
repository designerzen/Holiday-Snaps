package views;

import haxe.Template;
import haxe.Http;

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

class PasswordView extends View
{
	var input:InputElement;
	var field:LabelElement;
	var button:ButtonElement;
	
	var attempts:Int = 0;
	
	public static inline var TEMPLATE = "sections/password.html";
	
	public function new( doc:Document, mediator:Mediator ) 
	{
		super( doc, mediator, "password" );
		proxy = mediator;
		loadTemplate( TEMPLATE );
	}

	// transclude this raw data into the DOM
	override function transclude( data:String ) :Void
	{
		// get this DOM element and fill it with our template...
		view.innerHTML = data;
		
		// now activate some of the parts
		var section:Element = doc.getElementById( 'password' );
		
		input = cast doc.getElementById('password-input');
		field = cast doc.getElementById('password-label');
		
		// Submit button
		button = cast doc.getElementById('password-submit');
		button.onclick = onSubmit;
		input.onkeyup = onKeyInputted;
	}
	
	function onKeyInputted( event:KeyboardEvent ):Void
	{
		// find out the key pressed...
		trace('Key:'+event.charCode);
	}
	
	function onSubmit( event:Event ):Void
	{
		/*
		if (false) 
		{
			proxy.onPassword( 'mango' );
			return;
		}
		*/
		// make sure that a password has been entered...
		field.textContent = "Checking...";  
		proxy.onPassword( input.value );
		attempts++;
	}
	
	public function onPasswordIncorrect():Void
	{
		field.textContent = "Please try again, attempt " + attempts;
		button.className = 'try-again';
	}
	
	public function destroy():Void
	{
		
		
	}
}


/*

package views;


import js.Lib;
import js.Browser;
import js.html.Document;
import js.html.DivElement;
import js.html.ButtonElement;
import js.html.InputElement;
import js.html.LabelElement;
import js.html.Event;

class PasswordView extends Component
{
	var input:InputElement;
	var field:LabelElement;
	var button:ButtonElement;
	var proxy:Mediator;
	var attempts:Int = 0;
	
	var debug:Bool = true;
		
	public function new( doc:Document, mediator:Mediator ) 
	{
		
		super( doc, "password" );
		proxy = mediator;
		
		input = doc.createInputElement();
		input.required = true;  
		input.type = 'password';  
		input.value = "Password";  
		input.className = "password-input";  
		
		field = doc.createLabelElement();
		field.textContent = "Enter your password";  
		field.className = "password-label";  
		
		// Submit button
		button = doc.createButtonElement();  
		button.textContent = "Continue";  
		button.className = "password-submit";  
		button.onclick = onSubmit;
		
		var fragments = doc.createDocumentFragment();  
		fragments.appendChild(input);
		fragments.appendChild(field);
		fragments.appendChild(button);
		
		// now add our fragments to the main view
		view.appendChild(fragments);
		
	}
	
	function onSubmit( event:Event ) 
	{
		
		if (debug) 
		{
			proxy.onPassword( 'mango' );
			return;
		}
		
		// make sure that a password has been entered...
		field.textContent = "Checking...";  
		proxy.onPassword( input.value );
		attempts++;
	}
	
	public function onPasswordIncorrect():Void
	{
		field.textContent = "Please try again, attempt "+attempts;
	}
	
	public function destroy():Void
	{
		
		
	}
}

*/