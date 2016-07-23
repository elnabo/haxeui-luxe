package haxe.ui.backend.luxe.macros;

#if macro
import haxe.macro.Context;
import sys.FileSystem;
#end

class ResourceMacros {
    macro public static function buildPreloadList(path:String, type:String) {
        var pos = haxe.macro.Context.currentPos();
        
        var code:String = "function() {\n";

        var list:Array<String> = new Array<String>();
        listAllFiles(path, list);
        for (item in list) {
            var use:Bool = false;
            
            switch (type) {
                case "textures":
                    use = (StringTools.endsWith(item, ".jpg")
                            || StringTools.endsWith(item, ".jpeg")
                            || StringTools.endsWith(item, ".png"));
            }
            
            if (use == true) {
                code += 'config.preload.${type}.push({ id: "${item}" });\n';
            }
        }
        trace(code);
        code += "}()\n";
        return Context.parseInlineString(code, pos);
    }
    
    #if macro
    private static function listAllFiles(path:String, list:Array<String>) {
        var contents:Array<String> = FileSystem.readDirectory(path);
        if (contents != null) {
            for (file in contents) {
                if (FileSystem.isDirectory(path + "/" + file)) {
                    listAllFiles(path + "/" + file, list);
                } else {
                    list.push(path + "/" + file);
                }
            }
        }
    }
    #end
}