-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local animation = import ("app.objects.gameplay.level.animations.base.animation")

local explosion = class("explosion", animation)

function explosion:animate(cname)

    local death =  { name = "death", animation = { name = cname .. "_" .. "death", forever = true, delay = 0.10} }

    self.sprite_:load_action(death, false)
    return self
end

function explosion:build(args)

    self.speed_ = cc.p(0, 0)

    -- for directional movement
    self.directional_ = false
    self.angle_ = 0
    self.velocity_ = 0

    if args.type_ == "directional" then
        self.directional_ = true
        self.direction_ = args.direction_

        local delta_y = self.direction_.y - self:getPositionY()
        local delta_x = self.direction_.x - self:getPositionX()

        self.angle_ = math.atan2(delta_y, delta_x) -- * 180 / math.pi
        self.velocity_ = 5000

        self.sprite_:setColor(args.sprite_color_)


        self.sprite_:set_animation("explosion_death")
        self.sprite_:run_action("death")
    end
end


function explosion:step(dt)
    self.current_speed_ = self.speed_

    if self.directional_ then
        self.current_speed_.x = self.velocity_ * math.cos(self.angle_) * dt
        self.current_speed_.y = self.velocity_ * math.sin(self.angle_) * dt
    end

    return self
end

function explosion:kinematic_post_step(dt)

    if self.kinematic_body_.body_:getVelocity().x ~= self.current_speed_.x
            or self.kinematic_body_.body_:getVelocity().y ~= self.current_speed_.y then

        self.kinematic_body_.body_:setVelocity(self.current_speed_)

    end

end


function explosion:post_step(dt)
    self:kinematic_post_step(dt)
    local real_position = cc.p(self:getPositionX(), self:getPositionY())

    if not cc.bounds_:is_point_inside(real_position) then
        self.disposed_ = true
    end

    return self
end


return explosion
