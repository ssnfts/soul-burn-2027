-------------------------------------------------------------------------------
-- soulburnToolbarInstaller.ms
-- SoulBurn Scripts Pack v2.0 - Toolbar Installer
--
-- HOW TO USE (one time only):
--   In MaxScript Listener:
--   fileIn ((getdir #userScripts) + "\\SoulburnScripts\\scripts\\soulburnToolbarInstaller.ms")
--
-- What this does:
--   1. Loads SoulburnScripts.cuix from its installed location
--   2. Shows the toolbar in the current Max session
--   3. Saves the workspace so it persists on restart
--
-- If toolbar is not visible after running: 
--   Customize > Show UI > Show Toolbars > SoulburnScripts
-------------------------------------------------------------------------------

(
local cuixPath = (getdir #plugcfg) + "\\SoulburnScripts\\SoulburnScripts.cuix"

if not (doesFileExist cuixPath) then (
    MessageBox ("SoulburnScripts.cuix not found at:\n" + cuixPath + "\n\nPlease run the SoulBurn installer first.") title:"SoulburnScripts Setup"
) else (
    try (
        cui.loadConfig cuixPath
        cui.showToolbar "SoulburnScripts"
        cui.saveConfig()
        MessageBox "SoulburnScripts toolbar loaded!\n\nIf not visible: Customize > Show UI > Show Toolbars > SoulburnScripts" title:"SoulburnScripts"
    ) catch e (
        MessageBox ("Toolbar load failed: " + e as string + "\n\nGo to: Customize > Show UI > Show Toolbars > SoulburnScripts") title:"SoulburnScripts"
    )
)
)
