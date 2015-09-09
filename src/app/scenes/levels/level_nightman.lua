--
-- Created by Victor on 8/8/2015 3:42 PM
--

local level_base = import("app.objects.gameplay.control.level_base")

local level  = class("level_nightman", level_base)

-- anything related to physics should be created here
function level:init()
    self.level_bgm_ = "sounds/bgm_level_nightman.mp3"
    self.tmx_map_   = "tilemaps/nightman/level_nightman.tmx"
end

return level



