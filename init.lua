print('#######################')
print('>> Hammerspoon Init ...')
Profile = require('profile')
hs.window.animationDuration = 0 -- 禁用动画，默认 0.2 https://github.com/Hammerspoon/hammerspoon/issues/1936

hs.console.darkMode(true)
if hs.console.darkMode() then
  hs.console.outputBackgroundColor({white = 0, alpha = 0.5})
  hs.console.consoleCommandColor({white = 1, alpha = 0.7})
  hs.console.alpha(1.00)
end

-- 全局 hs.alert 样式
hs.alert.defaultStyle.textColor = hs.drawing.color.asRGB({hex = '#FFFFFF', alpha = 1.00}) -- 文本色
hs.alert.defaultStyle.fillColor = hs.drawing.color.asRGB({hex = '#000000', alpha = 0.75}) -- 背景色
hs.alert.defaultStyle.strokeColor = hs.drawing.color.asRGB({hex = '#FFFFFF', alpha = 0.30}) -- 边框色
hs.alert.defaultStyle.radius = 5
hs.alert.defaultStyle.textFont = 'Monaco'
hs.alert.defaultStyle.textSize = 16
hs.alert.defaultStyle.atScreenEdge = 0

hs.loadSpoon('AppKeyable') -- 给APP绑定独立的激活键
--hs.loadSpoon("SpeedMenu") -- 状态栏的下/下截网速
hs.loadSpoon('ReloadConfiguration') -- 自动重载 Hammerspoon 配置

spoon.AppKeyable.config.applications = {
  {key = 'A', color = '#FFFFFF', path = '/System/Applications/App Store.app'},
  {key = 'a', color = '#FFFFFF', path = '/Applications/Arduino IDE.app'},
  {key = 'b', color = '#FFFFFF', path = '/Applications/Blender.app'},
  {key = 'B', color = '#FFFFFF', path = '/System/Applications/Books.app'},
  {key = 'c', color = '#FFFFFF', path = '/Applications/Google Chrome.app'},
  {key = 'C', color = '#FFFFFF', path = '/System/Applications/Contacts.app'},
  {key = 'd', color = '#FFFFFF', path = '/Applications/DBeaver.app'},
  -- {key = 'D', color = '#FFFFFF', path = '/Applications/NeteaseDictionary.app'},
  {key = 'E', color = '#FFFFFF', path = '/System/Applications/TextEdit.app'}, -- Editor
  {key = 'e', color = '#03a9f4', path = '/Applications/MarkText.app'},
  {key = 'f', color = '#FFFFFF', path = '/System/Library/CoreServices/Finder.app'},
  {key = 'F', color = '#FFFFFF', path = '/Applications/FileZilla.app'},
  {key = 'g', color = '#FFFFFF', path = '/Applications/Fork.app'}, -- Git fork
  {key = 'G', color = '#FFFFFF', path = '/Applications/WeWork.app'},
  {key = 'h', color = '#FFFFFF', path = '/Applications/HBuilderX.app'},
  {key = 'H', color = '#FFFFFF', path = '/Applications/VirtualBox.app/Contents/Resources/VirtualBoxVM.app'},
  {key = 'i', color = '#FFFFFF', path = '/Applications/Postman.app'},
  -- {key = 'j', color = '#03a9f4', path = '/Applications/PhpStorm.app'},
  {key = 'j', color = '#FFFFFF', path = '/Applications/IntelliJ IDEA CE.app'},
  {key = 'K', color = '#FFFFFF', path = '/System/Applications/Utilities/Activity Monitor.app'},
  {key = 'k', color = '#FFFFFF', path = '/Applications/Sketch.app'},
  {key = 'm', color = '#FFFFFF', path = '/System/Applications/Messages.app'},
  {key = 'M', color = '#FFFFFF', path = '/Applications/TencentMeeting.app'},
  {key = 'o', color = '#FFFFFF', path = '/Applications/Pages.app'},
  {key = 'p', color = '#FFFFFF', path = '/Applications/Affinity Photo.app'},
  {key = 'P', color = '#FFFFFF', path = '/System/Applications/Freeform.app'},
  {key = 'q', color = '#FFFFFF', path = '/Applications/QQ.app'},
  {key = 'Q', color = '#FFFFFF', path = '/Applications/wechatwebdevtools.app'},
  {key = 'r', color = '#FFFFFF', path = '/Applications/Microsoft Remote Desktop.app'},
  {key = 's', color = '#FFFFFF', path = '/Applications/Safari.app'},
  {key = 'S', color = '#FFFFFF', path = '/System/Applications/System Settings.app'},
  {key = 't', color = '#FFFFFF', path = '/System/Applications/Utilities/Terminal.app'},
  {key = 'u', color = '#FFFFFF', path = '/Applications/Firefox.app'},
  {key = 'v', color = '#03a9f4', path = '/Applications/Visual Studio Code.app'},
  {key = 'V', color = '#FFFFFF', path = '/Applications/Cursor.app'},
  -- {key = 'V', color = '#FFFFFF', path = '/Applications/wechatwebdevtools.app'},
  {key = 'w', color = '#FFFFFF', path = '/Applications/WeChat.app'},
  {key = 'W', color = '#FFFFFF', path = '/Applications/WeWork.app'},
  {key = 'x', color = '#FFFFFF', path = '/Applications/Xmind.app'},
  {key = 'X', color = '#FFFFFF', path = '/Applications/Xcode.app'},
  {key = 'y', color = '#FFFFFF', path = '/Applications/NeteaseMusic.app'}
}

