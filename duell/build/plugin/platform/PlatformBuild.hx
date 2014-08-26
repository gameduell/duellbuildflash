/**
 * @autor kgar
 * @date 26.08.2014.
 * @company Gameduell GmbH
 */
 class PlatformBuild
 {
 	public var requiredSetups = ["flash"];

 	private var isDebug : Bool = false;
 	private var isAdvancedTelemetry : Bool = false;
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