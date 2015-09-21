-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local enemy   = import("app.objects.characters.enemies.base.enemy")
local mob     = class("backpacker", enemy)

function mob:onCreate()
    self.super:onCreate()
    self.default_health_ = 8
    self.attacking_    = false

    self.weapon_ = import("app.objects.weapons.enemies.night.backpacker_bullet")
    self.weapon_parameters_ = {
        category_ = "weapons",
        sub_category_ = "enemies",
        package_ = "night",
        cname_ = "backpacker_bullet"
    }
end

function mob:animate(cname)

    local stand  =  { name = "stand",    animation = { name = cname .. "_" .. "stand",   forever = false, delay = 0.10} }
    local attack =  { name = "attack",   animation = { name = cname .. "_" .. "attack",  forever = true,  delay = 0.10} }

    self.sprite_:load_action(stand, false)
    self.sprite_:load_action(attack, false)

    self.sprite_:set_animation(stand.animation.name)

    return self
end

function mob:onRespawn()
    self.attacking_ = false
end

function mob:walk()
end

function mob:attack()

    if not self.attacking_ then
        self.attacking_ = true

        -- wait
        local delay = cc.DelayTime:create(1.0)

        -- attack
        local attack = cc.CallFunc:create(function()
            self.sprite_:run_action("attack")
        end)

        local callback = cc.CallFunc:create(function()

            self:fire({  sfx = nil,
                offset = cc.p(-18, 45),
                weapon = self.weapon_,
                parameters = self.weapon_parameters_})

        end)


        -- reset
        local after_attack = cc.CallFunc:create(function()
            self.attacking_ = false
            self.sprite_:run_action("stand")
        end)


        local sequence = cc.Sequence:create(delay, attack, callback, delay, after_attack, nil)

        self:runAction(sequence)
    end

end

return mob

