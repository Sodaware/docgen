' ------------------------------------------------------------------------------
' -- src/descriptors/abstract_descriptor.bmx
' --
' -- Base type that all descriptors must extend. Contains standard information
' -- about an element such as its name, location, and raw comment.
' --
' -- This file is part of "docgen" (https://www.sodaware.net/docgen/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "source_file.bmx"


Type AbstractDescriptor
	
	' Location
	Field line:Int = 0
	Field column:Int = 0
	Field file:SourceFile
	
	Field name:String
	Field comments:String

	' Extra details
	Field summary:String	
	Field description:String
	Field seeAlso:String
	Field deprecatedNote:String
	Field replacedWith:String
	Field example:String
	
	''' <summary>Get the keyword that defines this descriptor, e.g. "Function" or "Method".</summary>
	Method getKeyword:String()
		Return ""
	End Method
	
End Type
