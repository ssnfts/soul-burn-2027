-------------------------------------------------------------------------------
-- smart_lighting.ms
-- By SoulBurn 2027 Update
-- v 1.00
-- Created On: 05/01/25
-- Modified On: 05/01/25
-- tested using Max 2027
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-- scripts/SoulburnScripts/lib/smart_lighting_ui.py
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Smart Lighting Assistant — builds KEY/FILL/RIM rigs for Arnold, V-Ray, Corona
-- and Scanline/ART, audits scene lights for common problems, and adds render-
-- element / AOV sets.  The UI is a PySide6 docked panel (smart_lighting_ui.py).
-- Launch via smartLightingDefaults() or smartLightingUI().
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals
global smartLightingDefaults
global smartLightingUI

-- Includes
include "$userScripts\SoulburnScripts\lib\sLib.ms"

-- Functions

fn smartLightingGetPyPath =
	(
	return ((getdir #userScripts) + "\\SoulburnScripts\\lib\\smart_lighting_ui.py")
	)

fn smartLightingUI =
	(
	local pyPath = smartLightingGetPyPath()
	if not (doesFileExist pyPath) then
		(
		messageBox ("Smart Lighting UI not found:\n" + pyPath) title:"smartLighting"
		return undefined
		)
	-- Ensure the lib directory is on Python's path so the module is importable
	-- by name (smart_lighting_ui) from callbacks registered inside the panel.
	local libDir = getFilenamePath pyPath
	local addPathCmd = "import sys; _d=r'" + libDir + "'; _d not in sys.path and sys.path.insert(0,_d)"
	python.Execute addPathCmd
	-- Execute the file so the module is freshly defined, then call show().
	python.ExecuteFile pyPath
	python.Execute "import smart_lighting_ui; smart_lighting_ui.show()"
	)

fn smartLightingDefaults =
	(
	smartLightingUI()
	)

)
-------------------------------------------------------------------------------
