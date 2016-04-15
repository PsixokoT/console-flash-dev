////////////////////////////////////////////////////////////////////////////////
//
//  © 2016 PsixokoT
//
////////////////////////////////////////////////////////////////////////////////
package com.psixokot.console.core {
	/**
	 * @author        PsixokoT
	 * @version       1.0
	 * @playerversion Flash 18
	 * @langversion   3.0
	 * @date	      07.03.2016
	 */
	public class Arg implements  IConsoleHintable {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		public function Arg(name:String, type:Class, description:String, value:* = null, optional:Boolean = false):void {
			super();
			_name = name;
			_type = type;
			_description = description;
			_optional = optional;

			if (value) {
				if (value is Function || _type == Array || _type == Object) {
					_value = value;
				} else {
					_value = new type(value);
				}
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		public var index:int;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _name:String;

		public function get name():String {
			return _name;
		}

		/**
		 * @private
		 */
		private var _type:Class;

		public function get type():Class {
			return _type;
		}

		/**
		 * @private
		 */
		private var _description:String;

		public function get description():String {
			return _description;
		}

		/**
		 * @private
		 */
		private var  _value:*;

		public function get value():* {
			return _value;
		}

		/**
		 * @private
		 */
		private var _optional:Boolean;

		public function get optional():Boolean {
		    return _optional;
		}

		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------

		public function getVariants(pattern:String = null):Array {
			var data:Array;
			if (_value is Function) {
				data = (_value as Function).apply(this, [pattern]) as Array;
			} else if (_value is Array) {
				data = _value as Array;
			} else if (_value) {
				data = [_value];
			}
			if (data && pattern) {
				data = data.filter(function(arg:*, index:int = 0, array:Array = null):Boolean {
					var str:String = arg.toString();
					return str.search(pattern) == 0 && str != pattern;
				});
			}
			return data;
		}

		public function toString():String {
			return _name;
		}

		public function getDescription():String {
			return _type.toString() + _description;
		}

		public function getValue(data:String = null):* {
			//JSON.parse(_sentence.arguments[i][0]);
			if (_value is Function) return (_value as Function).apply(null, [data]);
			if (!data) return _value;


			if (_type == Class) {
				return data as Class;
			} else if (_type == Array || _type == Object) {
				return JSON.parse(data);
			} else if (_type == Boolean) {
				return (data == 'false' || data == '0') ? false : Boolean(data);
			} else {
				return new _type(data);
			}
			return data as _type;
		}
	}
}