-------------------------------------------------------------------------------
-- SoulburnScripts_ToolbarAutoCreate.ms
-- By SoulBurn 2027 Update
-- v 1.00
-- Created On: 05/01/25
-- tested using Max 2027
--
-- PURPOSE:
-- This file is placed in scripts/Startup/ so 3ds Max runs it automatically
-- on every launch. It hands off to:
--   %LOCALAPPDATA%\...\ENU\scripts\SoulburnScripts\scripts\soulburnToolbarAutoCreate.ms
-- which creates the floating SoulburnScripts toolbar on first run and then
-- writes a version flag so it does not run again.
--
-- The flag lives in:
--   (getdir #plugcfg)\SoulburnScripts\SoulburnScripts.ini  [Toolbar] Created
-- Delete that key to force the toolbar to be rebuilt on next launch.
-------------------------------------------------------------------------------

(
local _autoCreate = ((getdir #userScripts) + "\\SoulburnScripts\\scripts\\soulburnToolbarAutoCreate.ms")
local _logTag     = "[SoulburnToolbar]"

if not (doesFileExist _autoCreate) then
(
	print (_logTag + " soulburnToolbarAutoCreate.ms not found at: " + _autoCreate)
	print (_logTag + " Toolbar auto-create skipped.")
)
else
(
	try
	(
		fileIn _autoCreate
	)
	catch
	(
		local _err = getCurrentException()
		print (_logTag + " Toolbar auto-create failed: " + _err as string)
	)
)
)
-------------------------------------------------------------------------------
