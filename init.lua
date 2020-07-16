print("#######################")
print(">> Hammerspoon Init ...")
hs.window.animationDuration = 0 -- 禁用动画，默认 0.2 https://github.com/Hammerspoon/hammerspoon/issues/1936

-- 全局 hs.alert 样式（hotkey.lua 中已重写）
hs.alert.defaultStyle.textColor    = hs.drawing.color.asRGB({hex = '#FFFFFF', alpha = 1.00}) -- 文本色
hs.alert.defaultStyle.fillColor    = hs.drawing.color.asRGB({hex = '#000000', alpha = 0.75}) -- 背景色
hs.alert.defaultStyle.strokeColor  = hs.drawing.color.asRGB({hex = '#FFFFFF', alpha = 0.50}) -- 边框色
hs.alert.defaultStyle.radius       = 5
hs.alert.defaultStyle.textFont     = 'Monaco'
hs.alert.defaultStyle.textSize     = 16
hs.alert.defaultStyle.atScreenEdge = 0

hs.loadSpoon("SpeedMenu") -- 状态栏的下/下截网速
hs.loadSpoon("ReloadConfiguration") -- 自动重载 Hammerspoon 配置
spoon.ReloadConfiguration:start() -- 启动自动重置配置功能

require "hotkey" -- 为 App 绑定快捷键
--require "winSwitch" -- 用 opt+tab 切换 app
--require "ime" -- 切换到中文输入法
--require "work" -- 锁屏断热点，登入启用热点
