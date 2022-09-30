print("#######################")
print(">> Hammerspoon Init ...")
hs.window.animationDuration = 0 -- 禁用动画，默认 0.2 https://github.com/Hammerspoon/hammerspoon/issues/1936

hs.console.darkMode(true)
if hs.console.darkMode() then
    hs.console.outputBackgroundColor({ white = 0, alpha = 0.5 })
    hs.console.consoleCommandColor({ white = 1, alpha = 0.7 })
    hs.console.alpha(1.00)
end

-- 全局 hs.alert 样式
hs.alert.defaultStyle.textColor    = hs.drawing.color.asRGB({hex = '#FFFFFF', alpha = 1.00}) -- 文本色
hs.alert.defaultStyle.fillColor    = hs.drawing.color.asRGB({hex = '#000000', alpha = 0.75}) -- 背景色
hs.alert.defaultStyle.strokeColor  = hs.drawing.color.asRGB({hex = '#FFFFFF', alpha = 0.50}) -- 边框色
hs.alert.defaultStyle.radius       = 5
hs.alert.defaultStyle.textFont     = 'Monaco'
hs.alert.defaultStyle.textSize     = 16
hs.alert.defaultStyle.atScreenEdge = 0

hs.loadSpoon("AppKeyable") -- 给APP绑定独立的激活键
--hs.loadSpoon("SpeedMenu") -- 状态栏的下/下截网速
hs.loadSpoon("ReloadConfiguration") -- 自动重载 Hammerspoon 配置

spoon.AppKeyable.config.applications = {
  {key = 'a', color = '#FFFFFF', path = '/Applications/Android Studio.app'},
  {key = 'A', color = '#FFFFFF', path = '/System/Applications/App Store.app'},
  {key = 'b', color = '#FFFFFF', path = '/Applications/Blender.app'},
  {key = 'B', color = '#FFFFFF', path = '/System/Applications/Books.app'},
  {key = 'c', color = '#FFFFFF', path = '/Applications/Google Chrome.app'},
  {key = 'C', color = '#FFFFFF', path = '/System/Applications/Contacts.app'},
  {key = 'd', color = '#FFFFFF', path = '/Applications/DBeaver.app'},
  -- {key = 'D', color = '#FFFFFF', path = '/Applications/NeteaseDictionary.app'},
  {key = 'E', color = '#FFFFFF', path = '/System/Applications/TextEdit.app'}, -- Editor
  {key = 'e', color = '#FFFFFF', path = '/Applications/Typora.app'},
  {key = 'f', color = '#FFFFFF', path = '/System/Library/CoreServices/Finder.app'},
  {key = 'F', color = '#FFFFFF', path = '/System/Applications/FaceTime.app'},
  {key = 'g', color = '#FFFFFF', path = '/Applications/Fork.app'}, -- Git fork
  {key = 'G', color = '#FFFFFF', path = '/Applications/WeWork.app'},
  {key = 'h', color = '#FFFFFF', path = '/Applications/HBuilderX.app'},
  {key = 'i', color = '#FFFFFF', path = '/Applications/Postman.app'},
  -- {key = 'j', color = '#03a9f4', path = '/Applications/PhpStorm.app'},
  {key = 'k', color = '#FFFFFF', path = '/System/Applications/Utilities/Activity Monitor.app'},
  {key = 'm', color = '#FFFFFF', path = '/System/Applications/Messages.app'},
  {key = 'M', color = '#FFFFFF', path = '/Applications/TencentMeeting.app'},
  {key = 'o', color = '#FFFFFF', path = '/Applications/wpsoffice.app'},
  {key = 'p', color = '#FFFFFF', path = '/Applications/Affinity Photo.app'},
  {key = 'P', color = '#FFFFFF', path = '/Applications/Postman.app'},
  {key = 'q', color = '#FFFFFF', path = '/Applications/QQ.app'},
  {key = 'r', color = '#FFFFFF', path = '/Applications/Microsoft Remote Desktop.app'},
  {key = 's', color = '#FFFFFF', path = '/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app'},
  {key = 'S', color = '#FFFFFF', path = '/System/Applications/System Preferences.app'},
  {key = 't', color = '#FFFFFF', path = '/System/Applications/Utilities/Terminal.app'},
  {key = 'v', color = '#03a9f4', path = '/Applications/Visual Studio Code.app'},
  {key = 'V', color = '#FFFFFF', path = '/Applications/wechatwebdevtools.app'},
  {key = 'w', color = '#FFFFFF', path = '/Applications/WeChat.app'},
  {key = 'W', color = '#FFFFFF', path = '/Applications/WeWork.app'},
  {key = 'x', color = '#FFFFFF', path = '/Applications/Xcode.app'},
  {key = 'X', color = '#FFFFFF', path = '/Applications/SunloginClient.app'},
  {key = 'y', color = '#FFFFFF', path = '/Applications/NeteaseMusic.app'},
}

spoon.ReloadConfiguration:start()
spoon.AppKeyable:start()
-- spoon.SpeedMenu:start() -- 不需要 start，loadSpoon() 时已经自动启动了

-- 打开项目所在文件夹
hs.hotkey.bind({'cmd'}, 'e',
  function()
    hs.execute('open ~/Projects')
  end
)

-- 切换输入法
hs.hotkey.bind({}, 'f17',
  function()
    hs.hid.capslock.set(false)
    local im = "com.apple.inputmethod.SCIM.WBX"
    hs.keycodes.currentSourceID(im)
    hs.alert.closeAll()
    hs.alert.show("中文")
  end
)
hs.hotkey.bind({}, 'f18',
  function()
    hs.hid.capslock.set(false)
    local im = "com.apple.keylayout.ABC"
    hs.keycodes.currentSourceID(im)
    hs.alert.closeAll()
    hs.alert.show("English")
  end
)

