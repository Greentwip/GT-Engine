-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local enemy = import("app.objects.characters.enemies.base.enemy")
local mob   = class("plane", enemy)

function mob:onCreate()
    self.super:onCreate()
    self.movement_is_non_blockable_ = true
    self.default_health_ = 2
    self.shooting_  = false
    self.moving_    = false
    self.orientation_set_ = false
end

function mob:animate(cname)

    local fly = {name = "fly",  animation = {name = cname .. "_" .. "fly", forever = true, delay = 0.10} }

    self.sprite_:load_action(fly, false)
    self.sprite_:set_animation(fly.animation.name)

    return self
end

function mob:onRespawn()
    self.shooting_ = false
    self.moving_    = false
    self.orientation_set_ = false
    self.current_speed_.x = 0
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
            self.current_speed_.x = self.walk_speed_
        else
            self.current_speed_.x = -self.walk_speed_
        end
    end
end

function mob:jump()
    self.current_speed_.y = 0
end

function mob:attack()

    if self.status_ == cc.enemy_.status_.fighting_ and not self.is_flipping_ and not self.shooting_ then
        -- this enemy throws projectiles
    end

end

return mob



