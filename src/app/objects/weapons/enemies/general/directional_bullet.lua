-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local weapon                = import("app.objects.weapons.base.weapon")
local directional_bullet    = class("directional_bullet", weapon)

function directional_bullet:onCreate()
    self.super:onCreate()
    self.speed_ = cc.p(0, 0)
    self.power_ = 2
end

function directional_bullet:setup_movement(point)

    local delta_y = point.y - self:getPositionY()
    local delta_x = point.x - self:getPositionX()

    self.angle_ = math.atan2(delta_y, delta_x) -- * 180 / math.pi
    self.velocity_ = 10000

    return self
end

function directional_bullet:step(dt)
    self.current_speed_ = self.speed_

    self.current_speed_.x = self.velocity_ * math.cos(self.angle_) * dt
    self.current_speed_.y = self.velocity_ * math.sin(self.angle_) * dt

    return self
end

return directional_bullet
