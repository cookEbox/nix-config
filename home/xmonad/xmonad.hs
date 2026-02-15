-- IMPORTS

-- Base
import XMonad
import Data.Monoid
import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- Utilities 
import XMonad.Util.SpawnOnce

-- Hooks
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Hooks.WorkspaceHistory
import XMonad.Hooks.EwmhDesktops (ewmh, ewmhFullscreen, fullscreenEventHook)

-- Actions
import XMonad.Actions.CycleWS
  ( nextWS
  , prevWS
  , nextScreen
  , prevScreen
  , shiftNextScreen
  , shiftPrevScreen
  )
import XMonad.Actions.SpawnOn

-- Data
import Data.Maybe (fromJust)
import Data.List (intercalate)

import XMonad.Util.Run (safeSpawn)

-- Layouts
import XMonad.Layout.PerWorkspace
import XMonad.Layout.NoBorders
import XMonad.Layout.MultiToggle 
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.Tabbed
import XMonad.Layout.SimplestFloat
import XMonad.Layout.MouseResizableTile
import XMonad.Layout.Spacing
import XMonad.Layout.ToggleLayouts (toggleLayouts, ToggleLayout(ToggleLayout))

-- Terminal
myTerminal      = "alacritty"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
myBorderWidth   = 2

-- Mod Key
myModMask       = mod4Mask

-- Workspaces
myWorkspaces    = ["hme","cht","www","dev","dev2","flt","med"]
myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..] -- (,) == \x y -> (x,y)

clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
    where i = fromJust $ M.lookup ws myWorkspaceIndices

