-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local weapon    = import("app.core.physics.kinematic_character").create("weapon")

function weapon:onCreate()
    self.disposed_ = false
    self.power_    = 1
    self.x_normal_  = 1
end

function weapon:init_weapon(x_normal, tag)

    local flip_x = false

    self.x_normal_ = x_normal
    self.weapon_tag_ = tag

    if self.x_normal_ == -1 then
       flip_x = true
    end

    self.speed_ = cc.p(260 * self.x_normal_, 0)
    self:getPhysicsBody():getShapes()[1]:setTag(tag)
    self.sprite_:setFlippedX(flip_x)
    return self

end

function weapon:step(dt)
    self:kinematic_step(dt)
    return self
end

function weapon:post_step(dt)
    self:kinematic_post_step(dt)
    local real_position = cc.p(self:getPositionX(), self:getPositionY())

    if not cc.bounds_:is_point_inside(real_position) then
        self.disposed_ = true
    end

    return self
end

return weapon