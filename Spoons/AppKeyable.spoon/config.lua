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
  {key = 'a', color = '#FFFFFF', path = '/Applications/Android Studio.app'},
  {key = 'A', color = '#FFFFFF', path = '/System/Applications/App Store.app'},
  {key = 'b', color = '#FFFFFF', path = '/Applications/Blender.app'},
  {key = 'd', color = '#FFFFFF', path = '/Applications/DBeaver.app'},
  {key = 'D', color = '#FFFFFF', path = '/Applications/NeteaseDictionary.app'},
  {key = 'e', color = '#FFFFFF', path = '/System/Library/CoreServices/Finder.app'},
  {key = 'E', color = '#FFFFFF', path = '/System/Applications/TextEdit.app'},
  {key = 'f', color = '#FFFFFF', path = '/Applications/Fork.app'},
  {key = 'F', color = '#FFFFFF', path = '/Applications/Seafile Client.app'},
  {key = 'g', color = '#FFFFFF', path = '/Applications/Google Chrome.app'},
  {key = 'i', color = '#FFFFFF', path = '/Applications/DingTalk.app'},
  {key = 'j', color = '#03a9f4', path = '/Applications/PhpStorm.app'}, 
  {key = 't', color = '#FFFFFF', path = '/System/Applications/Utilities/Terminal.app'},
  {key = 'o', color = '#FFFFFF', path = '/Applications/wpsoffice.app'},
  {key = 'm', color = '#FFFFFF', path = '/Applications/Motrix.app'},
  {key = 'M', color = '#FFFFFF', path = '/System/Applications/Utilities/Activity Monitor.app'},
  {key = 'p', color = '#FFFFFF', path = '/Applications/Postman.app'},
  {key = 'P', color = '#FFFFFF', path = '/Applications/Affinity Photo.app'},
  {key = 'q', color = '#FFFFFF', path = '/Applications/QQ.app'},
  {key = 'r', color = '#FFFFFF', path = '/Applications/Microsoft Remote Desktop.app'},
  {key = 's', color = '#FFFFFF', path = '/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app'},
  {key = 'S', color = '#FFFFFF', path = '/System/Applications/System Preferences.app'},
  {key = 'v', color = '#FFFFFF', path = '/Applications/Visual Studio Code.app'},
  {key = 'V', color = '#FFFFFF', path = '/Applications/VirtualBox.app/Contents/Resources/VirtualBoxVM.app'},
  {key = 'W', color = '#FFFFFF', path = '/Applications/WeChat.app'},
  {key = 'w', color = '#FFFFFF', path = '/Applications/wechatwebdevtools.app'},
  {key = 'x', color = '#FFFFFF', path = '/Applications/Xcode.app'},
  {key = 'y', color = '#FFFFFF', path = '/Applications/NeteaseMusic.app'}
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
  }
}

return module
