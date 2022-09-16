-- DON'T EDIT !!!!
-- Default configurations
-- Usage:
--   hs.loadSpoon("AppKeyable")
--   spoon.AppKeyable.config.hyper = {'ctrl', 'alt', 'cmd'} -- NOT'T ADD SHIFT KEY
--   spoon.AppKeyable.config.applications = {{key = 's', path='/Applications/Skype.app'}}
--   spoon.AppKeyable.config.functions = {} -- Empty table to replace default
--   spoon.AppKeyable:start()

local module = {}

module.hyper = {'control', 'option', 'command'} -- 不要加 shift，shift 在使用“大写字母”、“需要按Shift才能输入的符号”时会自动补上
module.todoFile = '~/Documents/todo.txt' -- 这是默认值，所以此行可删除
-- lnu
module.applications = {
  {key = 'a', color = '#FFFFFF', path = '/System/Applications/App Store.app'},
  {key = 'b', color = '#FFFFFF', path = '/System/Applications/Books.app'},
  {key = 'c', color = '#FFFFFF', path = '/Applications/Google Chrome.app'},
  {key = 'C', color = '#FFFFFF', path = '/System/Applications/Contacts.app'},
  {key = 'e', color = '#FFFFFF', path = '/System/Applications/TextEdit.app'}, -- Editor
  {key = 'f', color = '#FFFFFF', path = '/System/Library/CoreServices/Finder.app'},
  {key = 'F', color = '#FFFFFF', path = '/System/Applications/FaceTime.app'},
  {key = 'k', color = '#FFFFFF', path = '/System/Applications/Utilities/Activity Monitor.app'},
  {key = 'm', color = '#FFFFFF', path = '/System/Applications/Messages.app'},
  {key = 's', color = '#FFFFFF', path = '/System/Applications/System Preferences.app'},
  {key = 't', color = '#FFFFFF', path = '/System/Applications/Utilities/Terminal.app'},
}

module.functions = {
  {
    -- 获得当前 APP 的信息
    name = 'AppInfo',
    key = '.',
    fun =   function()
      local title = hs.application.frontmostApplication():title()
      local bundleID = hs.application.frontmostApplication():bundleID()
      local path = hs.application.frontmostApplication():path()
      local im = hs.keycodes.currentSourceID()
      local fillColor = function(string, color, alpha)
        return hs.styledtext.new(string ,{
          color = hs.drawing.color.asRGB({hex = color, alpha = 1}),
          font = {name = 'Monaco', size = 14}
        })
      end
      local content = fillColor('', '#666666')
      content = content .. fillColor('    Name ', '#666666') .. fillColor(title, '#FFFFFF') .. '\n'
      content = content .. fillColor('BundleID ', '#666666') .. fillColor(bundleID, '#FFFFFF') .. '\n'
      content = content .. fillColor('    Path ', '#666666') .. fillColor(path, '#FFFFFF') .. '\n'
      content = content .. fillColor('      IM ', '#666666') .. fillColor(im, '#FFFFFF')
      hs.alert.closeAll()
      hs.alert.show(
        content,
        alertStyle
      )
      -- hs.pasteboard.setContents(string.format('%s\n%s\n%s\n%s\n', title, bundleID, path, im)); -- 复制到剪贴板
      hs.pasteboard.setContents(path); -- 复制到剪贴板
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
      local file = nil ~= module.todoFile and module.todoFile or '~/Documents/todo.txt'
      local confirm, content = hs.dialog.textPrompt('请输入需要记录的内容', 'File: ' .. file, '', '保存', '取消')
      print(confirm, content);
      if ('保存' == confirm and '' ~= content) then
        local script = string.format([[
          do shell script "echo $(date) - %s >> %s"
        ]], content, file)
        print(script)
        local rs = hs.osascript.applescript(script)
        if rs == true then
          hs.alert.show('已记录 ' .. content)
        else
          -- 保存失败时存入剪贴板并在控制台输出
          hs.pasteboard.setContents(content);
          hs.alert.show('记录失败，已存入剪贴板 ' .. content)
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
      local file = nil ~= module.todoFile and module.todoFile or '~/Documents/todo.txt'
      local script = string.format([[
        do shell script "qlmanage -p %s"
      ]], file)
      print(script)
      hs.osascript.applescript(script)
    end
  },
  {
    name = 'Lock Screen',
    key = 'l',
    fun = function()
      -- 方法1：进入睡眠模式（黑屏，需要设置为恢复时输入密码）
      -- local script = 'do shell script "pmset displaysleepnow"'

      -- 方法2：启动屏保（需要设置为恢复时输入密码）
      local script = [[
        tell application "System Events" 
          start current screen saver
        end tell
      ]]
      hs.osascript.applescript(script)
    end
  }
}

return module
