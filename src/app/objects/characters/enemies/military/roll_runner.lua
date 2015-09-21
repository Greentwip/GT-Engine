-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local enemy = import("app.objects.characters.enemies.base.enemy")
local mob   = class("roll_runner", enemy)

function mob:onCreate()
    self.super:onCreate()
    self.default_health_ = 5
    self.shooting_  = false
    self.moving_    = false
    self.orientation_set_ = false
    self.orientation_ = 0
end

function mob:animate(cname)

    local walk = {name = "walk",  animation = {name = cname .. "_" .. "walk", forever = true, delay = 0.10} }

    self.sprite_:load_action(walk, false)
    self.sprite_:set_animation(walk.animation.name)

    return self
end

function mob:onRespawn()
    self.shooting_ = false
    self.moving_    = false
    self.orientation_set_ = false
    self.orientation_ = 0
    self.current_speed_.x = 0
    if self.sprite_:isFlippedX() then
        self.sprite_:setFlippedX(false)
    end
end

function mob:flip(x_normal)
    if not self.orientation_set_ then
        if x_normal == 1 and self.current_speed_.x > 0 then
            self.orientation_set_  = true
            self.sprite_:setFlippedX(true)
        elseif x_normal == -1 and self.current_speed_.x < 0 then
            self.orientation_set_  = true
            self.sprite_:setFlippedX(false)
        end
    end

    self.is_flipping_ = false
end

function mob:walk()

    if not self.moving_ then
        self.moving_ = true

        if self.player_:getPositionX() >= self:getPositionX() then
            self.orientation_ = 1
        else
            self.orientation_ = -1
        end
    end

    if self.moving_ then
        if self.contacts_[cc.kinematic_contact_.down] then
            if self.contacts_[cc.kinematic_contact_.right] then
                self.orientation_ = -1
                if self.sprite_:isFlippedX() then
                    self.sprite_:setFlippedX(false)
                end
            elseif self.contacts_[cc.kinematic_contact_.left] then
                self.orientation_ = 1

                if not self.sprite_:isFlippedX() then
                    self.sprite_:setFlippedX(true)
                end

            end

            if self.orientation_ == 1 then
                self.current_speed_.x = self.walk_speed_
            elseif self.orientation_ == -1 then
                self.current_speed_.x = -self.walk_speed_
            end
        end
    end


end

return mob





