--
-- Created by Victor on 8/2/2015 5:26 PM
--

local level_base = import("app.objects.gameplay.control.level_base")

local level  = class("level_vineman", level_base)

-- anything related to physics should be created here
function level:init()
    self.level_bgm_ = "sounds/bgm_level_vineman.mp3"
    self.tmx_map_   = "tilemaps/vineman/level_vineman.tmx"
end

return level



