////////////////////////////////////////////////////////////////////////////////
//
//  © 2016 PsixokoT
//
////////////////////////////////////////////////////////////////////////////////
package com.psixokot.console {
    import com.psixokot.console.core.Args;
    import com.psixokot.console.core.Command;
    import com.psixokot.console.fps.FPSMeterView;

    import flash.display.Sprite;
    import flash.errors.IllegalOperationError;
    import flash.events.Event;
    import flash.events.KeyboardEvent;

    /**
    * @author        PsixokoT
    * @version       1.0
    * @playerversion Flash 18
    * @langversion   3.0
    * @date	         07.03.2016
    */
    public class Console extends Sprite {

        //--------------------------------------------------------------------------
        //
        //  Class methods
        //
        //--------------------------------------------------------------------------

        public static function getInstance():Console {
            if (!_INSTANCE) {
                _INSTANCE = new Console();
            }
            return _INSTANCE;
        }

        public static function logError(message:String):void {
            _INSTANCE && _INSTANCE.addError(message);
        }

        public static function logWarning(message:String):void {
            _INSTANCE && _INSTANCE.addWarning(message);
        }

        public static function log(message:String):void {
            _INSTANCE && _INSTANCE.addInfo(message);
        }

        public static function toggleView():void {
            _INSTANCE && _INSTANCE.toggleView();
        }

        public static function toggleFps():void {
            _INSTANCE && _INSTANCE.toggleFps();
        }

        public static function setController(controller:Class, base:Boolean = true):void {
            _INSTANCE && _INSTANCE.setController(controller, base);
        }

        public static function addCommand(name:String, desc:String, callback:Function = null, args:Args = null, toObject:Boolean = true):Command {
            return _INSTANCE.addCommand(name, desc, callback, args, toObject);
        }

        //--------------------------------------------------------------------------
        //
        //  Class constants
        //
        //--------------------------------------------------------------------------

        public static const VERSION:String = 'v1.1';

        /**
        * @private
        */
        private static var _INSTANCE:Console;
    
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        public function Console() {
            super();
            if (_INSTANCE) {
                throw new IllegalOperationError("instance Console can be only one");
            }

            _INSTANCE = this;
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
        private var _view:ConsoleView;

        /**
         * @private
         */
        private var _fps:FPSMeterView;

        /**
         * @private
         */
        private var _controllerClass:Class = BaseConsoleController;

        //--------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        private var _controller:BaseConsoleController;

        public function get controller():BaseConsoleController {
            return _controller;
        }

        //--------------------------------------------------------------------------
        //
        //  Public methods
        //
        //--------------------------------------------------------------------------

        public function addError(message:String):void {
            _view.addError(message);
        }

        public function addWarning(message:String):void {
            _view.addWarning(message);
        }

        public function addInfo(message:String):void {
            _view.addInfo(message);
        }

        public function toggleView():void {
            if (_view.parent) {
                super.removeChild(_view);
            } else {
                super.addChildAt(_view, 0);
            }
        }

        public function toggleFps():void {
            if (_fps.parent) {
                super.removeChild(_fps);
            } else {
                super.addChild(_fps);
                _fps.x = super.stage.stageWidth - _fps.width;
            }
        }

        public function setController(controller:Class = null, base:Boolean = true):void {
            try {
                controller ||= _controllerClass;
                if (base && controller) {
                    _controllerClass = controller;
                }

                if (_controller) _controller.destroy();

                _controller = new controller();
                _controller.init(_view);
            } catch(error:Error) {
                logError("Can't make controller with class " + controller + ". Please extands your class From BaseConsoleController");
            }
        }

        public function addCommand(name:String, desc:String, callback:Function = null, args:Args = null, toObject:Boolean = true):Command {
            if (_controller) {
                return _controller.add(name, desc, callback, args, toObject);
            }
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
        private function handler_addedToStage(event:Event):void {
            super.removeEventListener(Event.ADDED_TO_STAGE, handler_addedToStage);
            super.stage.addEventListener(KeyboardEvent.KEY_DOWN, handler_keyUp);

            _view = new ConsoleView();
            _fps = new FPSMeterView();

            this.setController();
        }

        /**
         * @private
         */
        private function handler_keyUp(event:KeyboardEvent):void {
            if (event.keyCode == 192) {// ~
                this.toggleView();
            }
        }
    }
}
