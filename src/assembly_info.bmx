' ------------------------------------------------------------
' -- src/assembly_info.bmx
' -- 
' -- Application information that won't change that often.
' ------------------------------------------------------------


SuperStrict

Const FINAL_BUILD:Int		= True

''' <summary>Type containing information about this assembly (application)</summary>
Type AssemblyInfo
	
	Const NAME:String         = "docgen"
	Const VERSION:String      = "0.1.0.0"
	Const RELEASE_DATE:String = "March 23rd, 2017"
	Const COPYRIGHT:String    = "2016-2017 Phil Newton"
	Const HOMEPAGE:String     = "https://sodaware.net/docgen/"
	
End Type
