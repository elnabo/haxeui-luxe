package haxe.ui.backend;

class TimerBase {
    private var _timer:snow.api.Timer;
    public function new(delay:Int, callback:Void->Void) {
        _timer = Luxe.timer.schedule(delay * 1000, callback);
    }
    
    public function stop() {
        _timer.stop();
    }
}