package haxe.ui.backend;

import haxe.ui.backend.luxe.StyleGeometry;
import haxe.ui.core.Component;
import haxe.ui.core.ImageDisplay;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.TextDisplay;
import haxe.ui.core.TextInput;
import haxe.ui.core.UIEvent;
import haxe.ui.styles.Style;
import haxe.ui.Toolkit;
import haxe.ui.util.Rectangle;
import haxe.ui.util.CallStackHelper;

class ComponentBase {
    private var _eventMap:Map<String, UIEvent->Void>;

    public function new() {
        _eventMap = new Map<String, UIEvent->Void>();
    }

    public function handleCreate(native:Bool) {

    }

    private function handlePosition(left:Null<Float>, top:Null<Float>, style:Style):Void {
        if (left != null) {
            g.x = left;
        } else {
            g.x = 0;
        }

        if (top != null) {
            g.y = top;
        } else {
            g.y = 0;
        }

        update(style);
    }

    private function handleSize(width:Null<Float>, height:Null<Float>, style:Style) {
        if (width != null) {
            g.w = width;
        }
        if (height != null) {
            g.h = height;
        }
        update(style);
    }

    private function handleClipRect(value:Rectangle):Void {
        update();
    }

    private function handleReady() {
    }

    private function handlePreReposition() {

    }

    private function handlePostReposition() {

    }

    public var screenX(get, null):Float;
    private function get_screenX():Float {
        var c:Component = cast(this, Component);
        var xpos:Float = 0;
        while (c != null) {
            xpos += c.left;
            if (c.clipRect != null) {
                xpos -= c.clipRect.left;
            }
            c = c.parentComponent;
        }
        return xpos;
    }

    public var screenY(get, null):Float;
    private function get_screenY():Float {
        var c:Component = cast(this, Component);
        var ypos:Float = 0;
        while (c != null) {
            ypos += c.top;
            if (c.clipRect != null) {
                ypos -= c.clipRect.top;
            }
            c = c.parentComponent;
        }
        return ypos;
    }


    //***********************************************************************************************************
    // Text related
    //***********************************************************************************************************
    private var _textDisplay:TextDisplay;
    public function createTextDisplay(text:String = null):TextDisplay {
        if (_textDisplay == null) {
            _textDisplay = new TextDisplay();
            _textDisplay.parent = this;
        }
        if (text != null) {
            _textDisplay.text = text;
        }
        return _textDisplay;
    }

    public function getTextDisplay():TextDisplay {
        return createTextDisplay();
    }

    public function hasTextDisplay():Bool {
        return (_textDisplay != null);
    }

    private var _textInput:TextInput;
    public function createTextInput(text:String = null):TextInput {
        if (_textInput == null) {
            _textInput = new TextInput();
            _textInput.parent = this;
        }
        if (text != null) {
            _textInput.text = text;
        }
        return _textInput;
    }

    public function getTextInput():TextInput {
        return createTextInput();
    }

    public function hasTextInput():Bool {
        return (_textInput != null);
    }

    //***********************************************************************************************************
    // Image related
    //***********************************************************************************************************
    private var _imageDisplay:ImageDisplay;
    public function createImageDisplay():ImageDisplay {
        if (_imageDisplay == null) {
            _imageDisplay = new ImageDisplay();
            _imageDisplay.parent = this;
        }
        return _imageDisplay;
    }

    public function getImageDisplay():ImageDisplay {
        return createImageDisplay();
    }

    public function hasImageDisplay():Bool {
        return (_imageDisplay != null);
    }

    public function removeImageDisplay():Void {
        if (_imageDisplay != null) {
            _imageDisplay.dispose();
            _imageDisplay = null;
        }
    }

    //***********************************************************************************************************
    // Display tree
    //***********************************************************************************************************
    @:access(haxe.ui.core.Component)
    public function update(style:Style = null) {
        var c:Component = cast(this, Component);
        if (c.hidden == true) {
            return;
        }

        g.depth = _depth;
        g.x = screenX;
        g.y = screenY;// - clipY;
        g.w = cast(this, Component).componentWidth;
        g.h = cast(this, Component).componentHeight;
        g.update(style);

        if (_imageDisplay != null) {
            _imageDisplay.redraw(_depth + .5);
        }

        if (_textDisplay != null) {
            _textDisplay.redraw(_depth + .5);
        }

        if (_textInput != null) {
            _textInput.redraw(_depth + .5);
        }

        for (child in __children) {
            child.update();
        }

        if (c.clipRect != null) {
            var clipRect = c.clipRect;
            updateClipAll(screenX + clipRect.left + 0, screenY + clipRect.top + 0, clipRect.width - 0, clipRect.height - 0);
        }
    }

