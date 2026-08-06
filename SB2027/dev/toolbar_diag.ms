-------------------------------------------------------------------------------
-- toolbar_diag.ms (pass 3)
--
-- Findings so far:
--   cui.showToolbar "SoulburnScripts" -> false
--   cui.getConfigFile() -> ...\Workspaces\usersave\Workspace1__usersave__.cuix
--   that live config ALREADY contains <Window objectName="SoulburnScripts">
--
-- Hypothesis: loadConfig was pointed at SoulburnScripts.cuix (a partial file),
-- which does not register the toolbar with the ACTIVE workspace. Reloading the
-- live workspace config should register it, after which showToolbar succeeds.
-------------------------------------------------------------------------------
(
local logPath = "C:\\Users\\mabdu\\Downloads\\SoulburnScriptsPack_3dsMax_v112_R2013toR2022\\SB2027\\dev\\TOOLBAR_DIAG.txt"
local f = createFile logPath
fn L s = ( format "%\n" s to:f ; format "[diag3] %\n" s )

-- 1. Probe WorkspaceManager methods by trying them.
local wm = WorkspaceManager
fn tryCall nm fnc = ( local r = "ERR" ; try ( r = (fnc()) as string ) catch ( r = "n/a" ) ; L ("  " + nm + " -> " + r) )
L "WorkspaceManager probe:"
tryCall "getWorkspaceCount"   (fn a = wm.getWorkspaceCount())
tryCall "getCurrentWorkspace" (fn a = wm.getCurrentWorkspace())
tryCall "getActiveWorkspace"  (fn a = wm.getActiveWorkspace())
try ( local n = wm.getWorkspaceCount()
      for i = 0 to (n-1) do ( try ( L ("  ws[" + (i as string) + "] = " + (wm.getWorkspaceName i)) ) catch () )
    ) catch ( L "  cannot enumerate workspace names" )

-- 2. The live config file Max is actually using.
local cfg = cui.getConfigFile()
L ("live config: " + cfg)
L ("  exists: " + ((doesFileExist cfg) as string))

-- 3. Reload the LIVE workspace config, then try to show the toolbar.
local r1 = undefined
try ( r1 = cui.loadConfig cfg ) catch ( L ("loadConfig(live) threw: " + (getCurrentException() as string)) )
L ("loadConfig(live) -> " + (r1 as string))

local s1 = undefined
try ( s1 = cui.showToolbar "SoulburnScripts" ) catch ( L ("showToolbar threw: " + (getCurrentException() as string)) )
L ("showToolbar after live reload -> " + (s1 as string))

-- 4. If that failed, try switching workspace to ws2112 (we injected the
--    toolbar into ws2112.cuix earlier).
if s1 != true then
	(
	L "trying workspace switch to ws2112..."
	local switched = false
	try (
		local n = wm.getWorkspaceCount()
		for i = 0 to (n-1) do
			(
			local nm = ""
			try ( nm = wm.getWorkspaceName i ) catch ()
			if nm == "ws2112" then
				( try ( wm.setCurrentWorkspace i ; switched = true ; L ("  switched to ws2112 (index " + (i as string) + ")") ) catch ( L ("  setCurrentWorkspace threw: " + (getCurrentException() as string)) ) )
			)
		) catch ( L ("  workspace switch failed: " + (getCurrentException() as string)) )
	L ("  switched: " + (switched as string))
	local s2 = undefined
	try ( s2 = cui.showToolbar "SoulburnScripts" ) catch ()
	L ("showToolbar after ws switch -> " + (s2 as string))
	)

try ( cui.saveConfig() ; L "saveConfig ok" ) catch ()
close f
)
