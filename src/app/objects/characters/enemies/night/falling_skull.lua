-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local enemy   = import("app.objects.characters.enemies.base.enemy")
local mob     = class("falling_skull", enemy)

function mob:onCreate()
    self.super:onCreate()

    self.default_health_ = 2
    self.remove_kinematics_ = true
    self.falling_    = false
end

function mob:animate(cname)

    local still =  { name = "still",    animation = { name = cname .. "_" .. "still", forever = false, delay = 0.10} }
    local fall  =  { name = "fall",      animation = { name = cname .. "_" .. "fall",   forever = true,  delay = 0.02} }

    self.sprite_:load_action(still, false)
    self.sprite_:load_action(fall, false)
    self.sprite_:set_animation(still.animation.name)

    return self
end

function mob:onRespawn()
    self.falling_ = false
end

function mob:fall()
    if self.falling_ then
        if self.sprite_:current_action() ~= self.sprite_:get_action("fall") then
            self.sprite_:run_action("fall")
        end

        self.current_speed_ = self.kinematic_body_.body_:getVelocity()
    else
        self.current_speed_.y = 0
    end
end

function mob:attack()

    local distance = cc.pGetDistance(cc.p(self:getPositionX(), 0),
        cc.p(self.player_:getPositionX(), 0))

    if distance < 24 then

        if not self.falling_ then
            self.falling_ = true
        end

    end
end

function mob:move()
    self:fall()
end

function mob:kinematic_step(dt)
    if cc.game_status_ == cc.GAME_STATUS.RUNNING then
        -- invulnerable, for now, no kinematics
        --self:compute_position()
        self:move()
    end
end


return mob