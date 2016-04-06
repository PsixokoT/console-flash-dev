////////////////////////////////////////////////////////////////////////////////
//
//  © 2016 PsixokoT
//
////////////////////////////////////////////////////////////////////////////////
package com.psixokot.console {
    import com.psixokot.console.core.Arg;
    import com.psixokot.console.core.Args;
    import com.psixokot.console.core.Command;
    import com.psixokot.console.core.Option;
    import com.psixokot.console.core.SentanceHintData;
    import com.psixokot.console.core.Sentence;

    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.KeyboardEvent;
    import flash.globalization.DateTimeFormatter;
    import flash.globalization.DateTimeStyle;
    import flash.net.SharedObject;
    import flash.ui.Keyboard;

    /**
    * @author        PsixokoT
    * @version       1.0
    * @playerversion Flash 18
    * @langversion   3.0
    * @date	         07.03.2016
    */
    public class BaseConsoleController extends EventDispatcher {
    
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        public function BaseConsoleController() {
            super();
            try {
               _shared = SharedObject.getLocal('console', '/history');
            } catch (error:Error) {
                //_view.addError(error.toString());
            }
        }

        //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        protected var _view:ConsoleView;

        /**
         * @private
         */
        private const _sentence:Sentence = new Sentence();

        /**
         * @private
         */
        private var _shared:SharedObject;

        /**
         * @private
         */
        private var _history:Array;

        /**
         * @private
         */
        private var _historyIndex:int = -1;

        /**
         * @private
         */
        private var _commandsList:Array;

        /**
         * @private
         */
        private var _commandsHash:Object;

        /**
         * @private
         */
        private var _dtf:DateTimeFormatter;

        //--------------------------------------------------------------------------
        //
        //  Public methods
        //
        //--------------------------------------------------------------------------

        public function init(view:ConsoleView):void {
            _view = view;
            _view.inputField.addEventListener(Event.CHANGE, handler_vewInputChange);
            _view.addEventListener(KeyboardEvent.KEY_UP, handler_keyUp);
            _history = _shared ? _shared.data['list'] : [];
            _commandsList = [];
            _commandsHash = {};
            _dtf = new DateTimeFormatter('ru-RU', DateTimeStyle.NONE, DateTimeStyle.MEDIUM);

            _view.addInfo('PsixokoT Console [Version ' + Console.VERSION + '] 2016\nInput "help" to view command list');

            initCommands();
        }

        public function destroy():void {
            _view.inputField.removeEventListener(Event.CHANGE, handler_vewInputChange);
            _view.removeEventListener(KeyboardEvent.KEY_UP, handler_keyUp);
        }

        public function add(name:String, desc:String, callback:Function = null, args:Args = null, toObject:Boolean = true):Command {
            if (!name || name in _commandsHash) return null;
            return addCommand(new Command(name, desc, callback, args, toObject));
        }

        public function removeCommand(name:String):void {
            var command:Command = _commandsHash[name];
            if (command) {
                var index:int = _commandsList.indexOf(command);
                if (index >= 0) _commandsList.splice(index, 1);
            }
        }

        protected function initCommands():void {
            add('clear', 'clear screen', this.clear);
            add('fps', 'toggle FPSMeter', Console.toggleFps);

            add('help', 'input help', this.help,
                    new Args().add('name', String, 'Enter the name of the command to see the description', getHelpCommands, true),
                    false
            );
        }

        protected function addCommand(command:Command):Command {
            _commandsHash[command.name] = command;
            _commandsList.push(command);
            return command;
        }

        public function remove(name:String):void {
            if (name in _commandsHash) {
                var c:Command = _commandsHash[name];
                var i:int = _commandsList.indexOf(c);
                if (i >= 0) _commandsList.splice(i, 1);
                delete _commandsHash[name];
            }
        }

        //--------------------------------------------------------------------------
        //
        //  Protected methods
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        protected function getSign():String {
            return '[' + _dtf.format(new Date()) + ']';
        }

        /**
         * @private
         */
        protected function addToHistory(str:String):void {
            var index:int = _history.indexOf(str);
            if (index >= 0) {
                _history.splice(index, 1);
                _history.push(str);
            } else {
                _history.push(str);
            }

            if (_history.length > 30) {
                _history.splice(0, 10);
            }

            if (_shared) {
                _shared.data["history"] = _history;
                _shared.flush();
            }

            _historyIndex = -1;
        }

        /**
         * @private
         */
        protected function applyCommand(cmd:Command):void {
            //try {
                var args:Array = getArgsToCallback(cmd);
                var result:String = cmd.apply(args);
                if (result) _view.addInfo(result);
            //} catch (error:Error) {
                //_view.addError(error.toString());
            //}
        }

        /**
         * @private
         */
        private function getArgsToCallback(cmd:Command):Array {
            if (!cmd.arguments) return null;
            var data:Object = {};
            var result:Array = [];
            var arg:Arg;
            var value:*;
            var list:Array = cmd.arguments.list;

            for (var i:int = 0; i < list.length; i++) {
                arg = list[i];
                value = arg.getValue((i < _sentence.args.length) ? _sentence.args[i][0] : null);

                result.push(value);
                data[arg.name] = value;
            }

            for each (var opt:Option in _sentence.options) {
                arg = cmd.arguments.hash[opt.key];
                if (arg) {
                    value = arg.getValue(opt.value);
                    data[opt.key] = value;
                    result[arg.index] = value;
                }
            }

            if (cmd.toObject) return [data];

            return result;
        }

        /**
         * @private
         */
        protected function methodMissing():void {
            var text:String = 'Command with name "' + _sentence.commandName + '" is missing. ';
            if (_sentence.args.length) {
                text += 'Args: [';
                for each (var arg:Array in _sentence.args) {
                    text += arg[0] + ','
                }
                text = text.substr(0, text.length - 1) + ']';
            }
            if (_sentence.options.length) {
                text += ' Options: ' + _sentence.options.toString();
            }

            _view.addError(text);
        }

        //--------------------------------------------------------------------------
        //
        //  Private methods
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        private function next():void {
            if (this._view.hint.data) {
                this._view.hint.next();
            } else {
                _historyIndex++;
                if (_historyIndex >= _history.length) {
                    _historyIndex = -1;
                }
                _view.setInput(_historyIndex >= 0 && _history.length ? _history[_historyIndex] : '');
            }
        }

        /**
         * @private
         */
        private function previous():void {
            if (this._view.hint.data) {
                this._view.hint.previous();
            } else {
                _historyIndex--;
                if (_historyIndex < -1) {
                    _historyIndex = _history.length - 1;
                }
                _view.setInput(_historyIndex >= 0 && _history.length ? _history[_historyIndex] : '');
            }
        }

        /**
         * @private
         */
        private function enter():void {
            _sentence.input(_view.inputText, _view.inputField.caretIndex);

            if (tab()) return;

            var text:String = _view.inputText;
            if (text) addToHistory(text);
            _view.addInfo(getSign() + text);
            _view.setInput('');
            _view.hint.setData();

            if (text) {
                var cmd:Command = getCommand();

                if (cmd) applyCommand(cmd);
                else methodMissing();
            }

            if (text) _view.addInfo('\n');
        }

        /**
         * @private
         */
        private function hint():void {
            _sentence.input(_view.inputText, _view.inputField.caretIndex);

            var index:int = _view.inputField.caretIndex - 1;
            var cmd:Command = getCommand();
            var array:Array = [];
            var info:String;
            var arg:Arg;

            if (_sentence.hintData.enabled) {
                var data:SentanceHintData = _sentence.hintData;
                var value:String = data.value;
                var num:int = data.num;

                switch (data.type) {
                    case Sentence.COMMAND_NAME:
                        array = getCommands();
                        if (cmd && array.length == 1) {
                            info = cmd.getDescription();
                            array = [];
                        }
                        index = value ? data.index : data.caret - 1;
                        break;
                    case Sentence.OPTION_KEY:
                        break;
                    case Sentence.OPTION_ARG:

                        break;
                    case Sentence.ARGS:
                        if (cmd && cmd.arguments) {
                            arg = cmd.arguments.list[num];
                            if (arg) {
                                array = arg.getVariants(value);
                                info = arg.getDescription();
                                index = value ? data.index : data.caret - 1;
                            }
                        }
                        break;
                }
            } else {
                if (cmd) {
                    if (cmd.arguments) {
                        arg = cmd.arguments.list[_sentence.args.length];
                        if (arg) {
                            array = arg.getVariants(value);
                            info = arg.getDescription();
                            index = _view.inputField.caretIndex;
                        }
                    }
                }
            }

            _view.showHint(info, array && array.length ? array : null, index);
        }

        /**
         * @private
         */
        private function tab():Boolean {
            if (_view.hint.data) {
                var value:String = _view.hint.currentArg.toString();
                var index:int = _view.inputField.caretIndex - 1;
                var data:SentanceHintData = _sentence.hintData;
                var cmd:Command = getCommand();
                if (data.enabled) {
                    var num:int = data.num;

                    if (data.type == Sentence.ARGS) {
                        value = _view.inputField.text.slice(0, data.index) + value + _view.inputField.text.slice(data.index - 1 + value.length);
                    }
                } else if (cmd && cmd.arguments) {
                    value = _view.inputField.text.slice(0, index + 1) + value + _view.inputField.text.slice(index + value.length);
                }

                _view.setInput(value);
                _view.hint.setData();
                hint();

                return true;
            }
            return false;
        }

        /**
         * @private
         */
        private function getCommand(name:String = null):Command {
            name ||= _sentence.commandName;
            return _commandsHash[name];
        }

        /**
         * @private
         */
        private function getCommands(name:String = null):Array {
            name ||= _sentence.commandName;
            var pattern:RegExp;// = new RegExp("[" + name + "]+");
            var str:String = '';
            if (name) {
                for (var i:int = 0; i < name.length; i++) {
                    str += '[' + name.charAt(i) + ']+.*';
                }
            }
            pattern = new RegExp(str);
            var array:Array = _commandsList.filter(function(c:Command, index:int = 0, comands:Array = null):Boolean {
                return c.name.search(pattern) >= 0;
            });
            array.sort(sortCommands);
            return array;
        }

        /**
         * @private
         */
        private function sortCommands(a:Command, b:Command):Number {
            var ai:int = a.name.search(_sentence.commandName);
            var bi:int = b.name.search(_sentence.commandName);

            if(ai > bi) {
                return 1;
            } else if(ai < bi) {
                return -1;
            } else  {
                if (a.name.length > b.name.length) {
                    return 1;
                } else if (a.name.length < b.name.length) {
                    return -1;
                }
                return 0;
            }
        }

        //--------------------------------------------------------------------------
        //  Commands
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        private function help(name:String = null):String {
            if (name) {
                var cmd:Command = getCommand(name);
                if (cmd) {
                    return cmd.description;
                } else {
                    return getCommands(name).toString();
                }
            } else {
                return _commandsList.sort().join('\n');
            }
            return null;
        }

        /**
         * @private
         */
        private function getHelpCommands(arg:String):Array {
            var command:Command = getCommand();
            if (!command) return null;
            //if (!_sentence.arguments) return _
            var array:Array = _commandsList.filter(function(c:Command, index:int = 0, array:Array = null):Boolean {
                return !arg || c.name.search(arg) >= 0;
            });
            array.sort(sortCommands);
            return array;
        }

        /**
         * @private
         */
        private function clear(data:Object = null):String {
            this._view.setInput();
            this._view.setLog();
            return null;
        }

        //--------------------------------------------------------------------------
        //
        //  Events handlers
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        private function handler_keyUp(event:KeyboardEvent):void {
            if (!_view || !_view.parent) return;
            switch (event.keyCode) {
                case Keyboard.ENTER:
                    enter();
                    break;
                case Keyboard.UP:
                    previous();
                    break;
                case Keyboard.DOWN:
                    next();
                    break;
                case Keyboard.LEFT:
                case Keyboard.RIGHT:
                    hint();
                    break;
                case Keyboard.SPACE:
                    if (event.ctrlKey && !_view.inputText) {
                        if (_view.hint.data) {
                            _view.showHint();
                        } else {
                            _view.showHint(null, _commandsList, _view.inputField.caretIndex);
                        }
                    }
                    break;
                case Keyboard.TAB:
                    tab();
                    break;
            }
        }

        /**
         * @private
         */
        private function handler_vewInputChange(event:Event):void {
            hint();
        }
    }
}
