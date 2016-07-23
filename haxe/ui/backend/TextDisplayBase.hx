package haxe.ui.backend;

import haxe.ui.assets.FontInfo;
import haxe.ui.backend.ComponentBase;
import haxe.ui.core.Component;
import luxe.Color;
import luxe.Vector;
import phoenix.Rectangle;

class TextDisplayBase {
    private var _string:String;
    public var _text:luxe.Text;

    public var parent:ComponentBase;

    public function new() {
    }

    public var left(default, set):Float;
    private function set_left(value:Float):Float {
        left = value;
        return value;
    }

    public var top(default, set):Float;
    private function set_top(value:Float):Float {
        top = value;
        return value;
    }

    public var width(default, default):Float;
    public var height(default, default):Float;

    public var text(get, set):String;
    private function get_text():String {
        return _string;
    }
    private function set_text(value:String):String {
        _string = value;
        return value;
    }

    public var textWidth(get, null):Float;
    private function get_textWidth():Float {
        if (_text != null) {
            return _text.text_bounds.w;
        }
        return 0;
    }

    public var textHeight(get, null):Float;
    private function get_textHeight():Float {
        if (_text != null) {
            return _text.text_bounds.h + 0;
        }
        return 0;
    }

    private var _color:Int = 0;
    public var color(get, set):Int;
    private function get_color():Int {
        return _color;
    }
    private function set_color(value:Int):Int {
        _color = value;
        if (_text != null) {
            _text.color = new Color().rgb(_color);
        }
        return value;
    }

    private var _font:FontInfo;
    private var _fontName:String;
    public var fontName(get, set):String;
    private function get_fontName():String {
        return _fontName;
    }
    private function set_fontName(value:String):String {
        if (value == _fontName) {
            return value;
        }

        _fontName = value;
        Toolkit.assets.getFont(value, function(font:FontInfo) {
            if (value == _fontName) { // make sure its the right font!
                _font = font;
                dispose(); // since were changing fonts, lets recreate the text
                if (parent != null) {
                    parent.update();
                    cast(parent, Component).invalidateLayout();
                    // TODO: doesnt seem right to have to invalidate the parents parent - layout should have done that
                    /*
                    if (cast(parent, Component).parentComponent != null) {
                        cast(parent, Component).parentComponent.invalidateLayout();
                    }
                    */
                }
            }
        });
        return value;
    }

    private var _fontSize:Float;// = 16;
    public var fontSize(get, set):Null<Float>;
    private function get_fontSize():Null<Float> {
        return _fontSize;
    }
    private function set_fontSize(value:Null<Float>):Null<Float> {
        if (value == _fontSize) {
            return value;
        }

        _fontSize = value;
        if (parent != null) {
            //parent.paint();
            parent.update();
            cast(parent, Component).invalidateLayout();
            // TODO: doesnt seem right to have to invalidate the parents parent - layout should have done that
            /*
            if (cast(parent, Component).parentComponent != null) {
                cast(parent, Component).parentComponent.invalidateLayout();
            }
            */
        }
        return value;
    }

    public function hide() {
        if (_text != null) {
            _text.visible = false;
        }
    }

    public function show() {
        if (_text != null) {
            _text.visible = true;
        }
    }

    public function updateClip(x:Float, y:Float, w:Float, h:Float) {
        if (_text != null) {
            _text.clip_rect = new Rectangle(x, y, w, h);
        }
    }

    public function redraw(depth:Float) {
        if (_string != null && parent != null && _font != null) {
            if (_text == null) {
                _text = new luxe.Text( {
                    font: _font.data,
                    point_size: _fontSize,
                    text: _string,
                    depth: depth + 0.02,
                    pos: new Vector(Std.int(parent.screenX + left + 0), Std.int(parent.screenY + top + 0)),
                    color: new Color().rgb(_color)
                });
            } else {
                _text.point_size = _fontSize;
                _text.text = _string;
                _text.depth = depth + 0.02;
                _text.pos.x = Std.int(parent.screenX + left + 0);
                _text.pos.y = Std.int(parent.screenY + top + 0);
                _text.color = new Color().rgb(_color);
            }
        }
    }

    public function dispose():Void {
        if (_text != null) {
            _text.destroy(true);
            _text = null;
        }
    }
}