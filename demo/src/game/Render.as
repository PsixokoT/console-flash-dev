///////////////////////////////////////////////////////////////////////////
//
//  PsixokoT© 2015
//
///////////////////////////////////////////////////////////////////////////

package game {
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.display.Sprite;

    import nape.constraint.DistanceJoint;
    import nape.constraint.WeldJoint;

    import nape.phys.Body;
    import nape.phys.BodyType;
    import nape.shape.Circle;
    import nape.space.Space;
    import nape.util.BitmapDebug;
    import nape.util.ShapeDebug;

    /**
     * author PsixokoT
     * date   13.02.2015.
     */
    public class Render {

        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------

        public function Render(container:Sprite, width:int, height:int) {
            super();
            _container = container;
            _color = Level.getRandomColor();
            _graphics = _shape.graphics;
            _debugBMP = new BitmapDebug(width, height, 3355443, true);
            container.addChild(_shape);
            container.addChild(_debugBMP.display);

            container.graphics.beginFill(0xFF, 0.4);
            container.graphics.drawRect(0, height / 2, width, height / 2);
        }

        /**
         * @private
         */
        private var _shape:Shape = new Shape();

        //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------

        public var drawDebug:Boolean = false;

        /**
         * @private
         */
        private var _debugBMP:BitmapDebug;

        private var _container:Sprite;

        private var _color:uint;

        private var _graphics:Graphics;

        //--------------------------------------------------------------------------
        //
        //  Public methods
        //
        //--------------------------------------------------------------------------

        public function render(space:Space, joints:Vector.<WeldJoint>):void {
            if (drawDebug) {
                _debugBMP.clear();
                _debugBMP.draw(space);
                _debugBMP.flush();
            }

            _graphics.clear();
            space.bodies.foreach(drawBody);
            joints.forEach(drawJoin);
        }

        //--------------------------------------------------------------------------
        //
        //  Private methods
        //
        //--------------------------------------------------------------------------

        private function drawBody(body:Body):void {
            if (body.type == BodyType.DYNAMIC || body.userData.color) {

                _graphics.lineStyle();
                _graphics.beginFill(body.userData.color, body.userData.infected_at ? 1 : 0.7);

                if (body.userData.infected_at) {
                    _graphics.lineStyle(1, 0x00);
                }

                body.shapes.foreach(drawShape);
            }
        }

        private function drawShape(shape:Circle):void {
            _graphics.drawCircle(shape.worldCOM.x, shape.worldCOM.y, Level.BUBBLE_RADIUS);
        }

        /**
         * @private
         */
        private function drawJoin(joint:WeldJoint, ...args):void {
            if (joint.space) {
                _graphics.lineStyle(1, 0x00, 0.3);
                _graphics.moveTo(joint.body1.position.x, joint.body1.position.y);
                _graphics.lineTo(joint.body2.position.x, joint.body2.position.y);
            }
        }
    }
}
