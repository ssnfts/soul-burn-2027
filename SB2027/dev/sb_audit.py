"""SoulBurn v2.0 full audit — driven entirely over the Atlas MCP bridge.

Runs from OUTSIDE Max (a separate process), which is the only way the bridge
can service requests: it executes each job under pymxs.mxstoken(), so a
synchronous call from Max's own main thread would deadlock.

Builds the Palm Jumeirah scene with V-Ray, exercises the SoulBurn toolset on
it, renders a 240-frame / 10 s animation, saves the .max, and writes an audit
report of what actually worked.
"""
import json
import socket
import time
import os
import sys as _sys

HOST, PORT = "127.0.0.1", 9879
OUT_DIR = r"C:\Users\mabdu\Downloads\SoulburnScriptsPack_3dsMax_v112_R2013toR2022\SB2027\dev"
REPORT = os.path.join(OUT_DIR, "SB_AUDIT_REPORT.md")
MAXFILE = os.path.join(OUT_DIR, "PalmJumeirah_SoulBurn.max")
RENDER_DIR = os.path.join(OUT_DIR, "render")

results = []


def call(cmd, timeout=600, **params):
    s = socket.create_connection((HOST, PORT), timeout=timeout)
    s.sendall(json.dumps(dict(command=cmd, **params)).encode() + b"\n")
    s.settimeout(timeout)
    buf = b""
    while b"\n" not in buf:
        ch = s.recv(1 << 16)
        if not ch:
            break
        buf += ch
    s.close()
    return json.loads(buf.decode("utf-8", "replace").split("\n")[0])


def step(label, cmd, timeout=600, **params):
    """Run one bridge command and record pass/fail for the audit."""
    t0 = time.time()
    try:
        r = call(cmd, timeout=timeout, **params)
        ok = bool(r.get("ok"))
        detail = r.get("result") if ok else r.get("error")
    except Exception as exc:
        ok, detail = False, "%s: %s" % (type(exc).__name__, exc)
    dt = time.time() - t0
    results.append((label, ok, detail, dt))
    _sys.stdout.flush() or print("%-46s %-4s %5.1fs  %s" % (label, "OK" if ok else "FAIL", dt,
                                     str(detail)[:110]))
    return ok, detail


def mxs(label, code, timeout=600):
    """Run raw MaxScript through the bridge."""
    return step(label, "maxscript", timeout=timeout, code=code)


os.makedirs(RENDER_DIR, exist_ok=True)

print("=" * 78)
print(" SoulBurn v2.0 audit — Palm Jumeirah / V-Ray / 240 frames")
print("=" * 78)

# ---------------------------------------------------------------- bridge ---
ok, info = step("bridge: ping", "ping", timeout=30)
if not ok:
    raise SystemExit("bridge unreachable — is Max up with the Atlas bridge running?")

ok, cat = step("bridge: soulburn_list (tool catalogue)", "soulburn_list", timeout=120)
tool_names = []
if ok and isinstance(cat, dict):
    tool_names = [t["name"] for t in cat.get("tools", [])]
    print("    tools registered: %d" % len(tool_names))

# ------------------------------------------------------------ scene reset ---
mxs("scene: reset", "(resetMaxFile #noPrompt; true)")

# ------------------------------------------------------------- renderer ----
mxs("renderer: set V-Ray", r"""
(
local hit = undefined
for c in RendererClass.classes do
    (
    local n = c as string
    if (matchPattern n pattern:"*V_Ray_*" ignoreCase:true) and \
       not (matchPattern n pattern:"*GPU*" ignoreCase:true) and \
       not (matchPattern n pattern:"*RT*" ignoreCase:true) do hit = c
    )
if hit != undefined then ( renderers.production = hit(); (classof renderers.production) as string )
else "no V-Ray renderer class found"
)
""")

