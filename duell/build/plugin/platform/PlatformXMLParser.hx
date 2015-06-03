/*
 * Copyright (c) 2003-2015, GameDuell GmbH
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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

    public static function parse(xml: Fast): Void
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

    public static function parsePlatform(xml: Fast): Void
    {
        for (element in xml.elements)
        {
            if (!XMLHelper.isValidElement(element, DuellProjectXML.getConfig().parsingConditions))
                continue;
            switch (element.name)
            {
                case "swf":
                    parseSWFElement(element);
                case "as-source":
                    parseAsSource(element);
                case "win-size":
                    parseWinSizeElement(element);
                case "win-param":
                    parseWinParamElement(element);
                case "flash-var":
                    parseFlashVarElement(element);
                case "head-section":
                    parseHeadSection(element);
                case "js-source":
                    parseJSIncludeElement(element);
                case "prehead-section":
                    parsePreheadSectionElement(element);
                case "body-section":
                    parseBodySectionElement(element);
            }
        }
    }

    private static function parseAsSource(element: Fast): Void
    {
        if (element.has.src)
        {
            var sourceName: String = element.has.name ? element.att.name : haxe.crypto.Md5.encode(resolvePath(element.att.src));
            PlatformConfiguration.getData().AS_SOURCES.push(
                {
                sourceDirectory: resolvePath(element.att.src),
                swfLibraryPath:"",
                name: sourceName
                }
            );
        }
    }

    private static function parseHeadSection(element: Fast): Void
    {
        PlatformConfiguration.getData().HEAD_SECTIONS.push(element.innerHTML);
    }

    public static function parseBodySectionElement(element: Fast): Void
    {
        PlatformConfiguration.getData().BODY_SECTIONS.push(element.innerHTML);
    }

    public static function parsePreheadSectionElement(element: Fast): Void
    {
        PlatformConfiguration.getData().PREHEAD_SECTIONS.push(element.innerHTML);
    }

    public static function parseJSIncludeElement(element: Fast): Void
    {
        var path: haxe.io.Path;
        if (element.has.path)
        {
            path = new haxe.io.Path(resolvePath(element.att.path));
            PlatformConfiguration.getData().JS_INCLUDES.push({originalPath : resolvePath(element.att.path), destination : "libs/" + path.file + "." + path.ext, applyTemplate : element.has.applyTemplate ? cast element.att.applyTemplate : false});
        }
    }

    public static function parseWinParamElement(element: Fast): Void
    {
        if (element.has.key && element.has.value)
        {
            addUniqueKeyValueToKeyValueArray(PlatformConfiguration.getData().WIN_PARAMETERS, element.att.key, element.att.value);
        }
    }

    public static function parseFlashVarElement(element: Fast): Void
    {
        if (element.has.key && element.has.value)
        {
            addUniqueKeyValueToKeyValueArray(PlatformConfiguration.getData().FLASH_VARS, element.att.key, element.att.value);
        }
    }

    public static function parseWinSizeElement(element: Fast): Void
    {
        if (element.has.width && element.att.width != "")
        {
            PlatformConfiguration.getData().WIDTH = element.att.width;
        }
        if (element.has.height && element.att.height != "")
        {
            PlatformConfiguration.getData().HEIGHT = element.att.height;
        }
    }

    public static function parseSWFElement(element: Fast): Void
    {
        if (element.has.name && element.att.name != "")
        {
            PlatformConfiguration.getData().SWF_NAME = element.att.name;
        }

        if (element.has.fps && element.att.fps != "")
        {
            PlatformConfiguration.getData().FPS = element.att.fps;
        }

        if (element.has.bgColor && element.att.bgColor != "")
        {
            PlatformConfiguration.getData().BGCOLOR = element.att.bgColor;
        }

        if (element.has.targetPlayer && element.att.targetPlayer != "")
        {
            PlatformConfiguration.getData().TARGET_PLAYER = element.att.targetPlayer;
        }

    }

    private static function resolvePath(string: String): String /// convenience method
    {
        return DuellProjectXML.getConfig().resolvePath(string);
    }

    private static function addUniqueKeyValueToKeyValueArray(keyValueArray: Array<{KEY: String, VALUE: String}>, key: String, value: String)
    {
        for (keyValuePair in keyValueArray)
        {
            if (keyValuePair.KEY == key)
            {
                LogHelper.println('Overriting key $key value ${keyValuePair.VALUE} with value $value');
                keyValuePair.VALUE = value;
                return;
            }
        }

        keyValueArray.push({KEY : key, VALUE : value});
    }

}
