-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local weapon        = import("app.objects.weapons.base.weapon")
local violet_bullet = class("violet_bullet", weapon)

--[[
function violet_bullet:onCreate()
    self.super:onCreate()

    self.category_;
    self.sub_category_;
    self.package_;
    self.cname_;

end

]]-- --@todo

function violet_bullet:animate(cname)

    local action = {name = "shoot",   animation = {name = cname,  forever = true, delay = 0.10} }

    self.sprite_:load_action(action, false)
    self.sprite_:run_action("shoot")

end

function violet_bullet:step(dt)
    self.current_speed_ = self.speed_
    return self
end


return violet_bullet