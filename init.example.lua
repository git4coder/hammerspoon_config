-- 给APP绑定独立的激活键
hs.loadSpoon('AppKeyable')
spoon.AppKeyable.config.applications = {
  {key = 'A', color = '#FFFFFF', path = '/System/Applications/App Store.app'},
  {key = 'B', color = '#FFFFFF', path = '/System/Applications/Books.app'},
  {key = 'c', color = '#FFFFFF', path = '/Applications/Google Chrome.app'},
  {key = 'C', color = '#FFFFFF', path = '/System/Applications/Contacts.app'},
  {key = 'd', color = '#FFFFFF', path = '/Applications/DBeaver.app'},
  {key = 'E', color = '#FFFFFF', path = '/System/Applications/TextEdit.app'}, -- Editor
  {key = 'e', color = '#03a9f4', path = '/Applications/Typora.app'},
  {key = 'f', color = '#FFFFFF', path = '/System/Library/CoreServices/Finder.app'},
  {key = 'F', color = '#FFFFFF', path = '/System/Applications/FaceTime.app'},
  {key = 'g', color = '#FFFFFF', path = '/Applications/Fork.app'}, -- Git fork
  {key = 'G', color = '#FFFFFF', path = '/Applications/WeWork.app'},
  {key = 'j', color = '#FFFFFF', path = '/Applications/IntelliJ IDEA CE.app'},
  {key = 'K', color = '#FFFFFF', path = '/System/Applications/Utilities/Activity Monitor.app'},
  {key = 'm', color = '#FFFFFF', path = '/System/Applications/Messages.app'},
  {key = 'q', color = '#FFFFFF', path = '/Applications/QQ.app'},
  {key = 's', color = '#FFFFFF', path = '/Applications/Safari.app'},
  {key = 'S', color = '#FFFFFF', path = '/System/Applications/System Settings.app'},
  {key = 't', color = '#FFFFFF', path = '/System/Applications/Utilities/Terminal.app'},
  {key = 'v', color = '#03a9f4', path = '/Applications/Visual Studio Code.app'},
}
spoon.AppKeyable:start()
