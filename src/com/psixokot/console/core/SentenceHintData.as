////////////////////////////////////////////////////////////////////////////////
//
//  © 2016 PsixokoT
//
////////////////////////////////////////////////////////////////////////////////
package com.psixokot.console.core {
    import com.psixokot.console.Console;

    /**
     * @author        psixo
     * @version       1.0
     * @playerversion Flash 18
     * @langversion   3.0
     * @date            29.03.2016
     */
    public class SentenceHintData {

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

        public function SentenceHintData(sentence:Sentence) {
            super();
            _sentence = sentence;
        }

        //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        private var _sentence:Sentence;

        //--------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        private var _type:String;

        public function get type():String {
            return _type;
        }

        /**
         * @private
         */
        private var _value:String;

        public function get value():String {
            return _value;
        }

        /**
         * @private
         */
        private var _index:int;

        public function get index():int {
            return _index;
        }

        /**
         * @private
         */
        private var _num:int;

        public function get num():int {
            return _num;
        }

        /**
         * @private
         */
        private var _caret:int;

        public function get caret():int {
            return _caret;
        }

        /**
         * @private
         */
        private var _optionValue:String;

        public function get optionValue():String {
            return this._optionValue;
        }

        //--------------------------------------------------------------------------
        //
        //  Public methods
        //
        //--------------------------------------------------------------------------

        public function toString():String {
            return 'type: ' + _type + ', value: ' + _value + ', index: ' + _index + ', num: ' + _num + ', caret: ' + _caret;
        }

        public function setInputData(caretIndex:int):void {
            //if (_caret == caretIndex) return;

            _num = -1;

            var opt:Option = _sentence.getOptionAtIndex(caretIndex);
            if (!_sentence.commandName || caretIndex <= _sentence.commandIndex + _sentence.commandName.length) {
                //command
                if (caretIndex < _sentence.commandIndex) {
                    setData(COMMAND_NAME, null, caretIndex);
                } else {
                    setData(COMMAND_NAME, _sentence.commandName, _sentence.commandIndex);
                }

            } else if (opt) {
                //options
                if ((caretIndex - opt.index) <= opt.key.length) {
                    setData(OPTION_KEY, opt.key, opt.index);
                } else {
                    setData(OPTION_ARG, opt.value, opt.index + opt.input.length - opt.value.length);//TODO: value = null if caret is between key and arg
                    _optionValue = opt.key;
                }
            } else {
                //TODO: warning infinity while
                /*var char:String = _sentence.input.charAt(caretIndex);
                while (char && char != ' ') {
                    caretIndex++;
                    char = _sentence.input.charAt(caretIndex);
                }*/
                var str:String = _sentence.input.substr(0, caretIndex);
                var match:Array = str.match(/\s-[^\s]*(\s*)$/i);

                if (match && match.length) {
                    //TODO: if key == prev_opt.value -> goto Arguments
                    var spaces:RegExp = new RegExp(/\s+/);
                    if (spaces.test(match[1])) {
                        setData(OPTION_ARG, null, caretIndex);
                        _optionValue = (match[0] as String).substr(2).replace(/\s+/, '');
                    } else {
                        setData(OPTION_KEY, match[0].substr(2), str.lastIndexOf('-') + 1);
                    }
                } else if (_sentence.args.length) {
                    //arguments
                    var arg:Array;
                    var argValue:String;
                    var argIndex:int;
                    for (var i:int = 0; i < _sentence.args.length; i++) {
                        arg = _sentence.args[i];
                        argValue = arg[0];
                        argIndex = arg[1];
                        if (caretIndex < argIndex) {
                            setData(ARGS, null, caretIndex);
                            _num = i;
                            break;
                        } else if (caretIndex <= argIndex + argValue.length) {
                            setData(ARGS, argValue, argIndex);
                            _num = i;
                            break;
                        }
                    }

                    if (_num < 0) {
                        if (caretIndex > argIndex + argValue.length) {
                            setData(ARGS, null, caretIndex);
                            _num = i;
                        } else {
                            Console.logError('WTF!!!');
                        }
                    }
                } else {
                    setData(ARGS, null, caretIndex);
                    _num = 0;
                }
            }

            _caret = caretIndex;
        }

        public function inputHint(text:String):Array {
            var len:int = _value ? _value.length : 0;
            var start:String = _sentence.input.substr(0, _index);
            var finish:String = _sentence.input.substr(_index + len);

            return [start + text + finish, _index + text.length];
        }

        //--------------------------------------------------------------------------
        //
        //  Private methods
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        private function setData(type:String, value:String, index:int):void {
            this._type = type;
            this._value = value;
            this._index = index;
        }
    }
}
