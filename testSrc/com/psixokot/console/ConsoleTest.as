////////////////////////////////////////////////////////////////////////////////
//
//  © 2017 CrazyPanda LLC
//
////////////////////////////////////////////////////////////////////////////////
package com.psixokot.console {
	import org.flexunit.Assert;
	
	/**
	 * @author          s.lebedev
	 * @version         1.0
	 * @playerversion   Flash 10
	 * @langversion     3.0
	 * @date            19.04.2017
	 */
	public class ConsoleTest {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		public function ConsoleTest() {
		}
		
		[Before]
		public function setUp():void {
			new Console();
		}
		
		[Test]
		public function testLogError():void {
			
		}
		
		[Test]
		public function testLog():void {
			Console.log('test message');
			Assert.assertEquals('asda', 'sdasd');
		}
		
		[Test]
		public function testLogWarning():void {
			
		}
	}
}
