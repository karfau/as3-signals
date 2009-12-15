package de.karfau.signals
{
	import flash.events.IEventDispatcher;
	
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	public class AsyncResponseSignal extends SynchResponseSignal
	{
		
		//public var onResultBeforeResponse:NativeRelaySignal;
		
		public var uniqueObject:IEventDispatcher;
		
		public function AsyncResponseSignal (successType:Class=null, faultType:Class=null) {
			super(successType, faultType);
		}
		
		/** This will be dispatched after the success or fault has been dispatched.
		 * Maybe is is not needed in the synchronous part and will be moved to the asynch part.
		 *  listener-parameters: (signal:IResponseSignal)*/
		private var _dispatched:Signal;
		
		/** This will be dispatched after the success or fault has been dispatched.
		 * Maybe is is not needed in the synchronous part and will be moved to the asynch part.
		 *  listener-parameters: (signal:IResponseSignal)*/
		public function get dispatched ():ISignal {
			if (_dispatched == null)
				_dispatched = new Signal(AsyncResponseSignal);
			return _dispatched;
		}
		
		override public function dispatch (... valueObjects):void {
			if (!hasResponded) {
				super.dispatch(valueObjects);
			}
			if (hasResponded) {
				this._dispatched.dispatch(this);
			}
		}
	
	}
}