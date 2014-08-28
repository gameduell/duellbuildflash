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
					parseSWF(element);
				case "win-size":
					parseWinSize(element);
				case "swf-version":
					parseSWFVersion(element);
			}
		}
	}
	
	public static function parseSWFVersion(element : Fast) : Void
	{
	    if(element.has.version)
	    {
	     	PlatformConfiguration.getData().SWF_VERSION = element.att.version;     
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
			PlatformConfiguration.getData().TARGET_PLAYER = element.att.targetPlayer;
		}

	}
	private static function resolvePath(string : String) : String /// convenience method
	{
		return DuellProjectXML.getConfig().resolvePath(string);
	}

 }