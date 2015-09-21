-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local enemy     = import("app.objects.characters.enemies.base.enemy")
local mob       = class("flower", enemy)

function mob:onCreate()
    self.default_health_ = 9

    self.kinematic_body_size_   = cc.size(24.0, 180.0) -- default is cc.size(16.0, 16.0)
    self.kinematic_body_offset_ = cc.p(0.0, -self.kinematic_body_size_.height * 0.75)       -- default is cc.p(0, 0)
end

function mob:animate(cname)

    local attack  =  { name = "attack", animation = { name = cname .. "_" .. "attack", forever = true, delay = 0.10} }

    self.sprite_:load_action(attack, false)
    self.sprite_:set_animation(cname .. "_" .. "attack")

    return self
end

function mob:on_respawn()
    self.attacking_ = false
end

function mob:walk()
    if self.sprite_:current_action() ~= self.sprite_:get_action("stand") then
        self.sprite_:run_action("stand")
        self.current_speed_.x = 0
    end
end

function mob:jump()
    self.current_speed_.y = 0
end

function mob:flip(x_normal)
    -- this enemy does not flip
end

function mob:attack()

    if self.status_ == cc.enemy_.status_.fighting_ and not self.attacking_ then

        local player_x_distance = cc.pGetDistance(cc.p(self:getPositionX(), 0), cc.p(self.player_:getPositionX(), 0))

        if player_x_distance <= 24 then

            self.attacking_ = true

            local delay = cc.DelayTime:create(0.50)

            local move_up = cc.MoveBy:create(0.50, cc.p(0, 120))

            local move_down = cc.MoveBy:create(1.0, cc.p(0, -120))

            local callback = cc.CallFunc:create(function()
                self.attacking_ = false
            end)

            local sequence = cc.Sequence:create(delay, move_up, move_down, callback, nil)

            self:stopAllActions()
            self:runAction(sequence)
        end
    end

end

return mob



