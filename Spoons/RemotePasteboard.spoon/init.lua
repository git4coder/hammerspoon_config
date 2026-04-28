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
      local contents = hs.pasteboard.getContents()
      local text
      local types = hs.pasteboard.contentTypes()
      if hs.fnutils.contains(types, "public.file-url") then
        print("剪贴板数据类型：文件", contents)
        local function decodeURL(url)
          return url and url:gsub('%%(%x%x)', function(hex) return string.char(tonumber(hex, 16)) end)
        end
        local filePaths = {}
        local urls = hs.pasteboard.readURL(true)
        for _, item in ipairs(urls or {}) do
          local url = type(item) == 'string' and item or item.url or item[1]
          if type(url) == 'string' then
            url = url:gsub('^file://localhost', '')
            url = url:gsub('^file://', '')
            url = decodeURL(url)
            print("剪贴板文件URL: " .. url)
            table.insert(filePaths, url)
          end
        end
        print("共有 " .. #filePaths .. " 个文件")
        if #filePaths > 0 then
          local files = {}
          for _, filePathStr in ipairs(filePaths) do
            print("正在读取文件: " .. filePathStr)
            local file = io.open(filePathStr, 'rb')
            if file then
              local content = file:read('*all')
              print("读取文件内容: " .. filePathStr .. " (" .. #content .. " bytes)")
              file:close()
              table.insert(files, {
                name = string.match(filePathStr, "([^/]+)$"),
                content = hs.base64.encode(content)
              })
            else
              print("无法打开文件: " .. filePathStr)
            end
          end
          print("读取了 " .. #files .. " 个文件")
          text = hs.json.encode({type = 'files', files = files})
        end
      else
        print("剪贴板数据类型：文本", contents)
        -- 文本内容
        text = contents or ''
      end
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
        -- 尝试解析为 JSON
        local success, parsed = pcall(hs.json.decode, body)
        if success and type(parsed) == 'table' and parsed.type == 'files' then
          -- 文件内容
          local filePaths = {}
          for _, fileData in ipairs(parsed.files) do
            local content = hs.base64.decode(fileData.content)
            if content then
              local filename = fileData.name
              local tmpBaseFolder = os.getenv("TMPDIR") or "/tmp"
              local tmpFolder = tmpBaseFolder .. "/hammerspoon_remote-pasteboard"
              os.execute("mkdir -p " .. tmpFolder)
              local tmpfile = tmpFolder .. "/" .. filename
              local file = io.open(tmpfile, 'wb')
              if file then
                print("正在写入临时文件: " .. tmpfile .. " (" .. #content .. " bytes)")
                file:write(content)
                file:close()
                table.insert(filePaths, tmpfile)
              end
            end
          end
          local objects = {}
          for _, tmpfile in ipairs(filePaths) do
            table.insert(objects, {url = "file://" .. tmpfile})
          end
          hs.pasteboard.writeObjects(objects)
          -- 300秒后删除临时文件（文件是否已使用都会被删除）
          hs.timer.doAfter(300, function()
            for _, tmpfile in ipairs(filePaths) do
              os.remove(tmpfile)
            end
          end)
        else
          hs.pasteboard.setContents(body)
        end
      else
        hs.pasteboard.setContents(body or '')
      end
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