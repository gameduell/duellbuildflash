/**
 * @autor kgar
 * @date 26.08.2014.
 * @company Gameduell GmbH
 */
package duell.build.plugin.platform;
typedef PlatformConfigurationData = {
PLATFORM_NAME : String,
APP_MAIN_CLASS : String,
DEFAULT_BROWSER : String,
SWF_NAME : String,
WIN_WIDTH : String,
WIN_HEIGHT : String,
SWF_VERSION : String,
TARGET_PLAYER : String,
BUILD_DIR : String,
FPS  : String;
BGCOLOR : String;
DEBUG_FLAG : String,//advanced-telemetry OR final
}

class PlatformConfiguration
{
	public static var _configuration : PlatformConfigurationData = null;
	public static var _parsingDefines : Array<String> = ["flash"];
	public function new()
	{}

	public static function getData() : PlatformConfigurationData
	{
	    if(_configuration == null)
	    	initConfig();

	    return _configuration;
	}
	public static function getConfigParsingDefines() : Array<String>
	{
	    return _parsingDefines;
	}
	public static function addParsingDefines(str : String):Void
	{
	    _parsingDefines.push(str);
	}
	public static function initConfig() : Void
	{
	    _configuration = 
	    {
	    	PLATFORM_NAME : "flash",
	    	SWF_NAME : "main",
	    	WIDTH : "800",
	    	HEIGHT : "600",
	    	DEFAULT_BROWSER : "default" // "Google Chrome", "FireFox" etc... and "default" for picking user default browser
	    	SWF_VERSION : "20",// flash player version 11.7 , check http://goo.gl/OUiCVV for complete list
	    	TARGET_PLAYER : "11.7"
	    };
	}

}