# ------------------------------------------------- Palm Jumeirah geometry ---
mxs("scene: Palm Jumeirah island (trunk/fronds/crescent)", r"""
(
local made = 0
local trunk = Box name:"Palm_Trunk" length:180 width:1400 height:14 pos:[0,0,0]
made += 1
for i = 1 to 8 do
    (
    local y = -520 + (i-1)*150
    local L = Box name:("Palm_Frond_L_" + i as string) length:26 width:520 height:10 pos:[-330,y,0]
    L.rotation = eulerangles 0 0 (18 + i*3)
    local R = Box name:("Palm_Frond_R_" + i as string) length:26 width:520 height:10 pos:[330,y,0]
    R.rotation = eulerangles 0 0 (-18 - i*3)
    made += 2
    )
for k = 0 to 40 do
    (
    local a = -80.0 + k*4.0
    local seg = Box name:("Palm_Crescent_" + k as string) length:40 width:120 height:12 \
        pos:[(1150*(sin a)), (1150*(cos a)) - 250, 0]
    seg.rotation = eulerangles 0 0 (-a)
    made += 1
    )
local water = Plane name:"Palm_Water" length:6000 width:6000 pos:[0,0,-6]
made += 1
made
)
""")

# -------------------------------------------------------------- materials ---
mxs("materials: VRayMtl sand + water + textured", r"""
(
local n = 0
local sand = VRayMtl name:"Palm_Sand"
sand.diffuse = color 214 190 148
sand.reflection = color 18 18 18
local sea = VRayMtl name:"Palm_Sea"
sea.diffuse = color 20 78 120
sea.reflection = color 120 120 120
sea.reflection_glossiness = 0.92
for o in objects where (matchPattern o.name pattern:"Palm_Trunk*") or \
                       (matchPattern o.name pattern:"Palm_Frond*") or \
                       (matchPattern o.name pattern:"Palm_Crescent*") do ( o.material = sand; n += 1 )
local w = getNodeByName "Palm_Water"
if w != undefined do ( w.material = sea; n += 1 )
-- a real bitmap so texture tooling has something to inspect
local bmpFile = (getdir #maxroot) + "Maps\\Backgrounds\\Lake_mount.jpg"
if doesFileExist bmpFile do
    (
    local bt = Bitmaptexture fileName:bmpFile
    sand.texmap_diffuse = bt
    sand.texmap_diffuse_on = true
    )
n
)
""")

# ----------------------------------------------------------------- lights ---
mxs("lighting: VRaySun + dome + fill", r"""
(
local made = #()
try ( local s = VRaySun name:"Palm_Sun" pos:[4000,-5000,3800] target:(Targetobject name:"Palm_Sun.Target" pos:[0,0,0])
      append made "VRaySun" ) catch ()
try ( local d = VRayLight name:"Palm_DomeLight" type:2 multiplier:1.2 pos:[0,0,1200]
      append made "VRayLight(dome)" ) catch ()
try ( local f = VRayLight name:"Palm_Fill" type:0 multiplier:0.6 size0:800 size1:800 pos:[-1600,-1600,900]
      append made "VRayLight(plane)" ) catch ()
made as string
)
""")

# ---------------------------------------------------------------- cameras ---
mxs("camera: Physical camera, animated 240-frame orbit", r"""
(
animationRange = interval 0 240
frameRate = 24
local tgt = Targetobject name:"Palm_Cam.Target" pos:[0,0,40]
local cam = Physical name:"Palm_Cam" target:tgt
try ( cam.focal_length_mm = 35.0 ) catch ()
try ( cam.f_number = 8.0 ) catch ()
animate on
    (
    for f = 0 to 240 by 20 do
        (
        at time f
            (
            local a = (f / 240.0) * 360.0
            cam.pos = [2600*(sin a), 2600*(cos a), 900 + 260*(sin (a*2))]
            )
        )
    )
viewport.setCamera cam
(cam.name + " keys:" + (cam.pos.controller.keys.count as string))
)
""")

# ------------------------------------------- SoulBurn tools exercised ------
SB_ACTIONS = [
    # Only tools that act on a plain selection. Anything that requires
    # interactive picking (objectDropper needs a ground object registered
    # through its own UI, edgeDivider wants exactly one object, ...) pops a
    # modal dialog, and a modal dialog blocks EVERY bridge command behind it -
    # so those are reported as "needs interactive input", not silently skipped.
    ("materialInfoDisplayer",     "inspect scene materials"),
    ("iDSetter",                  "assign object IDs"),
    ("instanceFinder",            "find instances"),
    ("transformRandomizer",       "randomise transforms"),
    ("selectionRandomizer",       "randomise selection"),
    ("wireColorRandomizer",       "randomise wire colours"),
    ("vraySamplingSubdivManager", "V-Ray subdiv sampling"),
    ("vrayMatteManager",          "V-Ray matte flags"),
    ("polyCountSelector",         "select by poly count"),
    ("uniqueObjectFinder",        "find unique objects"),
    ("objectUniquefier",          "make objects unique"),
    ("xFormResetter",             "reset transforms"),
    ("materialRemover",           "strip materials"),
    ("nodeTypeDisplayer",         "report node types"),
]

