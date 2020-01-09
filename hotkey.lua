-- 打开项目所在文件夹(用了 finder 的设置项“开启新 Finder 时打开：”，这里不要了)
-- hs.hotkey.bind({'cmd'}, 'e',
--   function()
--     hs.execute('open ~/Projects')
--   end
-- )

-- 打开常用工具
apps = {
  {key = 'e', app = '/System/Library/CoreServices/Finder.app'},
  {key = 't', app = '/System/Applications/Utilities/Terminal.app'},
  {key = 'a', app = '/Applications/Affinity Photo.app'},
  {key = 'b', app = '/Applications/Bear.app'},
  {key = 'd', app = '/Applications/DBeaver.app'},
  {key = 'f', app = '/Applications/Fork.app'},
  {key = 'g', app = '/Applications/Google Chrome.app'},
  {key = 'm', app = '/System/Applications/Utilities/Activity Monitor.app'},
  {key = 'o', app = '/Applications/wpsoffice.app'},
  {key = 'q', app = '/Applications/QQ.app'},
  {key = 's', app = '/System/Applications/System Preferences.app'},
  {key = 'v', app = '/Applications/Visual Studio Code.app'},
  {key = 'w', app = '/Applications/wechatwebdevtools.app'},
  {key = 'x', app = '/Applications/Xcode.app'}
}

--  打开/切换到App(可以在当前 APP 的窗口间切换)
local launchOrFocusWindowByPath = function(path)
  local toApp  = hs.application.infoForBundlePath(path)
  return function()
    local curApp = hs.application.frontmostApplication()
    if curApp:path() == path then -- 当前 APP 就是要打开的 APP 时找到当前 APP 的下一个窗口
      -- APP 的所有窗口（不含 toast、scrollarea 等窗体）
      local wins = hs.fnutils.filter(curApp:allWindows(), function(item)
        return item:role() == "AXWindow"
      end)
      -- APP 没有窗口或只有一个窗口时直接返回（关闭所有窗口后程序并没有退出，所以写的是 <= 而不是 =，finder 有一个窗口是“桌面”）
      if #wins <= 1 then
        return
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
  end
end

-- 为常用工具绑定快捷键
hs.fnutils.each(
  apps,
  function(entry)
    hs.hotkey.bind(
      {'ctrl', 'alt', 'cmd'},
      entry.key,
      nil,
      -- string.match(entry.app, '/([%w%s]+).app$'),
      -- function()
      --   hs.application.launchOrFocus(entry.app)
      -- end
      launchOrFocusWindowByPath(entry.app)
    )
  end
)

alertStyle = {
  strokeColor = {white = 1, alpha = 0.25 },
  radius   = 5,
  textFont = 'Monaco',
  textSize = 16,
  atScreenEdge = 0
}

-- 获得当前 APP 的信息
hs.hotkey.bind(
  {'ctrl', 'alt', 'cmd'},
  '.',
  function()
    hs.alert.closeAll()
    hs.alert.show(
      string.format(
        '%s\n%s\n%s\n%sj',
        hs.window.focusedWindow():application():title(),
        hs.application.frontmostApplication():bundleID(),
        hs.window.focusedWindow():application():path(),
        hs.keycodes.currentSourceID()
      ),
      alertStyle
    )
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
      info = info .. 'Caps-' .. v.key .. ' ' .. string.match(v.app, '/([%w%s]+).app$') .. '\n'
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
