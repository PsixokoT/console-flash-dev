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

        /**
         * @private
         */
        private static const _COMMAND_NAME:String = 'command';

        /**
         * @private
         */
        private static const _ARGS:String = 'arg';

        /**
         * @private
         */
        private static const _OPTION_KEY:String = 'optKey';

        /**
         * @private
         */
        private static const _OPTION_ARG:String = 'optArg';

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

        /**
         * @private
         */
        private var _type:String;

        /**
         * @private
         */
        private var _value:String;

        /**
         * @private
         */
        private var _index:int;

        /**
         * @private
         */
        private var _num:int;

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
        private var _commands:Array;

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
                    setData(_COMMAND_NAME, null, caretIndex);
                } else {
                    setData(_COMMAND_NAME, _sentence.commandName, _sentence.commandIndex);
                }

            } else if (opt) {
                //options
                if ((caretIndex - opt.index) <= opt.key.length) {
                    setData(_OPTION_KEY, opt.key, opt.index);
                } else {
                    setData(_OPTION_ARG, opt.value, opt.index);//TODO: value = null if caret is between key and arg
                }
            } else {
                //TODO: warning infinity while
                var char:String = _sentence.input.charAt(caretIndex);
                while (char && char != ' ') {
                    caretIndex++;
                    char = _sentence.input.charAt(caretIndex);
                }
                var str:String = _sentence.input.substr(0, caretIndex);
                var match:Array = str.match(/\s-[^\s]*(\s*)$/i);

                if (match && match.length) {
                    //TODO: if key == prev_opt.value -> goto Arguments
                    var spaces:RegExp = new RegExp(/\s+/);
                    if (spaces.test(match[1])) {
                        setData(_OPTION_ARG, null, caretIndex);
                    } else {
                        setData(_OPTION_KEY, match[0].substr(2), str.lastIndexOf('-') + 1);
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
                            setData(_ARGS, null, caretIndex);
                            _num = i;
                            break;
                        } else if (caretIndex <= argIndex + argValue.length) {
                            setData(_ARGS, argValue, argIndex);
                            _num = i;
                            break;
                        }
                    }

                    if (_num < 0) {
                        if (caretIndex > argIndex + argValue.length) {
                            setData(_ARGS, null, caretIndex);
                            _num = i;
                        } else {
                            Console.logError('WTF!!!');
                        }
                    }
                } else {
                    setData(_ARGS, null, caretIndex);
                    _num = 0;
                }
            }

            _caret = caretIndex;
        }


        //TODO: move commands and other staff to Controller!!!
        public function getHintData(commands:Array):Array {
            _commands = commands;
            var charIndex:int = _caret - 1;
            var dataIndex:int = -1;
            var array:Array = [];
            var cmd:Command = getCommand();
            var info:String;
            var arg:Arg;

            var value:String = _value;
            var num:int = _num;

            switch (_type) {
                case _COMMAND_NAME:
                    array = getCommands();
                    if (cmd) {
                        if (array.length == 1) {
                            info = cmd.getDescription();
                            array = [];
                        }
                    }
                    charIndex = value ? _index : _caret;
                    dataIndex = 0;
                    break;
                case _OPTION_KEY:
                    if (cmd && cmd.arguments) {
                        array = getSortList(cmd.arguments.list, value);
                        if (array[0] == value) {
                            info = cmd.arguments.hash[value].getDescription();
                            array = null;
                        }
                        charIndex = _index - value.length;
                        dataIndex = 0;
                    }
                    break;
                case _OPTION_ARG:
                    if (cmd && cmd.arguments) {
                        arg = cmd.arguments.hash[value];
                        if (arg) {
                            array = arg.getVariants(value);
                            info = arg.getDescription();
                            charIndex = value ? _index : _caret - 1;
                        }
                    }
                case _ARGS:
                    if (cmd && cmd.arguments) {
                        arg = cmd.arguments.list[num];
                        if (arg) {
                            array = arg.getVariants(value);
                            info = arg.getDescription();
                            charIndex = _index;
                        }
                    }
                    break;
            }
            return [info, array && array.length ? array : null, charIndex, dataIndex];
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

        /**
         * @private
         */
        private function getCommand(name:String = null):Command {
            name ||= _sentence.commandName;
            for each (var cmd:Command in _commands) {
                if (cmd.name == name) return cmd;
            }
            return null;
        }

        /**
         * @private
         */
        private function getCommands(name:String = null):Array {
            name ||= _value;
            return getSortList(_commands, name == 'help' ? '' : name);
        }

        /**
         * @private
         */
        private function getSortList(input:Array, value:String):Array {
            var pattern:RegExp;
            var str:String = '';
            if (value) {
                for (var i:int = 0; i < value.length; i++) {
                    str += '[' + value.charAt(i) + ']+.*';
                }
            }
            
            pattern = new RegExp(str);

            var array:Array = input.filter(function(arg:String, ...args):Boolean {
                return arg.search(pattern) >= 0;
            });
            array.sort(function(a:String, b:String):Number {
                var ai:int = a.search(pattern);
                var bi:int = b.search(pattern);

                if(ai > bi) {
                    return 1;
                } else if(ai < bi) {
                    return -1;
                } else  {
                    if (a.length > b.length) {
                        return 1;
                    } else if (a.length < b.length) {
                        return -1;
                    }
                    return 0;
                }
            });
            return array;
        }
    }
}