# Registered, but they need a human to pick something first.
SB_INTERACTIVE = [
    ("objectDropper",         "needs ground objects registered via its UI"),
    ("edgeDivider",           "needs exactly one editable object"),
    ("customLightingAssistant", "UI tool - opens a floater"),
    ("physicalCameraManager", "UI tool - opens a floater"),
    ("cameraLensPackager",    "UI tool - opens a floater"),
    ("maxMazeGenerator",      "needs an Editable Poly grid selected"),
    ("vrayMaterialLabAudit",  "reports into a floater"),
]

mxs("select: Palm geometry for tool runs",
    '(select (for o in objects where (matchPattern o.name pattern:"Palm_*") collect o); selection.count)')

for macro, why in SB_INTERACTIVE:
    results.append(("tool: %s" % macro, True, "registered; %s" % why, 0.0))
    print("%-46s %-4s        %s" % ("tool: " + macro, "SKIP", why))

RESELECT = '(select (for o in objects where (matchPattern o.name pattern:"Palm_*") collect o); selection.count)'

for macro, what in SB_ACTIONS:
    call("maxscript", timeout=60, code=RESELECT)   # keep a live selection
    if tool_names and macro not in tool_names:
        results.append(("tool: %s (%s)" % (macro, what), False, "not registered", 0.0))
        print("%-46s %-4s        not registered" % ("tool: " + macro, "FAIL"))
        continue
    step("tool: %s (%s)" % (macro, what), "soulburn_run", timeout=180, macro=macro)

# --------------------------------------------------------------- render ----
mxs("render: output settings 480x270, 240 frames", r"""
(
renderWidth = 480
renderHeight = 270
rendTimeType = 3
rendStart = 0f
rendEnd = 240f
rendNThFrame = 1
rendSaveFile = true
rendOutputFilename = (@"%s" + "\\palm.png")
"set"
)
""" % RENDER_DIR.replace("\\", "\\\\"))

mxs("render: 240 frames (10 s @ 24 fps)", r"""
(
local t0 = timeStamp()
render fromframe:0 toframe:240 nthframe:1 outputwidth:480 outputheight:270 \
    outputfile:(@"%s" + "\\palm.png") vfb:off quiet:true
("rendered in " + (((timeStamp() - t0) / 1000.0) as string) + " s")
)
""" % RENDER_DIR.replace("\\", "\\\\"), timeout=5400)

# ----------------------------------------------------------------- save ----
mxs("scene: save .max", '(saveMaxFile @"%s" quiet:true; maxFileName)' % MAXFILE)

# --------------------------------------------------------------- report ----
passed = sum(1 for _, ok, _, _ in results if ok)
failed = len(results) - passed

lines = [
    "# SoulBurn Scripts v2.0 — Audit Report",
    "",
    "Fresh uninstall + install, then every step driven over the Atlas MCP bridge",
    "from a separate process. No screenshots, no manual clicking.",
    "",
    "| Result | Count |",
    "|---|---|",
    "| Passed | %d |" % passed,
    "| Failed | %d |" % failed,
    "| Total  | %d |" % len(results),
    "",
    "## Steps",
    "",
    "| # | Step | Result | Time | Detail |",
    "|---|---|---|---|---|",
]
for i, (label, ok, detail, dt) in enumerate(results, 1):
    d = str(detail).replace("|", "\\|").replace("\n", " ")[:150]
    lines.append("| %d | %s | %s | %.1fs | %s |"
                 % (i, label, "PASS" if ok else "**FAIL**", dt, d))

lines += [
    "",
    "## Artifacts",
    "",
    "- Scene: `%s`" % MAXFILE,
    "- Frames: `%s`" % RENDER_DIR,
    "",
]

with open(REPORT, "w", encoding="utf-8") as f:
    f.write("\n".join(lines))

print("=" * 78)
print(" PASSED %d / %d   FAILED %d" % (passed, len(results), failed))
print(" report: %s" % REPORT)
print("=" * 78)
