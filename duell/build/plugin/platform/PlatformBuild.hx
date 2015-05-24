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
import duell.build.plugin.platform.PlatformConfiguration;
import duell.build.objects.Configuration;
import duell.build.objects.DuellProjectXML;
import duell.helpers.PathHelper;
import duell.helpers.LogHelper;
import duell.helpers.FileHelper;
import duell.helpers.CommandHelper;
import duell.helpers.TestHelper;
import duell.objects.DuellLib;
import duell.objects.Haxelib;
import duell.helpers.ServerHelper;
import duell.helpers.TemplateHelper;
import duell.helpers.PlatformHelper;
import duell.objects.DuellProcess;
import duell.objects.Arguments;
import duell.objects.HXCPPConfigXML;
import duell.helpers.HXCPPConfigXMLHelper;

import sys.io.Process;
import sys.FileSystem;

import haxe.io.Path;
import sys.io.File;
import haxe.io.Path;

using StringTools;

class PlatformBuild
{
    public var requiredSetups = [{name: "flash", version: "2.0.0"}];
    public var supportedHostPlatforms = [WINDOWS, MAC];
    private static inline var TEST_RESULT_FILENAME = "test_result_flash.xml";
    private static inline var DEFAULT_SERVER_URL: String = "http://localhost:3000/";
    private static inline var DELAY_BETWEEN_PYTHON_LISTENER_AND_RUNNING_THE_APP = 1;

    private var airSDKLocation: String;
    private var isDebug: Bool = false;
    private var isTest: Bool = false;
    private var isAdvancedTelemetry: Bool = false;
    private var runInSlimerJS: Bool = false;
    private var runInBrowser: Bool = false;
    private var serverProcess: DuellProcess;
    private var slimerProcess: DuellProcess;
    private var fullTestResultPath: String;
    private var targetDirectory: String;
    private var duellBuildFlashPath: String;
    private var projectDirectory: String;
    private var applicationWillRunAfterBuild: Bool = false;

    public function new()
    {
        checkArguments();
    }

    public function checkArguments(): Void
    {
        if (Arguments.isSet("-debug"))
        {
            isDebug = true;
        }

        if (!Arguments.isSet("-norun"))
        {
            applicationWillRunAfterBuild = true;
        }

        if (Arguments.isSet("-advanced-telemetry"))
        {
            isAdvancedTelemetry = true;
        }

        if (Arguments.isSet("-slimerjs"))
        {
            runInSlimerJS = true;
        }

        if (Arguments.isSet("-browser"))
        {
            runInBrowser = true;
        }

        if (Arguments.isSet("-test"))
        {
            isTest = true;
            applicationWillRunAfterBuild = true;
            Configuration.addParsingDefine("test");
        }

        if (isDebug)
        {
            Configuration.addParsingDefine("debug");
        }
        else
        {
            Configuration.addParsingDefine("release");
        }

        if (isAdvancedTelemetry)
        {
            Configuration.addParsingDefine("advanced-telemetry");
        }
        else
        {
            Configuration.addParsingDefine("final");
        }
        /// if nothing passed slimerjs is the default
        if (runInBrowser == false && runInSlimerJS == false)
            runInSlimerJS = true;
    }

    public function parse(): Void
    {
        parseProject();
    }

    public function parseProject(): Void
    {
        var projectXML = DuellProjectXML.getConfig();
        projectXML.parse();
    }

    public function prepareBuild(): Void
    {
        prepareVariables();
        copySwfLibsToLibFolderAndIncludeLibSwf();
        convertDuellAndHaxelibsIntoHaxeCompilationFlags();
        convertParsingDefinesToCompilationDefines();
        forceHaxeJson();
        forceDeprecationWarnings();
        prepareFlashBuild();
        copyJSIncludesToLibFolder();
        if (applicationWillRunAfterBuild)
        {
            prepareAndRunHTTPServer();
        }
    }

