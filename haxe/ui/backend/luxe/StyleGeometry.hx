package haxe.ui.backend.luxe;

import haxe.ui.assets.ImageInfo;
import haxe.ui.styles.Style;
import luxe.Color;
import luxe.NineSlice;
import luxe.Sprite;
import luxe.Visual;
import phoenix.Rectangle;
import phoenix.Vector;
import phoenix.geometry.LineGeometry;
import phoenix.geometry.QuadGeometry;

class StyleGeometry {
	private var _border:QuadGeometry;
	private var _fill:QuadGeometry;
	private var _background:Visual;
	
	public var clip_rect:Rectangle;
	
    private var _shadow:Array<LineGeometry>;
    
	public function new() {
		
	}
	
	public function dispose() {
        clearBorders();
		if (_border != null) {
			_border.drop();
			_border = null;
		}
		if (_fill != null) {
			_fill.drop();
			_fill = null;
		}
		if (_background != null) {
			_background.destroy(true);
			_background = null;
		}
	}
	
    public function hide() {
        if (_border != null) {
            _border.visible = false;
        }
        if (_borders != null) {
            for (b in _borders) {
                b.visible = false;
            }
        }
        if (_fill != null) {
            _fill.visible = false;
        }
        if (_background != null) {
            _background.visible = false;
        }
        if (_shadow != null) {
            for (s in _shadow) {
                s.visible = false;
            }
        }
    }
    
    public function show() {
        if (_border != null) {
            _border.visible = true;
        }
        if (_borders != null) {
            for (b in _borders) {
                b.visible = true;
            }
        }
        if (_fill != null) {
            _fill.visible = true;
        }
        if (_background != null) {
            _background.visible = true;
        }
        if (_shadow != null) {
            for (s in _shadow) {
                s.visible = true;
            }
        }
    }
    
	public function updateClip(x:Float, y:Float, w:Float, h:Float) {
		clip_rect = new Rectangle(x, y, w, h);
		if (_border != null) {
			_border.clip_rect = new Rectangle(x, y, w, h);
		}
		if (_borders != null) {
			for (b in _borders) {
                b.clip_rect = new Rectangle(x, y, w, h);
            }
		}
		if (_fill != null) {
			_fill.clip_rect = new Rectangle(x, y, w, h);
		}
		_cacheClip = new Rectangle(x, y, w, h);
		if (_background != null) {
			_background.clip_rect = new Rectangle(x, y, w, h);
		}
	}
	
	private var _backgroundBitmapId:String = null;
	
	private var _cacheX:Float;
	private var _cacheY:Float;
	private var _cacheW:Float;
	private var _cacheH:Float;
	private var _cacheDepth:Float;
	private var _cacheClip:Rectangle;
	
    private var _x:Null<Float>;
    public var x(null, set):Float;
    private function set_x(value:Float):Float {
        _x = value;
        update();
        return value;
    }
    
    private var _y:Null<Float>;
    public var y(null, set):Float;
    private function set_y(value:Float):Float {
        _y = value;
        update();
        return value;
    }
    
    private var _w:Null<Float>;
    public var w(null, set):Float;
    private function set_w(value:Float):Float {
        _w = value;
        update();
        return value;
    }
    
    private var _h:Null<Float>;
    public var h(null, set):Float;
    private function set_h(value:Float):Float {
        _h = value;
        update();
        return value;
    }
    
    private var _depth:Null<Float>;
    public var depth(null, set):Float;
    private function set_depth(value:Float):Float {
        _depth = value;
        update();
        return value;
    }
    
    private var _style:Style;
    public var style(null, set):Style;
    private function set_style(value:Style):Style {
        _style = value;
        update();
        return value;
    }
    
    public function update(style:Style = null):Void {
        if (_x == null) {
            _x = 0;
            return;
        }
        if (_y == null) {
            _y = 0;
            return;
        }
        if (_w == null || _h == null) {
            return;
        }
        if (style != null) {
            _style = style;
        }
        if (_style == null) {
            return;
        }
        handleUpdate(_x, _y, _w, _h, _depth, _style);
    }
    
    private var _borders:Array<LineGeometry>;
    
