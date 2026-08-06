-------------------------------------------------------------------------------
-- atlas_test.ms -- start the Atlas bridge and prove the main-thread pump works
-------------------------------------------------------------------------------
(
local logPath = "C:\\Users\\mabdu\\Downloads\\SoulburnScriptsPack_3dsMax_v112_R2013toR2022\\SB2027\\dev\\ATLAS_TEST.txt"
local f = createFile logPath
fn L s = ( format "%\n" s to:f ; format "[atlas-test] %\n" s )

local py = ((getdir #userScripts) + "\\SoulburnScripts\\lib\\atlas\\start_bridge.py")
L ("start_bridge.py: " + (doesFileExist py) as string)

local ok = true
try ( python.ExecuteFile py )
catch ( ok = false ; L ("ExecuteFile threw: " + (getCurrentException() as string)) )
L ("start returned without exception: " + ok as string)

-- The timer must exist and be running for the queue ever to drain.
local t = undefined
try ( t = _atlasBridgeTimer ) catch ()
L ("_atlasBridgeTimer: " + (t as string))
if t != undefined then ( try ( L ("  Enabled: " + (t.Enabled as string) + "  Interval: " + (t.Interval as string)) ) catch ( L "  cannot read timer props" ) )

sleep 2

-- Ping goes out over TCP, is queued by the socket thread, and can only come
-- back if the timer drained it on the main thread.
local p = undefined
try ( p = sLibAtlasBridgeCall "ping" "" ) catch ( L ("ping threw: " + (getCurrentException() as string)) )
if p != undefined then
	(
	L ("ping.ok     : " + (p.ok as string))
	try ( L ("ping.result : " + (p.result as string)) ) catch ()
	)
else L "ping returned undefined"

close f
)
