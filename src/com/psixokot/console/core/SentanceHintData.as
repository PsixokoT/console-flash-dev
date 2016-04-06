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
     * @date            29.03.2016
     */
    public class SentanceHintData {

        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------

        public function SentanceHintData() {
            super();
        }

        //--------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------

        public var enabled:Boolean;

        public var type:String;

        public var value:String;

        public var index:int;

        public var num:int;

        public var caret:int;

        //--------------------------------------------------------------------------
        //
        //  Public methods
        //
        //--------------------------------------------------------------------------

        public function setData(type:String, value:String, index:int):void {
            this.type = type;
            this.value = value;
            this.index = index;
            enabled = true;
        }

    }
}
