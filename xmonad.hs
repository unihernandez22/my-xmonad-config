import System.IO
import System.Exit
--import System.Taffybar.Hooks.PagerHints (pagerHints)

import qualified Data.List as L

import XMonad
import XMonad.Actions.Navigation2D
--import XMonad.Actions.UpdatePointer

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Hooks.EwmhDesktops (ewmh)

import XMonad.Layout.Gaps
import XMonad.Layout.Fullscreen
import XMonad.Layout.BinarySpacePartition as BSP
import XMonad.Layout.NoBorders
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Spacing
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.NoFrillsDecoration
import XMonad.Layout.Renamed
import XMonad.Layout.Simplest
import XMonad.Layout.SubLayouts
--import XMonad.Layout.WindowNavigation
import XMonad.Layout.ZoomRow

import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.Cursor

import Graphics.X11.ExtraTypes.XF86
import Control.Monad (liftM2)
import qualified XMonad.StackSet as W
import qualified Data.Map        as M

import XMonad.Actions.CopyWindow

-- Default terminal
myTerminal = "termite"

-- The command to take a selective screenshot.
myScreenshot = "flameshot gui"

-- The command to launch the launcher
myLauncher = "synapse"



------------------------------------------------------------------------
-- Workspaces
-- The names of workspaces.

ws1 = "1"
ws2 = "2"
ws3 = "3"
ws4 = "4"
ws5 = "5"
ws6 = "6"
ws7 = "7"
ws8 = "8"
ws9 = "9"

xmobarEscape = concatMap doubleLts
  where doubleLts '<' = "<<"
        doubleLts x   = [x]

myWorkspaces :: [String]
myWorkspaces = nerdfont . (map xmobarEscape) $ [ ws1,ws2,ws3,ws4,ws5,ws6,ws7,ws8,ws9]
    where                                                                      
      nerdfont l = [ "<action=xdotool key super+" ++ show (n) ++ "> <fn=2>" ++ ws ++ "</fn> </action>" |
                      (i,ws) <- zip [1..9] l, let n = i ]


------------------------------------------------------------------------
-- Window rules
-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
-- Move favorites app to workspaces
myManageHook :: ManageHook
myManageHook = composeAll . concat $
    [ [ resource  =? r -->  doIgnore  | r <- myIgnores  ]
    , [ className =? c --> doCenterFloat | c <- myFloats ]
    , [ title =? t --> doCenterFloat | t <- myFloatstitle]
    , [ className =? c --> viewShift (myWorkspaces !! 1) | c <- myWebApps ]
    , [ className =? c --> viewShift (myWorkspaces !! 2) | c <- myChatApps ]
    , [ className =? c --> viewShift (myWorkspaces !! 3) | c <- myFileApps ]
    , [ className =? c --> viewShift (myWorkspaces !! 4) | c <- myEditorApps ]
    , [ className =? c --> viewShift (myWorkspaces !! 5) | c <- myPaintApps ]
    , [ className =? c --> viewShift (myWorkspaces !! 7) | c <- myVMApps ]
    , [ className =? c --> hasBorder False | c <- myNoBorderApps ]
    , [ isFullscreen   --> doFullFloat ]
    , [ isDialog     -->  doCenterFloat       ] ]
    where
        myIgnores = [] -- ["desktop","desktop_window","screenkey"]
        myWebApps = ["Brave-browser"]
        myFileApps = ["Thunar"] 
        myChatApps = ["TelegramDesktop"] 
        myEditorApps = ["Atom"]
        myPaintApps = []
        myVMApps = ["VirtualBox Manager", "VirtualBox Machine"] 
        myFloats = [] -- ["Variety", "yad", "Yad"]
        myFloatstitle = ["Picture in picture"]
        myNoBorderApps = ["Synapse", "Ulauncher"]
        viewShift = doF . liftM2 (.) W.greedyView W.shift

-----------------------------------------------------------------------
-- Layouts
-- You can specify and transform your layouts by modifying these values.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.

outerGaps    = 2
innerGaps    = 2
addSpace = spacingRaw True             -- Only for >1 window
                       -- The bottom edge seems to look narrower than it is
                       (Border outerGaps outerGaps outerGaps outerGaps) -- Outer gaps
                       True             -- Enable screen edge gaps
                       (Border innerGaps innerGaps innerGaps innerGaps) -- Inner gaps
                       True             -- Enable window gaps

tab          =  avoidStruts
               $ renamed [Replace "Tabbed"]
               $ addTopBar
               $ tabbed shrinkText myTabTheme

