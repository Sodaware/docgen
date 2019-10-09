' ------------------------------------------------------------------------------
' -- src/formatters/json_formatter.bmx
' --
' -- JSON output formatter. Converts a list of parsed files into JSON output.
' --
' -- This file is part of "docgen" (https://www.sodaware.net/docgen/)
' -- Copyright (c) 2016-2019 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


' [todo] - Make sure values in quotations are escaped

SuperStrict

Import sodaware.file_json
Import brl.system

Import "../assembly_info.bmx"
Import "base_formatter.bmx"
Import "../descriptors/abstract_descriptor.bmx"
Import "../descriptors/global_descriptor.bmx"
Import "../descriptors/const_descriptor.bmx"
Import "../descriptors/function_descriptor.bmx"
Import "../descriptors/type_descriptor.bmx"
Import "../descriptors/method_descriptor.bmx"
Import "../descriptors/parameter_descriptor.bmx"
Import "../descriptors/field_descriptor.bmx"
Import "../descriptors/source_file.bmx"


Type JsonFormatter Extends BaseFormatter ..
	{ name = "json" }

	Method generateOutput(files:TList)

		' Create a new output node and empty file list
		Local jsonOutput:TJsonObject = New TJsonObject
		Local fileNodes:TJSONArray   = TJSONArray.Create(files.Count())

		' Add header block with information about docgen
		Local appNode:TJSONObject = New TJSONObject
		appNode.set("version", AssemblyInfo.VERSION)
		appNode.set("created_at", CurrentDate() + " " + CurrentTime())
		jsonOutput.set("docgen", appNode)

		' Add each file
		Local filePos:Int = 0
		For Local file:SourceFile = EachIn files

			' Create the file node
			Local fileNode:TJSONObject = New TJSONObject

			' Set the basic data
			fileNode.set("name", file.name)
			fileNode.set("last_modified", file.lastModified)

			' Add Everyting
			Self._addItems(fileNode, "globals", file.globals, JsonFormatter._createGlobal)
			Self._addItems(fileNode, "constants", file.constants, JsonFormatter._createConstant)
			Self._addItems(fileNode, "types", file.types, JsonFormatter._createType)
			Self._addItems(fileNode, "functions", file.functions, JsonFormatter._createFunction)
'			Local globals:TJsonArray = TJsonArray.Create(file.globals.Count())
'			pos = 0
'			For Local g:GlobalDescriptor = EachIn file.globals
'				globals.SetByIndex(pos, Self._createGlobal(g))
'				pos:+ 1
'			Next
'
'			jsonOutput.SetByName("globals", globals)

			' Add constants

			' Add functions

			' Add to output
			fileNodes.SetByIndex(filePos, fileNode)
			filePos:+ 1

		Next

		' Assemble
		jsonOutput.set("files", fileNodes)

		' Save the output
		Local fileOut:TStream = WriteFile(Self.output)
		fileOut.WriteLine(jsonOutput.ToString())

	End Method

	' ------------------------------------------------------------
	' -- Generic Item Adder
	' ------------------------------------------------------------

	''
	' Add a list of items contained in ITEMS to jsonOutput. Used callback to format them.
	Method _addItems(jsonOutput:TJSONObject, name:String, items:TList, callback:TJSONObject(d:AbstractDescriptor))

		Local itemsList:TJsonArray = TJsonArray.Create(items.Count())
		Local pos:Int = 0

		For Local g:AbstractDescriptor = EachIn items
			itemsList.SetByIndex(pos, callback(g))
			pos:+ 1
		Next

		jsonOutput.SetByName(name, itemsList)

	End Method


	' ------------------------------------------------------------
	' -- Element Creators
	' ------------------------------------------------------------

	Function _createGlobal:TJSONObject(base:AbstractDescriptor)

		Local g:GlobalDescriptor = GlobalDescriptor(base)
		Local d:TJSONObject = New TJsonObject

		' Details
		d.SetByName("name", TJSONString.Create(g.name))
		d.SetByName("type", TJSONString.Create(g.variableType))
		d.SetByName("defaultValue", TJSONString.Create(g.defaultValue))

		' Docs
		d.SetByName("summary", TJSONString.Create(g.summary))
		d.SetByName("description", TJSONString.Create(g.description))
		d.SetByName("seeAlso", TJSONString.Create(g.seeAlso))

		' Location
		d.SetByName("line", TJSONNumber.Create(g.line))
		d.SetByName("column", TJSONNumber.Create(g.column))

		Return d

	End Function

	Function _createConstant:TJSONObject(base:AbstractDescriptor)

		Local variable:ConstDescriptor = ConstDescriptor(base)
		Local d:TJSONObject = New TJsonObject

		' Details
		d.SetByName("name", TJSONString.Create(variable.name))
		d.SetByName("type", TJSONString.Create(variable.variableType))
		d.SetByName("defaultValue", TJSONString.Create(variable.defaultValue))

		' Docs
		d.SetByName("summary", TJSONString.Create(variable.summary))
		d.SetByName("description", TJSONString.Create(variable.description))
		d.SetByName("seeAlso", TJSONString.Create(variable.seeAlso))

		' Location
		d.SetByName("line", TJSONNumber.Create(variable.line))
		d.SetByName("column", TJSONNumber.Create(variable.column))

		Return d

	End Function

	Function _createFunction:TJSONObject(base:AbstractDescriptor)

		Local f:FunctionDescriptor = FunctionDescriptor(base)
		Local d:TJSONObject = New TJsonObject

		' Details
		d.SetByName("name", TJSONString.Create(f.name))
		d.SetByName("type", TJSONString.Create(f.returnType))

		' Docs
		d.SetByName("summary", TJSONString.Create(f.summary))
		d.SetByName("description", TJSONString.Create(f.description))
		d.SetByName("returnType", TJSONString.Create(f.returnType))
		d.SetByName("returnDescription", TJSONString.Create(f.returnDescription))
		d.SetByName("seeAlso", TJSONString.Create(f.seeAlso))
		d.setByName("example", TJSONString.create(f.example))

		' Parameter docs
		If f.parameters.Count() > 0 Then
			Local parameters:TJSONArray = TJsonArray.Create(f.parameters.Count())

			Local i:Int = 0
			For Local p:ParameterDescriptor = EachIn f.parameters
				Local parameter:TJSONObject = New TJSONObject
				parameter.SetByName("name", TJSONString.Create(p.name))
				parameter.SetByName("type", TJSONString.Create(p.variableType))
				parameter.SetByName("defaultValue", TJSONString.Create(p.defaultValue))
				parameter.SetByName("description", TJSONString.Create(p.description))

				' Flags
				parameter.SetByName("isArray", TJSONBoolean.Create(p.isArray))
				parameter.SetByName("isVar", TJSONBoolean.Create(p.isVar))
				parameter.SetByName("isVarPtr", TJSONBoolean.Create(p.isVarPtr))
				parameter.SetByName("isFunctionPointer", TJSONBoolean.Create(p.isFunctionPointer))

				parameters.SetByIndex(i, parameter)
				i :+ 1
			Next

			d.SetByName("parameters", parameters)
		End If

		' Location
		d.SetByName("line", TJSONNumber.Create(f.line))
		d.SetByName("column", TJSONNumber.Create(f.column))

		Return d

	End Function

	Function _createType:TJSONObject(base:AbstractDescriptor)

		Local typeInfo:TypeDescriptor = TypeDescriptor(base)
		Local d:TJSONObject = New TJsonObject

		' Details
		d.SetByName("name", TJSONString.Create(typeInfo.name))

		' Docs
		d.SetByName("summary", TJSONString.Create(typeInfo.summary))
		d.SetByName("description", TJSONString.Create(typeInfo.description))
