' ------------------------------------------------------------------------------
' -- src/descriptors/abstract_variable_descriptor.bmx
' --
' -- Base type for `variable` elements. Contains variable-specific information
' -- such as the variable type and its default value.
' --
' -- This file is part of "docgen" (https://www.sodaware.net/docgen/)
' -- Copyright (c) 2016-2019 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "abstract_descriptor.bmx"

Type AbstractVariableDescriptor extends AbstractDescriptor abstract

	Field variableType:String
	Field defaultValue:String

	Field isArray:Byte
	Field isVar:Byte
	Field isVarPtr:Byte
	Field isFunctionPointer:Byte

End Type
