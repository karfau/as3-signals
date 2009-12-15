package de.karfau.signals
{
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
		protected var hasResponded:Boolean = false;
		
		private var onFault:Signal;
		
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
				} else {
					valueClasses.push(successType);
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
		 * Flags the call as successfull and ready to dispatch when a listener is added.
		 * Previous calls of applySuccess or applyFault are overriden.
		 * If the listener is already attached it will dispatch directly.
		 *
		 * "autoSuccess" through dispatch(resultValue) is not possible anymore.
		 *
		 * @param value the return value can (only) be omitted if returnsVoid is true;
		 */
		public function applySuccess (value:*=null):SynchResponseSignal {
			_resultValue = value;
			setReadyToDispatch(true);
			dispatch();
			return this;
		}
		
		/**
		 * Flags the call as not successfull and ready to dispatch when a listener is added.
		 * Previous calls of applySuccess or applyFault are overriden.
		 * If the listener is already attached it will dispatch directly.
		 *
		 * "autoSuccess" through dispatch(resultValue) is not possible anymore.
		 *
		 * @param info the value that will be passed to the fault-listener.
		 */
		public function applyFault (info:Object):SynchResponseSignal {
			_resultValue = info;
			setReadyToDispatch(false);
			dispatch();
			return this;
		}
		
		/**
		 * rather use applySuccess / applyFault to apply result of the function call,
		 * because dispatch will be called as soon as everything is in place.
		 *
		 * this will only dispatch in the following cases:
		 * a) either applySuccess or applyFault have been called and at least one responder has been added
		 * b) a responder has been added and the success-result is passed as the first parameter AND HAS NOT BEEN passed before
		 *
		 * @param valueObjects
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
				this.hasResponded = true;
			}
		}
		
		private function setReadyToDispatch (success:Boolean):void {
			hasReturned = true;
			didSucceed = success;
		}
	}
}