    private function assignDepth(c:ComponentBase, d:Float):Float {
        if (c == null) {
            return d;
        }

        d++;
        c._depth = d;
        for (child in c.__children) {
            d = assignDepth(child, d);
        }

        return d;
    }

    private var _depth:Float = 1;
    private var __children:Array<ComponentBase> = new Array<ComponentBase>();
    private function handleAddComponent(child:Component):Component {
        __children.push(child);

        var c:Component = cast(this, Component);
        if (c.parentComponent != null) {
            assignDepth(cast(c.parentComponent, ComponentBase), cast(c.parentComponent, ComponentBase)._depth);
        } else {
            assignDepth(this, this._depth);
        }

        update();
        return child;
    }

    private function handleRemoveComponent(child:Component, dispose:Bool = true):Component {
trace("remove - " + Type.getClassName(Type.getClass(child)) + ", " + dispose);
        if (dispose == true) {
            __children.remove(child);
            child.dispose();
        }

        if (this != null) {
            assignDepth(this, this._depth);
        }

        update();
        return child;
    }

    private function handleVisibility(show:Bool):Void {
        if (_g != null) {
            (show == true) ? _g.show() : _g.hide();
        }
        if (_textDisplay != null) {
            (show == true) ? _textDisplay.show() : _textDisplay.hide();
        }
        if (_textInput != null) {
            (show == true) ? _textInput.show() : _textInput.hide();
        }
        if (_imageDisplay != null) {
            (show == true) ? _imageDisplay.show() : _imageDisplay.hide();
        }

        if (__children != null) {
            for (child in __children) {
                child.handleVisibility(show);
            }
        }
    }

    private function dispose() {
        for (event in _eventMap.keys()) { // TODO: not sure this should happen
            unmapEvent(event, _eventMap.get(event));
        }
        if (_g != null) {
            _g.dispose();
            _g = null;
        }
        if (_textDisplay != null) {
            _textDisplay.dispose();
        }
        if (_textInput != null) {
            _textInput.dispose();
        }
        if (_imageDisplay != null) {
            trace("IMAGE DISPOSE: " + Type.getClassName(Type.getClass(this)));
            _imageDisplay.dispose();
        }

        if (__children != null) {
            for (child in __children) {
                child.dispose();
            }
        }
    }

    //***********************************************************************************************************
    // Redraw callbacks
    //***********************************************************************************************************
    private var _g:StyleGeometry;
    private var g(get, null):StyleGeometry;
    private function get_g():StyleGeometry {
        if (_g == null) {
            _g = new StyleGeometry();
        }
        return _g;
    }

    private function updateClipAll(x:Float, y:Float, w:Float, h:Float) {
        if (_g != null) {
            _g.updateClip(x, y, w, h);
        }
        if (_textDisplay != null) {
            _textDisplay.updateClip(x, y, w, h);
        }
        if (_textInput != null) {
            _textInput.updateClip(x, y, w, h);
        }
        if (_imageDisplay != null) {
            _imageDisplay.updateClip(x, y, w, h);
        }
        for (child in __children) {
            child.updateClipAll(x, y, w, h);
        }
    }

    private function applyStyle(style:Style) {
        update(style);
    }

    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************
    @:access(haxe.ui.core.Component)
    private function inBounds(x:Float, y:Float):Bool {
        if (cast(this, Component).hidden == true) {
            return false;
        }

        var b:Bool = false;
        var sx = screenX;
        var sy = screenY;
        var cx = cast(this, Component).componentWidth;
        var cy = cast(this, Component).componentHeight;

        if (x >= sx && y >= sy && x <= sx + cx && y <= sy + cy) {
            b = true;
        }

        // let make sure its in the clip rect too
        if (b == true && _g != null && _g.clip_rect != null) {
            b = false;
            var sx = _g.clip_rect.x;
            var sy = _g.clip_rect.y;
            var cx = _g.clip_rect.w;
            var cy = _g.clip_rect.h;
            if (x >= sx && y >= sy && x <= sx + cx && y <= sy + cy) {
                b = true;
            }
        }
        return b;
    }