    private function prepareVariables()
    {
        targetDirectory = Configuration.getData().OUTPUT;
        projectDirectory = Path.join([targetDirectory, "flash"]);
        fullTestResultPath = Path.join([Configuration.getData().OUTPUT, "test", TEST_RESULT_FILENAME]);
        duellBuildFlashPath = DuellLib.getDuellLib("duellbuildflash").getPath();

        var hxcppConfig = HXCPPConfigXML.getConfig(HXCPPConfigXMLHelper.getProbableHXCPPConfigLocation());
        airSDKLocation = hxcppConfig.getDefines()["AIR_SDK"];
    }

    private function convertDuellAndHaxelibsIntoHaxeCompilationFlags()
    {
        for (haxelib in Configuration.getData().DEPENDENCIES.HAXELIBS)
        {
            var version = haxelib.version;
            if (version.startsWith("ssh") || version.startsWith("http"))
                version = "";
            Configuration.getData().HAXE_COMPILE_ARGS.push("-lib " + haxelib.name + (version != "" ? ":" + version : ""));
        }

        for (duelllib in Configuration.getData().DEPENDENCIES.DUELLLIBS)
        {
            Configuration.getData().HAXE_COMPILE_ARGS.push("-cp " + DuellLib.getDuellLib(duelllib.name, duelllib.version).getPath());
        }

        for (path in Configuration.getData().SOURCES)
        {
            Configuration.getData().HAXE_COMPILE_ARGS.push("-cp " + path);
        }
    }

    private function forceHaxeJson(): Void
    {
        Configuration.getData().HAXE_COMPILE_ARGS.push("-D haxeJSON");
    }

    private function forceDeprecationWarnings(): Void
    {
        Configuration.getData().HAXE_COMPILE_ARGS.push("-D deprecation-warnings");
    }

    public function build(): Void
    {
        var buildPath: String = Path.join([targetDirectory, "flash", "hxml"]);

        var result = CommandHelper.runHaxe(buildPath,
        ["Build.hxml"],
        {
        logOnlyIfVerbose : false,
        systemCommand : true,
        errorMessage: "compiling the haxe code",
        exitOnError: false
        });

        if (result != 0)
        {
            if (applicationWillRunAfterBuild)
            {
                serverProcess.kill();
            }

            throw "Haxe Compilation Failed";
        }
    }

    public function run(): Void
    {
        runApp();/// run app in the browser
    }

    public function test()
    {
        testApp();
    }

    public function publish()
    {
        throw "Publishing is not yet implemented for this platform";
    }

    public function fast()
    {
        prepareVariables();
        prepareAndRunHTTPServer();
        build();

        if (Arguments.isSet("-test"))
            testApp()
        else
            runApp();
    }

    public function runApp(): Void
    {
        /// order here matters cause opening slimerjs is a blocker process
        if (runInBrowser)
        {
            CommandHelper.openURL(DEFAULT_SERVER_URL);
        }

        if (runInSlimerJS)
        {


            var slimerFolder: String;
            var xulrunnerFolder: String;
            var xulrunnerCommand: String;

            if (PlatformHelper.hostPlatform == LINUX)
            {
                slimerFolder = "slimerjs_linux";
                xulrunnerCommand = "xulrunner";
            }
            else if (PlatformHelper.hostPlatform == MAC)
            {
                slimerFolder = "slimerjs_mac";
                xulrunnerCommand = "xulrunner";
            }
            else
            {
                slimerFolder = "slimerjs_win";
                xulrunnerCommand = "xulrunner.exe";
            }

			xulrunnerFolder = Path.join([duellBuildFlashPath,"bin",slimerFolder,"xulrunner"]);

            var appPath = Path.join([duellBuildFlashPath, "bin", slimerFolder, "application.ini"]);
            var scriptPath = Path.join([duellBuildFlashPath, "bin", "test.js"]);

 			if (PlatformHelper.hostPlatform != WINDOWS)
 			{
	 			CommandHelper.runCommand(xulrunnerFolder,
	 									 "chmod",
	 									 ["+x", "xulrunner"],
	 									 {systemCommand: true,
	 									  errorMessage: "Setting permissions for slimerjs"});
 			}
            else
            {
                xulrunnerFolder = xulrunnerFolder.split("/").join("\\");
                xulrunnerCommand = xulrunnerCommand.split("/").join("\\");
                appPath = appPath.split("/").join("\\");
                scriptPath = scriptPath.split("/").join("\\");
            }

			slimerProcess = new DuellProcess(
												xulrunnerFolder,
												xulrunnerCommand,
												["-app",
												 appPath,
												 "-no-remote",
												 scriptPath],
												{
													logOnlyIfVerbose : true,
													systemCommand : false,
													errorMessage: "Running the slimer js browser"
												});
			slimerProcess.blockUntilFinished();
			serverProcess.kill();
        }
        else if (runInBrowser)
        {
            serverProcess.blockUntilFinished();
        }
    }

