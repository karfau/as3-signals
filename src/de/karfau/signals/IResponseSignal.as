package de.karfau.signals
{
	import org.osflash.signals.ISignal;
	
	/**
	 * This is  intended to be used as the return-value of service-methods in an mvcs-architecture.
	 *
	 * @author Karfau
	 *
	 * @see http://groups.google.com/group/robotlegs/browse_thread/thread/f0daf0d47a572bc9/52d930531daff392#52d930531daff392
	 */
	public interface IResponseSignal
	{
		/**
		 *
		 * @param sucess the function that will be called with the return-value when the call completed successfully
		 * @param fault the function that will be called if an error occured while processing passing info about the error.
		 */
		function addResponse (sucess:Function, fault:Function):void;
		
		function get successClass ():Class;
		
		function get faultClass ():Class;
		
		function get returnsVoid ():Boolean;
	}
}