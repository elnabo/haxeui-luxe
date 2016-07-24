<p align="center">
  <img src="https://dl.dropboxusercontent.com/u/26678671/haxeui2-warning.png"/>
</p>

[![Build Status](https://travis-ci.org/haxeui/haxeui-luxe.svg?branch=master)](https://travis-ci.org/haxeui/haxeui-luxe)
[![Support this project on Patreon](https://dl.dropboxusercontent.com/u/26678671/patreon_button.png)](https://www.patreon.com/haxeui)

<h2>haxeui-luxe</h2>
`haxeui-luxe` is the `luxe` backend for HaxeUI.

<p align="center">
	<img src="https://github.com/haxeui/haxeui-luxe/raw/master/screen.png" />
</p>

<h2>Installation</h2>
 * `haxeui-luxe` has a dependency to <a href="https://github.com/haxeui/haxeui-core">`haxeui-core`</a>, and so that too must be installed.
 * `haxeui-luxe` also has a dependency to <a href="http://luxeengine.com/docs/index.html">luxe</a>, please refer to the installation instructions on their <a href="http://luxeengine.com/docs/index.html">site</a>.

Eventually all these libs will become haxelibs, however, currently in their alpha form they do not even contain a `haxelib.json` file (for dependencies, etc) and therefore can only be used by downloading the source and using the `haxelib dev` command or by directly using the git versions using the `haxelib git` command (recommended). Eg:

```
haxelib git haxeui-core https://github.com/haxeui/haxeui-core
haxelib dev haxeui-luxe path/to/expanded/source/archive
```

<h2>Usage</h2>
The simplest method to create a new `luxe` application that is HaxeUI ready is to use one of the <a href="https://github.com/haxeui/haxeui-templates">haxeui-templates</a>. These templates will allow you to start a new project rapidly with HaxeUI support baked in. 

If however you already have an existing application, then incorporating HaxeUI into that application is straightforward:

<h2>project.flow</h2>
Simply add the following dependencies to your `project.flow`:

```js
"hscript":      "*",
"haxeui-core":  "*",
"haxeui-luxe":  "*"
```

Your `project.flow` should end up looking something like the following:

```js
{
	...
    "build": {
      "dependencies": {
        "luxe":         "*",
        "hscript":      "*",
        "haxeui-core":  "*",
        "haxeui-luxe":  "*"
      }
    },
	...
  }
}
```

_Note: its important to surround the dependencies `haxeui-core` and `haxeui-luxe` with double quotes (`"`) since they contain a hypen._

<h3>Toolkit initialisation and usage</h3>
Initialising the toolkit requires you to add this single line somewhere _before_ you start to actually use HaxeUI in your application, but _after_ the `luxe` application has been initialised - for example in the `ready` function. Eg:

```haxe
class Main extends luxe.Game {
	public override function ready() {
		Toolkit.init();
	}
}
```

<h2>Addtional resources</h2>
* <a href="http://haxeui.github.io/haxeui-api/">haxeui-api</a> - The HaxeUI api docs.
* <a href="https://github.com/haxeui/haxeui-guides">haxeui-guides</a> - Set of guides to working with HaxeUI and backends.
* <a href="https://github.com/haxeui/haxeui-demo">haxeui-demo</a> - Demo application written using HaxeUI.
* <a href="https://github.com/haxeui/haxeui-templates">haxeui-templates</a> - Set of templates for IDE's to allow quick project creation.
* <a href="https://github.com/haxeui/haxeui-bdd">haxeui-bdd</a> - A behaviour driven development engine written specifically for HaxeUI (uses <a href="https://github.com/haxeui/haxe-bdd">haxe-bdd</a> which is a gherkin/cucumber inspired project).
* <a href="https://www.youtube.com/watch?v=L8J8qrR2VSg&feature=youtu.be">WWX2016 presentation</a> - A presentation given at WWX2016 regarding HaxeUI.
