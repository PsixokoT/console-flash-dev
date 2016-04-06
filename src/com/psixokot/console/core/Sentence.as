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
     * @date            09.03.2016
     */
    public class Sentence {

        //--------------------------------------------------------------------------
        //
        //  Class constants
        //
        //--------------------------------------------------------------------------

        public static const COMMAND_NAME:String = 'command';

        public static const ARGS:String = 'arg';

        public static const OPTION_KEY:String = 'optKey';

        public static const OPTION_ARG:String = 'optArg';

        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------

        public function Sentence() {
            super();
        }

        //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        private var _input:String;

        /**
         * @private
         */
        private var _commandIndex:int;

        //--------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        private var _commandName:String;

        public function get commandName():String {
            return _commandName;
        }

        /**
         * @private
         */
        private var _args:Array;

        public function get args():Array {
            return _args;
        }

        /**
         * @private
         */
        private var _options:Array;

        public function get options():Array {
            return _options;
        }

        //--------------------------------------------------------------------------
        //  HINT
        //--------------------------------------------------------------------------


        public const hintData:SentanceHintData = new SentanceHintData();

        //--------------------------------------------------------------------------
        //
        //  Public methods
        //
        //--------------------------------------------------------------------------

        public function input(text:String, caretIndex:int):void {
            if (_input == text) return;
            _input = text;

            var match:Array;
            var index:int;
            var i:int;
            var str:String;

            text = text.toLowerCase();

            //command name
            match = text.match(/(\s+|^)([^\s]+)/);
            if (match && match.length) {
                _commandName = match[2];
                index = text.indexOf(_commandName);
                _commandIndex = index;
            } else {
                _commandName = null;
            }

            str = text.replace(_commandName, '');

            //options
            _options = [];
            match = text.match(/\s-[^\s]+\s+((\'[^\']*\')|(\"[^\"]*\")|(\[.*\])|(\{.*\})|[^\s]+)/g);
            if (match && match.length) {
                for (i = 0; i < match.length; i++) {
                    str = str.replace(match[i], '');
                    var opt:Option = new Option(/-(.*)/.exec(match[i])[1]);
                    index = text.indexOf(opt.input, index);
                    opt.index = index;
                    _options.push(opt);
                }
            }

            //arguments
            _args = [];
            match = str.match(/(\'[^\']*\')|(\"[^\"]*\")|(\[.*\])|(\{.*\})|[^\s]+/g);
            if (match && match.length) {
                index = _commandIndex + _commandName.length;
                for (i = 0; i < match.length; i++) {
                    str = match[i];
                    index = text.indexOf(str, index);
                    opt = getOptionAtIndex(index);
                    while (opt) {
                        index = opt.index + opt.input.length + 1;
                        opt = getOptionAtIndex(index);
                    }
                    _args.push([str, index]);

                    index += str.length;
                }
            }

            this.setInputData(caretIndex);
        }

        //--------------------------------------------------------------------------
        //
        //  Private methods
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        private function setInputData(caretIndex:int):void {
            hintData.enabled = false;

            if (!_commandName || caretIndex <= _commandIndex + _commandName.length) {
                hintData.setData(COMMAND_NAME, _commandName, _commandIndex);
            } else {
                var str:String = _input.substr(0, caretIndex);
                var match:Array = str.match(/\s-[^\s]*(\s*)$/);
                var opt:Option = getOptionAtIndex(caretIndex);
                if (opt) {
                    if ((caretIndex - opt.index) < opt.key.length) {
                        hintData.setData(OPTION_KEY, opt.key, opt.index);
                    } else {
                        hintData.setData(OPTION_ARG, opt.value, opt.index);
                    }
                } else if (match && match.length) {
                    if (match[1] == " ") {
                        hintData.setData(OPTION_ARG, match[1], caretIndex);
                    } else {
                        hintData.setData(OPTION_KEY, match[0], caretIndex);
                    }
                } else {
                    for (var i:int = 0; i < _args.length; i++) {
                        var arg:Array = _args[i];
                        if (caretIndex >= arg[1] && caretIndex <= arg[1] + arg[0].length) {
                            hintData.setData(ARGS, arg[0], arg[1]);
                            hintData.num = i;
                        }
                    }
                }
            }

            hintData.caret = caretIndex;
        }

        /**
         * @private
         */
        private function getOptionAtIndex(index:int):Option {
            for each (var opt:Option in _options) {
                if (index >= opt.index && index <= opt.index + opt.input.length) {
                    return opt;
                }
            }
            return null;
        }
    }
}