    public function prepareAndRunHTTPServer(): Void
    {
        var serverTargetDirectory: String = Path.join([targetDirectory, "flash", "web"]);
        serverProcess = ServerHelper.runServer(serverTargetDirectory, duellBuildFlashPath);
    }

    public function prepareFlashBuild(): Void
    {
        createDirectoryAndCopyTemplate();
    }

    public function createDirectoryAndCopyTemplate(): Void
    {
        /// Create directories
        PathHelper.mkdir(targetDirectory);

        ///copying template files
        /// index.html, expressInstall.swf and swiftObject.js
        TemplateHelper.recursiveCopyTemplatedFiles(Path.join([duellBuildFlashPath, "template", "flash"]), projectDirectory, Configuration.getData(), Configuration.getData().TEMPLATE_FUNCTIONS);
    }

    private function convertParsingDefinesToCompilationDefines()
    {

        for (define in DuellProjectXML.getConfig().parsingConditions)
        {
            if (define == "debug")
            {
                /// not allowed
                Configuration.getData().HAXE_COMPILE_ARGS.push("-debug");
                continue;
            }

            if (define == "flash")
            {
                /// not allowed
                continue;
            }

            Configuration.getData().HAXE_COMPILE_ARGS.push("-D " + define);
        }
    }

    private function copyJSIncludesToLibFolder(): Void
    {
        var jsIncludesPaths: Array<String> = [];
        var copyDestinationPath: String = "";

        for (scriptItem in PlatformConfiguration.getData().JS_INCLUDES)
        {
            copyDestinationPath = Path.join([projectDirectory, "web", scriptItem.destination]);

            PathHelper.mkdir(Path.directory(copyDestinationPath));
            if (scriptItem.applyTemplate == true)
            {
                TemplateHelper.copyTemplateFile(scriptItem.originalPath, copyDestinationPath, Configuration.getData(), Configuration.getData().TEMPLATE_FUNCTIONS);
            }
            else
            {
                FileHelper.copyIfNewer(scriptItem.originalPath, copyDestinationPath);
            }

        }
    }

    private function buildAS3Sources(asSourceItem: ASSourceItem): Void
    {
        /*
			compc -source-path ../mycomponents/components/local
	    		-include-classes CustomCellRendererComponent
	    		-directory=true
	    		-debug=false
	    		-output ../libraries/CustomCellRenderer
    	*/

        /// 1.build the spine as3 library with directory mode set to true to get the library.swf



        var classes: Array<String> = [];
        var libExportPath: String = Path.join([Configuration.getData().OUTPUT, "flash", "swf-libs", asSourceItem.name]);
        var dirs: Array<String> = [];

        if (asSourceItem.sourceDirectory.indexOf("/") >= 0)
        {
            dirs = asSourceItem.sourceDirectory.split("/");
        }
        else if (asSourceItem.sourceDirectory.indexOf("\\") >= 0)
        {
            dirs = asSourceItem.sourceDirectory.split("\\");
        }
        else
        {
            throw "invalid source directory";
        }

        var base: String = dirs[dirs.length - 1];
        getAllClassesInDir(asSourceItem.sourceDirectory, classes, base);
        var compcArguments: Array<String> = ["-source-path", ".", "-include-classes"];
        compcArguments = compcArguments.concat(classes);
        compcArguments.push("-directory=true");
        compcArguments.push("-debug=" + (isDebug ? "true" : "false"));
        compcArguments.push("-output");
        compcArguments.push(libExportPath);

        var buildSWFResult = CommandHelper.runCommand(asSourceItem.sourceDirectory,
								        			Path.join([airSDKLocation, "bin", "compc"]),
											        compcArguments,
											        {
												        logOnlyIfVerbose : false,
												        systemCommand : true,
												        errorMessage: "building actionscript sources for library " + asSourceItem.name,
												        exitOnError: true
								        			}
												        );

        ///2.add the library swf to the lib-swf config param in the duellbuildflash plugin
        asSourceItem.swfLibraryPath = Path.join([libExportPath, "library.swf"]);
    }

