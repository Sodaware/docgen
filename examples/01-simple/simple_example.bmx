Framework brl.basic

SuperStrict

Const SOMETHING_HERE:String = "I AM A CONSTANT!"

''' <summary>Name of the person.</summary>
Global thisIsMyName:String           = "My Name"
Global thisIsMyAge:Int               = 21
Global thisIsMySalary:Int            = 10.50

''' <summary>
''' This is a longer summary that may or may not have
''' multiple lines.
'''
''' And also a line break.
''' </summary>
''' <seealso cref="SimpleExample" />
''' <deprecated cref="thisIsMyFunction" />
Global thisIsMyExample:SimpleExample = new SimpleExample
Global thisIsMyFunction:String       = thisIsMyExample.sayGoodbye()


Local helloWorld:SimpleExample = New SimpleExample
helloWorld.sayHello("YOUR NAME HERE")

''' <summary>Hello</summary>
''' <author>Phil Newton</author>
Type SimpleExample

	Const GREETING:String = "Hello, "

	''
	' Says hello
	Method sayHello(name:String)
		Print SimpleExample.GREETING + name
	End Method

	Method sayGoodbye:String()
		return "Goodbye!"
	End Method

End Type