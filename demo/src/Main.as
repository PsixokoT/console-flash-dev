package {

    import com.psixokot.console.Console;
    import com.psixokot.console.core.Arg;
    import com.psixokot.console.core.Args;

    import flash.Boot;
    import flash.display.Sprite;
    import flash.events.Event;

    import game.Game;
    import game.Level;

    [SWF(frameRate=60, width=800, height=600)]//550a3d//380239
    public class Main extends Sprite {

        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------

        public function Main() {
            super();
            addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        }

        //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------

        private var _game:Game;

        //--------------------------------------------------------------------------
        //
        //  Event handlers
        //
        //--------------------------------------------------------------------------

        private function addedToStageHandler(event:Event):void {
            removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
            addChild(new Console());
            Console.toggleFps();

            new Boot();

            loadLevel(stage.stageWidth, stage.stageHeight, 20, 400);

            Console.addCommand('load_level', 'create new world with radius of balls', loadLevel, new Args([
                new Arg('width', int, 'Width of game', stage.stageWidth),
                new Arg('height', int, 'height of game', stage.stageHeight),
                new Arg('radius', int, 'radius of ball', 20),
                new Arg('gravity', int, 'gravity of game', 400)
            ]), false);

            Game.registerCommands();
        }

        private function loadLevel(width:int, height:int, radius:int, gravity:int):String {
            Level.BUBBLE_RADIUS = radius;
            if (_game && _game.parent) {
                removeChild(_game);
            }
            _game = new Game(width, height, gravity);
            addChildAt(_game, 0);

            Game.logParams();
            return 'Level loaded with params: width = ' + width + ', height = ' + height + ', radius = ' + radius + ', gravity = ' + gravity;
        }
    }
}
