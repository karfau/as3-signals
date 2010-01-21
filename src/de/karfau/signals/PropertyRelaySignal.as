package de.karfau.signals
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import org.osflash.signals.natives.NativeRelaySignal;
	
	/**
	 * This class dispatches properties of the related event instead of the whole event,
	 * so that the event can be hidden completely from the listeners.
	 *
	 * @author Karfau
	 */
	public class PropertyRelaySignal extends NativeRelaySignal
	{
		
		/**
		 * @default is initialized to flash.events.Event in constructor if omitted as parameter.
		 */
		protected var _eventClass:Class;
		
		/**
		 *
		 * @param target The IEventDispatcher that dispatches this event to filter the properties from.
		 * @param eventType The type of the event that this signal will attach to taget as as a listener for.
		 * @param eventClass The event-class that target will dispatch when dispatching an evet of type <code>eventType</code>.
		 * Defaults to flash.events.Event if omitted as target is an IEventDispatcher.
		 * @param propertyTypes types of the values that this signal will dispatch to its listeners
		 */
		public function PropertyRelaySignal (target:IEventDispatcher, eventType:String, eventClass:Class=null, ... propertyTypes) {
			
			/*We keep this class but it is not our valueClass.*/
			_eventClass = eventClass || Event;
			
			/*I want to use the super-contructor,
				 but the implicit call of setValueClasses(Event) will only be temporarily,
			 instead we want the valueClasses given as parameter in this constructor*/
			super(target, eventType);
			
			/*if valueClasses are not provided this will call the listeners with no parameter*/
			setValueClasses(valueClasses);
		
		}
		
		private var _propertyFilterFunction:Function = null;
		
		/*open for extension but closed for modifications*/
		protected function get propertyFilterFunction ():Function {
			return _propertyFilterFunction;
		}
		
		/**
		 *
		 * @param value
		 * @param checkValidityWithInitialCall
		 * @throws ArgumentError
		 * @throws ArgumentError
		 * @throws ArgumentError
		 */
		public function setPropertyFilterFunction (value:Function, checkValidityWithInitialCall:Boolean=true):void {
			if (value != null) {
				if (value.length != 1) {
					throw new ArgumentError("propertyFilterFunction needs to have exactly one parameter of type <" + this._eventClass +
																	"> but has " + value.length + "parameters.");
						//" Correct syntax is 'function [name] (event:[eventClass provided in constructor or flash.events.Event]):Array'.");
				}
				
				/*the benefit of calling it here is that we can validate the type of the parameter the function has fits
					 and we can match the length of the returned array to the length of valueClasses,
					 wich will result in an ArgumentError as soon as the signal is set up.
					 (We can not validate the returned types as the values will most likly be null)
					 Cases where this need to be surpressed:
					 - _eventClass has no zero-parameter-constructor
					 - value does processing of anything else then the given object, wich raises an error at the time the function is set
				 - did I miss something?*/
				if (checkValidityWithInitialCall) {
					try {
						var testResult:Array = value.call(null, new _eventClass());
						if (valueClasses.length > 0 && testResult.length != valueClasses.length) {
							throw new ArgumentError("calling propertyFilterFunction initially returned an array with a length of " + testResult.length +
																			" but was expected to return an array with this length an types as in valueClasses:[" + valueClasses + "]");
							
						}
					} catch (error:Error) {
						throw new ArgumentError("calling propertyFilterFunction initially raised the following Error: <" + error +
																		"> the initial call can be supressed by using 'setPropertyFilterFunction(yourFunction,false);'. Read the docs before doing this!");
						
					}
				} else {
					trace(this + ".setPropertyFilterFunction(...) supressed the initial call of its given value.");
				}
				
				_propertyFilterFunction = value;
			}
		}
		
		/**
		 * For usage without extension, instances of <code>PropertyRelaySignal</code> that are dispatching any values ( <code>valueClasses.length > 0</code> ),
		 * needs to be provided with a function with the follwing syntax:
		 * <code>function [name] (event:[eventClass provided in constructor or flash.events.Event]):Array</code>
		 * See <code>setPropertyFilterFunction</code> for more infos.
		 * Subcclasses could override this one instead of letting the environment set the propertyFilterFunction,
		 * MAKE SURE to also override <code>setPropertyFilterFunction(...)</code> if it should not be allowed.
		 *
		 * @parameter eventFromTarget the event that was dispatched from target.
		 * @return An array with value gathered from <code>eventFromTarget</code>.
		 * 				The default implemetation uses <code>propertyFilterFunction</code> if it is set.
		 * 				Otherwise it returns [] if <code>valueClasses.length > 0</code> or throws an ArgumentError.
		 *
		 *
		 * @see #setPropertyFilterFunction()
		 *
		 * @internal
		 * This function gets called by dispatch to recieve the needed property-values from <code>eventFromTarget</code>.
		 * It has to return an array that matches length and types of valueClasses, wich is checked by super.dispatch.apply(null,[returned array]) afterwards.
		 * */
		protected function filterPropertyArguments (eventFromTarget:Event):Array {
			if (_propertyFilterFunction != null) {
				return _propertyFilterFunction.call(null, eventFromTarget);
			} else if (valueClasses.length == 0) {
				return [];
			}
			throw new ArgumentError("There are valueClasses set to be dispatched <" + valueClasses + "> but propertyFilterFunction is null.");
		}
		
		/**
		 * This is used as eventHandler for target or can be called directly with the parameters specified by valueClasses.
		 * <p>If used as eventHandler this uses PropertyRelaySignal's (or an extensions) property-filter-mechanism to only
		 * dispatch the required values from the Event instead of the event itself.</p>
		 *
		 * @see #filterPropertyArguments()
		 * @see #setPropertyFilterFunction()
		 * @see org.osflash.signals.NativeRelaySignal#dispatch()
		 *
		 */
		override public function dispatch (... valueObjects):void {
			/*_target will call this with the dispatched Event as the only parameter*/
			if (valueObjects.length == 1 && valueObjects[0] is _eventClass) {
				super.dispatch.apply(null, filterPropertyArguments(valueObjects[0] as Event));
			} else {
				super.dispatch.apply(null, valueObjects);
			}
		}
		
		/**
		 * Setting target while listeners are attached
		 * will remove the eventListener from the old target and add it to the new one.
		 * NOTE: at the moment u will loose the priority that was set and the new priority will be 0.
		 *
		 * @see DeluxeSignal
		 */
		override public function set target (value:Object):void {
			if (value == _target)
				return;
			
			if (listenerBoxes.length >= 0) {
				if (_target)
					IEventDispatcher(_target).removeEventListener(_eventType, dispatch);
				/*as long as DeluxeSignal puts all listeners in order of highest priority first,
				 we can just use the first element to add with the highest requested priority*/
				var prio:int = 0;
				try {
					prio = listenerBoxes[0].priority;
				} catch (error:Error) {
					trace(this + ".target = <" + value + ">: priority could not be determined while trying to add listeners",
								"to the new target, using 0 as new priority. Cause:", error);
				}
				IEventDispatcher(value).addEventListener(_eventType, dispatch, false, prio);
			}
			_target = value;
		}
	
	}
}