-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local enemy     = import("app.objects.characters.enemies.base.enemy")
local mob       = class("claw_soldier", enemy)

function mob:onCreate()
    self.super:onCreate()
    self.default_health_ = 6
    self.moving_    = false
    self.orientation_set_ = false

    self.weapon_ = import("app.objects.weapons.enemies.military.claw_bullet")
    self.weapon_parameters_ = {
        category_ = "weapons",
        sub_category_ = "enemies",
        package_ = "military",
        cname_ = "claw_bullet"
    }

end

function mob:animate(cname)

    local stand =   { name = "stand",  animation = {name = cname .. "_" .. "stand", forever = false, delay = 0.10}   }
    local attack =  { name = "attack", animation = {name = cname .. "_" .. "attack", forever = false, delay = 0.10}  }

    self.sprite_:load_action(stand, false)
    self.sprite_:load_action(attack, false)
    self.sprite_:set_animation(stand.animation.name)

    return self
end

function mob:onRespawn()
    self.attacking_ = false
    self.sprite_:run_action("stand")
end

function mob:attack()

    if not self.attacking_ then
        self.attacking_ = true

        self.player_position_ = cc.p(self.player_:getPositionX(), self.player_:getPositionY())

        local action_delay = cc.DelayTime:create(2)

        local attack  = cc.CallFunc:create(function()
            self.sprite_:run_action("attack")
        end)

        local callback = cc.CallFunc:create(function()

            local bullet = self:fire({  sfx = nil,
                offset = cc.p(20, 16),
                weapon = self.weapon_,
                parameters = self.weapon_parameters_})

            bullet:setup_movement(self.player_position_)

        end)


        local on_end = cc.CallFunc:create(function()
            self.attacking_ = false
            self.sprite_:run_action("stand")
        end)

        local sequence = cc.Sequence:create(action_delay, attack, callback, action_delay, on_end, nil)

        self:stopAllActions()
        self:runAction(sequence)
    end

end

return mob





