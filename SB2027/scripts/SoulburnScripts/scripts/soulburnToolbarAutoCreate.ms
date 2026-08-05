-------------------------------------------------------------------------------
-- soulburnToolbarAutoCreate.ms
-- Runs at Max startup (called from scripts/Startup/SoulburnScripts_ToolbarAutoCreate.ms).
-- Creates the SoulburnScripts toolbar automatically on first install.
-- Safe to call multiple times - checks if toolbar already exists.
--
-- Loads the toolbar silently. soulburnToolbarInstaller.ms remains the manual,
-- user-invoked path and keeps its confirmation MessageBoxes; this one must not
-- pop modal dialogs during Max startup.
-------------------------------------------------------------------------------
(
global SB_TOOLBAR_VERSION = "2.0"
local sbIniPath = (getdir #plugcfg) + "\\SoulburnScripts\\SoulburnScripts.ini"
local tbCreated = getINISetting sbIniPath "Toolbar" "Created"
local logTag = "[SoulburnToolbar]"

if tbCreated != SB_TOOLBAR_VERSION then (
	-- Build the toolbar
	local cuixPath = (getdir #plugcfg) + "\\SoulburnScripts\\SoulburnScripts.cuix"
	if not (doesFileExist cuixPath) then (
		print (logTag + " SoulburnScripts.cuix not found at: " + cuixPath)
		print (logTag + " Toolbar auto-create skipped - run the SoulBurn installer.")
	)
	else (
		try (
			cui.loadConfig cuixPath
			cui.showToolbar "SoulburnScripts"
			cui.saveConfig()
			setINISetting sbIniPath "Toolbar" "Created" SB_TOOLBAR_VERSION
			print (logTag + " Toolbar created (v" + SB_TOOLBAR_VERSION + ").")
		)
		catch (
			local err = getCurrentException()
			print (logTag + " Toolbar auto-create failed: " + err as string)
			print (logTag + " Use: Customize > Show UI > Show Toolbars > SoulburnScripts")
		)
	)
)
)
