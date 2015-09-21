-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local enemy = import("app.objects.characters.enemies.base.enemy")
local mob   = class("tank", enemy)

function mob:onCreate()
    self.super:onCreate()
    self.default_health_ = 24
    self.walk_speed_ = 35
    self.attacking_  = false
    self.moving_    = false
    self.orientation_set_ = false

    self.weapon_ = import("app.objects.weapons.enemies.military.tank_bullet")
    self.weapon_parameters_ = {
        category_ = "weapons",
        sub_category_ = "enemies",
        package_ = "military",
        cname_ = "tank_bullet"
    }
end

function mob:animate(cname)

    local walk = {name = "walk",  animation = {name = cname .. "_" .. "walk", forever = true, delay = 0.10} }

    self.sprite_:load_action(walk, false)
    self.sprite_:set_animation(walk.animation.name)

    return self
end

function mob:onRespawn()
    self.attacking_ = false
    self.orientation_set_ = false
    self.sprite_:run_action("walk")
end

function mob:flip(x_normal)
    if not self.orientation_set_ then
        self.orientation_set_  = true
        if x_normal == 1 and self.current_speed_.x > 0 then
            self.sprite_:setFlippedX(true)
        else
            self.sprite_:setFlippedX(false)
        end
    end

    self.is_flipping_ = false
end

function mob:walk()

    local in_range = cc.pGetDistance(cc.p(self:getPositionX(), self:getPositionY()),
                     cc.p(self.player_:getPositionX(), self.player_:getPositionY())) < 72

    if self.player_:getPositionX() >= self:getPositionX() then
        if not in_range then
            self.current_speed_.x = self.walk_speed_
        end
    else
        if not in_range then
            self.current_speed_.x = -self.walk_speed_
        end
    end

    if in_range or self.contacts_[cc.kinematic_contact_.right] or self.contacts_[cc.kinematic_contact_.left] then
        self.current_speed_.x = 0
    end


    if self.sprite_:current_action() ~= self.sprite_:get_action("walk") then
        self.sprite_:run_action("walk")
    end

end

function mob:attack()
    if not self.attacking_ then
        self.attacking_ = true

        local action_delay = cc.DelayTime:create(2)

        local callback = cc.CallFunc:create(function()

                self:fire({  sfx = nil,
                offset = cc.p(20, 16),
                weapon = self.weapon_,
                parameters = self.weapon_parameters_})

        end)

        local on_end = cc.CallFunc:create(function()
            self.attacking_ = false
            self.sprite_:run_action("stand")
        end)

        local sequence = cc.Sequence:create(action_delay, callback, action_delay, on_end, nil)

        self:stopAllActions()
        self:runAction(sequence)
    end
end

return mob






