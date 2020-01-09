-- https://emacs-china.org/t/topic/6346
switcher = hs.window.switcher.new(
   hs.window.filter.new()
      :setAppFilter('Emacs', {allowRoles = '*', allowTitles = 1}), -- make emacs window show in switcher list
   {
      highlightColor = {0.8,0.5,0,0.8},
      backgroundColor = {0,0,0,0.7},
      onlyActiveApplication = false,
      showTitles = false,
      showThumbnails = true,
      thumbnailSize = 200,
      showSelectedThumbnail = false,
   }
)

hs.hotkey.bind("alt", "tab", function() switcher:next() end)
hs.hotkey.bind("alt-shift", "tab", function() switcher:previous() end)
