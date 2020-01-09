print("#######################")
print(">> Hammerspoon Init ...")
hs.window.animationDuration = 0 -- 禁用动画，默认 0.2 https://github.com/Hammerspoon/hammerspoon/issues/1936
--hs.alert.defaultStyle = {
--  strokeColor = {white = 1, alpha = 0.25 },
--  radius   = 5,
--  textFont = 'Monaco',
--  textSize = 16,
--  atScreenEdge = 0
--}
hs.loadSpoon("SpeedMenu")
require "hotkey"
--require "winSwitch"
--require "ime"
--require "work"

hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