    private function mapEvent(type:String, listener:UIEvent->Void) {
        switch (type) {
            case MouseEvent.MOUSE_OVER:
                if (_eventMap.exists(MouseEvent.MOUSE_OVER) == false) {
                    Toolkit.screen.registerEvent(MouseEvent.MOUSE_MOVE, __onMouseMove);
                    _eventMap.set(MouseEvent.MOUSE_OVER, listener);
                }
            case MouseEvent.MOUSE_OUT:
                if (_eventMap.exists(MouseEvent.MOUSE_OUT) == false) {
                    Toolkit.screen.registerEvent(MouseEvent.MOUSE_MOVE, __onMouseMove);
                    _eventMap.set(MouseEvent.MOUSE_OUT, listener);
                }
            case MouseEvent.MOUSE_DOWN:
                if (_eventMap.exists(MouseEvent.MOUSE_DOWN) == false) {
                    Toolkit.screen.registerEvent(MouseEvent.MOUSE_DOWN, __onMouseDown);
                    Toolkit.screen.registerEvent(MouseEvent.MOUSE_UP, __onMouseUp);
                    _eventMap.set(MouseEvent.MOUSE_DOWN, listener);
                }
            case MouseEvent.MOUSE_UP:
                if (_eventMap.exists(MouseEvent.MOUSE_UP) == false) {
                    Toolkit.screen.registerEvent(MouseEvent.MOUSE_UP, __onMouseUp);
                    _eventMap.set(MouseEvent.MOUSE_UP, listener);
                }

            case MouseEvent.CLICK:
                if (_eventMap.exists(MouseEvent.CLICK) == false) {
                    Toolkit.screen.registerEvent(MouseEvent.MOUSE_DOWN, __onMouseDown);
                    Toolkit.screen.registerEvent(MouseEvent.MOUSE_UP, __onMouseUp);
                    _eventMap.set(MouseEvent.CLICK, listener);
                }
        }
    }

    private function unmapEvent(type:String, listener:UIEvent->Void) {
        _eventMap.remove(type);

        // clean up
        if (_eventMap.exists(MouseEvent.MOUSE_OVER) == false
            && _eventMap.exists(MouseEvent.MOUSE_OUT) == false) {
            Toolkit.screen.unregisterEvent(MouseEvent.MOUSE_MOVE, __onMouseMove);
        }
        if (_eventMap.exists(MouseEvent.MOUSE_DOWN) == false
            && _eventMap.exists(MouseEvent.CLICK) == false) {
            Toolkit.screen.unregisterEvent(MouseEvent.MOUSE_DOWN, __onMouseDown);
        }
        if (_eventMap.exists(MouseEvent.MOUSE_DOWN) == false
            && _eventMap.exists(MouseEvent.MOUSE_UP) == false
            && _eventMap.exists(MouseEvent.CLICK) == false) {
            Toolkit.screen.unregisterEvent(MouseEvent.MOUSE_UP, __onMouseUp);
        }
    }

    private var _mouseDownFlag:Bool = false;
    private var _mouseOverFlag:Bool = false;
    private function __onMouseMove(event:MouseEvent) {
        var c:Component = cast(this, Component);
        if (c.hidden == true) {
            return;
        }

        var i = inBounds(event.screenX, event.screenY);
        if (i == true && _mouseOverFlag == false) {
            _mouseOverFlag = true;
            dispatchMouseEvent(MouseEvent.MOUSE_OVER, event);
        } else if (i == false && _mouseOverFlag == true) {
            _mouseOverFlag = false;
            dispatchMouseEvent(MouseEvent.MOUSE_OUT, event);
        }
    }

    private function __onMouseDown(event:MouseEvent) {
        var c:Component = cast(this, Component);
        if (c.hidden == true) {
            return;
        }

        var i = inBounds(event.screenX, event.screenY);
        if (i == true && _mouseDownFlag == false) {
            _mouseDownFlag = true;
            dispatchMouseEvent(MouseEvent.MOUSE_DOWN, event);
        }
    }

    private function __onMouseUp(event:MouseEvent) {
        var c:Component = cast(this, Component);
        if (c.hidden == true) {
            return;
        }

        var i = inBounds(event.screenX, event.screenY);
        if (i == true) {
            if (_mouseDownFlag == true) {
                dispatchMouseEvent(MouseEvent.CLICK, event);
            }

            _mouseDownFlag = false;
            dispatchMouseEvent(MouseEvent.MOUSE_UP, event);
        }
        _mouseDownFlag = false;
    }

    private function dispatchMouseEvent(type:String, copyFrom:MouseEvent) {
        var fn:UIEvent->Void = _eventMap.get(type);
        if (fn != null) {
            var mouseEvent = new MouseEvent(type);
            mouseEvent.screenX = copyFrom.screenX;
            mouseEvent.screenY = copyFrom.screenY;
            fn(mouseEvent);
        }
    }
}