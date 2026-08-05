-------------------------------------------------------------------------------
-- SoulburnScripts_AtlasAutoStart.ms
-- By SoulBurn 2027 Update
-- v 1.01
-- Created On: 05/01/25
-- Updated:    Fixed thread model — bridge must run on main thread (QTimer req)
-- tested using Max 2027
--
-- PURPOSE:
-- This file is placed in scripts/Startup/ so 3ds Max runs it automatically
-- on every launch. It checks a preference flag in:
--   %LOCALAPPDATA%\...\ENU\plugcfg\SoulburnScripts\presets\atlasBridgeLauncher.ini
-- If the flag is true, it launches the Atlas MCP bridge via python.ExecuteFile
-- which runs on the main thread (required for QTimer / asyncio event loop).
--
-- To enable:  setINISetting ... "atlasBridgeLauncher" "aBLAutoStartValue" "true"
-- To disable: setINISetting ... "atlasBridgeLauncher" "aBLAutoStartValue" "false"
-- Or use the atlasBridgeLauncher UI checkbox "Auto-start on Max launch".
-------------------------------------------------------------------------------

(
local _iniPath  = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\atlasBridgeLauncher.ini")
local _bridgePy = ((getdir #userScripts) + "\\SoulburnScripts\\lib\\atlas\\start_bridge.py")
local _logTag   = "[AtlasAutoStart]"

-- Read preference
local _enabled = false
if (doesFileExist _iniPath) then
(
	local _val = getINISetting _iniPath "atlasBridgeLauncher" "aBLAutoStartValue"
	_enabled = (_val == "true")
)

if _enabled then
(
	-- Verify bridge script exists
	if not (doesFileExist _bridgePy) then
	(
		print (_logTag + " start_bridge.py not found at: " + _bridgePy)
		print (_logTag + " Bridge auto-start skipped.")
	)
	else
	(
		-- NOTE: python.ExecuteFile runs on the MAIN thread which is required
		-- because start_bridge.py creates a QTimer/asyncio event loop that
		-- must live on the main thread. Do NOT wrap in threading.Thread here.
		print (_logTag + " Starting Atlas MCP bridge on main thread...")
		try
		(
			python.ExecuteFile _bridgePy
			print (_logTag + " Bridge started. Connect MCP client to 127.0.0.1:9879")
		)
		catch
		(
			local _err = getCurrentException()
			print (_logTag + " Bridge start failed: " + _err as string)
		)
	)
)
-- else: silent when disabled
)
-------------------------------------------------------------------------------
