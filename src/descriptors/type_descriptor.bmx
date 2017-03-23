' ------------------------------------------------------------------------------
' -- src/descriptors/type_descriptor.bmx
' --
' -- Descriptor for the `Type` keyword. Contains information about the type as
' -- well as its fields, methods and functions.
' --
' -- This file is part of "docgen" (https://www.sodaware.net/docgen/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "abstract_descriptor.bmx"

Type TypeDescriptor Extends AbstractDescriptor
	
	Field fields:TList
	Field constants:TList
	Field globals:TList
	Field methods:TList
	Field functions:TList
	
	Method New()
		Self.fields = New TList
		Self.constants = New TList
		Self.globals = New TList
		Self.methods = New TList
		Self.functions = New TList
	End Method
	
End Type
