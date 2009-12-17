package de.karfau.signals
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	import org.osflash.signals.DeluxeSignal;
	import org.osflash.signals.ISignal;
	
	public class PropertyRelaySignal extends DeluxeSignal
	{
		/* START (modified) COPY FROM NativeRelySignal*/
		protected var _eventType:String; //equates _name in NativeRelaySignal
		/* END (modified) COPY FROM NativeRelySignal*/
		
		protected var _eventClass:Class;
		protected var properties:Array;
		
		public function PropertyRelaySignal (target:IEventDispatcher, eventType:String, eventClass:Class=null, properties:Array=null) {
			
			/* START (modified) COPY FROM NativeRelySignal*/
			_eventType = eventType;
			_eventClass = eventClass || Event;
			super(target);
			/* END (modified) COPY FROM NativeRelySignal*/
			
			this.properties = [];
			
			if (properties) {
				var dt:XML = describeType(eventClass);
				var accessor:XML;
				for each (var prop:String in properties) {
					accessor = (dt..accessor.(@name == prop))[0];
					if (accessor != null) {
						this.properties.push(prop);
						_valueClasses.push(getDefinitionByName(accessor.@type) as Class);
					} else {
						throw new ArgumentError('Invalid properties argument: property "' + prop
																		+ '" not found in ' + _eventClass + '.');
					}
				}
			}
		
		}
		
		override public function dispatch (... valueObjects):void {
			if (valueObjects.length == 1 && valueObjects[0] is _eventClass) {
				var propArgs:Array = [];
				var event:* = valueObjects[0] as _eventClass;
				for each (var prop:String in properties) {
					propArgs.push(event[prop]);
				}
				super.dispatch.apply(null, propArgs);
			} else {
				super.dispatch.apply(null, valueObjects);
			}
		}
		
		/**
		 * Setting this value with a new value will remove the eventListener from the old target and add it to the new one.
		 * NOTE: at the moment u will loose the priority that was set and the new priority will be 0.
		 *
		 * @see DeluxeSignal
		 */
		override public function set target (value:Object):void {
			if (value == _target)
				return;
			
			//move listeners
			//we need to get the highest priority (would it get lost else?)
			//var prio:int = 0;
			//for (var i:int = listeners.length; i >= 0; i--) {
			//	prio = Math.max(prio, listeners[i].priority);
			//}
			/* START (modified) COPY FROM NativeRelySignal*/
			IEventDispatcher(_target).removeEventListener(_eventType, dispatch);
			/* END (modified) COPY FROM NativeRelySignal*/
			
			IEventDispatcher(value).addEventListener(_eventType, dispatch, false, 0);
			_target = value;
		}
		
		/* START COPY FROM NativeRelySignal*/ /** @inheritDoc */
		override public function add (listener:Function, priority:int=0):void {
			var prevListenerCount:uint = listeners.length;
			// Try to add first because it may throw an exception.
			super.add(listener);
			// Account for cases where the same listener is added twice.
			if (prevListenerCount == 0 && listeners.length == 1)
				IEventDispatcher(_target).addEventListener(_eventType, dispatch, false, priority);
		}
		
		/** @inheritDoc */
		override public function addOnce (listener:Function, priority:int=0):void {
			var prevListenerCount:uint = listeners.length;
			// Try to add first because it may throw an exception.
			super.addOnce(listener);
			// Account for cases where the same listener is added twice.
			if (prevListenerCount == 0 && listeners.length == 1)
				IEventDispatcher(target).addEventListener(_eventType, dispatch, false, priority);
		}
		
		/** @inheritDoc */
		override public function remove (listener:Function):void {
			var prevListenerCount:uint = listeners.length;
			super.remove(listener);
			if (prevListenerCount == 1 && listeners.length == 0)
				IEventDispatcher(_target).removeEventListener(_eventType, dispatch);
		}
	/* END COPY FROM NativeRelySignal*/
	}
}