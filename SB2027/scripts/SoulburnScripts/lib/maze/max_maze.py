"""
max_maze.py — recursive back-tracker maze on a 3ds Max editable poly/mesh
Run via: pymxs.runtime.fileIn @"C:\path\to\max_maze.py"
or paste into the Max Python listener.

Controls (edit the block below):
  SEED       — random seed (same seed → same maze)
  BRAID      — 0.0 = perfect maze, 1.0 = all loops (braided)
  DEPTH      — how deep to push the wall faces (0 = flat, just selects edges)
  WALL_WIDTH — bevel inset fraction (0.0–0.5); controls passage width
"""

import random
from pymxs import runtime as rt

# ── parameters ───────────────────────────────────────────────────────────────
SEED       = 42
BRAID      = 0.0   # 0.0 = perfect maze, 1.0 = fully braided
DEPTH      = 2.0   # push walls up by this amount (world units); 0 = skip
WALL_WIDTH = 0.3   # fraction of each cell edge used for walls (0.0–0.5)
# ─────────────────────────────────────────────────────────────────────────────


# ── pure-Python maze algorithm (ported from elfnor/mesh_maze) ─────────────

def _backtracker(adj, start=None):
    """
    Recursive back-tracker on an adjacency dict {node: [neighbour, ...]}.
    Returns list of (a, b) edges that form the maze spanning tree.
    adj must be built from a pre-sorted edge list for reproducibility.
    """
    nodes = list(adj.keys())
    if not nodes:
        return []
    # NOTE: do NOT re-seed here. run_maze() seeds from its `seed` argument;
    # re-seeding from the module-level SEED global made run_maze(seed=N)
    # silently produce the SEED-default maze regardless of N.
    start = start or nodes[0]
    visited = {start}
    stack   = [start]
    path    = []
    while stack:
        cur = stack[-1]
        free = [n for n in adj[cur] if n not in visited]
        if not free:
            stack.pop()
        else:
            nxt = random.choice(free)
            path.append((cur, nxt))
            visited.add(nxt)
            stack.append(nxt)
    return path


def _braid(path, adj, amount):
    """Add shortcuts between dead-ends to create loops (braiding)."""
    path_set = set(map(frozenset, path))
    degree   = {}
    for a, b in path:
        degree[a] = degree.get(a, 0) + 1
        degree[b] = degree.get(b, 0) + 1

    dead_ends = [n for n, d in degree.items() if d == 1]
    random.shuffle(dead_ends)

    extra = []
    for node in dead_ends:
        if degree.get(node, 0) != 1:
            continue
        if random.random() >= amount:
            continue
        # prefer linking to another dead end
        candidates = [n for n in adj[node] if frozenset((node, n)) not in path_set]
        best = [n for n in candidates if degree.get(n, 0) == 1]
        pool = best or candidates
        if not pool:
            continue
        pick = random.choice(pool)
        extra.append((node, pick))
        path_set.add(frozenset((node, pick)))
        degree[node] = degree.get(node, 0) + 1
        degree[pick] = degree.get(pick, 0) + 1

    return path + extra


# ── 3ds Max integration ───────────────────────────────────────────────────

def _face_centre(node, fi):
    """Return the world-space centroid of face fi (1-based)."""
    verts = rt.polyop.getFaceVerts(node, fi)
    pts   = [rt.polyop.getVert(node, int(v)) for v in verts]
    cx = sum(p.x for p in pts) / len(pts)
    cy = sum(p.y for p in pts) / len(pts)
    cz = sum(p.z for p in pts) / len(pts)
    return rt.Point3(cx, cy, cz)


def _edge_centre(node, ei):
    """Return the world-space midpoint of edge ei (1-based)."""
    verts = rt.polyop.getEdgeVerts(node, ei)
    v_list = list(verts)
    p0 = rt.polyop.getVert(node, int(v_list[0]))
    p1 = rt.polyop.getVert(node, int(v_list[1]))
    return rt.Point3((p0.x+p1.x)/2, (p0.y+p1.y)/2, (p0.z+p1.z)/2)


