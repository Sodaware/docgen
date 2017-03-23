' ------------------------------------------------------------------------------
' -- src/descriptors/callable_descriptor.bmx
' --
' -- Base descriptor for a `callable` element (i.e.. a function or a method).
' --
' -- This file is part of "docgen" (https://www.sodaware.net/docgen/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "abstract_descriptor.bmx"
Import "abstract_variable_descriptor.bmx"
Import "parameter_descriptor.bmx"

Type CallableDescriptor Extends AbstractDescriptor
	
	Field parameters:TList
	Field returnType:String
	Field returnDescription:String
	Field returnObject:AbstractVariableDescriptor
	
	Method getParameter:ParameterDescriptor(name:String)
		For Local p:ParameterDescriptor = EachIn Self.parameters
			If p.name = name Then Return p
		Next
		Return Null
	End Method
	
	Method New()
		Self.parameters = New TList
	End Method
		
End Type