-- table.insert(spoon.AppKeyable.config.functions, 1, {
--   name = 'Frontmost',
--   key = '5',
--   fun = function()
--     local script = [[
--     ]]
--     hs.osascript.applescript(script)
--   end
-- })

spoon.ReloadConfiguration:start()
spoon.AppKeyable:start()
-- spoon.SpeedMenu:start() -- 不需要 start，loadSpoon() 时已经自动启动了

-- 打开项目所在文件夹
hs.hotkey.bind(
  {'cmd'},
  'e',
  function()
    hs.execute('open ~/Projects')
  end
)

-- 切换输入法
hs.hotkey.bind(
  {},
  'f18',
  function()
    hs.hid.capslock.set(false)
    local im = 'com.apple.inputmethod.SCIM.WBX'
    hs.keycodes.currentSourceID(im)
    hs.alert.closeAll()
    hs.alert.show('🇨🇳中文', 0.3)
  end
)
hs.hotkey.bind(
  {},
  'f17',
  function()
    hs.hid.capslock.set(false)
    local im = 'com.apple.keylayout.ABC'
    hs.keycodes.currentSourceID(im)
    hs.alert.closeAll()
    hs.alert.show('🇬🇧English', 0.3)
  end
)

-- -- https://stackoverflow.com/questions/656199/search-for-an-item-in-a-lua-list
-- function Set(list)
--   local set = {}
--   for _, l in ipairs(list) do
--     set[l] = true
--   end
--   return set
-- end
-- 
-- -- 不同位置的 WiFi 使用不同的网络配置
-- function SSIDChanged()
--   hs.location.start()
--   local mac = hs.wifi.interfaceDetails().bssid
--   hs.location.stop()
--   local uuid = 'A2DF6E86-2F00-481C-938E-3CC160347D26' -- Automatic
--   local homeMacAddresses = Set {'8c:be:be:2c:fb:77', '8c:be:be:2c:fb:78'}
--   local ylgMacAddresses = Set {'a2:91:ce:b5:18:54'}
--   local currentUUID = Profile.getCurrentUUID()
--   if (mac ~= nil) then
--     if (mac == 'd4:da:21:5a:ee:41') then -- JonieuNet
--       uuid = 'E736F2F1-0DB3-47C6-A179-2779923A0021'
--     elseif homeMacAddresses[mac] then -- Home
--       uuid = '5AE03170-29FD-4ECE-B891-C72DCDB00712'
--     elseif ylgMacAddresses[mac] then -- YaoLG
--       uuid = '90C23198-478B-4032-BBA0-A7024FB19797'
--     end
--   end
--   if (currentUUID ~= uuid) then
--     Profile.setLocation(uuid)
--   end
-- end
-- wifiWatcher = hs.wifi.watcher.new(SSIDChanged)
-- wifiWatcher:start()
-- 
-- -- 不同的网络位置使用不同的浏览器(需要先将默认浏览器设为Hammerspoon.app)
-- hs.urlevent.httpCallback = function(scheme, host, params, fullURL, senderPID)
--   local p = Profile.getCurrentProfile()
--   local bundleID = nil
--   hs.urlevent.openURLWithBundle(fullURL, p.browser)
--   if (senderPID ~= -1) then
--     local app = hs.application.applicationForPID(senderPID)
--     if (app ~= nil) then
--       bundleID = app:bundleID();
--     end
--   end
--   print(' OpenURL: ' .. fullURL)
--   print(' Browser: ' .. p.browser)
--   print('Location: ' .. p.name)
--   print('     App: ' .. (bundleID or ''))
-- end

-- 定时锁屏
lockScreenTimes = { "11:45", "17:30", "18:45" }
LST = nil -- 在 hammerspoon 的控制台中输入 LST:stop() 可终止 timer
for _, time in pairs(lockScreenTimes)
do
  hs.timer.doAt(time, "1d", function()
    print('hs.timer.doAt: LockScreen: ' .. time)
    timer = hs.timer.delayed.new(300, function()
      notify:withdraw()
      hs.alert("Locking screen …")
      hs.caffeinate.lockScreen()
    end):start()
    LST = timer
    notify = hs.notify.new(
      function(notify)
        timer:stop()
        hs.alert("Screen lock terminated.")
        print('LockScreenTime: Cancelled ' .. time)
      end,
      {
        title = "即将锁屏",
        informativeText = "已计划于5分钟后锁定屏幕",
        actionButtonTitle = "终止计划",
        hasActionButton = true,
      }
    )
    notify:send()
  end, true)
  print('LockScreenTime: ' .. time)
end
