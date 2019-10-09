' ------------------------------------------------------------------------------
' -- src/descriptors/source_file.bmx
' --
' -- Descriptor for source files. Contains information about a file, what module
' -- it belongs to and a list of all its child descriptors (after parsing).
' --
' -- This file is part of "docgen" (https://www.sodaware.net/docgen/)
' -- Copyright (c) 2016-2019 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Type SourceFile

	' Module stuff (handle this differently?)
	Field isModule:Byte
	Field moduleName:String

	Field name:String
	Field path:String
	Field source:String

	Field lastModified:String

	Field includes:TList
	Field imports:TList

	Field functions:TList
	Field types:TList
	Field globals:TList
	Field locals:TList
	Field constants:TList

	Method addType:SourceFile(t:Object)
		Self.types.AddLast(t)
	End Method

	Method getFileName:String()
		Return StripDir(Self.path)
	End Method

	Method New()

		Self.includes  = New TList
		Self.imports   = New TList

		Self.functions = New TList
		Self.types     = New TList
		Self.globals   = New TList
		Self.locals    = New TList
		Self.constants = New TList

	End Method

End Type