layouts      = avoidStruts (
                (
                    renamed [CutWordsLeft 1]
                  $ addTopBar
                  $ renamed [Replace "BSP"]
                  $ addTabs shrinkText myTabTheme
                  $ subLayout [] Simplest
                  $ addSpace (BSP.emptyBSP)
                )
                ||| tab
               )

myLayout    = smartBorders
              $ mkToggle (NOBORDERS ?? FULL ?? EOT)
              $ layouts

myNav2DConf = def
    { defaultTiledNavigation    = centerNavigation
    , floatNavigation           = centerNavigation
    , screenNavigation          = lineNavigation
    , layoutNavigation          = [("Full",          centerNavigation)
    -- line/center same results   ,("Tabs", lineNavigation)
    --                            ,("Tabs", centerNavigation)
                                  ]
    , unmappedWindowRect        = [("Full", singleWindowRect)
    -- works but breaks tab deco  ,("Tabs", singleWindowRect)
    -- doesn't work but deco ok   ,("Tabs", fullScreenRect)
                                  ]
    }


------------------------------------------------------------------------
-- Colors and borders

-- Color of current window title in xmobar.
xmobarTitleColor = blue

-- Color of current workspace in xmobar.
xmobarCurrentWorkspaceColor = blue

-- Width of the window border in pixels.
myBorderWidth = 1

myNormalBorderColor     = "#313131"
myFocusedBorderColor    = blue

base03  = "#f0f1fa"
base02  = "#0d0d0d"
base00  = "#b4b4b4"
yellow  = "#b58900"
orange  = "#cb4b16"
red     = "#dc322f"
magenta = "#d33682"
violet  = "#6c71c4"
blue    = "#5da0ee"
cyan    = "#5beedc"
green   = "#859900"

-- sizes
topbar      = 0
border      = 0
prompt      = 20
status      = 20

active      = "#1e2028"
activeWarn  = red
inactive    = "#101216"
focusColor  = blue
unfocusColor = base02

myFont      = "xft:Zekton:size=9:bold:antialias=true"
myBigFont   = "xft:Zekton:size=9:bold:antialias=true"
myWideFont  = "xft:Eurostar Black Extended:"
            ++ "style=Regular:pixelsize=180:hinting=true"

-- this is a "fake title" used as a highlight bar in lieu of full borders
-- (I find this a cleaner and less visually intrusive solution)
topBarTheme = def
    {
      fontName              = myFont
    , inactiveBorderColor   = inactive
    , inactiveColor         = inactive
    , inactiveTextColor     = "#b4afb9"
    , activeBorderColor     = active
    , activeColor           = active
    , activeTextColor       = blue
    , urgentBorderColor     = red
    , urgentTextColor       = yellow
    , decoHeight            = topbar
    }

addTopBar =  noFrillsDeco shrinkText topBarTheme

myTabTheme = def
    { fontName              = myFont
    , activeColor           = active
    , inactiveColor         = inactive
    , activeBorderColor     = active
    , inactiveBorderColor   = inactive
    , activeTextColor       = blue
    , inactiveTextColor     = "#b4afb9"
    }

------------------------------------------------------------------------
-- Key bindings
--
-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask = mod4Mask
altMask = mod1Mask

