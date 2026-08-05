-------------------------------------------------------------------------------
-- atlasBridgeLauncher.ms
-- By SoulBurn 2027 Update
-- v 1.00
-- Created On: 05/01/25
-- tested using Max 2027
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-- scripts/SoulburnScripts/lib/atlas/start_bridge.py
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Start/Stop the Atlas MCP bridge (atlas_max_bridge.py) from within Max.
-- The bridge allows AI agents (Claude, GPT-4o, etc.) to control Max
-- via the MCP server on port 9879.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals
global atlasBridgeLauncherDefaults
global atlasBridgeLauncherUI

global aBLCloseOpenUI
global aBLStartBridge
global aBLStopBridge
global aBLPingBridge
global aBLHelp
global aBLLoadDef
global aBLSaveDef
global aBLDefineUI
global aBLRollout
global aBLFloater

-- Includes
include "$userScripts\SoulburnScripts\lib\sLib.ms"

-- Variables
aBLPortValue = 9879
aBLAutoStartValue = false  -- v2.00: auto-launch on Max startup
aBLPosValue = sLibGetSafeUIPos 290 310
global aBLBridgeProcess = undefined

-- Auto-start INI path (shared with SoulburnScripts_AtlasAutoStart.ms)
global aBLAutoStartIniPath = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\atlasBridgeLauncher.ini")

-- Functions

fn aBLPingBridge =
	(
	-- Returns true if bridge is reachable on the configured port
	local result = sLibAtlasBridgeCall "ping" ""
	return result.ok
	)

fn aBLStartBridge =
	(
	-- Use #userScripts NOT #scripts -- #scripts resolves to the program install folder.
	-- start_bridge.py lives in the user ENU scripts folder.
	local startScript = ((getdir #userScripts) + "\\SoulburnScripts\\lib\\atlas\\start_bridge.py")
	if not (doesFileExist startScript) then
		(
		MessageBox ("start_bridge.py not found.\nExpected:\n" + startScript + "\n\nMake sure the Atlas bridge files were installed correctly.") title:"atlasBridgeLauncher"
		return false
		)
	-- python.ExecuteFile runs a .py script inside Max's embedded Python interpreter.
	-- In Max 2027 this is the correct API. The script must not block -- start_bridge.py
	-- launches the server in a background thread and returns immediately.
	try
		(
		python.ExecuteFile startScript
		return true
		)
	catch e
		(
		MessageBox ("Failed to start bridge.\nError: " + e as string + "\n\nCheck that Max's embedded Python is working:\nScripting > Python Interpreter") title:"atlasBridgeLauncher"
		return false
		)
	)

fn aBLStopBridge =
	(
	-- Send a shutdown command to the bridge
	local result = sLibAtlasBridgeCall "shutdown" ""
	return result.ok
	)

fn aBLSetAutoStart enabled =
	(
	-- Write the preference that SoulburnScripts_AtlasAutoStart.ms reads on startup
	local presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	if (doesFileExist aBLAutoStartIniPath) then deleteFile aBLAutoStartIniPath
	setINISetting aBLAutoStartIniPath "AtlasAutoStart" "enabled" (if enabled then "true" else "false")
	aBLAutoStartValue = enabled
	if enabled then
		print "[AtlasBridgeLauncher] Auto-start ENABLED - bridge will launch on next Max startup."
	else
		print "[AtlasBridgeLauncher] Auto-start DISABLED."
	)

fn aBLReadAutoStart =
	(
	-- Read the current auto-start preference
	if (doesFileExist aBLAutoStartIniPath) then
		(
		local val = getINISetting aBLAutoStartIniPath "AtlasAutoStart" "enabled"
		aBLAutoStartValue = (val == "true")
		)
	else
		aBLAutoStartValue = false
	return aBLAutoStartValue
	)

fn atlasBridgeLauncherDefaults =
	(
	aBLLoadDef()
	)

fn atlasBridgeLauncherUI =
	(
	aBLLoadDef()
	aBLCloseOpenUI aBLPosValue
	)

fn aBLCloseOpenUI pos =
	(
	if aBLFloater != undefined then CloseRolloutFloater aBLFloater
	aBLReadAutoStart()
	aBLDefineUI()
	aBLFloater = newRolloutFloater "atlasBridgeLauncher v1.00" 290 310 pos.x pos.y
	addRollout aBLRollout aBLFloater
	)

fn aBLHelp =
	(
	MessageBox "atlasBridgeLauncher: Start/Stop the Atlas MCP bridge.\n\nThe bridge runs on 127.0.0.1:9879 and allows AI agents to control 3ds Max.\n\nStart: Launches the Python bridge inside Max.\nStop: Sends a shutdown signal.\nPing: Tests if bridge is reachable.\n\nAuto-start: When checked, the bridge launches automatically\nevery time 3ds Max starts. Uses the startup script:\n  scripts/Startup/SoulburnScripts_AtlasAutoStart.ms\n\nAfter starting, connect any MCP client to port 9879." title:"atlasBridgeLauncher Help"
	)

fn aBLLoadDef =
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	aBLInputFilename = presetDir + "atlasBridgeLauncher.ini"
	if (sLibFileExist aBLInputFilename == true) then
		(
		aBLPortValue = (getINISetting aBLInputFilename "atlasBridgeLauncher" "aBLPortValue") as integer
		aBLPosValue = sLibGetINIPoint2 aBLInputFilename "atlasBridgeLauncher" "aBLPosValue" (sLibGetSafeUIPos 290 310)
		if aBLPortValue == 0 then aBLPortValue = 9879
		)
	else
		(
		aBLPortValue = 9879
		aBLPosValue = sLibGetSafeUIPos 290 310
		)
	local asVal = getINISetting aBLInputFilename "atlasBridgeLauncher" "aBLAutoStartValue"
	aBLAutoStartValue = (asVal == "true")
	)

fn aBLSaveDef =
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	aBLOutputFilename = presetDir + "atlasBridgeLauncher.ini"
	if (sLibFileExist aBLOutputFilename == true) then deleteFile aBLOutputFilename
	setINISetting aBLOutputFilename "atlasBridgeLauncher" "aBLPortValue" (aBLPortValue as string)
	setINISetting aBLOutputFilename "atlasBridgeLauncher" "aBLPosValue" (aBLFloater.pos as string)
	setINISetting aBLOutputFilename "atlasBridgeLauncher" "aBLAutoStartValue" (if aBLAutoStartValue then "true" else "false")
	)

