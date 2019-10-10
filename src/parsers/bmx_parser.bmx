' ------------------------------------------------------------------------------
' -- src/parsers/bmx_parser.bmx
' --
' -- Basic parser for scanning BlitzMax source files. Reads the source code and
' -- extracts types, functions, methods, globals and other constructs.
' --
' -- Uses `cower.bmxlexer` for tokenizing the source code and `bah.libxml` for
' -- parsing XML comments.
' --
' -- This file is part of "docgen" (https://www.sodaware.net/docgen/)
' -- Copyright (c) 2016-2019 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import cower.bmxlexer
Import sodaware.file_util

Import bah.libxml

Import "../loggers/base_logger.bmx"

Import "../descriptors/source_file.bmx"
Import "../descriptors/abstract_descriptor.bmx"
Import "../descriptors/global_descriptor.bmx"
Import "../descriptors/const_descriptor.bmx"
Import "../descriptors/parameter_descriptor.bmx"
Import "../descriptors/type_descriptor.bmx"
Import "../descriptors/method_descriptor.bmx"
Import "../descriptors/function_descriptor.bmx"

Type BmxParser

	' Options
	Field parseIncludes:Byte = False

	' Internals
	Field _inputs:TList      = New TList
	Field _parsedFiles:TList = New TList
	Field _log:BaseLogger

	' TODO: Extract these to a location or something
	Field _currentDescriptor:AbstractDescriptor


	' ----------------------------------------------------------------------
	' -- Configuring the Parser
	' ----------------------------------------------------------------------

	Method addFile:BmxParser(fileName:String)
		Self._inputs.AddLast(fileName)
		Return Self
	End Method

	Method setLogger(logger:BaseLogger)
		Self._log = logger
		xmlSetErrorFunction(BmxParser.LogXmlError, Self)
	End Method

	Function LogXmlError(sender:Object, error:TxmlError)
		Local this:BmxParser = BmxParser(sender)
		If this = Null Or error = Null Then Return

		Local errorMessage:String = ""

		If this._currentDescriptor.file <> Null Then
			errorMessage :+ this._currentDescriptor.file.name + ": "
		End If

		If this._currentDescriptor <> Null Then
			errorMessage :+ "line " + this._currentDescriptor.line + " (" + this._currentDescriptor.name + ") "
		End If

		this._log.logError(errorMessage + error.getErrorMessage().Trim())
	End Function


	' ----------------------------------------------------------------------
	' -- Parsing Files
	' ----------------------------------------------------------------------

	''' <summary>
	''' Parses all files and returns a list of SourceFile objects.
	''' </summary>
	Method parseAll:TList()

		For Local file:String = EachIn Self._inputs
			Self._parsedFiles.AddLast(Self.parse(file))
		Next

		Return Self._parsedFiles

	End Method

	' [todo] - Should this be separate? Want to keep the pos / token etc hanging around. Maybe a general Parser object, and then a SourceParser object for parsing files etc

	''' <summary>
	''' Parses a single file and returns the parsed source file. Can add
	''' includes and imports if configured to do so.
	''' </summary>
	Method parse:SourceFile(fileName:String)

		' Load the source code.
		Local source:String = Trim(File_Util.getFileContents(fileName))

		' Create the lexer and parse the source file
		Local lexer:TLexer = New TLexer
		lexer.InitWithSource(source)
		lexer.Run()

		' Load tokens into source file
		Local pos:Int = 0
		Local currentToken:TToken
		Local file:SourceFile = New SourceFile

		Local currentType:TypeDescriptor = Null
		Local currentFunction:FunctionDescriptor = Null
		Local currentDescriptor:AbstractDescriptor
		Local currentComment:String = ""

		file.name = StripDir(fileName)
		file.path = RealPath(fileName)
		file.lastModified = File_Util.GetInfo(file.path).ToString()

		DebugLog ("Parsing file: " + fileName)

		While pos < lexer.NumTokens()

			currentToken = lexer.GetToken(pos)

			' Create a type
			If currentToken.kind = TToken.TOK_TYPE_KW Then

				DebugLog "Opening type: " + lexer.GetToken(pos + 1).ToString()

				' Create and setup the descriptor
				Local t:TypeDescriptor = TypeDescriptor(Self.createDescriptor(New TypeDescriptor, file, lexer, pos))

				' Set the current type to this object
				currentType = t
				currentDescriptor = t

				t.comments = currentComment
				currentComment = ""

				' Parse the comment
				Self.parseComment(t)

				' Add to list of types
				file.addType(t)
				pos:+ 1

			End If

			' Read a method
			If currentToken.kind = TToken.TOK_METHOD_KW Then

				' Create and setup the descriptor
				Local m:MethodDescriptor = MethodDescriptor(Self.createDescriptor(New MethodDescriptor, file, lexer, pos))

				m.comments = currentComment
				currentComment = ""

				' [todo] - Read in the return type
				If lexer.GetToken(pos + 2).kind = TToken.TOK_COLON Then
					m.returnType = lexer.GetToken(pos + 3).ToString()
					pos:+ 2
				End If

				' Read to the start of the parameters
				Self.findParametersStart(lexer, pos)

				' Only attempt to read parameters if the method actually has some
				If lexer.GetToken(pos + 1).kind <> TToken.TOK_CLOSEPAREN Then

					' Read all tokens until we hit a close parenthesis (i.e. end of all parameters)
					If lexer.GetToken(pos).kind <> TToken.TOK_CLOSEPAREN Then
						Repeat

							' Get the parameter
							Local param:ParameterDescriptor = ParameterDescriptor(Self.createDescriptor(New ParameterDescriptor, file, lexer, pos))
							If param.name = ":" Then
								param.name = lexer.GetToken(pos).ToString()
							EndIf

							' Set the variable type and default value
							Self.setVariableType(param, lexer, pos)
							Self.setVariableValue(param, lexer, pos)
							m.parameters.AddLast(param)

							Repeat
								pos:+ 1
							Until lexer.GetToken(pos).kind = TToken.TOK_CLOSEPAREN Or lexer.GetToken(pos).kind = TToken.TOK_COMMA

							' Repeat until end reached
							If lexer.GetToken(pos).kind = TToken.TOK_CLOSEPAREN Then Exit
							pos:+ 1
						Forever

					EndIf

				EndIf

				' Parse the comment
				Self.parseComment(m)
				currentDescriptor = m

				' TODO: Why this happen
				If currentType <> Null Then
					currentType.methods.AddLast(m)
				Else
					Print file.path
					Print currentToken.PositionString()
					Print m.name
					Throw "oops"
				EndIf
				pos:+ 1
			End If

			' Read a constant
			If currentToken.kind = TToken.TOK_CONST_KW Then

				' Create the descriptor and setup file/location
				Local constant:ConstDescriptor = ConstDescriptor(Self.createDescriptor(New ConstDescriptor, file, lexer, pos))

				' Add comments
				constant.comments = currentComment.Trim()
				currentComment = ""

				' Set the variable type and default value
				Self.setVariableType(constant, lexer, pos)
				Self.setVariableValue(constant, lexer, pos)

				' Do we need to do this for variables
				currentDescriptor = constant

				' Add to file unless defined in a type
				If currentType <> Null Then
					currentType.constants.AddLast(constant)
				Else
					file.constants.AddLast(constant)
				EndIf

				' Parse the comment
				Self.parseComment(constant)

				pos:+ 1

			End If

			' -- Read a global
			If currentToken.kind = TToken.TOK_GLOBAL_KW Then

				' Create the descriptor and setup file/location
				Local g:GlobalDescriptor = GlobalDescriptor(Self.createDescriptor(New GlobalDescriptor, file, lexer, pos))

				' Add comments
				g.comments = currentComment.Trim()
				currentComment = ""

				' Set the variable type and default value
				DebugLog "Parsed global: " + g.name
				Self.setVariableType(g, lexer, pos)
				DebugLog "Parsed global: " + g.name
				Self.setVariableValue(g, lexer, pos)
				DebugLog "Parsed global: " + g.name

				' Do we need to do this for variables
				currentDescriptor = g

				' Add to file unless defined in a type
				If currentType <> Null Then
					currentType.globals.AddLast(g)
				Else
					file.globals.AddLast(g)
				EndIf

				' Parse the comment
				Self.parseComment(g)

				' Move to the next item
				pos:+ 1
				' Continue

				DebugLog "Parsed global: " + g.name

			End If

			' Read a top-level function
			If currentToken.kind = TToken.TOK_FUNCTION_KW Then

				' Create and setup the descriptor
				Local f:FunctionDescriptor = FunctionDescriptor(Self.createDescriptor(New FunctionDescriptor, file, lexer, pos))

				f.comments = currentComment
				currentComment = ""

				' [todo] - Read in the return type
				If lexer.GetToken(pos + 2).kind = TToken.TOK_COLON Then
					f.returnType = lexer.GetToken(pos + 3).ToString()
					pos:+ 2
				End If

				' Read to the start of the parameters
				Self.findParametersStart(lexer, pos)

				' Only attempt to read parameters if the method actually has some
				If lexer.GetToken(pos + 1).kind <> TToken.TOK_CLOSEPAREN Then

					' Read all tokens until we hit a close parenthesis (i.e. end of all parameters)
					If lexer.GetToken(pos).kind <> TToken.TOK_CLOSEPAREN Then
						Repeat

							' Get the parameter
							Local param:ParameterDescriptor = ParameterDescriptor(Self.createDescriptor(New ParameterDescriptor, file, lexer, pos))
							If param.name = ":" Then
								param.name = lexer.GetToken(pos).ToString()
							EndIf

							' Set the variable type and default value
							Self.setVariableType(param, lexer, pos)
							Self.setVariableValue(param, lexer, pos)
							f.parameters.AddLast(param)

							Repeat
								pos:+ 1
							Until lexer.GetToken(pos).kind = TToken.TOK_CLOSEPAREN Or lexer.GetToken(pos).kind = TToken.TOK_COMMA

							' Repeat until end reached
							If lexer.GetToken(pos).kind = TToken.TOK_CLOSEPAREN Then Exit
							pos:+ 1
						Forever

					EndIf

				EndIf

				currentDescriptor = f
				currentFunction = f

				If currentType Then
					currentType.functions.addLast(f)
				Else
					file.functions.addLast(f)
				End If

				' Parse the comment
				Self.parseComment(f)

				pos:+ 1
			End If

			' Read comment line
			' [todo] - This should read ALL of the comments
			If currentToken.kind = TToken.TOK_LINE_COMMENT Then
				currentComment:+ lexer.getToken(pos).toString() + "~n"
			End if

			If currentToken.kind = TToken.TOK_ENDTYPE_KW Then
				DebugLog "Exiting type: " + currentType.name
				currentType = Null
				currentDescriptor = Null
			End If

			If currentToken.kind = TToken.TOK_ENDFUNCTION_KW Then
				currentFunction = Null
				currentDescriptor = Null
			End If

			' Move to the next token
			pos :+ 1

		WEnd

		For Local c:ConstDescriptor = EachIn file.constants
			DebugLog "Const " + c.name + ":" + c.variableType + " = " + c.defaultValue
			If c.summary Then
				DebugLog "  - " + c.summary
			EndIf
		Next

		For Local g:GlobalDescriptor = EachIn file.globals
			DebugLog "Global " + g.name + ":" + g.variableType + " = " + g.defaultValue
			If g.summary Then
				DebugLog "  - " + g.summary
			EndIf
		Next

		For Local t:TypeDescriptor = EachIn file.types
			DebugLog "Type " + t.name

			For Local m:MethodDescriptor = EachIn t.methods
				DebugLog "  Method " + m.name + ":" + m.returnType
			Next
		Next

		Return file

	End Method

	Method parseComment(descriptor:AbstractDescriptor)

		If descriptor.comments = "" Then Return

		' Remove all lines that don't start with the comment tag
		Local commentLines:String[] = descriptor.comments.split("~n")
		Local comments:String = ""
		For Local line:String = EachIn commentLines
			If line.Trim().StartsWith("''' ") Then comments :+ line
		Next

		descriptor.comments = comments

		If descriptor.comments.StartsWith("''' ") Then
			Self._currentDescriptor = descriptor
			Try
				Self.parseXmlComment(descriptor)
			Catch e:Object
				Self._log.logError("It broke")
			End Try
		End If

	End Method

	Method parseXmlComment(descriptor:AbstractDescriptor)

		Local comment:String = descriptor.comments.Replace("'''", "")
		comment = "<docString>" + comment + "</docString>"

		' Attempt to parse.
		Local commentDoc:TxmlDoc = TxmlDoc.parseDoc(comment)
		If commentDoc = Null Then Return

		Local commentNode:TxmlNode = commentDoc.getRootElement()

		For Local node:TxmlNode = EachIn commentNode.getChildren()
			Select node.getName().ToLower()

				Case "summary"
					descriptor.summary = node.getContent().Trim()
					descriptor.summary = descriptor.summary.Replace(" ~n", "<<< NEW LINE >>>")
					descriptor.summary = descriptor.summary.Replace("~n", "")
					descriptor.summary = descriptor.summary.Replace("<<< NEW LINE >>>", "\\n")

				Case "description"
					descriptor.description = node.getContent().Trim()
					descriptor.description = descriptor.description.Replace(" ~n", "<<< NEW LINE >>>")
					descriptor.description = descriptor.description.Replace("~n", "")
					descriptor.description = descriptor.description.Replace("<<< NEW LINE >>>", "\\n")

				case "example"
					descriptor.example = node.getContent().Trim()

				' TODO: Convert to arrays!
				Case "seealso"
					descriptor.seeAlso = node.getAttribute("cref")

				Case "return"
					CallableDescriptor(descriptor).returnDescription = node.getContent().Trim()

				Case "deprecated"
					descriptor.deprecatedNote = node.getContent().Trim()
					descriptor.replacedWith   = node.getAttribute("cref")

				Case "param"
					Local p:ParameterDescriptor = CallableDescriptor(descriptor).getParameter(node.getAttribute("name"))
					If p Then
						p.description = node.getContent().Trim()
					Else
						' Documentation for an unknown parameter
						Local message:String = "Could not find parameter `" + node.getAttribute("name") + "`"
						message :+ " for " + descriptor.getKeyword() + " `" + descriptor.name + "`"
						message :+ " (" + descriptor.file.getFileName() + ")"
						Self._log.logWarning(message)
					EndIf

			End Select
		Next


	End Method

	Method setVariableType(variable:AbstractVariableDescriptor Var, lexer:TLexer, pos:Int Var)

		' Check if it's a function pointer
		If Self.isVariableFunctionPointer(lexer, pos + 1) Then
			variable.name = lexer.GetToken(pos).ToString()
			variable.isFunctionPointer = True
			variable.variableType = Self.readFunctionPointer(lexer, pos)
			Return
		End If

		' This is horribly kludgey but it works
		Local offset:Int = 1
		If lexer.GetToken(pos + offset + 1).kind = TToken.TOK_COLON Then
			offset :+ 1
		End If

		' Read the variable's type
		If lexer.GetToken(pos + offset).kind = TToken.TOK_COLON Then

			variable.variableType = lexer.GetToken(pos + offset + 1).ToString()
			pos:+ 2

			' Check if it's an array
			If lexer.GetToken(pos + offset).kind = TToken.TOK_OPENBRACKET Then
				variable.isArray = True
				'pos:+ 2
			End If

			' Check if it's a var or var ptr
			If lexer.GetToken(pos + offset).kind = TToken.TOK_VAR_KW Then
				If lexer.GetToken(pos + offset + 1).kind = TToken.TOK_PTR_KW Then
					variable.isVarPtr = True
					pos:+ 3
				Else
					variable.isVar = True
					pos:+ 2
				EndIf
			End If

		End If

	End Method

	' TODO: Clean this up a little bit
	Method isVariableFunctionPointer:Byte(lexer:TLexer, pos:Int)

		Repeat
			If pos >= lexer.NumTokens() - 1 Then Return False
			If lexer.GetToken(pos).kind = TToken.TOK_OPENPAREN Then Return True
			pos:+ 1
		Until lexer.GetToken(pos).kind = TToken.TOK_CLOSEPAREN Or lexer.GetToken(pos).kind = TToken.TOK_COMMA Or lexer.GetToken(pos).kind = TToken.TOK_NEWLINE

		Return False

	End Method

	Method readFunctionPointer:String(lexer:TLexer, pos:Int Var)

		pos:+ 1
		Local definitionString:String = "function"

		Repeat
			definitionString:+ lexer.GetToken(pos).ToString()
			If lexer.GetToken(pos).kind = TToken.TOK_CLOSEPAREN Then Return definitionString
			pos:+ 1
		Until lexer.GetToken(pos).kind = TToken.TOK_CLOSEPAREN Or lexer.GetToken(pos).kind = TToken.TOK_COMMA

		Return definitionString + ")"

	End Method

	Method setVariableValue(variable:AbstractVariableDescriptor, lexer:TLexer, pos:Int Var)

		' Read in the default value
		If lexer.GetToken(pos + 2).kind = TToken.TOK_EQUALS Then

			If lexer.GetToken(pos + 3).kind = TToken.TOK_NEW_KW Then

				variable.defaultValue = "New " + lexer.GetToken(pos + 4).ToString()
				pos:+ 1

			ElseIf lexer.GetToken(pos + 3).kind = TToken.TOK_ID Then

				If lexer.GetToken(pos + 3).ToString().ToLower() = "true" Then
					variable.defaultValue = lexer.GetToken(pos + 3).ToString()
				ElseIf lexer.GetToken(pos + 3).ToString().ToLower() = "false" Then
					variable.defaultValue = lexer.GetToken(pos + 3).ToString()
				Else
					' Absorb everything until end of line
					Local i:Int = pos + 3
					While lexer.GetToken(i).kind <> TToken.TOK_NEWLINE
						variable.defaultValue:+ lexer.GetToken(i).ToString()
						i:+ 1
						pos:+ 1
					Wend
				EndIf
			Else
				variable.defaultValue = lexer.GetToken(pos + 3).ToString()
			End If

			pos:+ 3

		End If

	End Method

	Method findParametersStart(lexer:TLexer, pos:Int Var)
		Repeat
			pos:+ 1
		Until lexer.GetToken(pos).kind = TToken.TOK_OPENPAREN
	End Method

	''
	' Create a descriptor and set file, name and position
	Method createDescriptor:AbstractDescriptor(descriptor:AbstractDescriptor, file:SourceFile, lexer:TLexer, pos:Int)
		descriptor.file   = file
		descriptor.name   = lexer.GetToken(pos + 1).ToString()
		descriptor.column = lexer.GetToken(pos).column
		descriptor.line   = lexer.GetToken(pos).line

		Return descriptor
	End Method

End Type
