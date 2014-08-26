/**
 * @autor kgar
 * @date 26.08.2014.
 * @company Gameduell GmbH
 */
package duell.build.plugin.platform;
typedef PlatformConfigurationData = {
PLATFORM_NAME : String,
APP_MAIN_CLASS : String,
SWF_NAME : String,
WIN_WIDTH : String,
WIN_HEIGHT : String,
SWF_VERSION : String,
BUILD_DIR : String,
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
	    	WIN_WIDTH : "800",
	    	WIN_HEIGHT : "600",
	    	SWF_VERSION : "",
	    	BUILD_DIR : "",
	    	DEBUG_FLAG : "" 
	    };
	}

}