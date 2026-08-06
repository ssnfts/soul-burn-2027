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
	-- Primary location: #plugcfg\SoulburnScripts\ (en-US\plugcfg\SoulburnScripts on Max 2027)
	local cuixPath = (getdir #plugcfg) + "\\SoulburnScripts\\SoulburnScripts.cuix"
	-- Fallback: UI_ln\ (direct ENU\UI_ln placement used by cui.loadConfig on some Max builds)
	local cuixPathAlt = (getdir #ui) + "\\SoulburnScripts.cuix"
	-- Use whichever path exists; prefer the plugcfg location
	if not (doesFileExist cuixPath) do cuixPath = cuixPathAlt
	if not (doesFileExist cuixPath) then (
		print (logTag + " SoulburnScripts.cuix not found at plugcfg or UI_ln locations.")
		print (logTag + " Toolbar auto-create skipped - run the SoulBurn installer.")
	)
	else (
		try (
			-- cui.showToolbar returns a BOOLEAN. The old code ignored it and
			-- reported success whenever no exception was thrown, which hid the
			-- real failure: Max only treats a cuix <Window> as a toolbar when
			-- its type attribute is "T" (every native Max toolbar uses "T").
			-- With type="N" this silently returned false and nothing appeared.
			cui.loadConfig cuixPath
			local shown = cui.showToolbar "SoulburnScripts"
			cui.saveConfig()
			if shown == true then
				(
				setINISetting sbIniPath "Toolbar" "Created" SB_TOOLBAR_VERSION
				print (logTag + " Toolbar shown (v" + SB_TOOLBAR_VERSION + ").")
				)
			else
				(
				-- Do NOT write the flag - otherwise a failed attempt is never retried.
				print (logTag + " cui.showToolbar returned false - toolbar not registered.")
				print (logTag + " Check that SoulburnScripts.cuix has type=\"T\" on its Window element.")
				print (logTag + " Manual: Customize > Show UI > Show Toolbars > SoulburnScripts")
				)
		)
		catch (
			local err = getCurrentException()
			print (logTag + " Toolbar auto-create failed: " + err as string)
			print (logTag + " Use: Customize > Show UI > Show Toolbars > SoulburnScripts")
		)
	)
)
)
