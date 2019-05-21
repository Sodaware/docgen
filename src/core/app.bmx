' ------------------------------------------------------------------------------
' -- src/core/app.bmx
' --
' -- Main application logic. Handles pretty much everything.
' --
' -- This file is part of "docgen" (https://www.sodaware.net/docgen/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import sodaware.Console_Color
Import brl.reflection
Import brl.retro

' -- Application Setup
Import "../assembly_info.bmx"
Import "console_options.bmx"
Import "service_manager.bmx"
Import "generator.bmx"

' -- Services
Import "../services/configuration_service.bmx"
Import "../services/formatter_service.bmx"
Import "../services/parser_service.bmx"
Import "../services/logger_service.bmx"

' -- Formatters
Import "../formatters/json_formatter.bmx"


''' <summary>Main docgen application.</summary>
Type App

	Field _options:ConsoleOptions			'''< Command line options
	Field _services:ServiceManager			'''< Application services


	' ------------------------------------------------------------
	' -- Main application entry
	' ------------------------------------------------------------

	''' <summary>Application entry point.</summary>
	Method Run:Int()

		' -- Setup the app
		Self._setup()

		' -- Show application header (if not hidden)
		If Not(Self._options.NoLogo) Then Self.writeHeader()

		' -- Show help message if requested - quit afterwards
		If Self._options.Help Or Self._options.isEmpty() Then
			Self._options.showHelp()
			Self._shutdown()
		End If

		' -- Add standard services to ServiceManager
		Self._services.addService(New ConfigurationService)
		Self._services.addService(New FormatterService)
		Self._services.addService(New ParserService)
		Self._services.addService(New LoggerService)

		' -- Initialise the services
		Self._services.initaliseServices()

		' -- Make some documentation!
		Self._execute()

	End Method


	' ------------------------------------------------------------
	' -- Private execution
	' ------------------------------------------------------------

	''' <summary>Executes the selected build script & target.</summary>
	Method _execute()

		' Get required services
		Local formatters:FormatterService = FormatterService(Self._services.get("FormatterService"))
		Local parsers:ParserService       = ParserService(Self._services.get("ParserService"))
		Local loggers:LoggerService       = LoggerService(Self._services.get("LoggerService"))

		' Validate options
		If formatters.formatterExists(Self._options.Format) = False Then
			Throw "Could not find formatter: " + Self._options.Format
		End If

		If Self._options.Verbose Then
			loggers._log._logLevel = BaseLogger.LOG_LEVEL_ALL
			loggers._log.logVerbose("Verbose mode enabled")
		End If

		' Create a new generator
		Local gen:Generator = New Generator

		' Set up logging
		gen.setLogger(loggers.getLogger())

		' Set required options

		' Add parsers and formatters
		gen.setFormatter(formatters.getFormatter(Self._options.Format))

		' Set options
		' [todo] - Don't pass these in direct
		gen._options = Self._options

		' Generate!
		gen.generate()

		loggers.getLogger().logSuccess("Documentation saved to ~q" + Self._options.output + "~q")

		' -- All done!
		Self._shutdown()

	End Method


	' ------------------------------------------------------------
	' -- Output methods
	' ------------------------------------------------------------

	''' <summary>Writes the application header.</summary>
	Method writeHeader()

		PrintC "%g" + AssemblyInfo.NAME + " " + AssemblyInfo.VERSION + " (Released: " + AssemblyInfo.RELEASE_DATE + ")"
		PrintC "(C)opyright " + AssemblyInfo.COPYRIGHT
		PrintC "%c" + AssemblyInfo.HOMEPAGE + "%n"
		PrintC ""

	End Method


	' ------------------------------------------------------------
	' -- Application setup & shutdown
	' ------------------------------------------------------------

	Method _setup()

		' Get command line options
		Self._options = New ConsoleOptions

		' Setup service manager
		Self._services = New ServiceManager

	End Method

	Method _shutdown()
		Self._services.StopServices()
		End
	End Method


	' ------------------------------------------------------------
	' -- Construction / destruction
	' ------------------------------------------------------------

	Function Create:App()
		Local this:App	= New App
		Return this
	End Function

End Type
