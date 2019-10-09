' ------------------------------------------------------------------------------
' -- src/core/service_manager.bmx
' --
' -- Used to manage application services.
' --
' -- This file is part of "docgen" (https://www.sodaware.net/docgen/)
' -- Copyright (c) 2016-2019 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.map
Import brl.reflection

Import "../services/service.bmx"

' TODO: This needs rebuilding
Type ServiceManager

	Field _services:TList       = New TList
	Field _serviceLookup:TMap   = New TMap

	Method addService(service:Service)
		Self._services.addLast(service)
		Self._serviceLookup.insert(TTypeId.ForObject(service), service)
	End Method

	Method hasService:Byte(name:String)

	End Method

	Method get:Service(name:String)
		Return Self.getService(TTypeId.ForName(name))
	End Method

	Method getService:Service(serviceName:TTypeId)

		' Get service from lookup
		Local theService:Service = Service(Self._serviceLookup.ValueForKey(serviceName))

		' If not found, search the list of services
		If theService = Null Then

			For Local tService:Service = EachIn Self._services
				If TTypeId.ForObject(tService) = serviceName Then
					theService = tService
					Exit
				End If
			Next
			' If still not found, throw an error
		EndIf

		' Done
		Return theService

	End Method

	Method initaliseServices()
		For Local tService:Service = EachIn Self._services
			tService.initialiseService()
		Next
	End Method

	Method stopServices()
		Self._services.Reverse()
		For Local tService:Service = EachIn Self._services
			tService.unloadService()
		Next
	End Method

End Type
