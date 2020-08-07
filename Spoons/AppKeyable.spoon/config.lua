-- DON'T EDIT !!!!
-- Default configurations
-- Usage:
--   hs.loadSpoon("AppKeyable")
--   spoon.AppKeyable.hyper = {'ctrl', 'alt', 'cmd'} -- NOT'T ADD SHIFT KEY
--   spoon.AppKeyable.applications = {{key = 's', path='/Applications/Skype.app'}}
--   spoon.AppKeyable.functions = {} -- Empty table to replace default
--   spoon.AppKeyable:start()

local module = {}

module.hyper = {'control', 'option', 'command'} -- 不要加 shift，shift 在使用“大写字母”、“需要按Shift才能输入的符号”时会自动补上
module.todoFile = '~/Documents/todo.txt' -- 这是默认值，所以此行可删除

module.applications = {
  {key = 'a', path = '/Applications/Affinity Photo.app'},
  {key = 'A', path = '/System/Applications/App Store.app'},
  {key = 'b', path = '/Applications/Bear.app'},
  {key = 'B', path = '/Applications/Blender.app'},
  {key = 'd', path = '/Applications/DBeaver.app'},
  {key = 'D', path = '/Applications/DingTalk.app'},
  {key = 'e', path = '/System/Library/CoreServices/Finder.app'},
  {key = 'f', path = '/Applications/Fork.app'},
  {key = 'F', path = '/Applications/Seafile Client.app'},
  {key = 'g', path = '/Applications/Google Chrome.app'},
  {key = 'j', path = '/Applications/PhpStorm.app'}, 
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
    name = 'F5',
    key = 'r'
    -- 需要在 Karabiner-Elements 里将 Control + Option + Command + r 映射到 F5 上，这里仅作提示
  }
}

return module
