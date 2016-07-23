package haxe.ui.backend;

import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.dialogs.DialogButton;
import haxe.ui.core.Component;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.UIEvent;
import haxe.ui.util.EventMap;

class ScreenBase {
	private var _mapping:Map<String, UIEvent->Void>;
	
	public function new() {
		_mapping = new Map<String, UIEvent->Void>();
	}

	public var options(default, default):Dynamic;
	
	public var width(get, null):Float;	
	public function get_width():Float {
		return Luxe.screen.w;
	}
	
	public var height(get, null):Float;	
	public function get_height() {
		return Luxe.screen.h;
	}
	
	public var focus(get, set):Component;
	private function get_focus():Component {
		return null;
	}
	private function set_focus(value:Component):Component {
		return value;
	}
	
	private var _topLevelComponents:Array<Component> = new Array<Component>();
	public function addComponent(component:Component) {
		_topLevelComponents.push(component);
		resizeComponent(component);
		//component.dispatchReady();
	}
	
    public function removeComponent(component:Component) {
        _topLevelComponents.remove(component);
    }
    
	private function resizeComponent(c:Component) {
		if (c.percentWidth > 0) {
			c.width = (this.width * c.percentWidth) / 100;
		}
		if (c.percentHeight > 0) {
			c.height = (this.height * c.percentHeight) / 100;
		}
	}
	
	//***********************************************************************************************************
	// Dialogs
	//***********************************************************************************************************
    public function messageDialog(message:String, title:String = null, options:Dynamic = null, callback:DialogButton->Void = null):Dialog {
        return null;
    }
    
    public function showDialog(content:Component, options:Dynamic = null, callback:DialogButton->Void = null):Dialog {
        return null;
    }
    
    public function hideDialog(dialog:Dialog):Bool {
        return false;
    }
    
	//***********************************************************************************************************
	// Events
	//***********************************************************************************************************
	private static var HAXEUI_TO_LUXE_EVENT:Map<String, Luxe.Ev> = [
		MouseEvent.MOUSE_DOWN => Luxe.Ev.mousedown,
		MouseEvent.MOUSE_UP => Luxe.Ev.mouseup,
		MouseEvent.MOUSE_MOVE => Luxe.Ev.mousemove
	];
	
	private static var LUXE_STATE_TO_HAXEUI_EVENT:Map<luxe.Input.InteractState, String> = [
		luxe.Input.InteractState.down => MouseEvent.MOUSE_DOWN,
		luxe.Input.InteractState.up => MouseEvent.MOUSE_UP,
		luxe.Input.InteractState.move => MouseEvent.MOUSE_MOVE
	];
	
	private function supportsEvent(type:String):Bool {
		return HAXEUI_TO_LUXE_EVENT.get(type) != null;
	}
	
	private function mapEvent(type:String, listener:UIEvent->Void) {
		switch (type) {
			case MouseEvent.MOUSE_DOWN | MouseEvent.MOUSE_UP | MouseEvent.MOUSE_MOVE:
				if (_mapping.exists(type) == false) {
					_mapping.set(type, listener);
					Luxe.core.on(HAXEUI_TO_LUXE_EVENT.get(type), __onMouseEvent);
				}
		}
	}
	
	private function unmapEvent(type:String, listener:UIEvent->Void) {
		switch (type) {
			case MouseEvent.MOUSE_DOWN | MouseEvent.MOUSE_UP | MouseEvent.MOUSE_MOVE:
				_mapping.remove(type);
				Luxe.core.off(HAXEUI_TO_LUXE_EVENT.get(type), __onMouseEvent);
		}
	}
	
	private function __onMouseEvent(event:luxe.Input.MouseEvent) {
		var type:String = LUXE_STATE_TO_HAXEUI_EVENT.get(event.state);
		if (type != null) {
			var fn = _mapping.get(type);
			if (fn != null) {
				var mouseEvent = new MouseEvent(type);
				mouseEvent.screenX = event.x;
				mouseEvent.screenY = event.y;
				fn(mouseEvent);
			}
		}
	}
}