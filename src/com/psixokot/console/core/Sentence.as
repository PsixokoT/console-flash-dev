////////////////////////////////////////////////////////////////////////////////
//
//  © 2016 PsixokoT
//
////////////////////////////////////////////////////////////////////////////////
package com.psixokot.console.core {
    import com.psixokot.console.Console;

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
        //  Constructor
        //
        //--------------------------------------------------------------------------

        public function Sentence() {
            super();
            _hintData = new SentenceHintData(this);
        }

        //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        private var _hintData:SentenceHintData;

        //--------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        private var _input:String;

        public function get input():String {
            return _input
        }

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
        private var _commandIndex:int;

        public function get commandIndex():int {
            return _commandIndex;
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
        //
        //  Public methods
        //
        //--------------------------------------------------------------------------

        public function inputText(text:String, caretIndex:int):void {
            if (_input == text && caretIndex == _hintData.caret) return;
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

            //Console.log(_commandName + ":" + _commandIndex + ', options:' + _options + '' + ', args:' + _args);

            _hintData.setInputData(caretIndex);
        }

        public function getHintData(commands:Array):Array {
            return _hintData.getHintData(commands);
        }

        public function inputHint(text:String):Array {
            return _hintData.inputHint(text);
        }

        public function getOptionAtIndex(index:int):Option {
            for each (var opt:Option in _options) {
                if (index >= opt.index && index <= opt.index + opt.input.length) {
                    return opt;
                }
            }
            return null;
        }
    }
}
