package controllers;

#if haxe_320
    import haxe.extern.Rest;
#end

// lazy but im stuck so meh  -> Void
typedef Listener = Dynamic;

@:native('signals.SignalBinding')
extern class SignalBinding
{
	// If binding is active and should be executed.
	public var active:Bool;

	// Context on which listener will be executed (object that should represent the this variable inside listener function).
	// {Object | undefined | null } 
	public var context:Dynamic;
	
	// Default parameters passed to listener during Signal.dispatch and SignalBinding.execute. (curried parameters)
	// {Array|null} params
	public var params:Array<Dynamic>;
	
	/*
	Detach binding from signal. - alias to: mySignal.remove(myBinding.getListener());

	Returns:
		{Function|null} Handler function bound to the signal or `null` if binding was previously detached.
	*/
	public function detach():Listener;
	
	/*
	execute(paramsArr)
	Call listener passing arbitrary parameters.

	If binding was added using `Signal.addOnce()` it will be automatically removed from signal dispatch queue, this method is used internally for the signal dispatch.

	Parameters:
		{Array} paramsArr Optional
		Array of parameters that should be passed to the listener
		Returns:
		{*} Value returned by the listener.
	*/
	public function execute( paramaters:Array<Dynamic> ):Dynamic;

	// {Function} Handler function bound to the signal.
	public function getListener():Listener;

	// Signal that listener is currently bound to.
	public function getSignal():Signal;

	// true if binding is still bound to the signal and have a listener.
	public function isBound():Bool;

	// If SignalBinding will only be executed once.
	public function isOnce():Bool;

	// String representation of the object.
	public function toString():String;
}


@:native('signals.Signal')
extern class Signal
{
	public function new():Void;
	
	// If Signal is active and should broadcast events.
	// IMPORTANT: Setting this property during a dispatch will only affect the next dispatch, if you want to stop the propagation of a signal use `halt()` instead.
	public var active:Bool;
	
	//If Signal should keep record of previously dispatched parameters and automatically execute listener during add()/addOnce() if Signal was already dispatched before.
	public var memorize:Bool;
	
	// Signals Version Number
	public var VERSION:String;
	
	/*
	Add a listener to the signal.
	
	Parameters:
		{Function} listener
		Signal handler function.
		
		{Object} listenerContext Optional
		Context on which listener will be executed (object that should represent the `this` variable inside listener function).
		
		{Number} priority Optional
		The priority level of the event listener. Listeners with higher priority will be executed before listeners with lower priority. Listeners with same priority level will be executed at the same order as they were added. (default = 0)
	*/
	public function add( listener:Listener, ?context:Dynamic, ?priority:Float ):SignalBinding;

	
	/*
	Add listener to the signal that should be removed after first execution (will be executed only once).

	Parameters:
		{Function} listener
		Signal handler function.
		
		{Object} listenerContext Optional
		Context on which listener will be executed (object that should represent the `this` variable inside listener function).
		
		{Number} priority Optional
		The priority level of the event listener. Listeners with higher priority will be executed before listeners with lower priority. Listeners with same priority level will be executed at the same order as they were added. (default = 0)
	*/
	public function addOnce( listener:Listener, ?context:Dynamic, ?priority:Float ):SignalBinding;
	
	/*
	Dispatch/Broadcast Signal to all listeners added to the queue.

	Parameters:
		{...*} params Optional
		Parameters that should be passed to each handler.
	*/
	#if haxe_320
		public function dispatch( rest:Rest<Dynamic> ):Void;
	#else
		@:overload(function(a1:Dynamic, a2:Dynamic, a3:Dynamic, a4:Dynamic):Void {})
		@:overload(function(a1:Dynamic, a2:Dynamic, a3:Dynamic):Void {})
		@:overload(function(a1:Dynamic, a2:Dynamic):Void {})
		@:overload(function(a1:Dynamic):Void {})
		public function dispatch( ):Void;
	#end
	
	
	/*
	Remove all bindings from signal and destroy any reference to external objects (destroy Signal object).
	IMPORTANT: calling any method on the signal instance after calling dispose will throw errors.
	*/
	public function dispose():Void;
	
	
	/*
	Forget memorized arguments.
	See: Signal.memorize
	*/
	public function forget():Void;
	
	
	// Returns: Number of listeners attached to the Signal.
	public function getNumListeners():Int;
	
	
	/*
	Stop propagation of the event, blocking the dispatch to next listeners on the queue.
	IMPORTANT: should be called only during signal dispatch, calling it before/after dispatch won't affect signal broadcast.

	See:
	Signal.prototype.disable
	*/
	public function halt():Void;
	
	
	/*
	Check if listener was attached to Signal.

	Parameters:
		listener
		context Optional
	Returns:
		{boolean} if Signal has the specified listener.
	
	*/
	public function has(listener:Listener, context:Dynamic ):Bool;

	
	/*
	Remove a single listener from the dispatch queue.

	Parameters:
		Handler function that should be removed.
		Execution context (since you can add the same handler multiple times if executing in a different context).

	*/
	public function remove(listener:Listener, context:Dynamic ):Listener;

	
	// Remove all listeners from the Signal.
	public function removeAll():Void;

	
	// String representation of the object.
	public function toString():String;
}