/**
 * @autor kgar
 * @date 26.08.2014.
 * @company Gameduell GmbH
 */
  package duell.build.plugin.platform;

 import duell.build.objects.Configuration;
 import duell.build.objects.DuellProjectXML;
 import duell.helpers.PathHelper;
 import duell.helpers.LogHelper;
 import duell.helpers.FileHelper;
 import duell.helpers.ProcessHelper;
 import duell.objects.DuellLib;
 import duell.objects.Haxelib;
 import duell.helpers.TemplateHelper;
 
 import sys.io.Process;
 class PlatformBuild
 {
 	public var requiredSetups = ["flash"];

 	private static var isDebug : Bool = false;
 	private static var isAdvancedTelemetry : Bool = false;
	private var serverProcess : Process; 
 	public var targetDirectory : String;
 	public var duellBuildFlashPath : String;
 	public var projectDirectory : String;
 	public function new()
 	{
 		checkArguments();
 	}
	public static function checkArguments():Void
 	{
		for (arg in Sys.args())
		{
			if (arg == "-debug")
			{
				isDebug = true;
			}
			
			if( arg == "-advanced-telemetry")
			{
				isAdvancedTelemetry = true;
			}
		}

		if (isDebug)
		{
			PlatformConfiguration.addParsingDefines("debug");
		}
		else
		{
			PlatformConfiguration.addParsingDefines("release");
		}

		if(isAdvancedTelemetry)
		{
			PlatformConfiguration.addParsingDefines("advanced-telemetry");
		}
		else
		{
			PlatformConfiguration.addParsingDefines("final");
		}
 	}

 	public function parse() : Void
 	{
 	    parseProject();
 	}
 	public function parseProject() : Void
 	{
 	    var projectXML = DuellProjectXML.getConfig();
		projectXML.parse();
 	}
 	public function prepareBuild() : Void
 	{
 	    targetDirectory = Configuration.getData().OUTPUT + "/";
 	    projectDirectory = targetDirectory + "/";
 	    duellBuildFlashPath = DuellLib.getDuellLib("duellbuildflash").getPath();
		
		convertDuellAndHaxelibsIntoHaxeCompilationFlags();
 	    prepareFlashBuild();
 	    convertParsingDefinesToCompilationDefines();
 	}
 	private function convertDuellAndHaxelibsIntoHaxeCompilationFlags()
	{
		for (haxelib in Configuration.getData().DEPENDENCIES.HAXELIBS)
		{
			Configuration.getData().HAXE_COMPILE_ARGS.push("-cp");
			Configuration.getData().HAXE_COMPILE_ARGS.push(Haxelib.getHaxelib(haxelib.name, haxelib.version).getPath());
		}

		for (duelllib in Configuration.getData().DEPENDENCIES.DUELLLIBS)
		{
			Configuration.getData().HAXE_COMPILE_ARGS.push("-cp");
			Configuration.getData().HAXE_COMPILE_ARGS.push(DuellLib.getDuellLib(duelllib.name, duelllib.version).getPath());
		}

		for (path in Configuration.getData().SOURCES)
		{
			Configuration.getData().HAXE_COMPILE_ARGS.push("-cp");
			Configuration.getData().HAXE_COMPILE_ARGS.push(path);
		}
	}
 	public function build() : Void
 	{
		LogHelper.info("", "" + Configuration.getData());
		LogHelper.info("", "" + Configuration.getData().LIBRARY.GRAPHICS);
		ProcessHelper.runCommand(targetDirectory+"/flash/hxml/","haxe",["Build.hxml"]);
 	}

 	public function run() : Void
 	{
 	    runApp();/// run app in the browser
 	}
 	public function runApp() : Void
 	{
 		// LogHelper.info("", "Launching application in "+PlatformConfiguration.getData().DEFAULT_BROWSER+" browser");
 	 //    var result : Int = ProcessHelper.openURL(targetDirectory+"flash/web/index.html");
 	 //    if(result != 0)
 	 //    {
 	 //    	LogHelper.error ("could not launch the application");
 	 //    }
		var result : Int = prepareAndRunHTTPServer();
		Sys.putEnv("SLIMERJSLAUNCHER", duellBuildFlashPath+"bin/slimerjs-0.9.1/xulrunner/xulrunner");
		ProcessHelper.runCommand(duellBuildFlashPath+"bin/slimerjs-0.9.1","python",["slimerjs.py","../test.js"]);

 	}
 	public function prepareAndRunHTTPServer() : Int
 	{
 		var args:Array<String> = [duellBuildFlashPath+"bin/node/http-server/http-server",targetDirectory+"flash/web","-p", "3000", "-c-1"];
 	    serverProcess = new Process(duellBuildFlashPath+"/bin/node/node-mac",args);
 	    //var result : Int = serverProcess.exitCode();
 	    //return result;
 	    return 0;
 	}
 	public function prepareFlashBuild() : Void
 	{
 	    createDirectoryAndCopyTemplate();
 	}
 	public function createDirectoryAndCopyTemplate() : Void
 	{
 		/// Create directories
 		PathHelper.mkdir(targetDirectory);

 	    ///copying template files 
 	    /// index.html, expressInstall.swf and swiftObject.js
 	    TemplateHelper.recursiveCopyTemplatedFiles(duellBuildFlashPath + "template/", projectDirectory, Configuration.getData(), Configuration.getData().TEMPLATE_FUNCTIONS);
 	}
	private function convertParsingDefinesToCompilationDefines()
	{	

		for (define in DuellProjectXML.getConfig().parsingConditions)
		{
			if (define == "debug" )
			{
				/// not allowed
				Configuration.getData().HAXE_COMPILE_ARGS.push("-debug");
				continue;
			} 

			Configuration.getData().HAXE_COMPILE_ARGS.push("-D");
			Configuration.getData().HAXE_COMPILE_ARGS.push(define);
		}
	} 	

 }