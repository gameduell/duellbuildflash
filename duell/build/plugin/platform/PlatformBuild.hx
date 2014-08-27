/**
 * @autor kgar
 * @date 26.08.2014.
 * @company Gameduell GmbH
 */
 import duell.build.objects.Configuration;
 import duell.helpers.PathHelper;
 import duell.helpers.LogHelper;
 import duell.helpers.FileHelper;
 import duell.helpers.ProcessHelper;

 class PlatformBuild
 {
 	public var requiredSetups = ["flash"];

 	private var isDebug : Bool = false;
 	private var isAdvancedTelemetry : Bool = false;

 	public var targetDirectory : String;
 	public var duellBuildFlashPath : String;
 	public var projectDirectory : String;
 	public function new()
 	{
 		checkArguments();
 	}
 	public function parse():Void
 	{
 	    parseProject();
 	}
 	public function parseProject():Void
 	{
 	    var projectXML = DuellProjectXML.getConfig();
		projectXML.parse();
 	}
 	public function prepareBuild() : Void
 	{
 	    targetDirectory = Configuration.getData().OUTPUT + "/" + "flash";
 	    projectDirectory = targetDirectory + "/" + Configuration.getData().APP.FILE + "/";
 	    duellBuildFlashPath = DuellLib.getDuellLib("duellbuildflash").getPath();

 	    prepareFlashBuild();
 	}
 	public function build() : Void
 	{
		LogHelper.info("", "" + Configuration.getData());
		LogHelper.info("", "" + Configuration.getData().LIBRARY.GRAPHICS);

 	}

 	public function run() : Void
 	{
 	    runApp();/// run app in the browser
 	}
 	public function runApp() : Void
 	{
 		LogHelper.info("", "Launching application in "+PlatformConfiguration.getData().DEFAULT_BROWSER+" browser");
 	    var result : Int = ProcessHelper.openURL(duellBuildFlashPath);
 	    if(result != 0)

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
 	    TemplateHelper.recursiveCopyTemplatedFiles(duellBuildFlashPath + "template/flash/web", projectDirectory + "/haxe", Configuration.getData(), Configuration.getData().TEMPLATE_FUNCTIONS);
 	}

 	public static function checkArguments():Void
 	{
		for (arg in Sys.args())
		{
			if (arg == "-debug")
			{
				isDebug = true;
			}
			else if( arg == "-advanced-telemetry")
			{
				isAdvancedTelemetry = true;
			}
		}

		if (isDebug)
		{
			PlatformConfiguration.addParsingDefine("debug");
		}
		else
		{
			PlatformConfiguration.addParsingDefine("release");
		}

		if(isAdvancedTelemetry)
		{
			PlatformConfiguration.addParsingDefine("advanced-telemetry");
		}

 	}

 }