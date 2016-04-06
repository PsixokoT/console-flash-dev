////////////////////////////////////////////////////////////////////////////////
//
//  © 2016 PsixokoT
//
////////////////////////////////////////////////////////////////////////////////
package com.psixokot.console.core {

    /**
     * @author        psixo
     * @version       1.0
     * @playerversion Flash 18
     * @langversion   3.0
     * @date            25.03.2016
     */
    public class Option {

        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------

        public function Option(str:String) {
            super();
            input = str;

            str = str.replace(/\s+/, ' ');
            _key = /^([^\s]+)\s/.exec(str)[1];
            _value = str.substr(_key.length + 1);
        }

        //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------

        public var input:String;

        public var index:int;

        //--------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        private var _key:String;

        public function get key():String {
            return _key;
        }

        /**
         * @private
         */
        private var _value:String;

        public function get value():String {
            return _value;
        }

        //--------------------------------------------------------------------------
        //
        //  Public methods
        //
        //--------------------------------------------------------------------------

        public function toString():String {
            return _key + ':' + _value;
        }
    }
}
