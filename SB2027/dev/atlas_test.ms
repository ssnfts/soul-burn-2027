-------------------------------------------------------------------------------
-- atlas_test.ms -- the toolbar button's own path: start, then liveness check.
-- Also proves the catalogue is reachable from an EXTERNAL client (a separate
-- process), which is what an AI on the port actually is.
-------------------------------------------------------------------------------
(
local logPath = "C:\\Users\\mabdu\\Downloads\\SoulburnScriptsPack_3dsMax_v112_R2013toR2022\\SB2027\\dev\\ATLAS_TEST.txt"
local f = createFile logPath
fn L s = ( format "%\n" s to:f ; format "[atlas-test] %\n" s )

-- 1. START via the launcher's own function (what the toolbar button calls)
local py = ((getdir #userScripts) + "\\SoulburnScripts\\lib\\atlas\\start_bridge.py")
try ( python.ExecuteFile py ) catch ( L ("start threw: " + (getCurrentException() as string)) )
sleep 2

-- 2. LIVENESS via the new port check (no round-trip, so no deadlock)
local up = sLibAtlasBridgePortOpen()
L ("sLibAtlasBridgePortOpen : " + (up as string))

-- 3. The launcher's Ping button uses exactly this now
local ping2 = aBLPingBridge()
L ("aBLPingBridge (button)  : " + (ping2 as string))

close f
)
