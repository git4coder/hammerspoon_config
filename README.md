# Hammerspoon 为常用 App 绑定快捷键

## 预览

![打开 App 的快捷键清单](screenshot/app-hotkey-help.jpg)

## 用法

1. `caps + 字符` - 打开或切换到指定的 App （caps 代指 CapsLock 这个大小写切换键）
1. `caps + ?` - 显示已绑定快捷键的 App

Tip: 连按同一个快捷键可以在当前 App 的各窗口间循环切换，比如连续按 caps+g 可以在 Google Chrome 的各窗口间切换。

## 依赖

1. [Hammerspoon.app](https://www.hammerspoon.org/)
1. [Karabiner-Elements.app](https://karabiner-elements.pqrs.org/) - 把 CapsLock 变成 ^+⌥+⌘（仅与其它键组合按时才变）

## 配置

编辑 `./Spoons/AppKeyable.spoon/config.lua`，在 `applications` 中修改 app 及其快捷键；

或在 `./init.lua` 末尾添加以下内容：

```lua
spoon.AppKeyable.applications = {
  {key = 'a', path = '/Applications/Affinity Photo.app'},
  {key = 'b', path = '/Applications/Bear.app'},
  {key = 'B', path = '/Applications/Blender.app'},
  -- more applications ...
}
spoon.AppKeyable.functions = nil -- 关掉自带的 functions
```

**注意 key 是区分大小写的**，当设置为大写时快捷按需要增加一个 `shift`，例：

```
'key' = 'A' --> CapsLock + Shift + a
'key' = 'a' --> CapsLock + a
'key' = '@' --> CapsLock + Shift + 2
'key' = '2' --> CapsLock + 2
'key' = '<' --> CapsLock + Shift + ,
'key' = ',' --> CapsLock + ,
```

## 文件清单

以下功能需要在 `init.lua` 中启用：

1. `Spoons/AppKeyable.spoon` 常用 App 及其绑定的绑定快捷键
1. `Spoons/ReloadConfiguration.spoon` 自动加载新配置
1. `Spoons/SpeedMenu.spoon` 状态栏显示网速

## Karabiner-Elements 里设置 hyper 键的 json

* 按下 `capslock + {其它键}` 时相当于按下 `command + option + control + {其它键}`
* 当没有按下 `{其它键}` 时还是本身的 `capslock` 的功能

```jsonnet
// ~/.config/karabiner/assets/complex_modifications/capslock2hyper.json

{
  "title": "capslock2hyper",
  "rules": [
    {
      "description": "Hyper(⌃⌥⌘)",
      "manipulators": [
        {
          "from": {
            "key_code": "caps_lock",
            "modifiers": {
              "optional": ["any"]
            }
          },
          "to": [
            {
              "key_code": "right_control",
              "modifiers": ["right_command", "right_option"]
            }
          ],
          "to_if_alone": {
            "hold_down_milliseconds": 100,
            "key_code": "caps_lock"
          },
          "type": "basic"
        }
      ]
    }
  ]
}
```

## Other

多次点击 Dock 里的微信开发者工具后，会多出一个僵死的，以下可以找到它，但是杀不死……
```lua
for i,v in ipairs(hs.application.runningApplications()) do
  local title = v:title()
  if title == 'wechatwebdevtools' then
    local wins = v:allWindows()
    print(i, title, #wins)
    for a,b in ipairs(wins) do
      print(a, b:role(), b:title())
    end
    v:kill()
    v:kill9()
  end
end
```
