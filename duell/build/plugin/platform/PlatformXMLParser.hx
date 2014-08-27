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
				case "swf":
					parseSWF(element.name);
				case "win-size":
					parseWinSize(element.name);
				case "swf-version":
					parseSWFVersion(element.name);
				case "build-dir":
					parseBuildDir(element.name);
			}
		}
	}
	public static function parseTargetPlayer(element : Fast) : Void
	{
	    if(element.has.value)
	    {
	      	PlatformConfiguration.getData().TAGET_PLAYER =  element.att.value;  
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
	    if(element.has.width && element.att.width != "")
	    {
	    	PlatformConfiguration.getData().WIDTH = element.att.width;
	    }
	    if(element.has.height && element.att.height != "")
	    {
	    	PlatformConfiguration.getData().HEIGHT = element.att.height;
	    }
	}
	public static function parseSWF(element : Fast) : Void
	{
		if(element.has.name && element.att.name != "")
		{
			PlatformConfiguration.getData().SWF_NAME = element.att.name;
		}

		if(element.has.fps && element.att.fps != "")
		{
			PlatformConfiguration.getData().FPS = element.att.fps;
		}

		if(element.has.bgColor && element.att.bgColor != "")
		{
			PlatformConfiguration.getData().BGCOLOR = element.att.bgColor;
		}
		
		if(element.has.targetPlayer && element.att.targetPlayer != "")
		{
			PlatformConfiguration.getData().TAGET_PLAYER = element.att.targetPlayer;
		}

	}
	private static function resolvePath(string : String) : String /// convenience method
	{
		return DuellProjectXML.getConfig().resolvePath(string);
	}

 }