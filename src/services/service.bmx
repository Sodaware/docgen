' ------------------------------------------------------------------------------
' -- src/services/service.bmx
' --
' -- Base service. Contains hooks for initializing/unloading but that's about
' -- it.
' --
' -- This file is part of "docgen" (https://www.sodaware.net/docgen/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Type Service
	
	Method initialiseService() Abstract
	Method unloadService() Abstract
	
End Type
