////////////////////////////////////////////////////////////////////////////////
//
//  © 2017 CrazyPanda LLC
//
////////////////////////////////////////////////////////////////////////////////
package com.psixokot.console.reporter {

	/**
	 * @author          psixo
	 * @version         1.0
	 * @playerversion   Flash 10
	 * @langversion     3.0
	 * @date            02.11.2017
	 */
	public class Reporter extends Object {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		/*

		+=====================================================+
		|                    Title                            |
		+==============+===================+==================+
		| col_1        | col_2             | col_3            |
		+==============+===================+==================+
		| value_1      | value_2           | value_3          |
		|              | value_2           | value_3          |
		|              |                   | value_3          |
		+--------------+-------------------+------------------+
		| value_1      | value_2           | value_3          |
		|              |                   | value_3          |
		+--------------+-------------------+------------------+
		| value_1      | value_2           | value_3          |
		+--------------+-------------------+------------------+
		| value_1      | value_2           | value_3          |
		+--------------+-------------------+------------------+
		| value_1      | value_2           | value_3          |
		+--------------+-------------------+------------------+
		| value_1      | value_2           | value_3          |
		+--------------+-------------------+------------------+

		*/

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		public function Reporter(width:int = 0) {
			super();
			_width = width;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _width:int;

		/**
		 * @private
		 */
		private var _title:String;

		/**
		 * @private
		 */
		private var _fields:Array;

		/**
		 * @private
		 */
		private var _sizes:Array;

		/**
		 * @private
		 */
		private var _rows:Array;

		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------

		public function start(title:String = null, fields:Array = null):void {
			_title = title;
			_fields = fields;
			_sizes = [];
			_rows = [];
			calculateSizes(_fields);
		}

		public function add(row:Array):void {
			_rows.push(row);
			calculateSizes(row);
		}

		public function result():String {
			var width:int = getWidth();
			var str:String = '';
			if (_title) {
				str += drawLine(width, true, '=') + '\n';
				str += drawText(_title, width, true, true) + '\n';
			}
			if (_fields) {
				str += drawRow(_fields, '=');
			}

			reset();
			return str;
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function reset():void {
			_title = null;
			_fields = null;
			_rows = null;
		}

		/**
		 * @private
		 */
		private function calculateSizes(row:Array):void {
			if (!row) return;
			for (var i:int = 0; i < row.length; i++) {
				var value:String = row[i];
				var lines:Array = value.split('\n');
				_sizes[i] = Math.max(_sizes[i] || 0, getMaxLength(lines));
			}
		}

		/**
		 * @private
		 */
		private function getMaxLength(lines:Array):int {
			var result:int;
			for each (var str:String in lines) {
				result = Math.max(str.length, result);
			}
			return result;
		}

		/**
		 * @private
		 */
		private function getWidth():int {
			if (_width) return _width;
			var result:int;
			for (var i:int = 0; i < _sizes.length; i++) {
				result += _sizes[i];
			}
			result += _sizes.length * 2;
			result += _sizes.length;
			return result;
		}

		/**
		 * @private
		 */
		private function drawLine(width:int, end:Boolean = true, symbol:String = '-'):String {
			var str:String = '+';
			while (width-- > 2) str += symbol;
			str += end ? '+' : symbol;
			return str;
		}

		/**
		 * @private
		 */
		private function drawText(text:String, width:int, end:Boolean = true, center:Boolean = false):String {
			var str:String = '|';
			var startSpaces:int = 1; //
			if (center) {
				startSpaces = (width - 4 - text.length) / 2;
			}
			while (startSpaces-- > 0) str += ' ';
			str += text;
			while (str.length < width - 1) str += ' ';
			str += end ? '|' : ' ';
			return str;
		}

		/**
		 * @private
		 */
		private function drawRow(row:Array, symbol:String = '-'):String {
			var str:String = '';
			var i:int;
			var len:int = _sizes.length;
			for (i = 0; i < len; i++) {
				str += drawLine(_sizes[i] + len + 1, i == len - 1, symbol);
			}
			str += '\n';
			for (i = 0; i < len; i++) {
				str += drawText(row[i], _sizes[i] + len, i == len - 1);
			}
			str += '\n';

			return str;
		}
	}
}
