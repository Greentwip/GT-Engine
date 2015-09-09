--
-- Created by Victor on 7/25/2015 2:10 AM
--
local level_base = import("app.objects.gameplay.control.level_base")

local level  = class("level_sheriffman", level_base)

-- anything related to physics should be created here
function level:init()
    self.level_bgm_ = "sounds/bgm_level_sheriffman.mp3"
    self.tmx_map_   = "tilemaps/sheriffman/level_sheriffman.tmx"
end

return level