    private function getAllClassesInDir(source: String, retFiles: Array<String>, base: String): Void
    {
    	var pathSeparator : String = PlatformHelper.hostPlatform == WINDOWS ? "\\" : "/";
        var files: Array <String> = null;
        if (retFiles == null)
        {
            retFiles = [];
        }

        var oldPath: String;
        try
        {
            files = FileSystem.readDirectory(source);
        }
        catch (e: Dynamic)
        {
            throw "Could not find source directory \"" + source + "\"";
        }

        for (file in files)
        {
            if (file != "." && file != "..")
            {
                var itemSource: String = source + pathSeparator + file;

                if (FileSystem.isDirectory(itemSource))
                {
                    getAllClassesInDir(itemSource, retFiles, base);
                }
                else
                {
                	var baseIndex: Int = itemSource.lastIndexOf(base) + base.length + 1;
                    var fullClassPath: String = Path.withoutExtension(itemSource.substring(baseIndex).split(pathSeparator).join("."));
                    retFiles.push(fullClassPath);
                }
            }
        }
    }

    private function copySwfLibsToLibFolderAndIncludeLibSwf(): Void
    {
        //create swf-lib folder
        PathHelper.mkdir(Path.join([Configuration.getData().OUTPUT, "flash", "swf-libs"]));
        for (asSource in PlatformConfiguration.getData().AS_SOURCES)
        {
            buildAS3Sources(asSource);
            Configuration.getData().HAXE_COMPILE_ARGS.push("-swf-lib " + asSource.swfLibraryPath);
        }
    }

    private function testApp()
    {
        /// DELETE PREVIOUS TEST
        if (sys.FileSystem.exists(fullTestResultPath))
        {
            sys.FileSystem.deleteFile(fullTestResultPath);
        }

        /// CREATE TARGET FOLDER
        PathHelper.mkdir(Path.directory(fullTestResultPath));

        /// RUN THE APP IN A THREAD
        var targetTime = haxe.Timer.stamp() + DELAY_BETWEEN_PYTHON_LISTENER_AND_RUNNING_THE_APP;
        neko.vm.Thread.create(function()
        {
            Sys.sleep(DELAY_BETWEEN_PYTHON_LISTENER_AND_RUNNING_THE_APP);

            runApp();
        });

        /// RUN THE LISTENER
        try
        {
            TestHelper.runListenerServer(300, 8181, fullTestResultPath);
        }
        catch (e: Dynamic)
        {
            serverProcess.kill();
            if (runInSlimerJS)
            {
                slimerProcess.kill();
            }
            neko.Lib.rethrow(e);
        }
        serverProcess.kill();
        if (runInSlimerJS)
        {
            slimerProcess.kill();
        }
    }

	public function clean()
	{
		prepareVariables();

		LogHelper.info('Cleaning html5 part of export folder...');

		if (FileSystem.exists(targetDirectory))
		{
			PathHelper.removeDirectory(targetDirectory);
		}
	}

    public function handleError()
    {

    }

}
