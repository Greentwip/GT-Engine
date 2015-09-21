-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local weapon      = import("app.objects.weapons.base.weapon")
local grenade_bullet = class("grenade_bullet", weapon)

function grenade_bullet:onCreate()
    self.super:onCreate()
    self.movement_is_non_blockable_ = true

    self.rising_ = false
    self.rise_speed_ = 350
    self.move_speed_ = 60

    self.power_ = 4

end

function grenade_bullet:animate(cname)

    local walk = {name = "walk",   animation = {name = cname .. "_walk",  forever = true, delay = 0.10} }

    self.sprite_:load_action(walk, false)
    self.sprite_:run_action("walk")

    self.rising_ = false

    return self
end

function grenade_bullet:walk()
    if self.sprite_:isFlippedX() then
        self.current_speed_.x = -self.move_speed_
    else
        self.current_speed_.x = self.move_speed_
    end
end

function grenade_bullet:jump()
    if not self.rising_  then
        self.rising_ = true
        self.current_speed_.y  = self.rise_speed_
    end

end

return grenade_bullet







