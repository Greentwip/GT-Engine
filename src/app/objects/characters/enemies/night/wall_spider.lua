-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local enemy   = import("app.objects.characters.enemies.base.enemy")
local mob     = class("wall_spider", enemy)

function mob:onCreate()
    self.super:onCreate()

    self.default_health_ = 2
    self.moving_    = false
end

function mob:animate(cname)

    local stand =  { name = "stand", animation = { name = cname .. "_" .. "stand", forever = false, delay = 0.10} }

    self.sprite_:load_action(stand, false)
    self.sprite_:set_animation(stand.animation.name)

    return self
end

function mob:onRespawn()
    self.moving_ = false
end

function mob:walk()
    self.current_speed_.y = 0

    if self.sprite_:current_action() ~= self.sprite_:get_action("stand") then
        self.sprite_:run_action("stand")
    end

end

return mob