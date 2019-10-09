' ------------------------------------------------------------------------------
' -- src/formatters/base_formatter.bmx
' --
' -- Base documentation formatter. All formatters must extend this type.
' --
' -- This file is part of "docgen" (https://www.sodaware.net/docgen/)
' -- Copyright (c) 2016-2019 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Type BaseFormatter Abstract

	Field output:String

	Method setOutput(output:String)
		Self.output = output
	End Method

	Method generateOutput(files:TList) Abstract

End Type
