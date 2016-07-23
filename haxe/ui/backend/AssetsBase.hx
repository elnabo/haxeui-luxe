package haxe.ui.backend;

import haxe.ui.assets.FontInfo;
import haxe.ui.assets.ImageInfo;

class AssetsBase {
    public function new() {

    }

    private function getTextDelegate(resourceId:String):String {
        return null;
    }

    private function getImageInternal(resourceId:String, callback:ImageInfo->Void):Void {
        var texture:phoenix.Texture = Luxe.resources.texture(resourceId);
        if (texture != null) {
            var imageInfo:ImageInfo = {
                data: texture,
                width: texture.width,
                height: texture.height
            }

            callback(imageInfo);
        } else {
            callback(null);
        }
    }

    private function getImageFromHaxeResource(resourceId:String, callback:String->ImageInfo->Void) {
        var id = resourceId + "_texture";
        var bytes = Resource.getBytes(resourceId);
        var promise = Luxe.snow.assets.image_from_bytes(id + "_asset", snow.api.buffers.Uint8Array.fromBytes(bytes));
        promise.then(function(image:snow.systems.assets.Asset.AssetImage) {
            var texture = new phoenix.Texture({
                id: id,
                width: image.image.width_actual,
                height: image.image.height_actual,
                pixels: image.image.pixels
            });

            var imageInfo:ImageInfo = {
                data: texture,
                width: image.image.width,
                height: image.image.height
            }

            callback(resourceId, imageInfo);
        });
    }

    private function getFontInternal(resourceId:String, callback:FontInfo->Void):Void {
        var font:phoenix.BitmapFont = Luxe.resources.font(resourceId);
        if (font != null) {

            var fontInfo:FontInfo = {
                data: font,
            }

            callback(fontInfo);
        } else {
            callback(null);
        }
    }

    private function getFontFromHaxeResource(resourceId:String, callback:String->FontInfo->Void) {
        var fontString = Resource.getString(resourceId);
        var fontData:luxe.importers.bitmapfont.BitmapFontData = luxe.importers.bitmapfont.BitmapFontParser.parse(fontString);

        var pageParts = resourceId.split("/");
        pageParts.pop();
        var pagePath:String = pageParts.join("/") + "/" + fontData.pages[0].file;

        Toolkit.assets.getImage(pagePath, function(imageInfo:ImageInfo) {
            var pages:Array<phoenix.Texture> = [imageInfo.data];

            var font:phoenix.BitmapFont = new phoenix.BitmapFont({
                id: resourceId,
                font_data: fontString,
                pages: pages
            });

            var fontInfo:FontInfo = {
                data: font,
            }

            callback(resourceId, fontInfo);
        });
    }
}