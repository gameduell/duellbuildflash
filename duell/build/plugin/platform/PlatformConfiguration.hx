/**
 * @autor kgar
 * @date 26.08.2014.
 * @company Gameduell GmbH
 */
package duell.build.plugin.platform;
typedef KeyValueArray = Array<{KEY : String, VALUE : String}>;
typedef ScriptItem = {
	originalPath : String,
	destination : String, 
	applyTemplate : Bool
}
typedef PlatformConfigurationData = {
	PLATFORM_NAME : String,
	SWF_NAME : String,
	WIDTH : String,
	HEIGHT : String,
	TARGET_PLAYER : String,
	BUILD_DIR : String,
	FPS  : String,
	BGCOLOR : String,
	WIN_PARAMETERS : KeyValueArray,
	FLASH_VARS : KeyValueArray,
	HEAD_SECTIONS : Array<String>,
	BODY_SECTIONS : Array<String>,
	JS_INCLUDES : Array<ScriptItem>,
	PREHEAD_SECTIONS : Array<String>
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
	
	public static function initConfig() : Void
	{
	    _configuration = 
	    {
			PLATFORM_NAME : "flash",
			SWF_NAME : "main",
			WIDTH : "800",
			HEIGHT : "600",
			TARGET_PLAYER : "11.7",
			BUILD_DIR : "",
			FPS  : "60",
			BGCOLOR : "0xFFFFFF",
			WIN_PARAMETERS : [],
			FLASH_VARS :[],
			HEAD_SECTIONS:[],
			BODY_SECTIONS:[],
			JS_INCLUDES : [],
			PREHEAD_SECTIONS : []
	    };
	}

}