-- Border colors for unfocused and focused windows, respectively.
myNormalBorderColor  = "#000000"
myFocusedBorderColor = "#d79921"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    
    -- LAUNCH APPS
    -- launch a terminal
    [ ((modm,               xK_Return), spawn $ XMonad.terminal conf)

    -- launch dmenu
    , ((modm              , xK_space ), spawn "rofi -show drun")

    -- clipboard history picker (cliphist + rofi)
    , ((modm,               xK_v     ), spawn "cliphist-rofi-picker")

    -- launch qutebrowser
    , ((modm,               xK_b     ), spawn "firefox")

    -- launch video
    , ((modm .|. shiftMask, xK_b     ), spawn "brave")

    -- launch discord
    , ((modm,               xK_c    ), spawn "discord")

    -- launch whatsapp
    , ((modm .|. shiftMask, xK_c     ), spawn "wasistlos")

    -- launch file managers
    , ((modm,               xK_f     ), spawn "nemo")

    -- launch email 
    , ((modm,               xK_e   ), spawn "evolution")

    -- launch screentshot 
    , ((modm,               xK_s     ), spawn "flameshot gui")

    -- dunst history
    , ((modm .|. shiftMask, xK_grave), spawn "dunstctl close-all")

    -- dunst close
    , ((modm,               xK_grave), spawn "dunstctl history-pop")

    -- dunst history
    , ((modm .|. shiftMask, xK_d    ), spawn "dunstctl set-paused false")

    -- dunst close
    , ((modm,               xK_d    ), spawn "dunstctl set-paused true")

    -- toggle redshift
    , ((modm,               xK_r    ), spawn "pkill -USR1 redshift")

    -- LAUNCH SCRIPTS
    -- launch Random Wallpaper 
    , ((modm .|. shiftMask, xK_w     ), spawn "sh -lc 'feh --no-fehbg --bg-fill --randomize \"$HOME\"/Pictures/wallpapers/*'")

    -- WINDOW CONTROL
    -- close focused window
    , ((modm,               xK_w     ), kill)

     -- Rotate through the available layout algorithms
    -- , ((modm,            xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    -- , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    -- , ((modm .|. shiftMask, xK_a     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm .|. controlMask, xK_m), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. controlMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. controlMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm .|. shiftMask, xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm .|. shiftMask, xK_l     ), sendMessage Expand)

    -- Shrink the slave area
    , ((modm .|. shiftMask, xK_k     ), sendMessage ShrinkSlave)

    -- Expand the slave area
    , ((modm .|. shiftMask, xK_j     ), sendMessage ExpandSlave)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- True fullscreen (no gaps/struts): switches to a dedicated `noBorders Full` layout.
    , ((modm,               xK_x     ), sendMessage ToggleLayout)

    -- Toggle borders on the current (non-fullscreen) layout.
    , ((modm .|. shiftMask, xK_x     ), sendMessage (Toggle NOBORDERS))

    -- Increment the number of windows in the master area
    , ((modm              , xK_equal ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_minus ), sendMessage (IncMasterN (-1)))

    -- Move to next workstation
    , ((modm              , xK_l     ),  nextWS)

    -- Move to previous workstation
    , ((modm              , xK_h     ),  prevWS)

    -- TogglePanel
    -- , ((modm               , xK_t     ), sendMessage ToggleStruts)

    -- Quit xmonad
    -- , ((modm .|. controlMask, xK_q     ), io exitSuccess)

    -- Switch User (NOT SECURE)
    , ((modm .|. shiftMask, xK_q     ), spawn "byebye")

    -- Restart xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")

    -- Run xmessage with a summary of the default keybindings (useful for beginners)
    , ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]
    ++

    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    -- Screens
    -- Existing bindings (screen index ordering):
    -- mod-period / mod-comma: switch focus to next/prev screen
    -- mod-shift-period / mod-shift-comma: move window to next/prev screen
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_period, xK_comma] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

    ++

    -- More ergonomic screen focus switching (independent of Xinerama indexing):
    -- mod-Right / mod-Left: focus next/prev physical screen
    -- mod-shift-Right / mod-shift-Left: send focused window to next/prev screen
    [ ((modm,               xK_Right), nextScreen)
    , ((modm,               xK_Left ), prevScreen)
    , ((modm .|. shiftMask, xK_Right), shiftNextScreen)
    , ((modm .|. shiftMask, xK_Left ), shiftPrevScreen)
    ]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList  

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), \w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster)

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), \w -> focus w >> windows W.shiftMaster)

    -- mod-button3, Set the window to floating mode and resize by dragging
      , ((modm, button3), \w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster)

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- Use `toggleLayouts` to provide a *true* fullscreen layout that bypasses
-- spacing and struts. This avoids the common issue where gaps remain even when
-- toggling FULL via MultiToggle.
myLayout = toggleLayouts (noBorders Full)
        $ onWorkspace "med" ( noBorders Full ||| tiled ||| Mirror tiled )
        $ mkToggle (NOBORDERS ?? EOT)
        -- Increase gaps between splits and keep gaps even for a single tiled window.
        $ spacingRaw False (Border 50 50 50 50) True (Border 50 50 50 50) True
        $ avoidStruts
        $ onWorkspaces ["flt"] ( simplestFloat ||| noBorders Full ||| tiled ||| Mirror tiled )
        $ onWorkspace "dev" ( tiled ||| noBorders Full)
        ( mouseResizableTile ||| tiled ||| noBorders Full ||| Mirror tiled )
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

------------------------------------------------------------------------
-- Window rules:
myManageHook = composeAll
    [ className =? "MPlayer"           --> doFloat
    , className =? "Gimp"              --> doFloat
    , className =? "Nemo"              --> doFloat

    -- ProtonVPN
    -- WM_CLASS can vary; include common variants.
    , className =? "ProtonVPN"          --> doFloat
    , className =? "Proton VPN"         --> doFloat
    , appName   =? "protonvpn"          --> doFloat

    -- Blueman (Bluetooth manager) window
    , className =? "Blueman-manager"   --> doFloat
    , appName   =? "blueman-manager"   --> doFloat
    , title     =? "Bluetooth Devices" --> doFloat

    , className =? "Galculator"        --> doFloat
    , className =? "Application Finder" --> doFloat
    , resource  =? "desktop_window"    --> doIgnore
    , resource  =? "kdesktop"          --> doIgnore
    , isFullscreen                       --> doFullFloat ]

------------------------------------------------------------------------
-- Event handling
-- Ensure EWMH fullscreen requests are handled correctly (cover docks/bars).
myEventHook = docksEventHook <+> fullscreenEventHook