myKeys = [
  ----------------------------------------------------------------------
  -- Custom key bindings
  --

  -- Use this to launch dmenu.
  ((myModMask, xK_d),
     spawn "dmenu_run")

  -- Use this to launch the launcher.
  , ((myModMask, xK_p),
     spawn myLauncher)

  -- Use this to launch programs without a key binding.
  , ((myModMask, xK_Return),
     spawn myTerminal)

  -- Take a selective screenshot.
  , ((0, xK_Print),
     spawn myScreenshot)

  -- Window resize
  , ((myModMask .|. controlMask, xK_Right ), sendMessage $ ExpandTowards R)
  , ((myModMask .|. controlMask, xK_Left  ), sendMessage $ ExpandTowards L)
  , ((myModMask .|. controlMask, xK_Down  ), sendMessage $ ExpandTowards D)
  , ((myModMask .|. controlMask, xK_Up    ), sendMessage $ ExpandTowards U)

   -- Toggle current focus window to fullscreen
  , ((myModMask, xK_f), sendMessage $ Toggle FULL)

  -- Mute volume.
  , ((0, xF86XK_AudioMute),
     spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")

  -- Decrease volume.
  , ((0, xF86XK_AudioLowerVolume),
     spawn "pactl set-sink-volume @DEFAULT_SINK@ -10%")

  -- Increase volume.
  , ((0, xF86XK_AudioRaiseVolume),
     spawn "pactl set-sink-volume @DEFAULT_SINK@ +10%")

  -- Increase bright.
  , ((0, xF86XK_MonBrightnessDown),
     spawn "xbacklight -dec 5")

  -- Decrease bright.
  , ((0, xF86XK_MonBrightnessUp),
     spawn "xbacklight -inc 5")
  
  ----------- Spotify keybindings -------------------------------------------------
  -- Play/pause.
  , ((0, 0x1008FF14),
     spawn "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause")

  -- Stop
  , ((0, 0x1008ff15),
     spawn "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Stop")


  -- Audio previous.
  , ((0, 0x1008FF16),
     spawn "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous")

  -- Audio next.
  , ((0, 0x1008FF17),
     spawn "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next")

  -- Restart xmonad.
  , ((myModMask .|. controlMask, xK_r),
    restart "xmonad" True)
  ]

------------------------------------------------------------------------
-- Mouse bindings
--
-- Focus rules
-- True if your focus should follow your mouse cursor.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
--   [
--     -- mod-button1, Set the window to floating mode and move by dragging
--     ((modMask, button1),
--      (\w -> focus w >> mouseMoveWindow w))
-- 
--     -- mod-button2, Raise the window to the top of the stack
--     , ((modMask, button2),
--        (\w -> focus w >> windows W.swapMaster))
-- 
--     -- mod-button3, Set the window to floating mode and resize by dragging
--     , ((modMask, button3),
--        (\w -> focus w >> mouseResizeWindow w))
-- 
--     -- you may also bind events to the mouse scroll wheel (button4 and button5)
--   ]


------------------------------------------------------------------------
-- Status bars and logging
-- Perform an arbitrary action on each internal state change or X event.
-- See the 'DynamicLog' extension for examples.
--
-- To emulate dwm's status bar
--
-- > logHook = dynamicLogDzen
--


------------------------------------------------------------------------
-- Startup hook
-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
-- myStartupHook = do
--   setWMName "xmonad"
--   setDefaultCursor xC_left_ptr



------------------------------------------------------------------------
-- Run xmonad with all the defaults we set up.
--
main = do
  xmproc <- spawnPipe "xmobar ~/.xmonad/xmobarrc.hs"
  spawn "feh --bg-scale ~/Pictures/bridge-wallpaper.jpg"
  xmonad $ docks
         $ withNavigation2DConfig myNav2DConf
         $ additionalNav2DKeys (xK_Up, xK_Left, xK_Down, xK_Right)
                               [
                                  (mod4Mask,               windowGo  )
                                , (mod4Mask .|. shiftMask, windowSwap)
                               ]
                               False
         $ ewmh
         -- $ pagerHints -- uncomment to use taffybar
         $ defaults {
         logHook = dynamicLogWithPP xmobarPP {
                 ppCurrent = xmobarColor base03 xmobarCurrentWorkspaceColor . wrap "" "" 
                , ppHidden = xmobarColor xmobarCurrentWorkspaceColor "#555577" . wrap "" "" 
                , ppHiddenNoWindows = xmobarColor xmobarCurrentWorkspaceColor "#1E2028" . wrap "" "" 
                , ppTitle = xmobarColor xmobarTitleColor "" . shorten 20
                , ppSep = "   "
                , ppOrder  = \(ws:l:t:ex) -> [t,l,ws]
                , ppOutput = hPutStrLn xmproc
         }-- >> updatePointer (0.75, 0.75) (0.75, 0.75)
      }

------------------------------------------------------------------------
-- Combine it all together
-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults = def {
    -- simple stuff
    terminal           = myTerminal,
    focusFollowsMouse  = myFocusFollowsMouse,
    borderWidth        = myBorderWidth,
    modMask            = myModMask,
    workspaces         = myWorkspaces,
    normalBorderColor  = myNormalBorderColor,
    focusedBorderColor = myFocusedBorderColor,

    -- key bindings
    -- keys               = myKeys,
    -- mouseBindings      = myMouseBindings,

    -- hooks, layouts
    layoutHook         = myLayout,
    handleEventHook    = fullscreenEventHook,
    -- startupHook        = myStartupHook,
    manageHook         = manageDocks <+> myManageHook
} `additionalKeys` myKeys
