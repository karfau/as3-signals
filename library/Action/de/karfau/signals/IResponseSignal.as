package de.karfau.signals
{

  public interface IResponseSignal {

    public function IResponseSignal();

    function addResponse(success:Function, fault:Function) : void;

    function get successClass() : Class;

    function get faultClass() : Class;

    function get returnsVoid() : Boolean;

  }
}
