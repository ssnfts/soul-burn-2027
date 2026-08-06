"""
smart_lighting_ui.py
Smart Lighting Assistant — PySide6 docked panel for 3ds Max 2027.
Part of SoulBurn Scripts Pack v2.0.

Tabs:
  BUILD  — build KEY/FILL/RIM light rigs for Arnold, V-Ray, Corona, Scanline/ART.
  AUDIT  — scan scene lights for unmotivated, invisible-illum, ambient-drag,
           and sun-multiplier-drift issues.
  PASSES — add standard render-element / AOV sets and light-group AOVs.

Engine detection is live: click Re-detect or open a new file and the badge
updates automatically via filePostOpen / systemPostNew callbacks.
"""

from __future__ import annotations

import math
import re
import sys

try:
    from PySide6 import QtCore, QtWidgets, QtGui
    from PySide6.QtCore import Qt, Signal
    from PySide6.QtWidgets import (
        QWidget, QVBoxLayout, QHBoxLayout, QTabWidget,
        QPushButton, QLabel, QSlider, QComboBox, QListWidget, QListWidgetItem,
        QCheckBox, QGroupBox, QScrollArea, QSizePolicy, QFrame, QSpinBox,
        QDoubleSpinBox,
    )
except Exception as _pyside6_err:
    # PySide6 can fail with a DLL load error (not ImportError) when a pip copy
    # shadows Max's own Qt, so catch Exception, not ImportError. If PySide2 is
    # also absent we must not let a raw ModuleNotFoundError escape - report
    # something the artist can act on instead.
    try:
        from PySide2 import QtCore, QtWidgets, QtGui
        from PySide2.QtCore import Qt, Signal
        from PySide2.QtWidgets import (
            QWidget, QVBoxLayout, QHBoxLayout, QTabWidget,
            QPushButton, QLabel, QSlider, QComboBox, QListWidget, QListWidgetItem,
            QCheckBox, QGroupBox, QScrollArea, QSizePolicy, QFrame, QSpinBox,
            QDoubleSpinBox,
        )
    except Exception as _pyside2_err:
        # Every class below needs Qt, so the module genuinely cannot load.
        # Raise something the artist can act on rather than a bare
        # ModuleNotFoundError naming PySide2, which is not the real problem.
        raise RuntimeError(
            "smartLighting needs Qt inside Max and neither binding loaded.\n"
            "  PySide6: %s\n  PySide2: %s\n\n"
            "Usual cause: a pip-installed PySide6 shadowing Max's own copy. Fix with\n"
            '  "%s" -m pip uninstall PySide6 PySide6-Addons PySide6-Essentials\n\n'
            "The MaxScript tool 'customLightingAssistant' covers the same ground "
            "without Qt." % (_pyside6_err, _pyside2_err, sys.executable)
        )

import pymxs
rt = pymxs.runtime

# ---------------------------------------------------------------------------
# Engine detection
# ---------------------------------------------------------------------------

def detect_engine() -> str:
    """Return a lower-case engine key: arnold | vray | corona | art | scanline | unknown."""
    try:
        cls = str(type(rt.renderers.current)).lower()
    except Exception:
        return "unknown"
    if "arnold" in cls:
        return "arnold"
    if "vray" in cls or "v_ray" in cls:
        return "vray"
    if "corona" in cls:
        return "corona"
    if "art" in cls:
        return "art"
    return "scanline"


_ENGINE_COLOURS = {
    "arnold":   "#4CAF50",
    "vray":     "#FF9800",
    "corona":   "#2196F3",
    "scanline": "#9E9E9E",
    "art":      "#9C27B0",
    "unknown":  "#607D8B",
}


# ---------------------------------------------------------------------------
# Main panel widget
# ---------------------------------------------------------------------------

