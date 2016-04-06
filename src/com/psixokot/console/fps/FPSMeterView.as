////////////////////////////////////////////////////////////////////////////////
//
//  © 2014 CrazyPanda LLC
//
////////////////////////////////////////////////////////////////////////////////

package com.psixokot.console.fps {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * @author					s_lebedev
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @date					May 23, 2014
	 */
	public class FPSMeterView extends Sprite {
		
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static const WIDTH:int = 120;
		
		/**
		 * @private
		 */
		private static const HEIGHT:int = 60;
		
		/**
		 * @private
		 */
		private static const NORMAL:int = 20;
		
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		public function FPSMeterView() {
			super();
			super.addEventListener(Event.ADDED_TO_STAGE, this.handler_addedToStage);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private var _fpsField:TextField = new TextField();
		
		/**
		 * @private
		 */
		private var _memField:TextField = new TextField();
		
		/**
		 * @private
		 */
		private var _historyView:Bitmap = new Bitmap(new BitmapData(WIDTH, HEIGHT, true, 0x00), PixelSnapping.NEVER, false);
		
		/**
		 * @private
		 */
		private var _maxFPS:Number;
		
		/**
		 * @private
		 */
		private var _meter:FPSMeter;
		
		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function drawGrid():void {
			var g:Graphics = super.graphics;
			g.beginFill(0x000000, 0.3);
			g.drawRect(0, 0, WIDTH, HEIGHT);
			
			g.lineStyle(1, 0x00FF00, 0.7);
			g.moveTo(0, NORMAL);
			g.lineTo(WIDTH, NORMAL);
		}
		
		/**
		 * @private
		 */
		private function drawHistroty():void {
			var bd:BitmapData = this._historyView.bitmapData;
			bd.scroll(-1, 0);
			var y:int = HEIGHT - this._meter.currentFPS / this._maxFPS * (HEIGHT - NORMAL);
			bd.fillRect(new Rectangle(WIDTH - 1, 0, 1, HEIGHT), 0x00000000);
			bd.fillRect(new Rectangle(WIDTH - 1, y, 1, HEIGHT - y), 0x10B000FF00);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function handler_addedToStage(event:Event):void {
			super.removeEventListener(Event.ADDED_TO_STAGE, this.handler_addedToStage);
			
			this._maxFPS = super.stage.frameRate;
			this._meter = new FPSMeter(this._maxFPS);
			this.drawGrid();
			
			this._fpsField.defaultTextFormat = new TextFormat("Consolas, Courier", 13, 0xFFFFFF, false);
			this._fpsField.autoSize = TextFieldAutoSize.LEFT;
			this._fpsField.selectable = false;
			this._fpsField.text = "FPS: " + this._maxFPS + "\nAverage FPS: " + this._maxFPS;
			this._fpsField.y = HEIGHT - this._fpsField.height;
			
			this._memField.defaultTextFormat = new TextFormat("Consolas, Courier", 12, 0xFFFFFF, false);
			this._memField.autoSize = TextFieldAutoSize.RIGHT;
			this._memField.selectable = false;
			this._memField.text = "0Mb";
			this._memField.x = WIDTH - this._memField.width;
			this._memField.y = HEIGHT - this._memField.height;
			
			super.addChild(this._historyView);
			super.addChild(this._fpsField);
			super.addChild(this._memField);
			
			super.addEventListener(Event.ENTER_FRAME, this.handler_enterFrame);
		}
		
		/**
		 * @private
		 */
		private function handler_enterFrame(event:Event):void {
			this._meter.update();
			this.drawHistroty();
			this._fpsField.text = "CFPS: " + int(this._meter.currentFPS).toString() + "\nAFPS: " + int(this._meter.averageFPS).toString();
			this._memField.text = int(System.totalMemory / 1024 / 1000).toString() + " Mb";
		}
	}
}