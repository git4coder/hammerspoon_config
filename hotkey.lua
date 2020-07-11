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

local todoFile = '~/Documents/todo.txt' -- 这是默认值，所以此行可删除

alertStyle = {
  strokeColor = {white = 1, alpha = 0.25 },
  radius   = 5,
  textFont = 'Monaco',
  textSize = 12,
  atScreenEdge = 0
}

-- 显示可用快捷键清单
local shiftKeys = {
  [':'] = ';',
  ['"'] = "'",
  ['<'] = ',',
  ['>'] = '.',
  ['?'] = '/',
  ['{'] = '[',
  ['}'] = ']',
  ['|'] = '\\'
}

--  打开/切换到App(可以在当前 APP 的窗口间切换)
local launchOrFocusWindowByPath = function(path)
  local toApp  = hs.application.infoForBundlePath(path)
  return function()
    hs.alert.closeAll();
    local curApp = hs.application.frontmostApplication()
    print(string.match(path, '/([%w%d%s.]+).app$') .. ' <-- ' .. string.match(curApp:path(), '/([%w%d%s.]+).app$'))
    if curApp:path() == path then -- 当前 APP 就是要打开的 APP 时找到当前 APP 的下一个窗口
      -- 获取 APP 的所有窗口（不含 toast、scrollarea 等窗体）
      local wins = hs.fnutils.filter(curApp:allWindows(), function(item)
        return item:role() == "AXWindow"
      end)
      print('#wins: ' .. #wins .. ' <-- ' .. string.match(path, '/([%w%d%s.]+).app$'))
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
    color = hs.drawing.color.asRGB({hex = color, alpha = 1}),
    font = {name = 'Monaco', size = 14}
  })
end

-- 找到需要按shift才能打出的符号所在的键
local originKey = function(key)
  local origin = key
  for k, v in pairs(shiftKeys) do
    if k == key then
      origin = v
      break
    end
  end
  return origin
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

funs = {
  {
    -- 获得当前 APP 的信息
    name = 'Get BundleID',
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
      hs.pasteboard.setContents(string.format('%s\n%s\n%s\n%s\n', title, bundleID, path, im));
      print('BundleID:', bundleID);
      print('    Path:', path);
    end
  },
  {
    -- TodoList
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
  }
}

-- 为功能绑定快捷键
hs.fnutils.each(
  funs,
  function(fun)
    local message = nil
    local hyper = {'ctrl', 'alt', 'cmd'}
    local useShift = false
    local key = originKey(fun.key)
    if fun.key ~= key then
      useShift = true
    end
    if useShift then
      table.insert(hyper, 'shift')
    end
    hs.hotkey.bind(
      hyper,
      key,
      message,
      fun.fun
    )
  end
)

hs.hotkey.bind(
  {'ctrl', 'alt', 'cmd'},
  '/',
  function()
    hs.alert.closeAll();
    local info = fillColor('', '#FFFFFF') -- 开头必须是 hs.styledText ，不能是纯文本否则 hs.alert 的颜色不生效

    -- 合并 apps 和 funs
    local actions = {}
    for _, v in ipairs(apps) do
      table.insert(actions, v)
    end
    for _, v in ipairs(funs) do
      table.insert(actions, v)
    end

    -- terminal here 功能在系统偏好的快捷方式里添加的，这里只提示下具体的按键
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
    local colWidth = #'caps-? ' + appNameMaxLen
    if cols <= 0 then
      cols = 1
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
        local key = 'caps-' .. v.key
        local val = nil ~= v.name and v.name or string.match(v.path, '/([%w%d%s.]+).app$')
        local item = fillColor(key .. ' ', '#666666') .. fillColor(val, '#FFFFFF')
        if (#item < colWidth) then
          item = item .. string.rep(' ', colWidth - #item)
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

    --[[
    -- apps 横排
    for k, v in ipairs(apps) do
      local key = 'caps-' .. v.key
      local val = string.match(v.path, '/([%w%d%s.]+).app$')
      local item = fillColor(key .. ' ', '#666666') .. fillColor(val, '#FFFFFF')
      if (k % cols == 0) then
        item = item .. '\n'
      else
        if (#item < colWidth) then
          item = item .. string.rep(' ', colWidth - #item)
        end
        item = item .. '  '
      end
      info = info .. item
    end
    ]]

    -- funs 
    -- (不常用，顺序不好控制，不展示这个了)
    -- for k, v in pairs(funs) do
    --   local key = v.useShift and shiftKeys[v.key] or v.key
    --   local shortcut = 'caps-' .. key
    --   info = info .. shortcut .. ' ' .. v.name .. '\n'
    -- end
    -- info = info .. 'caps-r F5' -- 最后一个加了 \n 会多一个空行

    hs.alert.show(
      info,
      alertStyle
    )
  end
)

-- End
