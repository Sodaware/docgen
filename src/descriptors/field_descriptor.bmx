' ------------------------------------------------------------------------------
' -- src/descriptors/field_descriptor.bmx
' --
' -- Descriptor for the `Field` keyword.
' --
' -- This file is part of "docgen" (https://www.sodaware.net/docgen/)
' -- Copyright (c) 2016-2019 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "abstract_variable_descriptor.bmx"

Type FieldDescriptor Extends AbstractVariableDescriptor
	Method toString:String()
		Return Self.name + " : " + Self.variableType + " = " + Self.defaultValue
	End Method
End Type
