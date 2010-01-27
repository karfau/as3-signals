package de.karfau.signals
{
  import org.osflash.signals.*;

  public class SynchResponseSignal extends Signal implements IResponseSignal {
    protected var _resultValue:Object;
    protected var hasReturned:Boolean = false;
    protected var didSucceed:Boolean = false;
    protected var hasResponded:Boolean = false;
    private var onFault:Signal;

    public function SynchResponseSignal(successType:Class = null, faultType:Class = null) {
      if (faultType == null){
        this.onFault = new Signal(Object);
      }
      else{
        this.onFault = new Signal(faultType);
      }
      if (successType != null){
        if (!(successType is Class)){
          throw new ArgumentError("Invalid successType argument: " + " should be a Class but was:<" + successType + ">.");
        }
        valueClasses.push(successType);
      }
      return;
    }
    public function get returnsVoid() : Boolean {
      return _valueClasses.length == 0;
    }
    public function get successClass() : Class {
      return this.returnsVoid ? (null) : (_valueClasses[0]);
    }
    public function get faultClass() : Class {
      return this.onFault.valueClasses[0];
    }
    public function addResponse(success:Function, fault:Function) : void {
      super.addOnce(success);
      this.onFault.addOnce(fault);
      if (this.hasReturned){
        this.dispatch();
      }
      return;
    }
    public function applySuccess(value = null) : SynchResponseSignal {
      if (value == null){
      }
      if (!this.returnsVoid){
      }
      if (value is this.successClass){
        this._resultValue = value;
      }
      else{
        throw new ArgumentError("value " + value + " is not of expected type " + (this.returnsVoid ? ("void") : (this.successClass)));
      }
      this.setReadyToDispatch(true);
      this.dispatch();
      return this;
    }
    public function applyFault(info:Object) : SynchResponseSignal {
      if (info is this.faultClass){
        this._resultValue = info;
      }
      else{
        throw new ArgumentError("info " + info + " is not of expected type " + this.faultClass);
      }
      this.setReadyToDispatch(false);
      this.dispatch();
      return this;
    }
    override public function dispatch(... args) : void {
      if (!this.hasResponded){
        if (!this.hasReturned){
        }
        if (super.numListeners > 0){
          if (!this.returnsVoid){
          }
          if (args[0] is valueClasses[0]){
            this.applySuccess(args[0]);
          }
          else{
            if (this.returnsVoid){
            }
            if (args.length == 0){
              this.applySuccess();
            }
          }
        }
        if (this.hasReturned){
        }
        if (super.numListeners > 0){
          if (this.didSucceed){
            if (this.returnsVoid){
              super.dispatch();
            }
            else{
              super.dispatch(this._resultValue);
            }
          }
          else{
            this.onFault.dispatch(this._resultValue);
          }
          this.hasResponded = true;
        }
      }
      return;
    }
    private function setReadyToDispatch(success:Boolean) : void {
      this.hasReturned = true;
      this.didSucceed = success;
      return;
    }
  }
}
