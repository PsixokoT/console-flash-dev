////////////////////////////////////////////////////////////////////////////////
//
//  © 2016 PsixokoT
//
////////////////////////////////////////////////////////////////////////////////
package com.psixokot.console {
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;

    /**
    * @author        PsixokoT
    * @version       1.0
    * @playerversion Flash 18
    * @langversion   3.0
    * @date	         07.03.2016
    */
    public class ConsoleView extends Sprite {

        //--------------------------------------------------------------------------
        //
        //  Class constants
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        private static const _INFO_FORMAT:TextFormat = new TextFormat("Consolas, Courier", 13, 0x22FA11);

        /**
         * @private
         */
        private static const _WARNING_FORMAT:TextFormat = new TextFormat("Consolas, Courier", 13, 0xFF9900);

        /**
         * @private
         */
        private static const _ERROR_FORMAT:TextFormat = new TextFormat("Consolas, Courier", 13, 0xFF3300);

        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------

        public function ConsoleView() {
            super();
            _logField = new TextField();

            _logField.wordWrap = true;
            _logField.addEventListener(Event.SCROLL, handler_logTfScroll);
            super.addChild(_logField);

            _baseField = new TextField();
            _baseField.selectable = false;
            _baseField.defaultTextFormat = _INFO_FORMAT;
            _baseField.text = "> ";
            super.addChild(_baseField);

            _inputField = new TextField();
            _inputField.type = TextFieldType.INPUT;
            _inputField.defaultTextFormat = _INFO_FORMAT;
            _inputField.multiline = false;
            _inputField.restrict = "^`ё";
            super.addChild(_inputField);

            _hint = new ConsoleHint();
            super.addChild(_hint);

            super.addEventListener(Event.ADDED_TO_STAGE, handler_addedToStage);
        }

        //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        private var _autoScroll:Boolean = true;

        /**
         * @private
         */
        private var _logField:TextField;

        /**
         * @private
         */
        private var _baseField:TextField;

        //--------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        private var _inputField:TextField;

        public function get inputField():TextField {
            return this._inputField;
        }

        public function get inputText():String {
            return _inputField.text;
        }

        /**
         * @private
         */
        private var _hint:ConsoleHint;

        public function get hint():ConsoleHint {
            return this._hint;
        }

        //--------------------------------------------------------------------------
        //
        //  Public methods
        //
        //--------------------------------------------------------------------------

        public function addError(message:String):void {
            add(message, _ERROR_FORMAT);
        }

        public function addWarning(message:String):void {
            add(message, _WARNING_FORMAT);
        }

        public function addInfo(message:String):void {
            add(message, _INFO_FORMAT);
        }

        public function setInput(text:String = ''):void {
            _inputField.text = text;
            setMaxCaretIndex();
        }

        public function setLog(text:String = ''):void {
            _logField.text = text;
            update();
        }

        public function setMaxCaretIndex():void {
            _inputField.setSelection(_inputField.text.length, _inputField.text.length);
            super.stage.focus = _inputField;
        }

        public function showHint(info:String = null, data:Array = null, charIndex:int = 0, dataIndex:int = 0):void {
            _hint.setData(info, data, dataIndex);
            var bound:Rectangle = _inputField.getCharBoundaries(charIndex);
            _hint.x = bound ? _inputField.x + bound.x : _inputField.x + _inputField.textWidth;
        }

        //--------------------------------------------------------------------------
        //
        //  Private methods
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        private function add(message:String, textFormat:TextFormat):void {
            message ||= '';
            var last:int = _logField.text.length;
            _logField.appendText(message);

            if(message.length > 0) {
                _logField.setTextFormat(textFormat, last, _logField.text.length);
            }
            if (message != '\n') _logField.appendText('\n');
            update();
            if(_autoScroll) _logField.scrollV = _logField.maxScrollV;
        }

        /**
         * @private
         */
        private function update():void {
            if (!super.stage) return;
            var w:int = super.stage.stageWidth;
            var h:int = super.stage.stageHeight*0.7;
            drawUI(w, h);

            var inputH:int = 20;
            var maxInputY:int = h - inputH - 5;

            _logField.y = 5;
            _logField.x = 5;
            _logField.width = w - 10;
            _logField.height = Math.min(_logField.textHeight + 5, maxInputY);

            _baseField.x = _logField.x;
            _baseField.y = _logField.y + _logField.height;
            _baseField.width = 10;
            _baseField.height = inputH;

            _inputField.x = _baseField.x + _baseField.width + 5;
            _inputField.y = _baseField.y;
            _inputField.width = _logField.width - _baseField.width - 5;
            _inputField.height = inputH;

            _hint.x = _inputField.x;
            _hint.y = _inputField.y + inputH;
        }

        /**
         * @private
         */
        private function drawUI(width:int, height:int):void {
            var g:Graphics = super.graphics;
            g.clear();
            g.lineStyle(1, 0x0);
            g.beginFill(0x0, 0.75);
            g.drawRect(0, 0, width, height);
            g.endFill();
        }

        //--------------------------------------------------------------------------
        //
        //  Events handlers
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        private function handler_addedToStage(event:Event):void {
            super.removeEventListener(Event.ADDED_TO_STAGE, handler_addedToStage);
            super.addEventListener(Event.REMOVED_FROM_STAGE, handler_removedFromStage);
            super.addEventListener(MouseEvent.CLICK, handler_mouseClick);

            update();
            setMaxCaretIndex();
        }

        /**
         * @private
         */
        private function handler_removedFromStage(event:Event):void {
            if (!super.stage) return;
            super.removeEventListener(Event.REMOVED_FROM_STAGE, handler_removedFromStage);
            super.removeEventListener(MouseEvent.CLICK, handler_mouseClick);
            super.addEventListener(Event.ADDED_TO_STAGE, handler_addedToStage);

            this._hint.setData();
            super.stage.focus = null;
        }

        /**
         * @private
         */
        private function handler_mouseClick(event:MouseEvent):void {
            if (!stage) return;
            if (event.target is TextField) return;
            stage.focus = this._inputField;
        }

        /**
         * @private
         */
        private function handler_logTfScroll(event:Event):void {
            _autoScroll = _logField.scrollV != _logField.maxScrollV;
        }
    }
}
