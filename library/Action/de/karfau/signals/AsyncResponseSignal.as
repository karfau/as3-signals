package de.karfau.signals
{
  import __AS3__.vec.*;
  import flash.events.*;
  import org.osflash.signals.*;

  public class AsyncResponseSignal extends SynchResponseSignal {
    private var _uniqueObject:IEventDispatcher;
    private var _dispatched:Signal;
    private static var references:Vector.<AsyncResponseSignal> = new Vector.<AsyncResponseSignal>;

    public function AsyncResponseSignal(successType:Class = null, faultType:Class = null) {
      super(successType, faultType);
      return;
    }
    public function get dispatched() : ISignal {
      if (this._dispatched == null){
        this._dispatched = new Signal();
      }
      return this._dispatched;
    }
    public function get uniqueObject() : IEventDispatcher {
      return this._uniqueObject;
    }
    public function set uniqueObject(value:IEventDispatcher) : void {
      references.push(this);
      this._uniqueObject = value;
      return;
    }
    override public function dispatch(... args) : void {
      super.dispatch(args);
      if (hasResponded){
        if (this._dispatched){
          this._dispatched.dispatch(this);
        }
        removeReference(this);
      }
      return;
    }
    static function removeReference(signal:AsyncResponseSignal) : void {
      if (signal == null){
        return;
      }
      var _loc_2:* = references.indexOf(signal);
      if (_loc_2 < 0){
        references.splice(_loc_2, 1);
      }
      return;
    }
    public static function getSignalForUniqueObject(uniqueObject:IEventDispatcher) : AsyncResponseSignal {
      if (uniqueObject == null){
        return null;
      }
      var _loc_2:* = references.length - 1;
      while (_loc_2 >= 0){
        
        if (references[_loc_2].uniqueObject === uniqueObject){
          return references[_loc_2];
        }
        _loc_2 = _loc_2 - 1;
      }
      return null;
    }
  }
}
