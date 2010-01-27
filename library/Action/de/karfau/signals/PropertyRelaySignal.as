package de.karfau.signals
{
  import flash.events.*;
  import flash.utils.*;
  import org.osflash.signals.*;

  public class PropertyRelaySignal extends DeluxeSignal {
    protected var _eventType:String;
    protected var _eventClass:Class;
    protected var properties:Array;

    public function PropertyRelaySignal(target:IEventDispatcher, eventType:String, eventClass:Class = null, properties:Array = null) {
      var dt:XML;
      var accessor:XML;
      var prop:String;
      var target:* = target;
      var eventType:* = eventType;
      var eventClass:* = eventClass;
      var properties:* = properties;
      this._eventType = eventType;
      if (!eventClass){
      }
      this._eventClass = Event;
      super(target);
      this.properties = [];
      if (properties){
        dt = describeType(eventClass);
        var _loc_6:int = 0;
        var _loc_7:* = properties;
        while (_loc_7 in _loc_6){
          
          prop = _loc_7[_loc_6];
          var _loc_9:int = 0;
          var _loc_10:* = dt..accessor;
          var _loc_8:* = new XMLList("");
          for each (_loc_11 in _loc_10){
            
            var _loc_12:* = _loc_11;
            with (_loc_11){
              if (@name == prop){
                _loc_8[_loc_9] = _loc_11;
              }
            }
          }
          accessor = _loc_8[0];
          if (accessor != null){
            this.properties.push(prop);
            _valueClasses.push(getDefinitionByName(accessor.@type) as Class);
            continue;
          }
          throw new ArgumentError("Invalid properties argument: property \"" + prop + "\" not found in " + this._eventClass + ".");
        }
      }
      return;
    }
    override public function dispatch(... args) : void {
      args = null;
      var _loc_3:* = undefined;
      var _loc_4:String = null;
      if (args.length == 1){
      }
      if (args[0] is this._eventClass){
        args = [];
        _loc_3 = args[0] as this._eventClass;
        for each (_loc_4 in this.properties){
          
          args.push(_loc_3[_loc_4]);
        }
        super.dispatch.apply(null, args);
      }
      else{
        super.dispatch.apply(null, args);
      }
      return;
    }
    override public function set target(value:Object) : void {
      if (value == _target){
        return;
      }
      IEventDispatcher(_target).removeEventListener(this._eventType, this.dispatch);
      IEventDispatcher(value).addEventListener(this._eventType, this.dispatch, false, 0);
      _target = value;
      return;
    }
    override public function add(listener:Function, priority:int = 0) : void {
      var _loc_3:* = listeners.length;
      super.add(listener);
      if (_loc_3 == 0){
      }
      if (listeners.length == 1){
        IEventDispatcher(_target).addEventListener(this._eventType, this.dispatch, false, priority);
      }
      return;
    }
    override public function addOnce(listener:Function, priority:int = 0) : void {
      var _loc_3:* = listeners.length;
      super.addOnce(listener);
      if (_loc_3 == 0){
      }
      if (listeners.length == 1){
        IEventDispatcher(target).addEventListener(this._eventType, this.dispatch, false, priority);
      }
      return;
    }
    override public function remove(listener:Function) : void {
      var _loc_2:* = listeners.length;
      super.remove(listener);
      if (_loc_2 == 1){
      }
      if (listeners.length == 0){
        IEventDispatcher(_target).removeEventListener(this._eventType, this.dispatch);
      }
      return;
    }
  }
}
