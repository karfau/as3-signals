package de.karfau.signals
{
	import asunit.asserts.fail;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import org.hamcrest.assertThat;
	import org.hamcrest.collection.*;
	import org.hamcrest.core.*;
	import org.hamcrest.object.*;
	import org.hamcrest.text.containsString;
	
	public class PropertyRelaySignalFilterAndDispatchErrorsTest
	{
		private var signal:PropertyRelaySignal;
		private var dispatcher:EventDispatcher;
		private const eventClass:Class = MouseEvent;
		private const TEST:String = "test";
		private var types:Array = [MyClass, String, uint, Class];
		private var called:Vector.<Function>;
		private var calledArgs:Vector.<Array>;
		private var testedFunction:Function;
		
		[Before]
		public function setUp ():void {
			dispatcher = new EventDispatcher();
			called = new Vector.<Function>();
			calledArgs = new Vector.<Array>();
		}
		
		[After]
		public function tearDown ():void {
			signal.removeAll();
			signal = null;
			dispatcher = null;
			called = null;
			calledArgs = null;
			testedFunction = null;
		}
		
		// ### OWN ASSERTIONS ###
		
		private function checkFunctionCall (functions:Array, arguments:Array, removeCheckedElements:Boolean=true):void {
			assertThat("There need to be at least as much called function as functions to test", functions.length <= called.length, equalTo(true));
			assertThat("There need to be at least as much calledArguments arguments to test", arguments.length <= calledArgs.length, equalTo(true));
			assertThat("There need to be the same amount of functions and arguments to test", functions.length == arguments.length, equalTo(true));
			if (functions.length == 0) {
				assertThat("Check is for no functions and no args", called.length == 0 && calledArgs.length == 0, equalTo(true));
			} else {
				for (var i:int = 0; i < functions.length; i++) {
					assertThat(called[i], equalTo(functions[i]));
					assertThat(calledArgs[i], arguments[i] == null ? anything() : arguments[i].length == 0 ? emptyArray() : Function(array).apply(null, arguments));
				}
				if (removeCheckedElements) {
					called.splice(0, functions.length);
					calledArgs.splice(0, arguments.length);
				}
			}
		
		}
		
		// #############
		// ### TESTS ###
		// #############
		
		private function listenerWithNoArgs ():void {
			addCalledFunction(arguments.callee, []);
		}
		
		[Test]
		public function notSettingTypesAndDispatchingEventClassCallsListenerWithNoArgs ():void {
			signal = new PropertyRelaySignal(dispatcher, TEST, eventClass);
			testedFunction = listenerWithNoArgs
			signal.add(testedFunction);
			signal.dispatch(new eventClass(TEST));
			checkFunctionCall([testedFunction], [[]]);
		}
		
		[Test]
		public function notSettingTypesAndDispatchingNoArgsCallsListenerWithNoArgs ():void {
			signal = new PropertyRelaySignal(dispatcher, TEST, eventClass);
			testedFunction = listenerWithNoArgs
			signal.add(testedFunction);
			signal.dispatch();
			checkFunctionCall([testedFunction], [[]]);
		}
		
		[Test]
		public function settingTypesButNoFilterAndDispatchingEventClassCrashes ():void {
			signal = new PropertyRelaySignal(dispatcher, TEST, eventClass, types[0]);
			//this does crash even if there are no listeners attached.
			assertThat("PropertyRelaySignal cannot dispatch (eventClass instance) whith specified types and whithout propertyFilterFunction",
								 callWith(signal.dispatch, new eventClass(TEST)),
								 throws(allOf(
												isA(ArgumentError),
												hasPropertyWithValue("message", containsString("propertyFilterFunction"))
												)
												)
								 );
		}
		
		[Test]
		public function settingTypesButNoFilterAndDispatchingNoArgsCrashes ():void {
			signal = new PropertyRelaySignal(dispatcher, TEST, eventClass, types[0]);
			//this does crash even if there are no listeners attached.
			//crash is caused by super.dispatch and mismatch of valueClasses
			assertThat("PropertyRelaySignal cannot dispatch (no arguments) whith specified types and whithout propertyFilterFunction",
								 signal.dispatch,
								 throws(isA(ArgumentError))
								 );
		}
		
		private function filterVoidFromNoParameter ():void {
			addCalledFunction(arguments.callee, []);
		}
		
		[Test]
		public function settingTypesAndFilterWithNoArgsCrashes ():void {
			signal = new PropertyRelaySignal(dispatcher, TEST, eventClass, types[0]);
			testedFunction = filterVoidFromNoParameter;
			//this does crash even if there are no listeners attached.
			//crash is caused by testing testedFunctions length-property
			assertThat("PropertyRelaySignal checks number of arguments when setting propertyFilterFunction",
								 callWith(signal.setPropertyFilterFunction, testedFunction),
								 throws(allOf(isA(ArgumentError),
															hasPropertyWithValue("message",
																									 allOf(containsString(eventClass + ""),
																												 containsString("propertyFilterFunction"),
																												 containsString(testedFunction.length + "")
																												 )
																									 )
															)
												)
								 );
			//the error occures before the filter can be called
			checkFunctionCall([], []);
		}
		
		private function filterLengthFromMyClass (arg:MyClass):Array {
			addCalledFunction(arguments.callee, [arg]);
			return [arg.length];
		}
		
		[Test]
		public function settingTypesAndFilterWithWrongArgsCrashes ():void {
			signal = new PropertyRelaySignal(dispatcher, TEST, eventClass, types[0]);
			testedFunction = filterLengthFromMyClass;
			//crash is caused calling testedFunction that has wrong arguemnt-type(s)
			assertThat("PropertyRelaySignal calls filter and rethrows any (argument-type) error",
								 callWith(signal.setPropertyFilterFunction, testedFunction),
								 throws(allOf(isA(ArgumentError),
															hasPropertyWithValue("message",
																									 allOf(containsString("initial"),
																												 containsString("error"),
																												 containsString("setPropertyFilterFunction"),
																												 containsString("supress"),
																												 containsString("false")
																												 )
																									 )
															)
												)
								 );
			//the error occures before the filter can be called
			checkFunctionCall([], []);
		
		}
		
		private function filterThrowsNullPointer (event:Event):Array {
			addCalledFunction(arguments.callee, [event]);
			throw new TypeError("null");
		}
		
		[Test]
		public function settingTypesAndFilterThrowingErrorCrashes ():void {
			signal = new PropertyRelaySignal(dispatcher, TEST, eventClass, types[0]);
			testedFunction = filterThrowsNullPointer;
			assertThat("PropertyRelaySignal calls filter and rethrows any error from inside the filter",
								 callWith(signal.setPropertyFilterFunction, testedFunction),
								 throws(allOf(isA(ArgumentError),
															hasPropertyWithValue("message",
																									 allOf(containsString("initial"),
																												 containsString("error"),
																												 containsString("setPropertyFilterFunction"),
																												 containsString("supress"),
																												 containsString("false"),
																												 //about the Error from filterThrowsNullPointer
																												 containsString("TypeError"),
																												 containsString("null")
																												 )
																									 )
															)
												)
								 );
			checkFunctionCall([testedFunction], [null]);
		}
		
		private function filterNothingFromEvent (event:Event):Array {
			addCalledFunction(arguments.callee, [event]);
			return [];
		}
		
		[Test]
		public function settingTypesAndFilterWithWrongResultLengthCrashes ():void {
			signal = new PropertyRelaySignal(dispatcher, TEST, eventClass, types[0]);
			testedFunction = filterNothingFromEvent;
			assertThat("PropertyRelaySignal calls filter and checks length of result",
								 callWith(signal.setPropertyFilterFunction, testedFunction),
								 throws(allOf(isA(ArgumentError),
															hasPropertyWithValue("message",
																									 allOf(containsString("length"),
																												 containsString("0"), //length from filterNothingFromEvent
																												 containsString("valueClasses"),
																												 containsString(signal.valueClasses + "")
																												 )
																									 )
															)
												)
								 );
			checkFunctionCall([testedFunction], [null]);
		}
		
		private function filterThatFailsWhenCalled (event:Event):void {
			fail("This filter should not have been called");
		}
		
		[Test]
		public function settingTypesAndSupressInitialFilterCallDoesntCallFilter ():void {
			signal = new PropertyRelaySignal(dispatcher, TEST, eventClass, types[0]);
			signal.setPropertyFilterFunction(filterThatFailsWhenCalled, false);
		}
		
		// #### LISTENERS #### 
		
		private function listenerWithOneArg (arg:Object):void {
			addCalledFunction(arguments.callee, [arg]);
		}
		
		private function listenerWithAnyArgs (... args):void {
			addCalledFunction(listenerWithAnyArgs, args);
		}
		
		// #### FILTERS ####
		
		private function filterTypeFromEvent (event:Event):Array {
			addCalledFunction(arguments.callee, [event]);
			return [event.type];
		}
		
		// #### HELPERS ####
		
		private function addCalledFunction (func:Function, args:Array):void {
			called.push(func);
			calledArgs.push(args);
		}
		
		private function callWith (func:Function, ... args):Function {
			var result:Function = function ():* {
					return func.apply(null, args);
				};
			return result;
		}
	
	}

}

class MyClass
{
	public var length:uint;
}