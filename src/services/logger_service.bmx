' ------------------------------------------------------------------------------
' -- src/services/logger_service.bmx
' --
' -- Service for configuring and accessing the application logger.
' --
' -- This file is part of "docgen" (https://www.sodaware.net/docgen/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "service.bmx"
Import "../loggers/console_logger.bmx"


Type LoggerService Extends Service
	
	Field _log:BaseLogger
	
	Method getLogger:BaseLogger()
		Return Self._log
	End Method

	Method InitialiseService()
		Self._log = New ConsoleLogger
		Self._log._logLevel = ( BaseLogger.LOG_LEVEL_ERROR | BaseLogger.LOG_LEVEL_WARNING )
	End Method

	Method unloadService()
		Self._log = Null
	End Method
	
End Type
