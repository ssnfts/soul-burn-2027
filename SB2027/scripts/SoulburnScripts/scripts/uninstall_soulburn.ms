-- uninstall_soulburn.ms v1.0
-- Removes all SoulBurn Scripts Pack v2.0 files from 3ds Max
-- Run this script from the MaxScript Listener to uninstall

fn uninstallSoulburn =
(
	local maxUserDir = getDir #userScripts
	-- maxUserDir is something like C:\Users\...\ENU\scripts
	-- We need the ENU root (parent of scripts\)
	local enuRoot = getFilenamePath (getFilenamePath maxUserDir)

	local confirm = queryBox ("This will remove all SoulBurn Scripts Pack files from:\n" + enuRoot + "\n\nUser presets in plugcfg\\SoulburnScripts\\ will be PRESERVED.\n\nContinue?") title:"Uninstall SoulBurn Scripts Pack"

	if not confirm then return false

	local removed = #()
	local failed  = #()

	-- Remove scripts folder
	local scriptsDir = maxUserDir + "\\SoulburnScripts"
	if doesFileExist scriptsDir then
	(
		try
		(
			deleteDir scriptsDir
			append removed "scripts\\SoulburnScripts\\"
		)
		catch
		(
			append failed "scripts\\SoulburnScripts\\ (in use?)"
		)
	)

	-- Remove macro files
	local macroFiles = #( \
		(getDir #userMacros) + "\\SoulburnScripts.mcr", \
		(getDir #userMacros) + "\\SoulburnScriptsExtras.mcr" \
	)
	for f in macroFiles do
	(
		if doesFileExist f then
		(
			try   ( deleteFile f; append removed (filenameFromPath f) )
			catch ( append failed (filenameFromPath f) )
		)
	)

	-- Remove startup scripts
	local startupDir = getDir #userStartupScripts
	for fname in #("SoulburnScripts_AtlasAutoStart.ms", "SoulburnScripts_ToolbarAutoCreate.ms") do
	(
		local fp = startupDir + "\\" + fname
		if doesFileExist fp then
		(
			try   ( deleteFile fp; append removed fname )
			catch ( append failed fname )
		)
	)

	-- Remove icons (light + dark)
	local iconDirs = #( \
		(getDir #ui_ln) + "\\Icons", \
		(getDir #ui_ln) + "\\IconsDark" \
	)
	for iconDir in iconDirs do
	(
		local iconFiles = getFiles (iconDir + "\\SoulburnScripts_*")
		for f in iconFiles do
		(
			try   ( deleteFile f )
			catch ()
		)
		if iconFiles.count > 0 then
			append removed (iconDir + "\\SoulburnScripts_* (" + iconFiles.count as string + " files)")
	)

	-- Remove cuix
	local cuixPath = (getDir #ui_ln) + "\\SoulburnScripts.cuix"
	if doesFileExist cuixPath then
	(
		try   ( deleteFile cuixPath; append removed "SoulburnScripts.cuix" )
		catch ( append failed "SoulburnScripts.cuix" )
	)

	-- Report
	local msg = "SoulBurn Scripts Pack v2.0 Uninstall Complete\n\n"
	msg += "Removed (" + removed.count as string + "):\n"
	for r in removed do msg += "  + " + r + "\n"
	if failed.count > 0 then
	(
		msg += "\nFailed to remove (" + failed.count as string + ") -- may be in use:\n"
		for fa in failed do msg += "  ! " + fa + "\n"
	)
	msg += "\nUser presets preserved: " + (getDir #userPlugcfg) + "\\SoulburnScripts\\"
	msg += "\n\nRestart 3ds Max to complete removal."

	messageBox msg title:"SoulBurn Uninstall" beep:false
	return true
)

uninstallSoulburn()
