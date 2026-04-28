local obj = {}
obj.__index = obj

function obj:init()
  -- 初始化，如果需要
end

function obj:start(password, url)
  self.password = password or 'default_password'
  self.url = url or 'https://textdb.dev/api/data/028e9d18-dddb-41e4-b28a-b4a6f39dfe30'

  -- 绑定热键
  self.copyHotkey = hs.hotkey.bind(
    {'shift'},
    'f9',
    function()
      local loading = hs.alert.show("copying", 'allways')
      hs.eventtap.keyStroke({ "cmd" }, "c")
      local text = hs.pasteboard.readString()
      local encrypted = self:crypt(text, self.password)
      if encrypted then
        text = encrypted
      end
      local headers = {
        ['Content-Type'] = 'text/plain',
      }
      local code, body, headers = hs.http.post(self.url, text, headers)
      hs.alert.closeSpecific(loading)
      hs.alert.show("saved:" .. body)
    end
  )

  self.pasteHotkey = hs.hotkey.bind(
    {'shift'},
    'f8',
    function()
      local loading = hs.alert.show("pasting", 'allways')
      local code, body, headers = hs.http.get(self.url)
      local decrypted = self:crypt(body, self.password, false)
      print('remote-pasteboard.body:\n' .. body)
      if decrypted then
        body = decrypted
      end
      hs.pasteboard.setContents(body)
      hs.eventtap.keyStroke({ "cmd" }, "v")
      hs.alert.closeSpecific(loading)
    end
  )
end

function obj:stop()
  if self.copyHotkey then
    self.copyHotkey:delete()
  end
  if self.pasteHotkey then
    self.pasteHotkey:delete()
  end
end

function obj:crypt(message, password, isEncrypt)
  if nil == message then
    message = ''
  end
  -- 1. 写入临时文件
  local tmpfile = os.tmpname()
  local f = io.open(tmpfile, "w")
  f:write(message)
  f:close()
  -- 2. 构造 openssl 命令
  local mode = isEncrypt == false and "-d" or "-e"
  local cmd = string.format(
      [[openssl enc -aes-256-cbc -a -md sha256 -pbkdf2 -iter 1000 -salt -pass pass:%s -in "%s" %s]],
      password, tmpfile, mode
  )
  -- 3. 执行命令
  local output, status, type, rc = hs.execute(cmd, true)
  if nil == status then
    local message = hs.styledtext.new(
      'Error: crypt failed. [code:' .. rc ..  ']',
      {
        color = hs.drawing.color.asRGB(
          {
            hex = '#FF0000',
            alpha = 1
          }
        ),
        font = {
          name = 'Monaco',
          size = 14
        }
      }
    )
    hs.alert.show(message);
  end
  -- 4. 删除临时文件
  os.remove(tmpfile)
  -- 5. 返回结果
  print('crypt.message: ' .. message)
  print('crypt.cmd: ' .. cmd)
  print('crypt.status: ' .. tostring(status))
  print('crypt.terminatedReason: ' .. type)
  print('crypt.exitCode: ' .. rc)
  print('crypt.output: ' .. output)
  return status and output or nil
end

return obj