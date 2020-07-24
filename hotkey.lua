--[[

  为 App 绑定打开或切换到的全局快捷键

  提醒：
    不要连续重复切换微信开发者工具，会导致它在 dock 里一直弹跳无法关闭，需要`sudo killall launchservicesd && sudo killall Dock`才能关掉
    需要使用 Karabiner-Elements.app 将 CapsLock 键改为组合按时变为 Ctrl + Option + Command

]]

-- 指定需要绑快捷键的 App
local apps = {
  {key = 'a', path = '/Applications/Affinity Photo.app'},
  {key = 'b', path = '/Applications/Bear.app'},
  {key = 'B', path = '/Applications/Blender.app'},
  {key = 'd', path = '/Applications/DBeaver.app'},
  {key = 'D', path = '/Applications/DingTalk.app'},
  {key = 'e', path = '/System/Library/CoreServices/Finder.app'},
  {key = 'f', path = '/Applications/Fork.app'},
  {key = 'g', path = '/Applications/Google Chrome.app'},
  {key = 'j', path = '/Applications/PhpStorm 2020.2 EAP.app'}, 
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
  {key = 'W', path = '/Applications/WeChat.app'},
  {key = 'w', path = '/Applications/wechatwebdevtools.app'},
  {key = 'x', path = '/Applications/Xcode.app'},
  {key = 'y', path = '/Applications/NeteaseMusic.app'}
}

local hyper = {'ctrl', 'alt', 'cmd'} -- 不要加 shift，shift 在使用“大写字母”、“需要按Shift才能输入的符号”时会自动补上
local todoFile = '~/Documents/todo.txt' -- 这是默认值，所以此行可删除

-- 帮助信息的样式
local alertStyle = {
  textColor = hs.drawing.color.asRGB({hex = '#FFFFFF', alpha = 1.00}), -- 文本色
  fillColor = hs.drawing.color.asRGB({hex = '#000000', alpha = 0.75}), -- 背景色
  strokeColor = hs.drawing.color.asRGB({hex = '#FFFFFF', alpha = 0.35}), -- 边框色
  radius   = 5, -- 边框圆角半径
  textFont = 'Monaco', -- 字体
  textSize = 12, -- 字号
  atScreenEdge = 0, -- 显示位置：0: screen center (default); 1: top edge; 2: bottom edge
  fadeInDuration = 0, -- 渐现耗时
  fadeOutDuration = 0.15 -- 渐隐耗时
}

