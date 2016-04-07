////////////////////////////////////////////////////////////////////////////////
//
//  © 2016 PsixokoT
//
////////////////////////////////////////////////////////////////////////////////
package com.psixokot.console {
    import com.psixokot.console.core.IConsoleHintable;

    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;

    /**
    * @author        PsixokoT
    * @version       1.0
    * @playerversion Flash 18
    * @langversion   3.0
    * @date	         07.03.2016
    */
    public class ConsoleHint extends Sprite {

        //--------------------------------------------------------------------------
        //
        //  Class constants
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        private static const _TEXT_FORMAT:TextFormat = new TextFormat("Consolas, Courier", 13, 0x000000);

        /**
         * @private
         */
        private static const _SELECTED_COLOR:uint = 0xface8d;

        /**
         * @private
         */
        private static const _NORMAL_COLOR:uint = 0xCCCCCC;

        /**
         * @private
         */
        private static const _INFO_COLOR:uint = 0xCFCFCF;

        /**
         * @private
         */
        private static const _BORDER_COLOR:uint = 0x000000;
    
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        public function ConsoleHint() {
            super();
            _list = new Vector.<TextField>();

            _infoField = new TextField();
            _infoField.defaultTextFormat = _TEXT_FORMAT;
            _infoField.background = true;
            _infoField.backgroundColor = _NORMAL_COLOR;
            _infoField.border = true;
            _infoField.borderColor = _SELECTED_COLOR;
            _infoField.thickness = 2;
            _infoField.autoSize = TextFieldAutoSize.LEFT;
            _infoField.wordWrap = true;

            super.addChild(_infoField);
            super.visible = false;
        }

        //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        private var _list:Vector.<TextField>;

        /**
         * @private
         */
        private var _infoField:TextField;

        /**
         * @private
         */
        private var _selectIndex:int;

        /**
         * @private
         */
        private var _info:String;

        //--------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------



        /**
         * @private
         */
        private var _data:Array;

        public function get data():Array {
            return _data;
        }

        public function get currentArg():Object {
            return this._data[_selectIndex];
        }

        //--------------------------------------------------------------------------
        //
        //  Public methods
        //
        //--------------------------------------------------------------------------


        public function next():void {
            _selectIndex++;
            if (_selectIndex >= _data.length) {
                _selectIndex = 0;
            }

            updateSelected();
        }

        public function previous():void {
            _selectIndex--;
            if (_selectIndex < 0) {
                _selectIndex = _data.length - 1;
            }

            updateSelected();
        }

        public function setData(info:String = null, data:Array = null, dataIndex:int = 0):void {
            _info = info;
            _data = data;
            update(dataIndex);
        }

        //--------------------------------------------------------------------------
        //
        //  Private methods
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        private function update(dataIndex:int = 0):void {
            if (!super.stage) return;

            var field:TextField;
            var len:int = _data ? _data.length : 0;

            while (_list.length > len) {
                super.removeChild(_list.pop());
            }

            while (_list.length < len) {
                field = new TextField();
                field.defaultTextFormat = _TEXT_FORMAT;
                field.background = true;
                field.backgroundColor = _INFO_COLOR;
                field.border = true;
                field.borderColor = _BORDER_COLOR;
                field.multiline = false;
                field.height = 20;
                field.y = this._list.length * 20;
                super.addChild(field);
                _list.push(field);
            }

            var maxW:int = 100;

            for (var i:int = 0; i < len; i++) {
                _list[i].text = _data[i].toString();
                maxW = Math.max(_list[i].textWidth + 10, maxW);
            }

            for each (field in _list) {
                field.width = maxW;
            }

            _infoField.x = len ? maxW : 0;
            _infoField.width = stage.stageWidth - localToGlobal(new Point(_infoField.x, _infoField.y)).x - 15;

            _selectIndex = dataIndex;

            updateSelected();

            super.visible = _data || _info;
        }

        /**
         * @private
         */
        private function updateSelected():void {
            _infoField.htmlText = _info || '';

            if (!_data || !_data.length) return;
            var len:int = _list.length;

            for (var i:int = 0; i < len; i++) {
                var field:TextField = _list[i];

                if (i == _selectIndex) {
                    field.backgroundColor = _SELECTED_COLOR;
                    if (currentArg is IConsoleHintable) {
                        _infoField.htmlText += currentArg.getDescription();
                    } else {
                        //_infoField.htmlText += currentArg.toString();
                    }
                } else {
                    field.backgroundColor = _INFO_COLOR;
                }
            }
        }
    }
}
