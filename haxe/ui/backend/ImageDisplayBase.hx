package haxe.ui.backend;

import haxe.ui.util.Rectangle;
import haxe.ui.backend.ComponentBase;
import haxe.ui.core.Component;
import haxe.ui.assets.ImageInfo;
import phoenix.Rectangle;
import phoenix.Vector;

class ImageDisplayBase {
    public var aspectRatio:Float = 1; // width x height
    //public var _texture:phoenix.Texture;
    public var _sprite:luxe.Sprite;

    public var parent:ComponentBase;

    public function new() {

    }

    private var _left:Float = 0;
    public var left(get, set):Float;
    private function get_left():Float {
        return _left;
    }
    private function set_left(value:Float):Float {
        _left = value;
        return value;
    }

    private var _top:Float = 0;
    public var top(get, set):Float;
    private function get_top():Float {
        return _top;
    }
    private function set_top(value:Float):Float {
        _top = value;
        return value;
    }

    private var _imageWidth:Float = -1;
    public var imageWidth(get, set):Float;
    private function set_imageWidth(value:Float):Float {
        return value;
    }

    private function get_imageWidth():Float {
        if (_imageInfo == null) {
            return 0;
        }
        return _imageWidth;
    }

    private var _imageHeight:Float = -1;
    public var imageHeight(get, set):Float;
    private function set_imageHeight(value:Float):Float {
        return value;
    }

    private function get_imageHeight():Float {
        if (_imageInfo == null) {
            return 0;
        }
        return _imageHeight;
    }

    public function redraw(depth:Float) {
        if (_imageInfo != null) {
            if (_sprite == null) {
                _sprite = new luxe.Sprite({
                    texture: _imageInfo.data,
                    centered: false,
                });
            }

            _sprite.depth = depth + 0.002;
            _sprite.pos = new Vector(parent.screenX + left, parent.screenY + top);
        }
    }

    public function hide() {
        if (_sprite != null) {
            _sprite.visible = false;
        }
    }

    public function show() {
        if (_sprite != null) {
            _sprite.visible = true;
        }
    }


    public function updateClip(x:Float, y:Float, w:Float, h:Float) {
        if (_sprite != null) {
            _sprite.clip_rect = new Rectangle(x, y, w, h);
        }
    }

    private var _imageInfo:ImageInfo;
    public var imageInfo(get, set):ImageInfo;
    private function get_imageInfo():ImageInfo {
        return _imageInfo;
    }
    private function set_imageInfo(value:ImageInfo):ImageInfo {
        dispose();
        _imageInfo = value;
        _imageWidth = _imageInfo.width;
        _imageHeight = _imageInfo.height;
        aspectRatio = _imageWidth / _imageHeight;
        updateParentWithClip();
        return value;
    }

    public var imageClipRect(get, set):Rectangle;
    private var _imageClipRect:Rectangle;
    public function get_imageClipRect():Rectangle {
        return _imageClipRect;
    }
    private function set_imageClipRect(value:Rectangle):Rectangle {
        _imageClipRect = value;

        //TODO
        if(value == null) {

        } else {

        }

        return value;
    }

    public function dispose():Void {
        if (_sprite != null) {
            _sprite.destroy(true);
            _sprite = null;
        }
    }

    // this might be ill concieved
    private function updateParentWithClip() {
        var p:Component = cast parent;
        while (p != null) {
            if (p.clipRect != null) {
                p.invalidateDisplay();
                break;
            }
            p = p.parentComponent;
        }
    }
}