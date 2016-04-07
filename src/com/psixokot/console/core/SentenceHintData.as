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
        private var _enabled:Boolean;

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

        public function setInputData(caretIndex:int):void {
            _enabled = false;
            if (!_sentence.commandName || caretIndex <= _sentence.commandIndex + _sentence.commandName.length) {
                setData(_COMMAND_NAME, _sentence.commandName, _sentence.commandIndex);
            } else {
                var str:String = _sentence.input.substr(0, caretIndex);
                var match:Array = str.match(/\s-[^\s]*(\s*)$/);
                var opt:Option = _sentence.getOptionAtIndex(caretIndex);

                if (match) Console.logWarning(match.join(",") + (opt ? 'opt: ' + opt.toString() : 'opt: false'));
                if (opt) {//TODO: fuck this shit
                    if ((caretIndex - opt.index) < opt.key.length) {
                        setData(_OPTION_KEY, opt.key, opt.index);
                    } else {
                        setData(_OPTION_ARG, opt.value, opt.index);
                    }
                } else if (match && match.length) {
                    if (match[1] == " ") {
                        setData(_OPTION_ARG, match[0].substr(2), caretIndex);
                    } else {
                        setData(_OPTION_KEY, match[0].substr(2), caretIndex);
                    }
                } else {
                    for (var i:int = 0; i < _sentence.args.length; i++) {
                        var arg:Array = _sentence.args[i];
                        if (caretIndex >= arg[1] && caretIndex <= arg[1] + arg[0].length) {
                            setData(_ARGS, arg[0], arg[1]);
                            _num = i;
                        }
                    }
                }
            }

            _caret = caretIndex;
        }

        public function getHintData(commands:Array):Array {
            _commands = commands;
            var charIndex:int = _caret - 1;
            var dataIndex:int = -1;
            var array:Array = [];
            var cmd:Command = getCommand();
            var info:String;
            var arg:Arg;

            if (_enabled) {
                var value:String = _value;
                var num:int = _num;

                switch (_type) {
                    case _COMMAND_NAME:
                        array = getCommands();
                        if (cmd) {
                            if (cmd.name == 'help') array.length = 1;

                            if (array.length == 1) {
                                info = cmd.getDescription();
                                array = [];
                            }
                        }
                        charIndex = value ? _index : _caret - 1;
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
                                charIndex = value ? _index : _caret - 1;
                            }
                        }
                        break;
                }
            } else {
                if (cmd) {
                    if (cmd.arguments) {
                        for (var i:int = 0; i < _sentence.args.length; i++) {
                            var sArg:Array = _sentence.args[i];
                            if (_caret <= sArg[1]) {
                                break;
                            }
                        }
                        arg = cmd.arguments.list[i];
                        if (arg) {
                            array = arg.getVariants(value);
                            info = arg.getDescription();
                            charIndex = _caret;
                        }
                    }
                }
            }
            return [info, array && array.length ? array : null, charIndex, dataIndex];
        }

        public function inputHint(text:String):Array {
            var result:String = text;
            var startIndex:int = _index;
            var caretIndex:int = _caret;
            var cmd:Command = getCommand();
            if (cmd) {
                switch (_type) {
                    case _COMMAND_NAME:
                        startIndex = _caret;
                        caretIndex = _caret + cmd.name.length;
                        break;
                    case _OPTION_KEY:
                        startIndex = _index - _value.length;
                        caretIndex = _index + _value.length;
                        break;
                    case _OPTION_ARG:
                        caretIndex = _index + _value.length;
                        break;
                    case _ARGS:
                        for (var i:int = 0; i < _sentence.args.length; i++) {
                            var sArg:Array = _sentence.args[i];
                            if (_caret <= sArg[1]) {
                                break;
                            }
                        }
                        if (_index == _caret - 1) {
                            caretIndex = _caret + sArg[0].length;
                        } else {
                            startIndex = _caret;
                        }

                        break;
                    default:
                        result = "error";
                        break;
                }
            } else {
                caretIndex = _index + text.length;
            }

            result = _sentence.input.substr(0, startIndex) + text + _sentence.input.substr(caretIndex);

            return [result, caretIndex];
        }

        //--------------------------------------------------------------------------
        //
        //  Private methods
        //
        //--------------------------------------------------------------------------

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
            name ||= _sentence.commandName;
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

        /**
         * @private
         */
        private function setData(type:String, value:String, index:int):void {
            this._type = type;
            this._value = value;
            this._index = index;
            _enabled = true;
        }

    }
}
