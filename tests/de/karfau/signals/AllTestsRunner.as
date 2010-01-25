package de.karfau.signals
{
	import asunit4.ui.MinimalRunnerUI;
	
	import de.karfau.signals.AllTests;
	
	[SWF(width='800', height='600', backgroundColor='#333333', frameRate='31')]
	public class AllTestsRunner extends MinimalRunnerUI
	{
		public function AllTestsRunner () {
			super.run(de.karfau.signals.AllTests); //, "as3-signals-tests"
		}
	}
}

