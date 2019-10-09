' ------------------------------------------------------------------------------
' -- src/descriptors/method_descriptor.bmx
' --
' -- Descriptor for the `Method` keyword.
' --
' -- This file is part of "docgen" (https://www.sodaware.net/docgen/)
' -- Copyright (c) 2016-2019 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "callable_descriptor.bmx"

Type MethodDescriptor Extends CallableDescriptor
	Field locals:TList = New TList

	Method getKeyword:String()
		Return "method"
	End Method

End Type