------------------------------------------------------------------------
-- Status bars and logging
-- Publish workspace state to Eww so the bar can highlight focused/visible workspaces.
updateEwwWorkspaces :: X ()
updateEwwWorkspaces = withWindowSet $ \ws -> do
        let focused = W.currentTag ws
            visible = map (W.tag . W.workspace) (W.visible ws)
            visibleJson = "[" ++ intercalate "," (map show visible) ++ "]"
        safeSpawn "eww" ["update", "xmonad_focused_ws=" ++ focused]
        safeSpawn "eww" ["update", "xmonad_visible_ws=" ++ visibleJson]

myLogHook :: X ()
myLogHook = workspaceHistoryHook >> updateEwwWorkspaces

------------------------------------------------------------------------
-- Startup hook
myStartupHook = do
        -- Run the Home Manager managed autostart script (portable; no relative paths).
        spawnOnce "$HOME/.xmonad/autostart.sh"
        -- spawnOn "hme" "evolution &"
        -- spawnOn "hme" "alacritty -e tmux new-session -A -s btop 'btop -p 4'"
        -- spawnOn "cht" "wasitlos &"
        -- spawnOn "cht" "discord &"
        -- spawnOn "med" "firefox &"
        -- spawnOn "dev" "alacritty &"
        -- spawnOn "dev2" "alacritty &"
        -- spawnOn "dev2" "brave &"

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.
main =
        xmonad $ ewmhFullscreen $ ewmh $ docks $ def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'WIN'. Keybindings:",
    "",
    "-- launching applications",
    "mod-Enter              Launch terminal (wezterm)",
    "mod-Shift-Enter        Application launcher (rofi drun)",
    "mod-b                  Web browser (qutebrowser)",
    "mod-Shift-b            Web browser (brave)",
    "mod-f                  File manager (nemo)",
    "mod-Ctrl-e             Mail (evolution)",
    "mod-s                  Screenshot (flameshot gui)",
    "mod-grave              Dunst: pop notification from history",
    "mod-Shift-grave        Dunst: close all notifications",
    "",
    "-- scripts",
    "mod-Shift-w            Random wallpaper",
    "",
    "-- window management",
    "mod-w                  Close/kill the focused window",
    "mod-Space              Rotate through the available layout algorithms",
    "mod-Shift-Space        Reset the layout on the current workspace",
    "mod-Shift-a            Refresh (resize viewed windows to correct size)",
    "mod-Tab / mod-j        Move focus to the next window",
    "mod-k                  Move focus to the previous window",
    "mod-m                  Move focus to the master window",
    "mod-Ctrl-m             Swap the focused window and the master window",
    "mod-Ctrl-j             Swap the focused window with the next window",
    "mod-Ctrl-k             Swap the focused window with the previous window",
    "mod-Shift-h            Shrink the master area",
    "mod-Shift-l            Expand the master area",
    "mod-Shift-k            Shrink the slave area",
    "mod-Shift-j            Expand the slave area",
    "mod-t                  Push window back into tiling (sink)",
    "mod-x                  Toggle true fullscreen (no gaps/struts)",
    "mod-Shift-x            Toggle borders on current layout (NOBORDERS)",
    "mod-=                  Increment the number of windows in the master area",
    "mod--                  Deincrement the number of windows in the master area",
    "mod-l                  Next workspace",
    "mod-h                  Previous workspace",
    "mod-q                  Recompile & restart xmonad",
    "mod-Shift-q            Switch user (byebye)",
    "mod-Shift-/            Show this help",
    "",
    "-- workspaces",
    "mod-[1..9]             Switch to workspace N",
    "mod-Shift-[1..9]       Move client to workspace N",
    "",
    "-- screens",
    "mod-period             Switch to screen 1",
    "mod-comma              Switch to screen 2",
    "mod-Shift-period       Move client to screen 1",
    "mod-Shift-comma        Move client to screen 2",
    "",
    "-- mouse bindings",
    "mod-button1            Set the window to floating mode and move by dragging",
    "mod-button2            Raise the window to the top of the stack",
    "mod-button3            Set the window to floating mode and resize by dragging"]