def run_maze(node=None, seed=SEED, braid=BRAID, depth=DEPTH, wall_width=WALL_WIDTH):
    """
    Apply a maze to `node` (defaults to the current selection).

    Steps:
    1. Build a face-adjacency graph from shared interior edges.
    2. Run the back-tracker to get a spanning-tree edge set.
    3. Optionally braid (add loops).
    4. Select the wall faces (NOT in the maze path).
    5. If depth > 0, extrude the wall faces up to create raised walls.
    """
    if node is None:
        node = rt.selection[0] if rt.selection.count > 0 else None
    if node is None:
        rt.messageBox("Select a mesh/poly object first.")
        return

    # Convert to Editable Poly if needed
    if rt.classOf(node) != rt.Editable_Poly:
        rt.convertTo(node, rt.Editable_Poly)

    num_faces = rt.polyop.getNumFaces(node)
    num_edges = rt.polyop.getNumEdges(node)
    if num_faces < 2:
        rt.messageBox("Need at least 2 faces.")
        return

    # ── build face adjacency via shared edges ──────────────────────────────
    # For each edge, find the (up to 2) faces that share it.
    adj = {fi: [] for fi in range(1, num_faces + 1)}

    for ei in range(1, num_edges + 1):
        faces = rt.polyop.getEdgeFaces(node, ei)
        face_list = [int(f) for f in faces]
        if len(face_list) == 2:
            a, b = face_list
            if b not in adj[a]:
                adj[a].append(b)
            if a not in adj[b]:
                adj[b].append(a)

    # ── run maze ──────────────────────────────────────────────────────────
    random.seed(seed)
    path = _backtracker(adj)
    if braid > 0.0:
        path = _braid(path, adj, braid)

    path_pairs = set(frozenset(p) for p in path)

    # ── find maze-path edges (edges shared by two path-connected face pairs) ─
    path_edges = []
    wall_faces = []

    for ei in range(1, num_edges + 1):
        faces = rt.polyop.getEdgeFaces(node, ei)
        face_list = [int(f) for f in faces]
        if len(face_list) == 2:
            a, b = face_list
            if frozenset((a, b)) in path_pairs:
                path_edges.append(ei)

    path_face_set = set()
    for a, b in path:
        path_face_set.add(a)
        path_face_set.add(b)

    wall_faces = [fi for fi in range(1, num_faces + 1) if fi not in path_face_set]

    # ── select path edges so the user can see the maze ─────────────────────
    rt.subObjectLevel = 2  # edge sub-object
    rt.polyop.setEdgeSelection(node, rt.BitArray())  # clear
    edge_ba = rt.BitArray(num_edges)
    for ei in path_edges:
        edge_ba[ei - 1] = True
    rt.polyop.setEdgeSelection(node, edge_ba)
    node.selectedEdges = edge_ba

    # ── optionally raise wall faces ────────────────────────────────────────
    if depth > 0.001 and wall_faces:
        rt.subObjectLevel = 4  # face sub-object
        face_ba = rt.BitArray(num_faces)
        for fi in wall_faces:
            face_ba[fi - 1] = True
        rt.polyop.setFaceSelection(node, face_ba)

        # Bevel (inset + extrude) to create raised walls
        if wall_width > 0.001:
            rt.polyop.bevelFaces(node, face_ba, 0, wall_width, False)

        rt.polyop.extrudeFaces(node, face_ba, depth)

    rt.subObjectLevel = 0  # back to object level
    rt.redrawViews()
    print(f"[max_maze] Done - {len(path)} maze passages, {len(wall_faces)} wall faces.")
    return len(path), len(wall_faces)


# ── run immediately on selected object ────────────────────────────────────
# Guarded so the module can be imported by maxMazeGenerator.ms to call
# run_maze() with UI parameters. Without the guard, importing would fire a
# full default-parameter maze run as a side effect.
if __name__ == "__main__":
    run_maze()


# ponytail: face-lookup is O(edges); fine for grids up to ~10k faces.
#           For huge meshes, cache edge→face maps in a dict upfront.
