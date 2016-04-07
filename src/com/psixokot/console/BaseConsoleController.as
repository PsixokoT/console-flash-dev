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

            _view.addInfo('PsixokoT Console [' + Console.VERSION + '] 2016\nInput "help" to view command list\n');

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

        public function remove(name:String):void {
            if (name in _commandsHash) {
                var c:Command = _commandsHash[name];
                var i:int = _commandsList.indexOf(c);
                if (i >= 0) _commandsList.splice(i, 1);
                delete _commandsHash[name];
            }
        }

        protected function initCommands():void {
            add('clear', 'clear screen', this.clear);
            add('fps', 'toggle FPSMeter', Console.toggleFps);

            /*add('help', 'input help', this.help,
                    new Args().add('name', String, 'Enter the name of the command to see the description', getCommands, true),
                    false
            );*/
        }

        protected function addCommand(command:Command):Command {
            _commandsHash[command.name] = command;
            _commandsList.push(command);
            return command;
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
            _sentence.inputText(_view.inputText, _view.inputField.caretIndex);

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
            _sentence.inputText(_view.inputText, _view.inputField.caretIndex);

            var data:Array = _sentence.getHintData(_commandsList);
            _view.showHint(data[0], data[1], data[2], data[3]);
        }

        /**
         * @private
         */
        private function tab(force:Boolean = false):Boolean {//TODO: rename arg
            if (_view.hint.data) {
                var value:String;
                if (_view.hint.currentArg) {
                    value = _view.hint.currentArg.toString();
                } else if (force) {
                    value = _view.hint.data[0].toString();
                } else {
                    return false;
                }
                var inputHint:Array =_sentence.inputHint(value);
                _view.setInput(inputHint[0]);
                _view.inputField.setSelection(inputHint[1], inputHint[1]);
                _view.hint.setData();
                hint();
                return true;
                var index:int = _view.inputField.caretIndex - 1;
                /*var data:SentenceHintData = _sentence.hintData;
                var cmd:Command = getCommand();
                if (data.enabled) {
                    var num:int = data.num;
                    if (data.type == Sentence.OPTION_KEY) {
                        value = _view.inputField.text.slice(0, data.index - data.value.length) + value + _view.inputField.text.slice(index + value.length);
                    }
                    if (data.type == Sentence.ARGS) {
                        value = _view.inputField.text.slice(0, data.index) + value + _view.inputField.text.slice(data.index - 1 + value.length);
                    }
                } else if (cmd && cmd.arguments) {
                    value = _view.inputField.text.slice(0, index + 1) + value + _view.inputField.text.slice(index + value.length);
                }*/


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
        private function getCommand(name:String = null):Command {//TODO: check for duplicate in SentenceHintData
            name ||= _sentence.commandName;
            return _commandsHash[name];
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
                }
            }
            return _commandsList.sort().join('\n');
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
                    tab(true);
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
