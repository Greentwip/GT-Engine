-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local weapon        = import("app.objects.weapons.base.weapon")
local linear_missile_bullet = class("linear_missile_bullet", weapon)

function linear_missile_bullet:animate(cname)

    local action = {name = "walk",   animation = {name = cname .. "_" .. "walk",  forever = true, delay = 0.10} }

    self.sprite_:load_action(action, false)
    self.sprite_:run_action("walk")

end

function linear_missile_bullet:step(dt)
    self.current_speed_ = self.speed_
    return self
end


return linear_missile_bullet

