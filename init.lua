print("#######################")
print(">> Hammerspoon Init ...")
hs.window.animationDuration = 0 -- 禁用动画，默认 0.2 https://github.com/Hammerspoon/hammerspoon/issues/1936

-- hs.alert.defaultStyle.textColor    = {white = 1, alpha = 1 } -- 修改默认的黑白色
-- hs.alert.defaultStyle.textColor    = hs.drawing.color.asRGB({hex = '#CC0000', alpha = 1}) -- 自定义颜色
hs.alert.defaultStyle.fillColor    = {white = 0, alpha = 0.75 }
hs.alert.defaultStyle.strokeColor  = {white = 1, alpha = 0.50 }
hs.alert.defaultStyle.radius       = 5
hs.alert.defaultStyle.textFont     = 'Monaco'
hs.alert.defaultStyle.textSize     = 16
hs.alert.defaultStyle.atScreenEdge = 0

hs.loadSpoon("SpeedMenu")
require "hotkey"
--require "winSwitch"
--require "ime"
--require "work"

hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

