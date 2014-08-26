/**
 * @autor kgar
 * @date 26.08.2014.
 * @company Gameduell GmbH
 */
import haxe.xml.Fast;

import duell.build.objects.DuellProjectXML;
import duell.build.objects.Configuration;
import duell.helpers.XMLHelper;
import duell.helpers.LogHelper;

 class PlatformXMLParser
 {
 	public function new()
 	{}

 	public static function parse(xml : Fast) : Void
	{
		for (element in xml.elements) 
		{
			switch(element.name)
			{
				case 'flash':
					parsePlatform(element);
			}
		}
	}
	public static function parsePlatform(xml : Fast) : Void
	{
	    for (element in xml.elements) 
		{
			if (!XMLHelper.isValidElement(element, DuellProjectXML.getConfig().parsingConditions))
				continue;
			switch (element.name) 
			{
				case "app-main-class":
					parseMainClassElement(element.name);
				case "swf-name":
					parseSWFName(element.name);
				case "win-size":
					parseWinSize(element.name);
				case "swf-version":
					parseSWFVersion(element.name);
				case "build-dir":
					parseBuildDir(element.name);
				case "debug-flag":
					parseDebugFlag(element.name);

			}
		}
	}
	public static function parseDebugFlag(element : Fast) : Void
	{
	    if(element.has.value)
	    {
	          PlatformConfirguration.getData().DEBUG_FLAG = element.att.value;
	    }
	}
	public static function parseBuildDir(element : Fast) : Void
	{
	    if(element.has.value)
	    {
	      	PlatformConfiguration.getData().BUILD_DIR =   resolvePath(element.att.value);  
	    }
	}
	public static function parseSWFVersion(element : Fast) : Void
	{
	    if(element.has.value)
	    {
	     	PlatformConfiguration.getData().SWF_VERSION = element.att.value;     
	    }
	}
	public static function parseWinSize(element : Fast) : Void
	{
	    if(element.has.width)
	    {
	    	PlatformConfiguration.getData().WIN_WIDTH = element.att.width;
	    }
	    if(element.has.height)
	    {
	    	PlatformConfiguration.getData().HEIGHT = element.att.height;
	    }
	}
	public static function parseMainClassElement(element : Fast) : Void
	{
		if(element.has.value)
		{
	    	PlatformConfiguration.getData().APP_MAIN_CLASS = element.att.value;
		}
	}
	public static function parseSWFName(element : Fast) : Void
	{
		if(element.has.value)
		{
			PlatformConfiguration.getData().SWF_NAME = element.att.value;
		}
	}
	private static function resolvePath(string : String) : String /// convenience method
	{
		return DuellProjectXML.getConfig().resolvePath(string);
	}

 }