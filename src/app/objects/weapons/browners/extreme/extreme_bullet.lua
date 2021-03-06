-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local weapon        = import("app.objects.weapons.base.weapon")
local violet_bullet = class("violet_bullet", weapon)

function violet_bullet:animate(cname)

    local fire = {name = "fire",   animation = {name = cname,  forever = true, delay = 0.10} }

    self.sprite_:load_action(fire, false)

    self.sprite_:set_animation(cname)
    self.sprite_:run_action("fire")

    self.power_ = 8

    return self
end

function violet_bullet:step(dt)
    self.current_speed_ = self.speed_
    return self
end


return violet_bullet