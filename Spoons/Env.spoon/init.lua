local obj = {}
obj.__index = obj

obj.name = "Env"
obj.version = "1.1"
obj.env = {}

local function parseValue(val)
  -- 去除首尾空白
  local s = val:gsub("^%s+", ""):gsub("%s+$", "")
  -- 布尔
  if s == "true" then
    return true
  end
  if s == "false" then
    return false
  end
  -- 数组 逗号分割
  if s:find(",") then
    local arr = {}
    for item in s:gmatch("[^,]+") do
      local it = item:gsub("^%s+", ""):gsub("%s+$", "")
      it = it:gsub('^[\'"]', ""):gsub('[\'"]$', "")
      table.insert(arr, it)
    end
    return arr
  end
  -- 去除引号
  s = s:gsub('^[\'"]', ""):gsub('[\'"]$', "")
  return s
end

-- 加载 .env，文件不存在直接静默跳过
function obj:load(customPath)
  local path = customPath or hs.configdir .. "/.env"
  local file = io.open(path, "r")
  if not file then
    return self
  end

  for line in file:lines() do
    local pure = line:match("^(.-)%s*#.*$") or line
    local trimmed = pure:match("^%s*(.-)%s*$")
    if trimmed ~= "" then
      local key, rawVal = trimmed:match("^([^=]+)%s*=%s*(.*)$")
      if key and rawVal then
        self.env[key] = parseValue(rawVal)
      end
    end
  end

  file:close()
  return self
end

function obj:get(key, default)
  local v = self.env[key]
  if v ~= nil then
    return v
  end
  return default
end

function obj:sys(key)
  return os.getenv(key)
end

return obj
