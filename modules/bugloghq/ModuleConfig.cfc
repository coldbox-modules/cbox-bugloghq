/**
* Bug Log HQ Module
*/
component {

	// Module Properties
	this.title 				= "bugloghq";
	this.author 			= "Luis Majano";
	this.webURL 			= "http://www.ortussolutions.com";
	this.description 		= "Bug Log HQ Interaction";
	this.version			= "1.0.0";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup 	= true;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = true;
	// Module Entry Point
	this.entryPoint			= "";

	function configure(){
		// module settings - stored in modules.name.settings
		settings = {
			// The location of the listener where to send the bug reports
			"bugLogListener" : "",
			// A comma-delimited list of email addresses to which send the bug reports in case
			"bugEmailRecipients" :  "",
			// The sender address to use when sending the emails mentioned above.
			"bugEmailSender" : "",
			// The api key in use to submit the reports, empty if none.
			"apikey" : "",
			// The hostname of the server you are on, leave empty for auto calculated
			"hostname" : "",
			// The aplication name
			"appName"	: "",
			// The max dump depth
			"maxDumpDepth" : 10,
			// Write out errors to CFLog
			"writeToCFLog" : true,
			// Enable the BugLogHQ LogBox Appender Bridge
			"enableLogBoxAppender" : false
		};

		// SES Routes
		routes = [
			// Module Entry Point
			{pattern="/", handler="home",action="index"},
			// Convention Route
			{pattern="/:handler/:action?"}
		];

		// Custom Declared Points
		interceptorSettings = {
			customInterceptionPoints = ""
		};

		// Custom Declared Interceptors
		interceptors = [
		];


		// Map service
		binder.map( "BugLogService@bugloghq" )
			.to( "#moduleMapping#.model.BugLogService" )
			.asSingleton()
			.initArg( name="bugLogListener", 		value=settings.bugLogListener )
			.initArg( name="bugEmailRecipients", 	value=settings.bugEmailRecipients )
			.initArg( name="bugEmailSender", 		value=settings.bugEmailSender )
			.initArg( name="hostname", 				value=settings.hostname )
			.initArg( name="apikey", 				value=settings.apikey )
			.initArg( name="appName", 				value=settings.appName )
			.initArg( name="maxDumpDepth", 			value=settings.maxDumpDepth )
			.initArg( name="writeToCFLog", 			value=settings.writeToCFLog );
	}

	/**
	* Trap exceptions
	*/
	function onException( event, interceptData, buffer ){
		wirebox.getInstance( "BugLogService@bugloghq" )
			.notifyService(
				message = interceptData.exception.message & "." & interceptData.exception.detail,
				exception = interceptData.exception,
				extraInfo = getHTTPRequestData(),
				severityCode = "error"
			);
	}

	/**
	* Fired when the module is registered and activated.
	*/
	function onLoad(){
		// Load the LogBox Appenders
		loadAppenders();
	}

	/**
	* Fired when the module is unregistered and unloaded
	*/
	function onUnload(){

	}

	// load LogBox appenders
	private function loadAppenders(){
		// Get config
		var logBoxConfig 	= controller.getLogBox().getConfig();
		var rootConfig 		= "";

		// Register tracer appender
		if( settings.enableLogBoxAppender ){
			rootConfig = logBoxConfig.getRoot();
			logBoxConfig.appender( name="bugloghq_appender", class="#moduleMapping#.model.BugLogAppender" );
			logBoxConfig.root( levelMin=rootConfig.levelMin,
							   levelMax=rootConfig.levelMax,
							   appenders=listAppend( rootConfig.appenders, "bugloghq_appender") );
		}

		// Store back config
		controller.getLogBox().configure( logBoxConfig );
	}


}