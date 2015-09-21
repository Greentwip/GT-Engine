-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local weapon      = import("app.objects.weapons.base.weapon")
local tank_bullet = class("tank_bullet", weapon)

function tank_bullet:onCreate()
    self.super:onCreate()
    self.movement_is_non_blockable_ = true

    self.rising_ = false
    self.rise_speed_ = 380
    self.move_speed_ = 60

    self.power_ = 4
end

function tank_bullet:walk()
    if self.sprite_:isFlippedX() then
        self.current_speed_.x = -self.move_speed_
    else
        self.current_speed_.x = self.move_speed_
    end
end

function tank_bullet:jump()
    if not self.rising_  then
        self.rising_ = true
        self.current_speed_.y  = self.rise_speed_
    end

end



return tank_bullet



