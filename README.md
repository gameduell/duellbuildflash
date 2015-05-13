## Description
 
Use this plugin to build for the flash platform.
## Usage:
`$ duell build flash -browser -debug`
## Arguments:
* `-browser` &ndash; runs the app in your default browser.
* `-slimerjs` &ndash; Use this argument to make the app run on slimerjs which is a standalone tiny firefox. This has the benefit of not opening a new tab on your browser.
* `-debug` &ndash; Use this argument if you want to build in debug.

## Project Configuration: 
* `<swf>` &ndash; Use this to specify targetPlayer, fps or bgColor of the swf. E.g.:`<swf targetPlayer="14" fps="60" bgColor="0x000000" />`.
* `<win-size>` &ndash; Use this to specifie the swf dimension (width x height) in the application html page. E.g.:`<win-size width="1024" height="768" />`.
* `<as-source>` &ndash; Use this to specifie to add an as3 library source to your project. E.g.:`<as-source name="myLib" src="myLibSourceFolder" />`.The name attribute is optional.
* `<win-param>` &ndash; Use this to specifie windows parameters for the swf embedding. E.g.:`<win-param key="wmode" value="direct" />`. Multiple tags are supported.
* `<flash-var>` &ndash; Use this to specifie flash vars for your application. E.g.:`<flash-var key="myVar" value="myValue" />`. Multiple tags are supported.
