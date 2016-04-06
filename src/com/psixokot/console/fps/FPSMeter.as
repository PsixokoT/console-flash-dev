////////////////////////////////////////////////////////////////////////////////
//
//  © 2014 CrazyPanda LLC
//
////////////////////////////////////////////////////////////////////////////////

package com.psixokot.console.fps {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	
	/**
	 * @author					s_lebedev
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @date					Jun 4, 2014
	 */
	public class FPSMeter extends EventDispatcher {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		public function FPSMeter(fps:int) {
			super();
			this._stageFPS = fps;
			this._tickTime = 1000 / fps;
			this._lastUpdate = this._time = getTimer();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private var _stageFPS:int;
		
		/**
		 * @private
		 */
		private var _tickTime:Number; 
		
		/**
		 * @private
		 */
		private var _time:int;
		
		/**
		 * @private
		 */
		private var _lastUpdate:int;
		
		/**
		 * @private
		 */
		private var _framesCount:int;
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private var _currentFPS:Number;
		
		public function get currentFPS():Number {
			return this._currentFPS;
		}
		
		/**
		 * @private
		 */
		private var _averageFPS:Number;
		
		public function get averageFPS():Number {
			return this._averageFPS;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------
		
		public function update(event:Event = null):void {
			var delta:int = getTimer() - this._time;
			this._time += delta;
			this._currentFPS = (this._tickTime / delta) * this._stageFPS;
			this._framesCount++;
			
			if (this._time - this._lastUpdate > 1000) {
				this._averageFPS = this._stageFPS * this._framesCount / this._stageFPS;
				this._lastUpdate = this._time;
				this._framesCount = 0;
			}
		}
		
	}
}