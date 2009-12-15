package de.karfau.signals
{
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	/**
	 * This is an implementation to make synchronous functioncalls semi-asynchronous,
	 * so that the command/controller in the mvcs-application doesn't need to know
	 * if the service is using an synch or asynch approach.
	 *
	 * @author Karfau
	 */
	public class SynchResponseSignal extends Signal implements IResponseSignal
	{
		private var _resultValue:*;
		
		private var hasReturned:Boolean = false;
		private var didSucceed:Boolean = false;
		
		/** This will be dispatched after the success or fault has been dispatched.
		 * Maybe is is not needed in the synchronous part and will be moved to the asynch part.
		 *  listener-parameters: (signal:IResponseSignal)*/
		private var _dispatched:Signal;
		
		private var onFault:Signal;
		
		/** This will be dispatched after the success or fault has been dispatched.
		 * Maybe is is not needed in the synchronous part and will be moved to the asynch part.
		 *  listener-parameters: (signal:IResponseSignal)*/
		public function get dispatched ():ISignal {
			if (_dispatched == null)
				_dispatched = new Signal(IResponseSignal);
			return _dispatched;
		}
		
		public function get returnsVoid ():Boolean {
			return valueClasses.length == 0;
		}
		
		/**
		 *
		 * @param successType null(dafeult) equates to a return-type void
		 * @param faultType if null or ommitted the fault-listener has to have an Object as the only parameter.
		 * @throws ArgumentError if one of the parameters is not of type Class, as in Signal.
		 */
		public function SynchResponseSignal (successType:Class=null, faultType:Class=null) {
			
			if (faultType == null) {
				onFault = new Signal(Object);
			} else {
				onFault = new Signal(faultType);
			}
			
			super();
			if (successType != null) {
				if (!(successType is Class)) {
					throw new ArgumentError('Invalid successType argument: ' +
																	' should be a Class but was:<' + successType + '>.');
				}
			}
		}
		
		/** @inheritDoc */
		public function addResponse (success:Function, fault:Function):void {
			super.addOnce(success);
			this.onFault.addOnce(fault);
			if (hasReturned)
				dispatch();
		}
		
		/**
		 *
		 * @param value
		 */
		public function applySuccess (value:*=null):void {
			_resultValue = value;
			setReadyToDispatch(true);
			dispatch();
		}
		
		/**
		 *
		 * @param info
		 */
		public function applyFault (info:Object):void {
			_resultValue = info;
			setReadyToDispatch(false);
			dispatch();
		}
		
		/**
		 * this will only dispatch in the following cases:
		 * a) either applySuccess or applyFault have been called and at least one responder has been added
		 * b) a responder has been added and the success-result is passed as the first parameter AND HAS NOT BEEN passed before
		 *
		 * @param valueObjects
		 *
		 *
		 */
		override public function dispatch (... valueObjects):void {
			
			/*try to autoSuccess through dispatch with valueObjects[0] as return value:
			 listeners already need to be attached and there is no result yet*/
			if (super.numListeners > 0 && !hasReturned) {
				if (!returnsVoid && valueObjects[0] is valueClasses[0]) {
					applySuccess(valueObjects[0])
				} else if (returnsVoid && valueObjects.length == 0) {
					applySuccess();
				}
			}
			
			if (hasReturned && super.numListeners > 0) {
				if (didSucceed) {
					if (valueClasses.length == 0) {
						super.dispatch();
					} else {
						super.dispatch(_resultValue);
					}
				} else {
					onFault.dispatch(_resultValue);
				}
				if (_dispatched != null)
					_dispatched.dispatch(this);
			}
		}
		
		private function setReadyToDispatch (success:Boolean):void {
			hasReturned = true;
			didSucceed = success;
		}
	}
}