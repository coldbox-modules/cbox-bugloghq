/**
********************************************************************************
*Copyright 2012 Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* A BugLogHQ Appender
**/
component extends="coldbox.system.logging.AbstractAppender"{
	
	/**
	* Constructor
	*/
	function init( 
		required name,
		struct properties=structnew(),
		layout="",
		numeric levelMin=0,
		numeric levelMax=4
	){
		super.init( argumentCollection=arguments );
		
		// Get buglogHQ Service, wirebox must be in application scope.
		variables.buglogHQService = application.wirebox.getInstance( "BugLogService@bugloghq" );
		
		return this;
	}
	
	/**
	* Log a message
	*/
	function logMessage( required logEvent ){
		var entry 	= "";
		
		if ( hasCustomLayout() ){
			entry = getCustomLayout().format( arguments.logEvent );
		} else {
			entry = arguments.logEvent.getCategory() & ":" & arguments.logEvent.getMessage();
		}

		if( getUtil().inThread() ) {
			// log it
			variables.buglogHQService.notifyService(
				message 		= entry,
				exception 		= {},
				extraInfo 		= arguments.logEvent.getExtraInfo(),
				severityCode 	= this.logLevels.lookup( arguments.logEvent.getSeverity() )
			);
		} else {
			// Thread this puppy
			thread 	action="run" 
					name="#threadName#" 
					logEvent="#arguments.logEvent#" 
					entry="#entry#"
			{
				// log it
				variables.buglogHQService.notifyService(
					message 		= attributes.entry,
					exception 		= {},
					extraInfo 		= attributes.logEvent.getExtraInfo(),
					severityCode 	= this.logLevels.lookup( attributes.logEvent.getSeverity() )
				);
			}
		}
	}
	
}