	private function handleUpdate(x:Float, y:Float, w:Float, h:Float, depth:Float, style:Style) {
		if (w <= 0 || h <= 0) {
            if (_border != null) {
                _border.visible = false;
            }
            if (_fill != null) {
                _fill.visible = false;
            }
            if (_background != null) {
                _background.visible = false;
            }
			return;
		}
		
        x = Math.ffloor(x);
        y = Math.ffloor(y);
        w = Math.fceil(w);
        h = Math.fceil(h);
        
		var borderRadius:Float = 0;
		if (style.borderRadius != null) {
			borderRadius = style.borderRadius;
		}
		
        var opacity:Float = 1;
        if (style.opacity != null) {
            opacity = style.opacity;
        }
        
		var borderSize:Float = 0;
        if (style.borderLeftColor != null
            && style.borderLeftColor == style.borderRightColor
            && style.borderLeftColor == style.borderBottomColor
            && style.borderLeftColor == style.borderTopColor) { // full border
                
            borderSize = style.borderLeftSize;
            clearBorders();
            
            addBorder(x, y, x + w, y, rgba(style.borderTopColor, opacity), depth);
            addBorder(x + w, y, x + w, y + h, rgba(style.borderRightColor, opacity), depth);
            addBorder(x + w - 1, y + h - 1, x + 1, y + h - 1, rgba(style.borderBottomColor, opacity), depth);
            addBorder(x + 1, y, x + 1, y + h, rgba(style.borderLeftColor, opacity), depth);
            
            x += borderSize;
            y += borderSize;
            w -= 2 * borderSize;
            h -= 2 * borderSize;
            
        } else { // compound border  
            clearBorders();
            if (style.borderTopSize != null && style.borderTopSize > 0) {
                addBorder(x, y, x + w, y, rgba(style.borderTopColor, opacity), depth);
            }
            
            if (style.borderLeftSize != null && style.borderLeftSize > 0) {
                addBorder(x + 1, y, x + 1, y + h, rgba(style.borderLeftColor, opacity), depth);
            }
            
            if (style.borderBottomSize != null && style.borderBottomSize > 0) {
                addBorder(x + w - 1, y + h - 1, x + 1, y + h - 1, rgba(style.borderBottomColor, opacity), depth);
            }
            
            if (style.borderRightSize != null && style.borderRightSize > 0) {
                addBorder(x + w, y, x + w, y + h, rgba(style.borderRightColor, opacity), depth);
            }
            
            // shrink rect for fill
            if (style.borderTopSize != null && style.borderTopSize > 0) {
                y += style.borderTopSize;
            }
            if (style.borderLeftSize != null && style.borderLeftSize > 0) {
                x += style.borderLeftSize;
            }
            if (style.borderBottomSize != null && style.borderBottomSize > 0) {
                h -= 2 * style.borderBottomSize;
            }
            if (style.borderRightSize != null && style.borderRightSize > 0) {
                w -= 2 * style.borderRightSize;
            }
        }
		
		if (style.backgroundColor != null) {
			if (style.backgroundColorEnd != null && style.backgroundColor != style.backgroundColorEnd) { // gradient
				if (_fill == null) {
					_fill = Luxe.draw.box( {
						x: x,
						y: y,
						w: w,
						h: h,
						color: rgba(style.backgroundColor, opacity),
						depth: depth + 0.001,
					});
				} else {
					_fill.set_xywh(x, y, w, h);
					_fill.depth = depth + 0.001;
					_fill.color = rgba(style.backgroundColor, opacity);
				}
				
				var direction:String = "vertical";
				if (style.backgroundGradientStyle != null) {
					direction = style.backgroundGradientStyle;
				}
				
				if (direction == "vertical") {
					_fill.vertices[0].color = rgba(style.backgroundColor, opacity);
					_fill.vertices[1].color = rgba(style.backgroundColor, opacity);
					_fill.vertices[2].color = rgba(style.backgroundColorEnd, opacity);
					
					_fill.vertices[3].color = rgba(style.backgroundColorEnd, opacity);
					_fill.vertices[4].color = rgba(style.backgroundColor, opacity);
					_fill.vertices[5].color = rgba(style.backgroundColorEnd, opacity);
				} else if (direction == "horizontal") {
					_fill.vertices[0].color = rgba(style.backgroundColor, opacity);
					_fill.vertices[1].color = rgba(style.backgroundColorEnd, opacity);
					_fill.vertices[2].color = rgba(style.backgroundColorEnd, opacity);
					
					_fill.vertices[3].color = rgba(style.backgroundColor, opacity);
					_fill.vertices[4].color = rgba(style.backgroundColor, opacity);
					_fill.vertices[5].color = rgba(style.backgroundColorEnd, opacity);
				}
			} else {
				if (_fill == null) {
					_fill = Luxe.draw.box( {
						x: x,
						y: y,
						w: w,
						h: h,
						color: rgba(style.backgroundColor, opacity),
						depth: depth + 0.001
					});
				} else {
					_fill.set_xywh(x, y, w, h);
					_fill.color = rgba(style.backgroundColor, opacity);
					_fill.depth = depth + 0.001;
				}
			}
		} else {
			if (_fill != null) {
				_fill.drop();
				_fill = null;
			}
		}

		if (style.backgroundImage != null) {
			_cacheX = x;		
			_cacheY = y;		
			_cacheW = w;		
			_cacheH = h;		
			_cacheDepth = depth;
					
			var bitmapId:String = style.backgroundImage;
			var clipRect:Rectangle = null;
			if (style.backgroundImageClipTop != null
				&& style.backgroundImageClipLeft != null
				&& style.backgroundImageClipBottom != null
				&& style.backgroundImageClipRight != null) {
				bitmapId += "_" + style.backgroundImageClipTop
								+ "_" + style.backgroundImageClipLeft
								+ "_" + style.backgroundImageClipBottom
								+ "_" + style.backgroundImageClipRight;
				clipRect = new Rectangle(style.backgroundImageClipLeft,
										 style.backgroundImageClipTop,
										 style.backgroundImageClipRight - style.backgroundImageClipLeft,
										 style.backgroundImageClipBottom - style.backgroundImageClipTop);
			}

			if (_backgroundBitmapId != bitmapId) {
				_backgroundBitmapId = bitmapId;
				Toolkit.assets.getImage(style.backgroundImage, function(imageInfo:ImageInfo) {
                    if (imageInfo == null) {
                        return;
                    }
					var clip_rect = null;
					if (_background != null) {
						clip_rect = _background.clip_rect;
						_background.destroy(true);
                        _background = null;
					} else {
						clip_rect = _cacheClip;
					}
				
					if (clipRect == null) { // make it the size of the full iamge
						clipRect = new Rectangle(0, 0, imageInfo.width, imageInfo.height);
					}

					if (style.backgroundImageSliceTop != null
						&& style.backgroundImageSliceLeft != null
						&& style.backgroundImageSliceBottom != null
						&& style.backgroundImageSliceRight != null) {
							
							_background = new NineSlice( {
								texture: imageInfo.data,
								depth: _cacheDepth + 0.005,
                                
								top: style.backgroundImageSliceTop,
								left: style.backgroundImageSliceLeft,
								bottom: clipRect.h - style.backgroundImageSliceBottom,
								right: clipRect.w - style.backgroundImageSliceRight,
                                
								source_x: clipRect.x,
								source_y: clipRect.y,
								source_w: clipRect.w,
								source_h: clipRect.h,
							});
							
							cast(_background, NineSlice).create(new Vector(_cacheX, _cacheY), _cacheW, _cacheH);
							_background.clip_rect = clip_rect;
					} else {
						_background = new Sprite({
							texture: imageInfo.data,
							depth: depth + 0.005,
							pos: new Vector(_cacheX, _cacheY),
							size: new Vector(_cacheW, _cacheH),
                            centered: false
						});
                        cast(_background, Sprite).uv = new Rectangle(clipRect.x, clipRect.y, clipRect.w, clipRect.h);
                        _background.clip_rect = clip_rect;
					}
				});
			} else {
				if (_background != null) {
					_background.depth = depth + 0.005;
					_background.pos = new Vector(x, y);
					_background.size = new Vector(w, h);
				}
			}
		} else {
            if (_background != null) {
                _background.destroy();
                _background = null;
            }
        }
        
        if (_border != null && _border.visible == false) {
            _border.visible = true;
        }
        if (_fill != null && _fill.visible == false) {
            _fill.visible = true;
        }
        if (_background != null && _background.visible == false) {
            _background.visible = true;
        }
        
        if (_shadow != null) {
            for (s in _shadow) {
                s.drop();
            }
        }
        
        if (style.filter != null) {
            drawShadow(0x888888 | 0x444444, x, y, w, h, 1, _depth + 0.008, true);
        }
	}
    
