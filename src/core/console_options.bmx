' ------------------------------------------------------------------------------
' -- src/core/console_options.bmx
' --
' -- Command line options for docgen.
' --
' -- This file is part of "docgen" (https://www.sodaware.net/docgen/)
' -- Copyright (c) 2016-2019 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import sodaware.Console_Color
Import sodaware.Console_CommandLine

Type ConsoleOptions Extends CommandLineOptions

	' Switches
	Field Help:Byte        = False
	Field Silent:Byte      = False          { Description="Supress output to the console" LongName="silent" ShortName="s" }
	Field Verbose:Byte     = False          { Description="Show lots of extra detail" LongName="verbose" ShortName="v" }
	Field NoLogo:Byte      = False          { Description="Hide the copyright notice and header information" LongName="nologo" ShortName="n" }

	' Build config.
	Field InputFile:String = ""             { Description="The input file or module to parse" LongName="input" ShortName="i" }
	Field Output:String    = ""             { Description="The output file to write to" LongName="output" ShortName="o" }
	Field Format:String    = "json"         { Description="The formatter to use" LongName="format" ShortName="f" }
	Field ModPath:String   = ""				{ Description="The full path to the blitzmax module directory" LongName="mod-path" ShortName="m" }


	''' <summary>Check if all required inputs have been sent.</summary>
	Method isEmpty:Byte()
		Return Not(Self.InputFile) And Not(Self.hasArguments())
	End Method

	Method showHelp()

		PrintC "Usage%n: docgen [options] [--input input] [--output output]"
		PrintC ""
		PrintC "Extracts information from BlitzMax source code and turns it into"
		PrintC "something that can be used by other applications."
		PrintC ""

		PrintC "%YCommands:%n "

		PrintC(Super.CreateHelp(80, True))

	End Method

	' sorry :(
	Method New()
		Super.init(AppArgs)
	End Method

End Type
