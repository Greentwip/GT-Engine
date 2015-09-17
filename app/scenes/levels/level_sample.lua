--
-- Created by Victor on 6/27/2015 2:59 PM
--

local level_base = import("app.objects.gameplay.control.level_base")

local level  = class("level_militaryman", level_base)

-- anything related to physics should be created here
function level:prepare(args)
    self.level_bgm_ = "sounds/bgm_level_militaryman.mp3"
    self.tmx_map_   = "tilemaps/militaryman/level_militaryman.tmx"
end

return level