package de.karfau.signals
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import org.hamcrest.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.collection.emptyArray;
	import org.hamcrest.object.equalTo;
	
	public class PropertyRelaySignalConstructorTest
	{
		
		private var signal:PropertyRelaySignal;
		private var dispatcher:EventDispatcher;
		private const eventClass:Class = MouseEvent;
		private const TEST:String = "test";
		
		[Before]
		public function setUp ():void {
			dispatcher = new EventDispatcher();
		}
		
		[After]
		public function tearDown ():void {
			signal = null;
			dispatcher = null;
		}
		
		[Test]
		public function twoArgsConstructor ():void {
			signal = new PropertyRelaySignal(dispatcher, TEST);
			assertThat(signal.target, equalTo(dispatcher));
			assertThat(signal.eventClass, equalTo(Event));
			assertThat(signal.valueClasses, emptyArray());
		}
		
		[Test]
		public function threeArgsConstructor ():void {
			signal = new PropertyRelaySignal(dispatcher, TEST, eventClass);
			assertThat(signal.target, equalTo(dispatcher));
			assertThat(signal.eventClass, equalTo(eventClass));
			assertThat("signal.valueclasses has length of 0", signal.valueClasses, emptyArray());
		}
		
		[Test]
		public function fourOrMoreArgsConstructor ():void {
			signal = new PropertyRelaySignal(dispatcher, TEST, eventClass, String, uint, Class);
			assertThat(signal.target, equalTo(dispatcher));
			assertThat(signal.eventClass, equalTo(eventClass));
			assertThat(signal.valueClasses, array(String, uint, Class));
		}
		
		[Test(expects="ArgumentError")]
		public function fourArgsConstructorNull ():void {
			signal = new PropertyRelaySignal(dispatcher, TEST, eventClass, null);
			//assertThat(signal.eventClass, equalTo(clazz));
			//assertThat(signal.valueClasses, array(null));
		}
	}
}