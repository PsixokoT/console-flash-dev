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
    * @date	         07.03.2016
    */
    public class Command implements IConsoleHintable {
    
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        public function Command(name:String, desc:String, callback:Function = null, arguments:Args = null, toObject:Boolean = true) {
            super();
            _name = name;
            _description = desc;
            _callback = callback;
            _arguments = arguments;
            _toObject = toObject;
        }

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
        private var _description:String;

        public function get description():String {
            return _description;
        }

        /**
         * @private
         */
        private var _callback:Function;

        public function get callback():Function {
            return _callback;
        }

        /**
         * @private
         */
        private var _arguments:Args;

        public function get arguments():Args {
            return _arguments;
        }

        /**
         * @private
         */
        private var _toObject:Boolean;

        public function get toObject():Boolean {
            return _toObject;
        }

        //--------------------------------------------------------------------------
        //
        //  Public methods
        //
        //--------------------------------------------------------------------------


        public function toString():String {
            return _name;
        }

        public function getDescription():String {
            var str:String = _description;
            if (_arguments) {
                str += '\n<i>Args:</i>';
                str += _arguments.toString();
            }
            return str;
        }

        public function apply(args:Array = null):String {
            var str:String = '';

            if (_arguments && args) {
                if (args.length < _arguments.requiredArgumentsCount) {
                    str.concat('Warning: arguments count small that need\n');
                }
            }

            return str + _callback.apply(null, args ? args : []);
        }
    }
}
