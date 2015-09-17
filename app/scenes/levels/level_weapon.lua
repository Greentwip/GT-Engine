--
-- Created by Victor on 8/2/2015 5:26 PM
--

local level_base = import("app.objects.gameplay.control.level_base")
local weapon_controller = import("app.scenes.levels.demo.weapon_controller")

local level  = class("level_weapon", level_base)

-- anything related to physics should be created here
function level:prepare(args)
    self.level_bgm_ = "sounds/bgm_get_weapon.mp3"
    self.tmx_map_   = "tilemaps/weapon/level_weapon.tmx"

    self.load_arguments_ = {}
    self.load_arguments_.disable_hud_ = true
    self.load_arguments_.disable_ready_object_ = true
    self.load_arguments_.time_to_play_ = 1
    self.load_arguments_.is_demo_ = true
    self.load_arguments_.demo_controller_ = weapon_controller
    self.load_arguments_.demo_browner_id_ = args.demo_browner_id_
end

return level
