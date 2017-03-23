' ------------------------------------------------------------------------------
' -- src/loggers/console_logger.bmx
' --
' -- Sends log messages straight to the console. Supports colour codes.
' --
' -- This file is part of "docgen" (https://www.sodaware.net/docgen/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import sodaware.Console_Color

Import "base_logger.bmx"

Type ConsoleLogger extends BaseLogger

	Method logError(message:String)
		If Self._logLevel & BaseLogger.LOG_LEVEL_ERROR Then
			Super.logError(message)
			PrintC("  [%rerror%n] " + message)
		EndIf
	End Method

	Method logInfo(message:String)
		If Self._logLevel & BaseLogger.LOG_LEVEL_INFO Then
			Super.logInfo(message)
			PrintC("   [%cinfo%n] " + message)		
		EndIf
	End Method
	
	Method logVerbose(message:String)
		If Self._logLevel & BaseLogger.LOG_LEVEL_VERBOSE Then
			Super.logInfo(message)
			PrintC("[%cverbose%n] " + message)		
		EndIf
	End Method
	
	Method logWarning(message:String)
		super.logWarning(message)
		PrintC("[%ywarning%n] " + message)
	End Method
	
	Method logSuccess(message:String)
		super.logSuccess(message)
		PrintC("[%Gsuccess%n] " + message)
	End Method

	Method logFailure(message:String)
		super.logFailure(message)
		PrintC("[%Rfailure%n] " + message)
	End Method
	
End Type
