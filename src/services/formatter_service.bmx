' ------------------------------------------------------------------------------
' -- services/formatter_service.bmx
' --
' -- Service that manages all formatters registered with the application.
' --
' -- This file is part of "docgen" (https://www.sodaware.net/docgen/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------

SuperStrict

Import brl.map
Import brl.reflection

Import "service.bmx"
Import "../formatters/base_formatter.bmx"


Type FormatterService Extends Service
	
	Field _availableFormatters:TMap
	
	
	' ------------------------------------------------------------
	' -- Configuration API
	' ------------------------------------------------------------
	
	Method getFormatter:BaseFormatter(name:String)
		
		' Only create valid formatters
		If Not(Self.formatterExists(name)) Then Return Null
		
		' Create the new formatter
		Local formatterType:TTypeId = TTypeId(Self._availableFormatters.ValueForKey(name))
		Return BaseFormatter(formatterType.NewObject())
		
	End Method
	
	Method formatterExists:Byte(name:String)
		Return (Self._availableFormatters.ValueForKey(name) <> Null)
	End Method
	
	
	' ------------------------------------------------------------
	' -- Standard service methods
	' ------------------------------------------------------------

	Method InitialiseService()
		
		' Load all formatter types
		Local baseType:TTypeId = TTypeId.ForName("BaseFormatter")
		For Local formatterType:TTypeId = EachIn baseType.DerivedTypes()
			
			If formatterType.MetaData("name") <> "" Then
				DebugLog "Loaded: " + formatterType.MetaData("name")
				Self._availableFormatters.Insert(formatterType.MetaData("name"), formatterType)
			EndIf
			
		Next
		
	End Method
	
	Method UnloadService()
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Construction & Destruction
	' ------------------------------------------------------------
	
	Method New()
		Self._availableFormatters = New TMap
	End Method

End Type