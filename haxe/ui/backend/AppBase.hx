package haxe.ui.backend;

class AppBase {
    public function new() {

    }

    private function build() {
    }

    private function getToolkitInit():Dynamic {
        return {
        };
    }

    private function init(callback:Void->Void, onEnd:Void->Void = null) {
        callback();
    }

    public function start() {

    }
}