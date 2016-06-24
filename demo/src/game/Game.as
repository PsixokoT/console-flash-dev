package game {
    import com.psixokot.console.Console;
    import com.psixokot.console.core.Arg;
    import com.psixokot.console.core.Args;
    import com.psixokot.console.core.Command;

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.utils.getTimer;

    import nape.callbacks.CbType;
    import nape.callbacks.InteractionCallback;
    import nape.constraint.WeldJoint;
    import nape.dynamics.CollisionArbiter;
    import nape.geom.Vec2;
    import nape.phys.Body;
    import nape.phys.BodyList;
    import nape.phys.BodyType;

    public class Game extends Sprite {

        //--------------------------------------------------------------------------
        //
        //  Class constants
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        private static var _INFECTED_TIME:int = 1000;

        /**
         * @private
         */
        private static var _BOOM_BEFORE:Boolean;

        /**
         * @private
         */
        private static var _BOOM_AFTER:Boolean;

        /**
         * @private
         */
        private static var _JOINTS_MODE:Boolean;

        /**
        * @private
        */
        private static var _JOINTS_SEQUENCE:Boolean;

        /**
         * @private
         */
        private static var _STATIC_INFECTION:Boolean = false;

        /**
        * @private
        */
        private static var _INFECTIONS_PER_FRAME:int = 3;
        
        /**
        * @private
        */
        private static var _commands:Vector.<Command>;

        public static function registerCommands():void {
            _commands = new Vector.<Command>();

            _commands.push(Console.addCommand('game_infected_time', 'Time for infection' + _INFECTED_TIME, function(value:int):String {
                _INFECTED_TIME = value;
                return 'infected_time = ' + _INFECTED_TIME;
            }, new Args().add('time', int, 'ms time', _INFECTED_TIME), false));

            _commands.push(Console.addCommand('game_boom_before', 'Toggle explosions on start infection ON/OFF', function():String {
                _BOOM_BEFORE = !_BOOM_BEFORE;
                return 'boom before = ' + _BOOM_BEFORE;
            }));

            _commands.push(Console.addCommand('game_boom_after', 'Toggle explosions on finish infection ON/OFF', function():String {
                _BOOM_AFTER = !_BOOM_AFTER;
                return 'boom after = ' + _BOOM_AFTER;
            }));

            _commands.push(Console.addCommand('game_joints_mode', 'Toggle joints mode ON/OFF', function():String {
                _JOINTS_MODE = !_JOINTS_MODE;
                return 'with joints = ' + _JOINTS_MODE;
            }));

            _commands.push(Console.addCommand('game_joints_sequence', 'Toggle joints sequence ON/OFF', function():String {
                _JOINTS_SEQUENCE = !_JOINTS_SEQUENCE;
                return 'joints_sequence = ' +  _JOINTS_SEQUENCE;
            }));

            _commands.push(Console.addCommand('game_static_infected', 'Toggle infected static body ON/OFF', function():String {
                _STATIC_INFECTION = !_STATIC_INFECTION;
                return 'joints dont work with static infection, value  = ' + _STATIC_INFECTION;
            }));

            _commands.push(Console.addCommand('game_infections_per_frame', 'Set count, default ' + _INFECTIONS_PER_FRAME, function(value:int):String {
                _INFECTIONS_PER_FRAME = value;
                return 'infections per frame = ' + _INFECTIONS_PER_FRAME;
            }, new Args().add('time', int, 'count', _INFECTIONS_PER_FRAME), false));

        }

        public static function logParams():void {
            Console.log('infected_time = ' + _INFECTED_TIME);
            Console.log('boom_before = ' + _BOOM_BEFORE);
            Console.log('boom_after = ' + _BOOM_AFTER);
            Console.log('with_joints = ' + _JOINTS_MODE);
            Console.log('joints_sequence = ' +  _JOINTS_SEQUENCE);
            Console.log('static_infection  = ' + _STATIC_INFECTION);
            Console.log('infections_per_frame = ' + _INFECTIONS_PER_FRAME);
        }

        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------

        public function Game(width:int = 800, height:int = 600, gravity:Number = 0) {
            super();
            this.init(width, height, gravity);
            super.addEventListener(Event.ADDED_TO_STAGE, this.addedToStageHandler);
        }

        //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        private var _level:Level;

        /**
         * @private
         */
        private var _render:Render;

        /**
         * @private
         */
        private var _time:int;

        /**
         * @private
         */
        private var _bubble:CbType;

        /**
         * @private
         */
        private var _infectedBubble:CbType;

        /**
         * @private
         */
        private var _infectedQueue:Vector.<Body>;

        /**
         * @private
         */
        private var _infectedBodies:Vector.<Body>;

        /**
         * @private
         */
        private var _joints:Vector.<WeldJoint>;

        //--------------------------------------------------------------------------
        //
        //  Private methods
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        private function init(width:int, height:int, gravity:Number = 0):void {
            _level = new Level(width, height, gravity);
            _time = getTimer();
            _render = new Render(this, width, height);

            _bubble = new CbType();
            _infectedBubble = new CbType();

            _level.addListener(_bubble, _infectedBubble, collisionListener);
            _level.init(_bubble);

            _infectedQueue = new Vector.<Body>();
            _infectedBodies = new Vector.<Body>();
            _joints = new Vector.<WeldJoint>();

            Console.addCommand('game_get_count', 'input balls count', getBallsCount, new Args().addArg(new Arg(
                    'podrobno', Boolean, 'podrobnuy otchet', [true, false], true
            )));
        }

        private function getBallsCount(data:Object):String {
            if (data['podrobno']) {
                var str:String = '';
                var colors:Object = {};
                _level.space.bodies.foreach(function(b:Body):void {
                    if (b.userData['color']) {
                        if (colors[b.userData['color']]) colors[b.userData['color']]++;
                        else colors[b.userData['color']] = 1;
                    }
                });
                for (var key:uint in colors) {
                    str += key.toString(16) + ': ' + colors[key] + '\n';
                }

                return str  + 'Balls count = ' + _level.space.bodies.length.toString();
            } else {
                return 'Balls count = ' + _level.space.bodies.length.toString();
            }
        }

        /**
         * @private
         */
        private function collisionListener(cb:InteractionCallback):void {
            if (!_infectedBodies.length) return;

            var body:Body = cb.int1.castBody;

            if (_infectedBodies[0].userData.color == body.userData.color) {
                killBody(body);
            }
        }

        /**
         * @private
         */
        private function infectBody(body:Body):void {
            var hero:Body = _infectedBodies.length ? _JOINTS_SEQUENCE ? _infectedBodies[_infectedBodies.length - 1] : _infectedBodies[0] : body;
            body.cbTypes.remove(_bubble);
            body.cbTypes.add(_infectedBubble);
            body.userData.infected_at = _time || hero.userData.infected_at;
            _infectedBodies.push(body);

            var len:int = _infectedBodies.length;
            if (len > 1 && _JOINTS_MODE && !_STATIC_INFECTION) {
                var point:Vec2 = Vec2.get((hero.position.x + body.position.x) / 2, (hero.position.y + body.position.y) / 2);
                var joint:WeldJoint;


                if (_joints.length > len - 1) {

                    joint = _joints[len - 1];
                    joint.body1 = hero;
                    joint.body2 = body;
                    joint.anchor1 = hero.worldPointToLocal(point);
                    joint.anchor2 = body.worldPointToLocal(point);
                } else {
                    joint =  new WeldJoint(hero, body, hero.worldPointToLocal(point), body.worldPointToLocal(point));
                    joint.debugDraw = true;
                    _joints.push(joint);
                }

                joint.space = _level.space;
            }

            if (_STATIC_INFECTION) body.type = BodyType.STATIC;

            body.arbiters.foreach(function (arb:CollisionArbiter):void {
                var b:Body = arb.body1 == body ? arb.body2 : arb.body1;
                if (b == hero) return;
                if (body.userData.color == b.userData.color) {
                    killBody(b);
                }
            });
        }

        /**
         * @private
         */
        private function killBody(body:Body):void {
            if (_infectedQueue.indexOf(body) < 0 && _infectedBodies.indexOf(body) < 0) {
                //body.cbTypes.remove(_bubble);
                //body.cbTypes.add(_infectedBubble);
                //body.userData.infected_at = _time || _infectedBodies[0].userData.infected_at;
                _infectedQueue.push(body);
            }
        }

        /**
         * @private
         */
        private function update(time:Number):void {
            //trace(_infectedQueue.length)
            if (_infectedQueue.length) {
                var i:int = 0;
                while (i++ < _INFECTIONS_PER_FRAME) {
                    if (_infectedQueue.length) infectBody(_infectedQueue.shift());
                }
            } else if (_infectedBodies.length) {
                if (_infectedBodies[0].userData.infected_at + _INFECTED_TIME < this._time) {
                    disposeBody();
                }
            }

            _level.update(time);

            _render.render(_level.space, _joints);
        }

        /**
         * @private
         */
        private function setBody(body:Body):void {
            if (this._infectedBodies.length) this.disposeBody();

            killBody(body);

            if (_BOOM_BEFORE) boom(body.position);
        }

        /**
         * @private
         */
        private function disposeBody():void {
            if (_infectedQueue.length) _infectedQueue = new Vector.<Body>();

            if (_BOOM_AFTER)  boom(_infectedBodies[0].position);

            var row:int = 0;
            var count:int = 0;

            while (_infectedBodies.length)  {
                var body:Body = _infectedBodies.pop();
                body.type = BodyType.DYNAMIC;
                body.userData.infected_at = null;
                body.cbTypes.remove(_infectedBubble);
                body.cbTypes.add(_bubble);
                body.userData.color = Level.getRandomColor();


                body.position.x = Math.random() * _level.width;
                body.position.y = Math.random() * 300;
                //_level.width / Level.BUBBLE_RADIUS
                count++;
            }

            if (_JOINTS_MODE) {
                for each (var j:WeldJoint in _joints) {
                    j.space = null;
                }
            }
        }

        /**
         * @private
         */
        private function boom(vec:Vec2):void {
            const explosionRadius:Number = 128;

            var bodyList:BodyList = _level.space.bodiesInCircle(vec, explosionRadius);
            bodyList.foreach(function(body:Body):void {
                var len:Number = Vec2.distance(vec, body.position);
                var imp:Vec2 = body.position.sub(vec);
                var len2:Number = imp.length;

                imp.muleq(1 / len2);
                imp.muleq(((explosionRadius - len) / explosionRadius) * 1000);

                body.applyImpulse(imp, body.position);
            });
        }

        //--------------------------------------------------------------------------
        //
        //  Event handlers
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         */
        private function addedToStageHandler(event:Event):void {
            super.removeEventListener(Event.ADDED_TO_STAGE, this.addedToStageHandler);

            super.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
            super.addEventListener(Event.ENTER_FRAME, this.enterFrameHandler);
            super.addEventListener(MouseEvent.MOUSE_DOWN, this.mouseDownHandler);
            //super.addEventListener(MouseEvent.MOUSE_UP, this.mouseUpHandler);
        }

        /**
         * @private
         */
        private function removedFromStage(event:Event):void {
            super.removeEventListener(Event.REMOVED_FROM_STAGE, this.removedFromStage);
            super.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
            super.removeEventListener(Event.ENTER_FRAME, this.enterFrameHandler);
            super.removeEventListener(MouseEvent.MOUSE_DOWN, this.mouseDownHandler);

            _level.space.clear();
            Console.getInstance().controller.remove('game_get_count');
        }

        /**
         * @private
         */
        private function enterFrameHandler(event:Event):void {
            var delta:int = getTimer() - this._time;
            this._time += delta;
            var time:Number = delta / 1000;

            this.update(time);
        }

        /**
         * @private
         */
        private function mouseDownHandler(event:MouseEvent):void {
            //if (!_infectedBodies.length) return;
            var mp:Vec2 = Vec2.get(mouseX, mouseY);
            var bodyList:BodyList = _level.space.bodiesUnderPoint(mp);
            for (var i:uint = 0; i < bodyList.length; i++) {
                var body:Body = bodyList.at(i);

                if (body.isDynamic() && (!_infectedBodies.length || body != _infectedBodies[0])) {
                    this.setBody(body);
                    break;
                }
            }

            mp.dispose();
        }
    }
}
