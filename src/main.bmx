' ------------------------------------------------------------------------------
' -- src/main.bmx
' --
' -- Primary file for "docgen". Docgen is a very simple tool for extracting
' -- documentation tags from a BlitzMax source file and converting them to
' -- something else.
' --
' -- This file is part of "docgen" (https://www.sodaware.net/docgen/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- This library is free software; you can redistribute it and/or modify
' -- it under the terms of the GNU General Public License as published by 
' -- the Free Software Foundation; either version 3 of the License, or 
' -- (at your option) any later version.
' --
' -- This library is distributed in the hope that it will be useful,
' -- but WITHOUT ANY WARRANTY; without even the implied warranty of
' -- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
' -- GNU General Public License for more details.
' -- 
' -- You should have received a copy of the GNU General Public
' -- License along with this library (see the file COPYING for more
' -- details); If not, see <http://www.gnu.org/licenses/>.
' ------------------------------------------------------------------------------


SuperStrict
 
Framework brl.basic
Import "core/app.bmx"

Local theApp:App = New App
theApp.Run()
