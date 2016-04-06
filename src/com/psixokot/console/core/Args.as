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
	public class Args implements IConsoleHintable {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		public function Args(data:Array = null):void {
			super();
			if (data) {
				for (var i:int = 0; i < data.length; i++) {
					var object:Object = data[i];
					if (object is Arg) {
						addArg(object as Arg);
					} else if (object is Array) {
						add(object[0], object[1], object[2], object[3]);
					}
				}
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		public const hash:Object = {};

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _list:Array = [];

		/**
		 * Список команд
		 */
		public function get list():Array {
			return _list;
		}

		public function get requiredArgumentsCount():int {
			for (var i:int = 0; i < _list.length; i++) {
				if ((_list[i] as Arg).optional) return i;
			}
			return 0;
		}

		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------

		/**
		 * Добавляет команду в список комманд
		 * @param argName название команды
		 * @param description описание
		 * @return
		 */
		public function add(argName:String, argType:Class, description:String, value:* = null, option:Boolean = false):Args {
			return addArg(new Arg(argName, argType, description, value, option));
		}

		public function addArg(value:Arg):Args {
			if (value.name in hash) {
				throw new ArgumentError('Duplicate arg with name ' + value.name);
			}
			value.index = _list.length;

			_list.push(value);
			hash[value.name] = value;

			return this;
		}

		public function toString():String {
			return '\n' + getDescription();
		}

		public function getDescription():String {
			var s:String = "";
			var len:int = _list.length;
			for (var i:int = 0; i < len; i++) {
				var arg:Arg = _list[i];
				s += (arg.optional ? '   * ' : '   $ ') + arg.toString() + ' - ' + arg.getDescription() + "\n";
			}
			return s;
		}
	}
}