class SmartLightingPanel(QWidget):
    """Three-tab Smart Lighting panel.

    Singleton pattern: call :func:`show` rather than constructing directly.
    """

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Smart Lighting")
        self.setMinimumWidth(320)
        self._current_engine = "unknown"
        self._build_ui()
        self._refresh_engine()
        # Register scene-change callbacks so the engine badge stays current.
        try:
            rt.callbacks.addScript(
                rt.Name("systemPostNew"),
                "python.Execute('import smart_lighting_ui; smart_lighting_ui._panel_refresh()')",
                id=rt.Name("SmartLighting"),
            )
            rt.callbacks.addScript(
                rt.Name("filePostOpen"),
                "python.Execute('import smart_lighting_ui; smart_lighting_ui._panel_refresh()')",
                id=rt.Name("SmartLighting"),
            )
        except Exception:
            pass  # callbacks are non-critical

    # ------------------------------------------------------------------
    # UI construction
    # ------------------------------------------------------------------

    def _build_ui(self):
        layout = QVBoxLayout(self)
        layout.setContentsMargins(6, 6, 6, 6)
        layout.setSpacing(4)

        # Engine header row
        header = QHBoxLayout()
        self.engine_badge = QLabel("◉  detecting…")
        self.engine_badge.setAutoFillBackground(True)
        self.engine_badge.setAlignment(Qt.AlignCenter)
        f = self.engine_badge.font()
        f.setBold(True)
        self.engine_badge.setFont(f)
        self.engine_badge.setMinimumHeight(26)

        self.redetect_btn = QPushButton("Re-detect")
        self.redetect_btn.setFixedWidth(80)
        self.redetect_btn.clicked.connect(self._refresh_engine)
        header.addWidget(self.engine_badge, 1)
        header.addWidget(self.redetect_btn)
        layout.addLayout(header)

        # Tabs
        tabs = QTabWidget()
        tabs.addTab(self._build_tab(), "BUILD")
        tabs.addTab(self._audit_tab(), "AUDIT")
        tabs.addTab(self._passes_tab(), "PASSES")
        layout.addWidget(tabs)

        # Shared status bar at the bottom
        self.status_label = QLabel("")
        self.status_label.setWordWrap(True)
        self.status_label.setStyleSheet("color:#AAAAAA;font-size:11px;")
        layout.addWidget(self.status_label)

    # --- BUILD tab -------------------------------------------------------

    def _build_tab(self) -> QWidget:
        w = QWidget()
        l = QVBoxLayout(w)
        l.setSpacing(6)

        g1 = QGroupBox("Scene Mood")
        g1l = QVBoxLayout(g1)
        self.mood_combo = QComboBox()
        self.mood_combo.addItems(["Archviz", "Dramatic", "Night", "Overcast"])
        g1l.addWidget(self.mood_combo)
        l.addWidget(g1)

        g2 = QGroupBox("Rig Settings")
        g2l = QVBoxLayout(g2)
        row1 = QHBoxLayout()
        row1.addWidget(QLabel("Type:"))
        self.rig_combo = QComboBox()
        self.rig_combo.addItems(["3-Point", "4-Point"])
        row1.addWidget(self.rig_combo)
        g2l.addLayout(row1)
        row2 = QHBoxLayout()
        row2.addWidget(QLabel("Ratio:"))
        self.ratio_combo = QComboBox()
        self.ratio_combo.addItems(["2:1", "4:1", "8:1"])
        row2.addWidget(self.ratio_combo)
        g2l.addLayout(row2)
        self.sun_lock_cb = QCheckBox("Lock sun multiplier to 1.0")
        g2l.addWidget(self.sun_lock_cb)
        l.addWidget(g2)

        self.build_btn = QPushButton("⚡  Build Rig")
        self.build_btn.setMinimumHeight(36)
        self.build_btn.setStyleSheet(
            "QPushButton{background:#1565C0;color:white;font-weight:bold;"
            "border-radius:4px;font-size:13px;}"
            "QPushButton:hover{background:#1976D2;}"
            "QPushButton:pressed{background:#0D47A1;}"
        )
        self.build_btn.clicked.connect(self.build_rig)
        l.addWidget(self.build_btn)
        l.addStretch()
        return w

    # --- AUDIT tab -------------------------------------------------------

    def _audit_tab(self) -> QWidget:
        w = QWidget()
        l = QVBoxLayout(w)
        btn_row = QHBoxLayout()
        run_btn = QPushButton("▶  Run Audit")
        run_btn.clicked.connect(self.run_audit)
        clear_btn = QPushButton("Clear")
        clear_btn.setFixedWidth(60)
        clear_btn.clicked.connect(lambda: self.results_list.clear())
        btn_row.addWidget(run_btn)
        btn_row.addWidget(clear_btn)
        l.addLayout(btn_row)
        self.results_list = QListWidget()
        self.results_list.setWordWrap(True)
        self.results_list.itemClicked.connect(self.on_audit_item_clicked)
        l.addWidget(self.results_list)
        return w

    # --- PASSES tab ------------------------------------------------------

    def _passes_tab(self) -> QWidget:
        w = QWidget()
        l = QVBoxLayout(w)
        add_btn = QPushButton("+ Add Standard AOV Set")
        add_btn.clicked.connect(self.add_standard_set)
        l.addWidget(add_btn)
        self.merge_exr_cb = QCheckBox("Merge to multi-channel EXR")
        l.addWidget(self.merge_exr_cb)

        lg = QGroupBox("Light Group AOVs")
        lgl = QVBoxLayout(lg)
        add_grp_btn = QPushButton("Add Groups for KEY / FILL / RIM lights")
        add_grp_btn.clicked.connect(self.add_light_groups)
        lgl.addWidget(add_grp_btn)
        l.addWidget(lg)

        self.passes_status = QLabel("")
        self.passes_status.setWordWrap(True)
        l.addWidget(self.passes_status)
        l.addStretch()
        return w

    # ------------------------------------------------------------------
    # Engine badge
    # ------------------------------------------------------------------

    def _refresh_engine(self) -> str:
        e = detect_engine()
        self._current_engine = e
        colour = _ENGINE_COLOURS.get(e, "#607D8B")
        self.engine_badge.setText(f"◉  {e.upper()}")
        self.engine_badge.setStyleSheet(
            f"background:{colour};color:white;padding:4px 8px;border-radius:3px;"
        )
        return e

    # ------------------------------------------------------------------
    # BUILD logic
    # ------------------------------------------------------------------

    def build_rig(self):
        """Create KEY_01 / FILL_01 / RIM_01 lights for the active renderer."""
        engine = self._refresh_engine()
        mood = self.mood_combo.currentText()
        ratio = int(self.ratio_combo.currentText().split(":")[0])

        kelvin = {
            "Archviz":  (5500, 6500),
            "Dramatic": (3200, 5500),
            "Night":    (2700, 2700),
            "Overcast": (6500, 6500),
        }
        key_k, fill_k = kelvin.get(mood, (5500, 6500))
        key_mult  = 1.0
        fill_mult = key_mult / ratio

        d = 200.0
        key_pos  = rt.Point3(
            d * math.cos(math.radians(45)),
            d * math.sin(math.radians(45)),
            d,
        )
        fill_pos = rt.Point3(-d * 0.7, d * 0.3, d * 0.5)
        rim_pos  = rt.Point3(0.0, -d, d * 0.6)

        # Centre rig on selected object if any
        if rt.selection.count > 0:
            obj = rt.selection[0]
            bb = rt.nodeGetBoundingBox(obj, rt.Matrix3(1))
            cx = (bb[0].x + bb[1].x) / 2.0
            cy = (bb[0].y + bb[1].y) / 2.0
            cz = (bb[0].z + bb[1].z) / 2.0
            key_pos  = rt.Point3(cx + key_pos.x,  cy + key_pos.y,  cz + d)
            fill_pos = rt.Point3(cx + fill_pos.x, cy + fill_pos.y, cz + d * 0.5)
            rim_pos  = rt.Point3(cx + rim_pos.x,  cy + rim_pos.y,  cz + d * 0.6)

        lights_created = []
        try:
            if engine == "arnold":
                key = rt.Arnold_Light()
                key.name = "KEY_01"
                try:
                    key.type = rt.Name("distant")
                    key.color_temperature = key_k
                    key.intensity = key_mult
                    key.cast_shadows = True
                except Exception:
                    pass
                fill = rt.Arnold_Light()
                fill.name = "FILL_01"
                try:
                    fill.type = rt.Name("area")
                    fill.color_temperature = fill_k
                    fill.intensity = fill_mult
                except Exception:
                    pass
                rim = rt.Arnold_Light()
                rim.name = "RIM_01"
                try:
                    rim.type = rt.Name("area")
                    rim.color_temperature = key_k
                    rim.intensity = fill_mult * 0.5
                except Exception:
                    pass
                lights_created = [key, fill, rim]

            elif engine == "vray":
                key = rt.VRaySun()
                key.name = "KEY_01"
                fill = rt.VRayLight()
                fill.name = "FILL_01"
                try:
                    fill.type = 0
                    fill.multiplier = fill_mult
                except Exception:
                    pass
                rim = rt.VRayLight()
                rim.name = "RIM_01"
                try:
                    rim.type = 0
                    rim.multiplier = fill_mult * 0.5
                except Exception:
                    pass
                lights_created = [key, fill, rim]

            elif engine == "corona":
                key = rt.CoronaSun()
                key.name = "KEY_01"
                fill = rt.CoronaLight()
                fill.name = "FILL_01"
                try:
                    fill.intensity = fill_mult
                except Exception:
                    pass
                rim = rt.CoronaLight()
                rim.name = "RIM_01"
                try:
                    rim.intensity = fill_mult * 0.5
                except Exception:
                    pass
                lights_created = [key, fill, rim]

            else:  # scanline / art / unknown
                key = rt.Target_Direct()
                key.name = "KEY_01"
                try:
                    key.multiplier = key_mult
                    key.shadow = rt.Shadow_Map()
                except Exception:
                    pass
                fill = rt.Omni()
                fill.name = "FILL_01"
                try:
                    fill.multiplier = fill_mult
                except Exception:
                    pass
                rim = rt.Target_Spot()
                rim.name = "RIM_01"
                try:
                    rim.multiplier = fill_mult * 0.5
                except Exception:
                    pass
                lights_created = [key, fill, rim]

            # Position
            if len(lights_created) >= 3:
                lights_created[0].pos = key_pos
                lights_created[1].pos = fill_pos
                lights_created[2].pos = rim_pos

                # Mood overrides
                if mood == "Night":
                    try:
                        lights_created[1].on = False  # kill fill
                    except Exception:
                        pass
                if mood == "Overcast":
                    try:
                        lights_created[0].on = False  # kill key/sun
                    except Exception:
                        pass

                # Optional per-frame sun-lock callback
                if self.sun_lock_cb.isChecked() and engine in ("vray", "corona"):
                    key_name = lights_created[0].name
                    try:
                        rt.callbacks.addScript(
                            rt.Name("renderPreEval"),
                            (
                                f"if {key_name}.multiplier < 0.95 or "
                                f"{key_name}.multiplier > 1.05 do "
                                f"{key_name}.multiplier = 1.0"
                            ),
                            id=rt.Name("SunLock"),
                        )
                    except Exception:
                        pass

            self.status_label.setText(
                f"✓ Built {engine} {mood} rig — KEY/FILL/RIM at ratio {ratio}:1"
            )

        except Exception as exc:
            self.status_label.setText(f"Error building rig: {exc}")

    # ------------------------------------------------------------------
    # AUDIT logic
    # ------------------------------------------------------------------

    def run_audit(self):
        """Check scene lights for four common lighting errors."""
        self.results_list.clear()
        issues: list[tuple[str, object]] = []

        lights = [n for n in rt.objects if rt.isKindOf(n, rt.Light)]
        meshes = [n for n in rt.objects if rt.isKindOf(n, rt.GeometryClass)]
        motivated_re = re.compile(r"lamp|window|fire|candle|screen", re.I)

        for light in lights:
            lpos = light.pos

            # 1. Unmotivated — no named motivator mesh within falloff radius
            try:
                radius = getattr(light, "falloff", 200.0) * 2
            except Exception:
                radius = 200.0
            nearby = [
                m for m in meshes
                if rt.distance(lpos, m.pos) < radius and motivated_re.search(m.name)
            ]
            if not nearby:
                issues.append((
                    f"UNMOTIVATED: {light.name} — no lamp/window/fire within {radius:.0f} u",
                    light,
                ))

            # 2. Invisible illumination — diffuse but no shadows at >50 % power
            try:
                if (
                    getattr(light, "affectDiffuse", False)
                    and not getattr(light, "castShadows", True)
                    and getattr(light, "multiplier", 1.0) > 0.5
                ):
                    issues.append((
                        f"INVISIBLE ILLUM: {light.name} — no shadows, multiplier > 0.5",
                        light,
                    ))
            except Exception:
                pass

            # 3. Ambient drag — ambient light washing out shadow depth
            try:
                if rt.isKindOf(light, rt.Ambient_Light):
                    mul = getattr(light, "multiplier", 0.0)
                    if mul > 0.05:
                        issues.append((
                            f"AMBIENT DRAG: {light.name} — mul={mul:.2f} kills shadow depth",
                            light,
                        ))
            except Exception:
                pass

            # 4. Sun multiplier drift — directional/sun ≠ 1.0 by more than 5 %
            cls_str = str(type(light)).lower()
            if any(x in cls_str for x in ("direct", "sun", "vraylight", "coronasun")):
                try:
                    mul = getattr(light, "multiplier", 1.0)
                    if abs(mul - 1.0) > 0.05:
                        issues.append((
                            f"SUN DRIFT: {light.name} — mul={mul:.2f} ≠ 1.0",
                            light,
                        ))
                except Exception:
                    pass

        if not issues:
            self.results_list.addItem("✓  No issues found")
            return

        colour_map = {
            "UNMOTIVATED": "#FF9800",
            "INVISIBLE":   "#F44336",
            "AMBIENT":     "#9C27B0",
            "SUN":         "#2196F3",
        }
        for msg, ref in issues:
            item = QListWidgetItem(msg)
            item.setData(Qt.UserRole, ref)
            for key, hex_col in colour_map.items():
                if key in msg:
                    item.setForeground(QtGui.QColor(hex_col))
                    break
            self.results_list.addItem(item)

    def on_audit_item_clicked(self, item: QListWidgetItem):
        ref = item.data(Qt.UserRole)
        if ref is not None:
            try:
                rt.select(ref)
            except Exception:
                pass

    # ------------------------------------------------------------------
    # PASSES logic
    # ------------------------------------------------------------------

    def add_standard_set(self):
        """Add the engine-appropriate AOV / render-element set."""
        engine = self._current_engine
        added: list[str] = []

        if engine == "arnold":
            try:
                mgr = rt.renderers.current.aov_manager
                for name in [
                    "beauty", "diffuse", "specular", "sss",
                    "depth", "N", "P", "UV", "emission",
                ]:
                    try:
                        a = rt.Arnold_AOV()
                        a.name = name
                        a.type = name
                        mgr.aovs.add(a)
                        added.append(name)
                    except Exception:
                        pass
            except Exception as exc:
                self.passes_status.setText(f"Arnold AOV error: {exc}")
                return

        elif engine == "vray":
            for cls_name in [
                "VRayRawLighting", "VRaySpecular", "VRayZDepth", "VRayNormals",
            ]:
                try:
                    cls = getattr(rt, cls_name, None)
                    if cls:
                        rt.maxOps.addRenderElement(cls())
                        added.append(cls_name)
                except Exception:
                    pass

        elif engine == "corona":
            for cls_name in [
                "CShading_Beauty", "CShading_Diffuse", "CShading_Reflect",
                "CShading_Refract", "CShading_SSS", "CShading_ShadowsRaw",
            ]:
                try:
                    cls = getattr(rt, cls_name, None)
                    if cls:
                        rt.maxOps.addRenderElement(cls())
                        added.append(cls_name)
                except Exception:
                    pass

        else:  # scanline / art / unknown
            for cls_name in [
                "Diffuse_Map_Element", "Specular_Map_Element",
                "Shadow_Map_Element", "ZDepth_Map_Element",
            ]:
                try:
                    cls = getattr(rt, cls_name, None)
                    if cls:
                        rt.maxOps.addRenderElement(cls())
                        added.append(cls_name)
                except Exception:
                    pass

        # Optionally switch render output to EXR
        if self.merge_exr_cb.isChecked():
            try:
                current = rt.renderOutputFilename or ""
                for ext in (".png", ".jpg", ".jpeg", ".tga", ".tif", ".tiff"):
                    if current.lower().endswith(ext):
                        rt.renderOutputFilename = current[: -len(ext)] + ".exr"
                        break
                else:
                    rt.renderOutputFilename = "output.exr"
            except Exception:
                pass

        label = ", ".join(added) if added else "none (check renderer is active)"
        self.passes_status.setText(f"Added: {label}")

    def add_light_groups(self):
        """Tag KEY_* / FILL_* / RIM_* / BG_* lights with a light-group AOV prefix."""
        engine = self._current_engine
        lights = [n for n in rt.objects if rt.isKindOf(n, rt.Light)]
        rig_lights = [
            lt for lt in lights
            if any(lt.name.startswith(p) for p in ("KEY_", "FILL_", "RIM_", "BG_"))
        ]
        for lt in rig_lights:
            if engine == "arnold":
                try:
                    lt.aiAovLightGroupPrefix = lt.name.split("_")[0].lower()
                except Exception:
                    pass
            # V-Ray and Corona light-group membership is set via render settings;
            # only Arnold exposes it as a per-light property in Max 2027.
        names = [lt.name for lt in rig_lights]
        self.passes_status.setText(
            f"Groups set: {', '.join(names)}" if names else "No KEY/FILL/RIM/BG lights found"
        )


# ---------------------------------------------------------------------------
# Module-level singleton + callback hook
# ---------------------------------------------------------------------------

_panel: SmartLightingPanel | None = None


def _panel_refresh():
    """Called by the MaxScript systemPostNew / filePostOpen callbacks."""
    global _panel
    if _panel is not None:
        try:
            _panel._refresh_engine()
        except Exception:
            pass


def show() -> SmartLightingPanel:
    """Show (or raise) the Smart Lighting panel.  Returns the panel instance."""
    global _panel

    # Resolve a parent window if possible
    parent = None
    try:
        import qtmax  # 3ds Max 2024+ ships qtmax
        parent = qtmax.GetQMaxMainWindow()
    except Exception:
        try:
            import MaxPlus
            parent = MaxPlus.GetQMaxMainWindow()
        except Exception:
            pass

    if _panel is None or not _panel.isVisible():
        _panel = SmartLightingPanel(parent)

    # Floating, always-on-top tool window — matches other SoulBurn panels
    _panel.setWindowFlags(Qt.Tool | Qt.WindowStaysOnTopHint)
    _panel.show()
    _panel.raise_()
    _panel.activateWindow()
    return _panel