    private function drawShadow(color:Int, x:Float, y:Float, w:Float, h:Float, size:Int, depth:Float, inset:Bool = false):Void {
        _shadow = new Array<LineGeometry>();
        if (inset == false) {
            
        } else {
            for (i in 0...size) {
                addShadowLine(x + i, y + i, x + w - i, y + i, rgba(color, .5), depth); // top
                addShadowLine(x + i + 1, y + i, x + i + 1, y + h - i, rgba(color, .5), depth); // left
            }
        }
    }
    
    private function clearBorders() {
        if (_borders != null) {
            for (b in _borders) {
                b.drop();
            }
        }

        _borders = new Array<LineGeometry>();
    }
    
    private function addShadowLine(x1:Float, y1:Float, x2:Float, y2:Float, color, depth:Float) {
        var line = Luxe.draw.line({
            p0: new Vector(x1, y1),
            p1: new Vector(x2, y2),
            color: color,
            depth: depth
        });
        line.clip_rect = clip_rect;
        _shadow.push(line);
    }
    
    private function addBorder(x1:Float, y1:Float, x2:Float, y2:Float, color, depth:Float) {
        var border = Luxe.draw.line({
            p0: new Vector(x1, y1),
            p1: new Vector(x2, y2),
            color: color,
            depth: depth
        });
        border.clip_rect = clip_rect;
        _borders.push(border);
    }
    
    private function rgba(color:Int, opacity:Float = 1):Color {
        var c = new Color().rgb(color);
        c.a = opacity;
        return c;
    }
}