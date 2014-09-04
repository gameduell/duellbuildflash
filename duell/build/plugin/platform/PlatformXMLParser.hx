/**
 * @autor kgar
 * @date 26.08.2014.
 * @company Gameduell GmbH
 */
package duell.build.plugin.platform;

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
					parseSWFElement(element);
				case "win-size":
					parseWinSizeElement(element);
				case "win-param":
					parseWinParamElement(element);
				case "flash-var":
					parseFlashVarElement(element);
			}
		}
	}
	
	public static function parseWinParamElement(element : Fast):Void
	{
	    if(element.has.key && element.has.value)
	    {
	    	PlatformConfiguration.getData().WIN_PARAMETERS.push({KEY:element.att.key, VALUE:element.att.value});
	    	trace(PlatformConfiguration.getData().WIN_PARAMETERS);
	    }
	}
	public static function parseFlashVarElement(element : Fast):Void
	{
	    if(element.has.key && element.has.value)
	    {
	    	PlatformConfiguration.getData().FLASH_VARS.push({KEY:element.att.key, VALUE:element.att.value});
	    	trace(PlatformConfiguration.getData().FLASH_VARS);
	    }
	}
	public static function parseWinSizeElement(element : Fast) : Void
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
	public static function parseSWFElement(element : Fast) : Void
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
			PlatformConfiguration.getData().TARGET_PLAYER = element.att.targetPlayer;
		}

	}
	private static function resolvePath(string : String) : String /// convenience method
	{
		return DuellProjectXML.getConfig().resolvePath(string);
	}

 }