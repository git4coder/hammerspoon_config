print("#######################")
print(">> Hammerspoon Init ...")
hs.window.animationDuration = 0 -- 禁用动画，默认 0.2 https://github.com/Hammerspoon/hammerspoon/issues/1936

-- 全局 hs.alert 样式
hs.alert.defaultStyle.textColor    = hs.drawing.color.asRGB({hex = '#FFFFFF', alpha = 1.00}) -- 文本色
hs.alert.defaultStyle.fillColor    = hs.drawing.color.asRGB({hex = '#000000', alpha = 0.75}) -- 背景色
hs.alert.defaultStyle.strokeColor  = hs.drawing.color.asRGB({hex = '#FFFFFF', alpha = 0.50}) -- 边框色
hs.alert.defaultStyle.radius       = 5
hs.alert.defaultStyle.textFont     = 'Monaco'
hs.alert.defaultStyle.textSize     = 16
hs.alert.defaultStyle.atScreenEdge = 0

hs.loadSpoon("AppKeyable") -- 给APP绑定独立的激活键
hs.loadSpoon("SpeedMenu") -- 状态栏的下/下截网速
hs.loadSpoon("ReloadConfiguration") -- 自动重载 Hammerspoon 配置

spoon.ReloadConfiguration:start()
spoon.AppKeyable:start()
-- spoon.SpeedMenu:start() -- 貌似不需要 start

-- 打开项目所在文件夹
hs.hotkey.bind({'cmd'}, 'e',
  function()
    hs.execute('open ~/Projects')
  end
)
