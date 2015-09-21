-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local enemy   = import("app.objects.characters.enemies.base.enemy")
local mob     = class("robot_worm", enemy)

function mob:onCreate()
    self.super:onCreate()
    self.default_health_ = 3
    self.attacking_    = false
end

function mob:animate(cname)

    local still  =  { name = "still",    animation = { name = cname .. "_" .. "still",   forever = false, delay = 0.10} }
    local attack =  { name = "attack",   animation = { name = cname .. "_" .. "attack",  forever = true,  delay = 0.10} }

    self.sprite_:load_action(still, false)
    self.sprite_:load_action(attack, false)
    self.sprite_:set_animation(still.animation.name)

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
        local delay = cc.DelayTime:create(self.sprite_:get_action_duration("attack"))

        -- attack
        local attack = cc.CallFunc:create(function()
            self.sprite_:run_action("attack")
        end)

        -- reset
        local after_attack = cc.CallFunc:create(function()
            self.attacking_ = false
            self.sprite_:run_action("still")
        end)

        local sequence = cc.Sequence:create(delay, attack, delay, delay, after_attack, nil)

        self:runAction(sequence)
    end

end

return mob




