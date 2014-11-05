component output="false" extends="BugLogAppender" hint="Async BugLogHQ appender" {

	/** Init
	* Constructor
	* @name The unique name for this appender.
	* @properties A map of configuration properties for the appender
	* @layout The layout class to use in this appender for custom message rendering.
	* @levelMin The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARN
	* @levelMax The default log level for this appender, by default it is 5. Optional. ex: LogBox.logLevels.WARN
	*/
	public AsyncBugLogAppender function init(
		Required	String	name,
					Struct	properties	= {},
					String	layout		= "",
					Numeric	levelMin	= 0,
					Numeric	levelMax	= 5
	) {
		// Init supertype
		super.init(argumentCollection=arguments);
		// strong reference to super scope if not cf9 and below choke on high load and cfthread
		variables.$super = super;
		return this;
	}
	
	
	

	/** logMessage
	* Write an entry into the appender
	* @logEvent The logging event
	*/
	public void function logMessage(
		Required	Any		logEvent
	) {
		var uuid = createobject("java", "java.util.UUID").randomUUID();
		var threadName = "#getname()#_logMessage_#replace(uuid,"-","","all")#";
		
		//Are we in a thread already?
		if( getUtil().inThread() ) {
			super.logMessage(arguments.logEvent);
		} else {
			//Thread this puppy
			 thread action="run" name="#threadName#" logEvent="#arguments.logEvent#" {
			 	variables.$super.logMessage(attributes.logEvent);
			 }
		}
	}
	
}