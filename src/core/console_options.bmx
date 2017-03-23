' ------------------------------------------------------------------------------
' -- src/core/console_options.bmx
' --
' -- Command line options for docgen.
' --
' -- This file is part of "docgen" (https://www.sodaware.net/docgen/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import sodaware.Console_Color
Import sodaware.Console_CommandLine

Type ConsoleOptions Extends CommandLineOptions

	Field NoLogo:Int       = False          { Description="Hides the copyright notice and header information" LongName="nologo" ShortName="n" }
	Field InputFile:String = ""             { Description="The input file or module to parse" LongName="input" ShortName="i"  }
	Field Output:String    = ""             { Description="The output file to write to" LongName="output" ShortName="o" }
	Field Format:String    = "json"         { Description="The formatter to use" LongName="format" ShortName="f" }
	Field ModPath:String   = ""         	{ Description="The full path to the blitzmax module directory" LongName="mod-path" ShortName="m" }
	
	Field Silent:Int	= False				{ Description="Supresses output to the console" LongName="silent" ShortName="s" }
	Field Verbose:Int   = False				{ Description="Show lots of extra detail" LongName="verbose" ShortName="v" }
	
	Field Help:Int		= False
	
	''
	' Check if all required inputs have been sent
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
		Super.Init(AppArgs)
	End Method
	
End Type
