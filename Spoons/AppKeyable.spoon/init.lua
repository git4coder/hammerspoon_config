--- === AppKeyable ===
---
--- You can use the shortcut key to switch to the specified app, or switch between the windows of the current app.
local obj = {
  name = 'AppKeyable',
  version = '1.0',
  author = 'Mr.User <root@upall.net>',
  homepage = 'https://github.com/git4coder/hammerspoon_config/tree/master/Spoons/AppKeyable.spoon',
  license = 'MIT - https://opensource.org/licenses/MIT'
}

local _config = {}

--- AppKeyable.hyper
--- Variable
--- hyper key
---
--- Do not use the shift key. The shift key will be added automatically when the upper case letter is specified.
---
--- Expmple:
---  `{'ctrl', 'option', 'cmd'}`
_config.hyper = nil

--- AppKeyable.applications
--- Variable
--- applications table
---
--- Expmple:
---  `{{key = 'a', path = '/Applications/Affinity Photo.app'},{key = 'A', path = '/Applications/Blender.app'}}`
_config.applications = nil

--- AppKeyable.functions
--- Variable
--- functions table
---
--- Expmple:
---  `{{key = 'c', name = 'Show Hello', fun = function() hs.alert('hello') end},{key = 'C', name = 'Show World', fun = function() hs.alert('world') end}}
_config.functions = nil

-- obj.config = {applications = nil}
obj.config = dofile(hs.spoons.scriptPath() .. 'config.lua') or {}
obj.__index = obj

-- 帮助信息的样式
local alertStyle = {
  textColor = hs.drawing.color.asRGB(
    {
      hex = '#FFFFFF',
      alpha = 1.00
    }
  ), -- 文本色
  fillColor = hs.drawing.color.asRGB(
    {
      hex = '#000000',
      alpha = 0.90
    }
  ), -- 背景色
  strokeColor = hs.drawing.color.asRGB(
    {
      hex = '#FFFFFF',
      alpha = 0.45
    }
  ), -- 边框色
  radius = 5, -- 边框圆角半径
  textFont = 'Monaco', -- 字体
  textSize = 12, -- 字号
  atScreenEdge = 0, -- 显示位置：0: screen center (default); 1: top edge; 2: bottom edge
  fadeInDuration = 0, -- 渐现耗时
  fadeOutDuration = 0.5 -- 渐隐耗时
}

-- 彩色化文本
local fillColor = function(string, color, alpha)
  if nil == string then
    string = ''
  end
  if nil == color then
    color = '#FFFFFF'
  end
  if nil == alpha then
    alpha = 1
  end
  return hs.styledtext.new(
    string,
    {
      color = hs.drawing.color.asRGB(
        {
          hex = color,
          alpha = alpha
        }
      ),
      font = {
        name = 'Monaco',
        size = 14
      }
    }
  )
end

--  打开/切换到App(可以在当前 APP 的窗口间切换)
local launchOrFocusWindowByPath = function(path)
  return function()
    -- 切换时添加提醒信息（hs.hotkey.bind 的 message 去不掉按键提示）
    hs.alert.closeAll()
    local message = string.match(path, '/([^/]-).app$')
    local key = 'SwitchTo'
    local alertStyle = hs.fnutils.copy(alertStyle)
    alertStyle['fadeInDuration'] = 0.2 -- 渐现耗时
    alertStyle['fadeOutDuration'] = 0.5 -- 渐隐耗时
    for i, v in pairs(obj.config.applications) do
      if v.path == path then
        key = 'caps-' .. v.key
        break
      end
    end
    message = fillColor(key .. ': ', '#666666') .. fillColor(message, '#FFFFFF')
    hs.alert.show(message, alertStyle, hs.screen.mainScreen(), 0.5)

    local curApp = hs.application.frontmostApplication()
    -- print(string.match(path, '/([^/]-).app$') .. ' <-- ' .. string.match(curApp:path(), '/([^/]-).app$'))
    if curApp:path() == path then -- 当前 APP 就是要打开的 APP 时找到当前 APP 的下一个窗口
      -- 获取 APP 的所有窗口（不含 toast、scrollarea 等窗体）
      local wins =
        hs.fnutils.filter(
        curApp:allWindows(),
        function(item)
          return item:role() == 'AXWindow'
        end
      )
      --[[
        -- 调试用
        print('#wins: ' .. #wins .. ' <-- ' .. string.match(path, '/([^/]-).app$'))
        for i,v in ipairs(curApp:allWindows()) do
          print(i, v:role(), v:title())
        end
        ]]
      -- 只有一个窗口时直接返回
      if #wins == 1 then
        for _,v in ipairs(wins) do
          if true ==  v:isMinimized() then
            v:unminimize()
          end
        end
        return
      end
      -- 没有窗口（当前窗口全部关闭后程序并不退出）
      if #wins == 0 then
        hs.application.launchOrFocus(path)
      end
      -- 显示当前 APP 的下一个窗口
      local curWin = curApp:focusedWindow()
      table.sort(
        wins,
        function(x, y)
          return x:id() < y:id()
        end
      )
      wins[#wins + 1] = wins[1] -- 把第一个窗口追加到末尾，用于当前窗口是最后一个窗口时可以快速找到下一个窗口
      -- 把第一个窗口追加到末尾，用于当前窗口是最后一个窗口时可以快速找到下一个窗口
      for k, v in ipairs(wins) do
        if v:id() == curWin:id() then
          if true ==  wins[k + 1]:isMinimized() then
            wins[k + 1]:unminimize()
          end
          wins[k + 1]:focus()
          return
        end
      end
      wins = nil
    else -- 当前 APP 不是要打开的 APP 时直接切到 APP 不用切换 APP 的窗口
      hs.application.launchOrFocus(path)
      -- Finder 比较特殊，可能 focus 不了，需要再来一下，原因不详
      local appBundleID = hs.application.infoForBundlePath(path)['CFBundleIdentifier']
      if 'com.apple.finder' == appBundleID then
        local app = hs.application.get(appBundleID) -- 参数不能是 Finder 得是 访达，不过支持传 bundleID
        local wins =
          hs.fnutils.filter(
          app:allWindows(),
          function(item)
            return item:role() == 'AXWindow'
          end
        )
        if #wins == 1 then -- 有时 Finder active 不了，得全部 active 才有效果
          app:activate(true)
        else -- 当窗口多时不想全 active ，也不知道在多个 window 时下边这行能不能解决不能 active 的问题
          app:activate()
        end
        wins = nil
      end
    end
    curApp = nil
    alertStyle = nil
  end
end

-- 为 applications 和 functions 绑定快捷键的方法
local bindHotkey = function(app)
  -- in case called as function
  if self ~= obj then self = obj end

  local hyper = hs.fnutils.copy(obj.config.hyper) -- clone
  -- 找到需要按shift才能打出的符号字母所在的键
  local getOriginKey = function(key)
    local origin = key
    -- 需要按 Shift 才能输出的按键
    local shiftKeys = {
      ['~'] = '`',
      ['!'] = '1',
      ['@'] = '2',
      ['#'] = '3',
      ['$'] = '4',
      ['%'] = '5',
      ['^'] = '6',
      ['&'] = '7',
      ['*'] = '8',
      ['('] = '9',
      [')'] = '0',
      ['_'] = '-',
      ['+'] = '=',
      [':'] = ';',
      ['"'] = "'",
      ['<'] = ',',
      ['>'] = '.',
      ['?'] = '/',
      ['{'] = '[',
      ['}'] = ']',
      ['|'] = '\\'
    }
    -- 检查标点符号
    origin = shiftKeys[key] or origin
    -- 检查字母
    origin = nil ~= string.match(key, '[A-Z]') and string.lower(key) or origin
    return origin
  end
  local key = getOriginKey(app.key) -- 找到大写对应的小写按键、“上档符号”所在的按键（比如“E“在键“e”上、“#”的键是“3”、“?”的键在“/”上）
  local message = nil
  -- message = nil ~= app.path and string.match(app.path, '/([^/]-).app$') or nil
  if app.key ~= key then
    table.insert(hyper, 'shift')
  end

  if nil ~= app.fun or nil ~= app.path then
    local bound = hs.hotkey.bind(hyper, key, message, app.fun or launchOrFocusWindowByPath(app.path))
    table.insert(self.boundHotkey, bound)
  end
