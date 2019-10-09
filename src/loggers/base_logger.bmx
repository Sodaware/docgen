' ------------------------------------------------------------------------------
' -- src/loggers/base_logger.bmx
' --
' -- Base logger that all loggers must extend.
' --
' -- Loggers are used during parsing and generation to notify the user of any
' -- parsing issues.
' --
' -- This file is part of "docgen" (https://www.sodaware.net/docgen/)
' -- Copyright (c) 2016-2019 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Type BaseLogger

	Const LOG_LEVEL_VERBOSE:Int	= 1
	Const LOG_LEVEL_INFO:Int	= 2
	Const LOG_LEVEL_WARNING:Int = 4
	Const LOG_LEVEL_ERROR:Int	= 8
	Const LOG_LEVEL_ALL:Int     = 15

	Field _logLevel:Int = LOG_LEVEL_ALL
	Field _errorCount:Int = 0
	Field _warningCount:Int = 0

	Method logError(message:String)
		Self._errorCount:+ 1
	End Method

	Method logInfo(message:String)
	End Method

	Method logVerbose(message:String)
	End Method

	Method logWarning(message:String)
		Self._warningCount:+ 1
	End Method

	Method logSuccess(message:String)

	End Method

	Method logFailure(message:String)

	End Method

End Type
