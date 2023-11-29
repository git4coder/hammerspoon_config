-- usage:
--   require('profile')
--   profile.getCurrentLocation()
-- usage:
--   local p = require('profile')
--   p.getCurrentLocation()

module = {}

module.locations = {
  ['A2DF6E86-2F00-481C-938E-3CC160347D26'] = {
    name= 'Automatic',
    browser = 'com.apple.Safari',
  },
  ['5AE03170-29FD-4ECE-B891-C72DCDB00712'] = {
    name= 'Home',
    browser = 'com.google.Chrome',
  },
  ['90C23198-478B-4032-BBA0-A7024FB19797'] = {
    name= 'YaoLG',
    browser = 'com.google.Chrome',
  },
  ['AE128892-4C47-400D-B784-7C5EB9A60442'] = {
    name= 'Company',
    browser = 'org.mozilla.firefox',
  },
  ['E736F2F1-0DB3-47C6-A179-2779923A0021'] = {
    name= 'JonieuNET',
    browser = 'org.mozilla.firefox',
  },
}

function module.getCurrentUUID()
  local uuid = (hs.network.configuration.open():location():gsub('/Sets/', ''))
  return uuid
end

function module.getCurrentProfile()
  local uuid = (hs.network.configuration.open():location():gsub('/Sets/', ''))
  return module.locations[uuid] or module.locations['A2DF6E86-2F00-481C-938E-3CC160347D26']
end

function module.setLocation(uuid)
  local profile = module.locations[uuid]
  hs.notify.new({title = '位置', informativeText = '已切换至「' .. profile.name .. '」'}):send()
  print('WiFi位置:' .. profile.name)
  return hs.network.configuration.open():setLocation(uuid)
end

-- -- https://igregory.ca/2020/hammerspoon-browser-picker/
-- function module.chooseBrowser()
--   local appBundle
--   local networkAddress = (hs.network.configuration.open():location():gsub('/Sets/', '')) -- scselect UUID
--   if networkAddress == 'E736F2F1-0DB3-47C6-A179-2779923A0021' then -- Jonieu.NET
--     appBundle = 'org.mozilla.firefox'
--   elseif networkAddress == '5AE03170-29FD-4ECE-B891-C72DCDB00712' then -- Home
--     appBundle = 'com.google.Chrome'
--   else
--     if host == nil then
--       host = 'file'
--     end
--     local script = 'choose from list {"Chrome", "Safari", "Firefox"} with prompt "Open ' .. fullURL .. ' with…"'
--     local success, _, res = hs.osascript.applescript(script)
--     local appBundle
--     if success and res:match('Chrome') ~= nil then
--       appBundle = 'com.google.Chrome'
--     elseif success and res:match('Safari') ~= nil then
--       appBundle = 'com.apple.Safari'
--     elseif success and res:match('Firefox') ~= nil then
--       appBundle = 'org.mozilla.firefox'
--     else
--       return
--     end
--   end
-- end

return module