--  打开/切换到App(可以在当前 APP 的窗口间切换)
local launchOrFocusWindowByPath = function(path)
  return function()
    hs.alert.closeAll();
    local curApp = hs.application.frontmostApplication()
    -- print(string.match(path, '/([%w%d%s.]+).app$') .. ' <-- ' .. string.match(curApp:path(), '/([%w%d%s.]+).app$'))
    if curApp:path() == path then -- 当前 APP 就是要打开的 APP 时找到当前 APP 的下一个窗口
      -- 获取 APP 的所有窗口（不含 toast、scrollarea 等窗体）
      local wins = hs.fnutils.filter(curApp:allWindows(), function(item)
        return item:role() == "AXWindow"
      end)
      --[[
      -- 调试用
      print('#wins: ' .. #wins .. ' <-- ' .. string.match(path, '/([%w%d%s.]+).app$'))
      for i,v in ipairs(curApp:allWindows()) do
        print(i, v:role(), v:title())
      end
      ]]
      -- 只有一个窗口时直接返回
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
      -- Finder 比较特殊，可能 focus 不了，需要再来一下，原因不详
      local appBundleID = hs.application.infoForBundlePath(path)['CFBundleIdentifier']
      if 'com.apple.finder' == appBundleID then
        local app = hs.application.get(appBundleID) -- 参数不能是 Finder 得是 访达，不过支持传 bundleID
        local wins = hs.fnutils.filter(app:allWindows(), function(item)
          return item:role() == "AXWindow"
        end)
        if #wins == 1 then -- 有时 Finder active 不了，得全部 active 才有效果
          app:activate(true)
        else -- 当窗口多时不想全 active ，也不知道在多个 window 时下边这行能不能解决不能 active 的问题
          app:activate()
        end
      end
    end
  end
end

-- 彩色化文本
local fillColor = function(string, color, alpha)
  if nil == string then
    string  = ''
  end
  if nil == color then
    color = '#FFFFFF'
  end
  if nil == alpha then
    alpha = 1
  end
  return hs.styledtext.new(string ,{
    color = hs.drawing.color.asRGB({hex = color, alpha = alpha}),
    font = {name = 'Monaco', size = 14}
  })
end

-- 指定需要绑定快捷键的功能
local funs = {
  -- {
  --   name = 'MoveTo Right Desktop',
  --   key = 'right',
  --   fun = function()
  --     if hs.window.focusedWindow() then
  --       hs.window.focusedWindow():focusWindowEast()
  --     end
  --   end
  -- },
  -- {
  --   name = 'MoveTo Left Desktop',
  --   key = 'left',
  --   fun = function()
  --     if hs.window.focusedWindow() then
  --       hs.window.focusedWindow():focusWindowWest()
  --     end
  --   end
  -- },
  {
    -- 获得当前 APP 的信息
    name = 'AppInfo',
    key = '.',
    fun =   function()
      local title = hs.application.frontmostApplication():title()
      local bundleID = hs.application.frontmostApplication():bundleID()
      local path = hs.application.frontmostApplication():path()
      local im = hs.keycodes.currentSourceID()
      local content = fillColor('    Name ', '#666666') .. fillColor(title, '#FFFFFF') .. '\n'
      content = content .. fillColor('BundleID ', '#666666') .. fillColor(bundleID, '#FFFFFF') .. '\n'
      content = content .. fillColor('    Path ', '#666666') .. fillColor(path, '#FFFFFF') .. '\n'
      content = content .. fillColor('      IM ', '#666666') .. fillColor(im, '#FFFFFF')
      hs.alert.closeAll()
      hs.alert.show(
        content,
        alertStyle
      )
      hs.pasteboard.setContents(string.format('%s\n%s\n%s\n%s\n', title, bundleID, path, im)); -- 复制到剪贴板
      print('BundleID:', bundleID);
      print('    Path:', path);
    end
  },
  {
    -- todo form
    name = 'Todo Form',
    key = "'",
    fun = function()
      hs.alert.closeAll();
      hs.focus()
      local file = nil ~= todoFile and todoFile or '~/Documents/todo.txt'
      local confirm, content = hs.dialog.textPrompt('请输入需要记录的内容', 'File: ' .. file, '', '保存', '取消')
      print(confirm, content);
      if ('保存' == confirm and '' ~= content) then
        local script = string.format([[
          do shell script "echo $(date) - %s >> %s"
        ]], content, file)
        print(script)
        local rs = hs.osascript.applescript(script)
        if rs == true then
          hs.alert.show(fillColor('已记录 ', '#4caf50') .. fillColor(content, '#FFFFFF'))
        else
          -- 保存失败时存入剪贴板并在控制台输出
          hs.pasteboard.setContents(content);
          hs.alert.show(fillColor('记录失败，已存入剪贴板 ', '#f44336') .. fillColor(content, '#FFFFFF'))
          print('save todo fail:', content)
        end
      end
    end
  },
  {
    name = 'Todo List',
    key = '"',
    fun = function()
      hs.alert.closeAll();
      hs.focus()
      local file = nil ~= todoFile and todoFile or '~/Documents/todo.txt'
      local script = string.format([[
        do shell script "qlmanage -p %s"
      ]], file)
      print(script)
      hs.osascript.applescript(script)
    end
  },
  {
    name = 'F5',
    key = 'r'
  },
  {
    name = 'Help',
    key = '/'
  }
}

function table.filter(t, fn)
    local n = {}
    for k, v in pairs(t) do
        local item = fn(v, k, t)
        if item then
            table.insert(n, v)
        end
    end
    return n
end

function table.map(t, fn)
    local n = {}
    for k, v in pairs(t) do
        local item = fn(v, k, t)
        table.insert(n, item)
    end
    return n
end

local hyper = table.filter(hyper, function(v) return v ~= 'shift' end) -- 排除 shift

-- 为 apps 和 funs 绑定快捷键的方法
local bindHotkey = function(app)
  local hyper = table.map(hyper, function(v) return v end) -- clone
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
  -- message = nil ~= app.path and string.match(app.path, '/([%w%d%s.]+).app$') or nil
  if app.key ~= key then
    table.insert(hyper, 'shift')
  end
  
  if nil ~= app.fun or nil ~= app.path then
    hs.hotkey.bind(
      hyper,
      key,
      message,
      app.fun or launchOrFocusWindowByPath(app.path)
    )
  end
end

-- 为常用工具绑定快捷键
hs.fnutils.each(
  apps,
  function(app)
    bindHotkey(app)
  end
)

-- 为功能绑定快捷键
hs.fnutils.each(
  funs,
  function(fun)
    bindHotkey(fun)
  end
)

-- 显示帮助
hs.hotkey.bind(
  hyper,
  '/',
  function()
    hs.alert.closeAll();
    local info = fillColor('', '#FFFFFF') -- 开头必须是 hs.styledText ，不能是纯文本否则 hs.alert 的颜色不生效
    local capsLockSymbol = 'caps' -- '⇪'

    -- 合并 apps 和 funs
    local actions = {}
    for _, v in ipairs(apps) do
      table.insert(actions, v)
    end
    for _, v in ipairs(funs) do
      table.insert(actions, v)
    end

    -- terminal here 功能：系统偏好设置 > 键盘 > 快捷键 > 服务 > 新键位于文件夹位置的终端标签页，打勾并添加快捷键“⌃⌥⇧⌘T”
    if hs.application.frontmostApplication():path() == '/System/Library/CoreServices/Finder.app' then
      table.insert(actions, {
        name = 'Terminal Here',
        key = 'T'
      })
    end

    table.sort(actions, function(e1, e2)
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
    end)

    -- 多列显示
    local cols = 2
    local appNameMaxLen = 0
    for _, v in ipairs(actions) do
      local appName = nil ~= v.name and v.name or string.match(v.path, '/([%w%d%s.]+).app$')
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
    for i=1,totalRow,1 do
      local row = fillColor('', '#FFFFFF')
      for j=0,cols-1,1 do
        local v = actions[i + j * totalRow]
        if nil == v then
          break
        end
        local key = capsLockSymbol .. '-' .. keyName2KeySymbol(v.key)
        local val = nil ~= v.name and v.name or string.match(v.path, '/([%w%d%s.]+).app$')
        local item = fillColor(key .. ' ', '#666666') .. fillColor(val, '#FFFFFF')
        local itemLen = #(capsLockSymbol .. '-? ') + #val --  不使用 #item 是因为“←”等的长度不是1，可能是2、3（取决于字符的 utf8 长度），会导致对不齐
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

    hs.alert.show(
      info,
      alertStyle
    )
  end
)

-- End
