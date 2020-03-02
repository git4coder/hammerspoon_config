-- 打开项目所在文件夹(用了 finder 的设置项“开启新 Finder 时打开：”，这里不要了)
-- hs.hotkey.bind({'cmd'}, 'e',
--   function()
--     hs.execute('open ~/Projects')
--   end
-- )

-- 打开常用工具
apps = {
  {key = 'a', path = '/Applications/Affinity Photo.app'},
  {key = 'b', path = '/Applications/Bear.app'},
  {key = 'd', path = '/Applications/DBeaver.app'},
  {key = 'D', path = '/Applications/DingTalk.app'},
  {key = 'e', path = '/System/Library/CoreServices/Finder.app'},
  {key = 'f', path = '/Applications/Fork.app'},
  {key = 'g', path = '/Applications/Google Chrome.app'},
  {key = 't', path = '/System/Applications/Utilities/Terminal.app'},
  {key = 'o', path = '/Applications/wpsoffice.app'},
  {key = 'm', path = '/Applications/Motrix.app'},
  {key = 'M', path = '/System/Applications/Utilities/Activity Monitor.app'},
  {key = 'p', path = '/Applications/Postman.app'},
  {key = 'q', path = '/Applications/QQ.app'},
  {key = 's', path = '/Applications/Safari.app'},
  {key = 'S', path = '/System/Applications/System Preferences.app'},
  {key = 'v', path = '/Applications/Visual Studio Code.app'},
  {key = 'V', path = '/Applications/VirtualBox.app'},
  {key = 'w', path = '/Applications/wechatwebdevtools.app'},
  {key = 'x', path = '/Applications/Xcode.app'},
  {key = 'y', path = '/Applications/NeteaseMusic.app'}
}

--  打开/切换到App(可以在当前 APP 的窗口间切换)
local launchOrFocusWindowByPath = function(path)
  local toApp  = hs.application.infoForBundlePath(path)
  return function()
    local curApp = hs.application.frontmostApplication()
    print(string.match(path, '/([%w%s]+).app$') .. ' <-- ' .. string.match(curApp:path(), '/([%w%s]+).app$'))
    if curApp:path() == path then -- 当前 APP 就是要打开的 APP 时找到当前 APP 的下一个窗口
      -- 获取 APP 的所有窗口（不含 toast、scrollarea 等窗体）
      local wins = hs.fnutils.filter(curApp:allWindows(), function(item)
        return item:role() == "AXWindow"
      end)
      print('#wins: ' .. #wins .. ' <-- ' .. string.match(path, '/([%w%s]+).app$'))
      for i,v in ipairs(curApp:allWindows()) do
        print(i, v:role(), v:title())
      end
      -- 只有一个窗口时直接返回（关闭所有窗口后程序并没有退出，所以写的是 <= 而不是 =，finder 有一个窗口是“桌面”）
      if #wins == 1 then
        return
      end
      -- 没有窗口（当前窗口全部关闭后程序并不退出）
      if #wins == 0 then
        hs.application.launchOrFocus(path)
      end
      -- 显示当前 APP 的下一个窗口
      local curWin = curApp:focusedWindow()
      table.sort(wins, function(x, y)
        return x:id() < y:id()
      end)
      wins[#wins + 1] = wins[1] -- 把第一个窗口追加到末尾，用于当前窗口是最后一个窗口时可以快速找到下一个窗口
      for k, v in ipairs(wins) do
        if v:id() == curWin:id() then
          wins[k + 1]:focus()
          return
        end
      end
    else -- 当前 APP 不是要打开的 APP 时直接切到 APP 不用切换 APP 的窗口
      hs.application.launchOrFocus(path)
    end
    -- Finder 比较特殊，可能 focus 不了，需要再来一下
    local appBundleID = hs.application.infoForBundlePath(path)['CFBundleIdentifier']
    if 'com.apple.finder' == appBundleID then
      hs.application.get(appBundleID):activate() -- 参数不能是 Finder 得是 访达，不过支持传 bundleID
    end
  end
end

-- 为常用工具绑定快捷键
hs.fnutils.each(
  apps,
  function(app)
    -- local message = string.match(app.path, '/([%w%s]+).app$') -- nil
    local message = nil
    local hyper = {'ctrl', 'alt', 'cmd'}
    if string.match(app.key, '[A-Z]') then
      table.insert(hyper, 'shift')
    end
    hs.hotkey.bind(
      hyper,
      app.key,
      message,
      -- function()
      --   hs.application.launchOrFocus(app.path)
      -- end
      launchOrFocusWindowByPath(app.path)
    )
  end
)

alertStyle = {
  strokeColor = {white = 1, alpha = 0.25 },
  radius   = 5,
  textFont = 'Monaco',
  textSize = 12,
  atScreenEdge = 0
}

-- 获得当前 APP 的信息
hs.hotkey.bind(
  {'ctrl', 'alt', 'cmd'},
  '.',
  function()
    local title = hs.application.frontmostApplication():title()
    local bundleID = hs.application.frontmostApplication():bundleID()
    local path = hs.application.frontmostApplication():path()
    local im = hs.keycodes.currentSourceID()
    hs.alert.closeAll()
    hs.alert.show(
      string.format('%s\n%s\n%s\n%s', title, bundleID, path, im),
      alertStyle
    )
    print('BundleID:', bundleID);
    print('    Path:', path);
  end
)

-- 显示可用快捷键清单
hs.hotkey.bind(
  {'ctrl', 'alt', 'cmd'},
  '/',
  function()
    hs.alert.closeAll();
    local info = ''
    for k, v in ipairs(apps) do
      local key = 'Caps-' .. v.key
      local val = string.match(v.path, '/([%w%s]+).app$')
      info = info .. key .. ' ' .. val .. '\n'
    end
    if hs.application.frontmostApplication():path() == '/System/Library/CoreServices/Finder.app' then
      info = info .. 'Caps-T Terminal Here\n'
    end
    info = info .. 'Caps-r F5' -- 最后一个加了 \n 会多一个空行
    hs.alert.show(
      info,
      alertStyle
    )
  end
)

-- End