end

function obj:init()
  for i, v in pairs(_config) do -- ipairs 在遇到第一个 nil 就终止了，nil 会自动跳过
    -- print('merge config:', i, v)
    self.config[i] = v
  end
  _config = nil
  self.boundHotkey = {} -- 已经绑好的快捷键，用于 release hotkey
  return self
end

function obj:start()
  local hyper = hs.fnutils.filter(
    self.config.hyper,
    function(v)
      return string.lower(v) ~= 'shift'
    end
  ) -- 排除 shift
  -- 为常用工具绑定快捷键
  hs.fnutils.each(
    self.config.applications,
    function(app)
      bindHotkey(app)
    end
  )

  -- 为功能绑定快捷键
  hs.fnutils.each(
    self.config.functions,
    function(fun)
      bindHotkey(fun)
    end
  )

  -- 显示帮助
  local bound = hs.hotkey.bind(
    hyper,
    '/',
    function()
      hs.alert.closeAll()
      local info = fillColor('', '#FFFFFF') -- 开头必须是 hs.styledText ，不能是纯文本否则 hs.alert 的颜色不生效
      local capsLockSymbol = 'caps' -- '⇪'

      -- 合并 applications 和 functions
      local actions = {}
      for _, v in ipairs(self.config.applications) do
        table.insert(actions, v)
      end
      for _, v in ipairs(self.config.functions) do
        table.insert(actions, v)
      end

      table.insert(
        actions,
        {
          name = 'Help',
          key = '/'
        }
      )

      table.sort(
        actions,
        function(e1, e2)
          local e1Key = string.byte(string.upper(e1.key)) -- ascii
          local e2Key = string.byte(string.upper(e2.key))
          -- 先排字母，后排符号，字母前的符号都移到后边
          if e1Key < 65 then
            e1Key = e1Key + 128
          end
          if e2Key < 65 then
            e2Key = e2Key + 128
          end
          return e1Key < e2Key
        end
      )

      -- 多列显示
      local cols = 2
      local appNameMaxLen = 0
      for _, v in ipairs(actions) do
        local appName = nil ~= v.name and v.name or string.match(v.path, '/([^/]-).app$')
        appNameMaxLen = #appName > appNameMaxLen and #appName or appNameMaxLen
      end
      local colWidth = #(capsLockSymbol .. '-? ') + appNameMaxLen
      if cols <= 0 then
        cols = 1
      end

      -- 把单词表示的按键转为单个符号（防止显示时错位）
      local keyName2KeySymbol = function(name)
        local data = {
          left = '←',
          right = '→',
          up = '↑',
          down = '↓'
        }
        return data[name] or name
      end

      -- actions 竖排
      local totalRow = math.ceil(#actions / cols) -- 0-4,5-9,10-13 size*(p-1)
      for i = 1, totalRow, 1 do
        local row = fillColor('', '#FFFFFF')
        for j = 0, cols - 1, 1 do
          local v = actions[i + j * totalRow]
          if nil == v then
            break
          end
          local key = capsLockSymbol .. '-' .. keyName2KeySymbol(v.key)
          local val = nil ~= v.name and v.name or string.match(v.path, '/([^/]-).app$')
          local color = v.color or '#FFFFFF'
          local item = fillColor(key .. ' ', '#666666') .. fillColor(val, color)
          local itemLen = #(capsLockSymbol .. '-? ') + #val --  不使用 #item 是因为“←”等的长度不是1，可能是2、3（取决于字符的 utf8 长度），会导致对不齐
          -- paddingLeft
          local colPrefix = fillColor(' ', '#666666')
          item = colPrefix .. item
          itemLen = #colPrefix + itemLen
          -- 每项宽度一样才能对齐列
          if (itemLen < colWidth) then
            item = item .. string.rep(' ', colWidth - itemLen)
          end
          -- 列加间距
          if j ~= cols - 1 then
            item = item .. '  '
          end
          -- 合并列为行
          row = row .. item
        end
        info = info .. row
        -- 不是最后一页的话加个换行
        if (i ~= totalRow) then
          info = info .. '\n'
        end
      end

      local displaySeconds = 1 -- 展示时长
      hs.alert.show(info, alertStyle, hs.screen.mainScreen(), displaySeconds)
    end
  )
  table.insert(self.boundHotkey, bound)
end

function obj:stop()
  for _, v in pairs(self.boundHotkey) do
    v:delete()
  end
end

return obj
