Config {
       font = "xft:JetbrainsMono:size=10"
       , additionalFonts = [ "xft:JetbrainsMono:size=11","xft:Robot Crush:size=12","xft:Symbols Nerd Font:size=10","xft:Symbols Nerd Font:size=12" ]
       -- , additionalFonts = [ "xft:JetbrainsMono:size=10","xft:Symbols Nerd Font:size=10","xft:Symbols Nerd Font:size=12","xft:Symbols Nerd Font:size=15","xft:JetbrainsMono:size=10" ]
       , allDesktops = True
    -- , textOffset = 23
       , bgColor = "#1e2028"
       , fgColor = "#b4afb9"
    -- , position = Static { xpos = 0 , ypos = 0, width = 1367, height = 22 }
       , position = TopSize L 100 10
    -- , border = FullBM 0
    -- , borderColor =  "#fff"
    -- , borderWidth = 0
       , commands = [ 
          Run Memory ["-t","<usedratio>%"
                       ,"-H","80"
                       ,"-L","10"
                       ,"-l","#b4afb9"
                       ,"-n","#b4afb9"
                       ,"-h","#fb4934"] 50

          , Run Date "%I:%M" "date" 300

          , Run ThermalZone 4 ["-t","<temp>°"
                         , "-L", "30"
                         , "-H", "65"
                         , "-l", "#b4afb9"
                         , "-n", "#b4afb9"
                         , "-h", "#aa4450"] 50

					, Run CommandReader "sh .xmonad/wifi.sh -a" "wifi"
					, Run CommandReader "sh .xmonad/battery.sh -level" "batterylevel"
					, Run CommandReader "sh .xmonad/battery.sh -icon" "batteryicon"

          , Run UnsafeStdinReader
          ]
       , sepChar = "$"
       , alignSep = "}{"
       , template = "<fn=1> <fn=3></fn> $date$ || <fn=3></fn> $wifi$ || <fn=4>$batteryicon$</fn> $batterylevel$ || <fn=3></fn> $thermal4$ || <fn=4></fn> $memory$ </fn> }{ <fn=1> $UnsafeStdinReader$ </fn>" -- use <fc=#xxxxxx> for colors
       }