'		d.SetByName("seeAlso", TJSONString.Create(typeInfo.seeAlso))
'		d.setByName("example", TJSONString.create(typeInfo.example))

		' Fields
		If typeInfo.fields.Count() > 0 Then
			Local typeFields:TJSONArray = TJsonArray.Create(typeInfo.fields.Count())

			Local i:Int = 0
			For Local t:FieldDescriptor = EachIn typeInfo.fields
				Local typeField:TJSONObject = New TJSONObject
				typeField.SetByName("name", TJSONString.Create(t.name))
				typeField.SetByName("type", TJSONString.Create(t.variableType))
				typeField.SetByName("defaultValue", TJSONString.Create(t.defaultValue))
				typeField.SetByName("description", TJSONString.Create(t.description))

				' Flags
				typeField.SetByName("isArray", TJSONBoolean.Create(t.isArray))
				typeField.SetByName("isVar", TJSONBoolean.Create(t.isVar))
				typeField.SetByName("isVarPtr", TJSONBoolean.Create(t.isVarPtr))
				typeField.SetByName("isFunctionPointer", TJSONBoolean.Create(t.isFunctionPointer))

				typeFields.SetByIndex(i, typeField)
				i :+ 1
			Next

			d.SetByName("fields", typeFields)
		End If

		' Methods
		If typeInfo.methods.Count() > 0 Then
			Local typeMethods:TJSONArray = TJsonArray.Create(typeInfo.methods.Count())

			Local i:Int = 0
			For Local m:MethodDescriptor = EachIn typeInfo.methods
				Local methodNode:TJSONObject = New TJSONObject
				methodNode.SetByName("name", TJSONString.Create(m.name))
				methodNode.SetByName("summary", TJSONString.Create(m.summary))
				methodNode.SetByName("returnType", TJSONString.Create(m.returnType))
				methodNode.SetByName("returnDescription", TJSONString.Create(m.returnDescription))
				methodNode.SetByName("seeAlso", TJSONString.Create(m.seeAlso))
				methodNode.setByName("example", TJSONString.Create(m.example))

				' Parameter docs
				If m.parameters.Count() > 0 Then
					Local parameters:TJSONArray = TJsonArray.Create(m.parameters.Count())

					Local i:Int = 0
					For Local p:ParameterDescriptor = EachIn m.parameters
						Local parameter:TJSONObject = New TJSONObject
						parameter.SetByName("name", TJSONString.Create(p.name))
						parameter.SetByName("type", TJSONString.Create(p.variableType))
						parameter.SetByName("defaultValue", TJSONString.Create(p.defaultValue))
						parameter.SetByName("description", TJSONString.Create(p.description))

						' Flags
						parameter.SetByName("isArray", TJSONBoolean.Create(p.isArray))
						parameter.SetByName("isVar", TJSONBoolean.Create(p.isVar))
						parameter.SetByName("isVarPtr", TJSONBoolean.Create(p.isVarPtr))
						parameter.SetByName("isFunctionPointer", TJSONBoolean.Create(p.isFunctionPointer))

						parameters.SetByIndex(i, parameter)
						i :+ 1
					Next

					methodNode.SetByName("parameters", parameters)
				End If

				typeMethods.SetByIndex(i, methodNode)
				i :+ 1
			Next

			d.SetByName("methods", typeMethods)
		End If

		' Location
		d.SetByName("line", TJSONNumber.Create(typeInfo.line))
		d.SetByName("column", TJSONNumber.Create(typeInfo.column))

		Return d

	End Function

End Type