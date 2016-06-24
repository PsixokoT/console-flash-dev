///////////////////////////////////////////////////////////////////////////
//
//  PsixokoT© 2015
//
///////////////////////////////////////////////////////////////////////////

package game {
    import com.psixokot.console.Console;
    import com.psixokot.console.core.Args;

    import nape.callbacks.CbEvent;
    import nape.callbacks.CbType;
    import nape.callbacks.InteractionListener;
    import nape.callbacks.InteractionType;
    import nape.geom.Vec2;
    import nape.phys.Body;
    import nape.phys.BodyType;
    import nape.phys.Material;
    import nape.shape.Circle;
    import nape.shape.Polygon;
    import nape.space.Space;

    /**
     * author PsixokoT
     * date   13.02.2015.
     */
    public class Level {

        public static var BUBBLE_RADIUS:int = 20;

        /**
         * @private
         */
        private static var _COLORS:Array = [];

        public static function getRandomColor():uint {
            return _COLORS[int(Math.random() * _COLORS.length - 1)];
        }

        public static function setColorsCount(value:int):void {
            _COLORS = [];
            while (_COLORS.length < value) {
                _COLORS.push(0xFFFFFF * Math.random());
            }
        }

        Console.addCommand('set_colors_count', 'set colors count', setColorsCount, new Args().add('value', int, 'count', 3), false);

        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------

        public function Level(width:int = 800, height:int = 600, gravity:Number = 0) {
            super();
            _width = width;
            _height = height;
            this.createSpace(gravity);
        }

        //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        private var _width:int;

        /**
         * @private
         */
        private var _height:int;

        //--------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        private var _space:Space;

        public function get space():Space {
            return _space;
        }

        //--------------------------------------------------------------------------
        //
        //  Public methods
        //
        //--------------------------------------------------------------------------

        public function init(bubbleType:CbType):void {
            setColorsCount(3);
            createObjects(bubbleType);
        }

        public function update(time:Number):void {
            try {
                this._space.step(time);
            } catch (error:Error) {
                Console.logError(error.getStackTrace());
            }

        }

        public function addListener(type1:CbType, type2:CbType, callback:Function):void {
            _space.listeners.add(new InteractionListener(CbEvent.END, InteractionType.COLLISION, type1, type2, callback));
        }

        //--------------------------------------------------------------------------
        //
        //  Private methods
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        private function createSpace(gravity:Number):void {
            _space = new Space(new Vec2(0, gravity));
            createBoards();
        }

        /**
         * @private
         */
        private function createBoards():void {
            var border:Body = new Body(BodyType.STATIC);
            border.shapes.add(new Polygon(Polygon.rect(0, 0, -20, _height)));
            border.shapes.add(new Polygon(Polygon.rect(0, 0, _width, -20)));
            border.shapes.add(new Polygon(Polygon.rect(_width, 0, 20, _height)));
            border.shapes.add(new Polygon(Polygon.rect(0, _height, _width, 20)));
            border.space = _space;
            border.debugDraw = true;
        }

        /**
         * @private
         */
        private function createObjects(type:CbType):void {
            var count:int = (_width / (BUBBLE_RADIUS * 2)) * (_height / 2 / (BUBBLE_RADIUS * 2));
            var lineCount:int = _width / (BUBBLE_RADIUS * 2);
            for (var i:int = 0; i < count; i++) {
                var shape:Circle = new Circle(BUBBLE_RADIUS, new Vec2(), Material.wood());
                var xpos:int = i % lineCount;
                var ypos:int = int(i / lineCount);
                var color:uint = getRandomColor();
                var position:Vec2 = Vec2.get((ypos % 2 ? 0 : BUBBLE_RADIUS/2) + (xpos + 1) * BUBBLE_RADIUS * 2 - BUBBLE_RADIUS, (ypos + 1) * BUBBLE_RADIUS * 2 - BUBBLE_RADIUS)
                var body:Body = new Body(BodyType.DYNAMIC, position);

                body.shapes.add(shape);
                body.allowRotation = false;
                body.align();
                body.userData.color = color;
                body.cbTypes.add(type);
                body.space = _space;
            }
        }

        public function get width():int {
            return _width;
        }

        public function get height():int {
            return _height;
        }
    }
}