-- UI

fn aBLDefineUI =
	(
	rollout aBLRollout "atlasBridgeLauncher"
		(
		-- Status row
		-- NOTE: label text cannot be a runtime expression at definition time in MaxScript.
		-- We set the real port text in the "on open" handler below.
		label aBLPortLabel "Bridge Port: 9879" align:#center
		label aBLStatusLabel "Status: Unknown" align:#center

		-- Ping / Status buttons
		button aBLPingButton "Ping Bridge" width:130 align:#left across:2
		button aBLStatusButton "Check Status" width:130 align:#right

		label aBLSpacer1 "" height:4

		-- Start / Stop buttons  (no Unicode arrows - cp1252 safe)
		button aBLStartButton "[ START Bridge ]" width:260 height:28 align:#center
		button aBLStopButton  "[  STOP Bridge  ]" width:260 height:28 align:#center

		label aBLSpacer2 "" height:4

		-- Auto-start preference
		groupBox aBLAutoGroup "Auto-Launch" width:260 height:54 align:#center
		checkbox aBLAutoStartCheckbox "Launch bridge automatically on Max startup" \
			checked:false align:#left offset:[8,-44]
		label aBLAutoInfo "Takes effect next time Max starts" \
			align:#left offset:[8,0]

		label aBLSpacer3 "" height:4
		label aBLInfo1 "Connect MCP client to 127.0.0.1:9879" align:#center

		-- Bottom buttons
		button aBLHelpButton "Help" width:80 align:#left across:2
		button aBLSaveDefButton "SaveDef" width:80 align:#right

		-- Handlers
		on aBLPingButton pressed do
			(
			if aBLPingBridge() then
				(
				aBLStatusLabel.text = "Status: ONLINE [OK]"
				MessageBox "Bridge is ONLINE and responding." title:"atlasBridgeLauncher"
				)
			else
				(
				aBLStatusLabel.text = "Status: OFFLINE"
				MessageBox ("Bridge not reachable on port " + (aBLPortValue as string) + ".\nTry clicking START Bridge.") title:"atlasBridgeLauncher"
				)
			)

		on aBLStatusButton pressed do
			(
			if aBLPingBridge() then aBLStatusLabel.text = "Status: ONLINE [OK]"
			else aBLStatusLabel.text = "Status: OFFLINE"
			)

		on aBLStartButton pressed do
			(
			aBLStatusLabel.text = "Status: Starting..."
			if aBLStartBridge() then
				(
				sleep 1.5
				if aBLPingBridge() then aBLStatusLabel.text = "Status: ONLINE [OK]"
				else aBLStatusLabel.text = "Status: Started (ping pending...)"
				)
			else aBLStatusLabel.text = "Status: Start FAILED"
			)

		on aBLStopButton pressed do
			(
			if aBLStopBridge() then aBLStatusLabel.text = "Status: Stopped"
			else aBLStatusLabel.text = "Status: Stop signal sent"
			)

		on aBLAutoStartCheckbox changed state do
			(
			-- Immediately persist the preference so it takes effect on next Max launch
			aBLSetAutoStart state
			if state then
				aBLStatusLabel.text = "Auto-start: ENABLED"
			else
				aBLStatusLabel.text = "Auto-start: disabled"
			)

		on aBLHelpButton pressed do aBLHelp()
		on aBLSaveDefButton pressed do aBLSaveDef()

		on aBLRollout open do
			(
			-- Set port label text now (can't use expression at definition time)
			aBLPortLabel.text = "Bridge Port: " + (aBLPortValue as string)
			-- Sync checkbox to current file-based state on open
			aBLReadAutoStart()
			aBLAutoStartCheckbox.checked = aBLAutoStartValue
			-- Show live bridge status
			if aBLPingBridge() then aBLStatusLabel.text = "Status: ONLINE [OK]"
			else aBLStatusLabel.text = "Status: OFFLINE"
			)
		)
	)
)
-------------------------------------------------------------------------------
