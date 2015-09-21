-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local enemy  = import("app.objects.characters.enemies.base.enemy")
local mob    = class("sumatran", enemy)

function mob:onCreate()
    self.super:onCreate()
    self.default_health_ = 12
    self.jump_speed_ = cc.p(60, 260)
end

function mob:animate(cname)
    local stand =  { name = "stand", animation = { name = cname .. "_" .. "stand", forever = true,  delay = 0.10} }
    local jump  =  { name = "jump",  animation = { name = cname .. "_" .. "jump",  forever = false, delay = 0.10} }

    self.sprite_:load_action(stand, false)
    self.sprite_:load_action(jump, false)
    self.sprite_:set_animation(stand.animation.name)

    return self
end

function mob:onRespawn()
    self.attacking_ = false
    self.sprite_:stop_actions()
    self.sprite_:run_action("stand")
end

function mob:walk()
    if self.on_ground_ then

        if self.sprite_:current_action() ~= self.sprite_:get_action("stand") then
            self.sprite_:run_action("stand")
            self.current_speed_.x = 0
        end

    end
end

function mob:jump()
    if self.jumping_ and self.on_ground_ then
        self.jumping_ = false
        self.on_ground_ = false
        self.current_speed_.x = self.jump_speed_.x * self:get_sprite_normal().x
        self.current_speed_.y = self.jump_speed_.y

        audio.playSound("sounds/sfx_roar.wav", false)

        self.sprite_:stop_actions()
        self.sprite_:run_action("jump")
    end
end

function mob:attack()
    if cc.pGetDistance(cc.p(self:getPositionX(), self:getPositionY()),
        cc.p(self.player_:getPositionX(), self.player_:getPositionY())) < 100
            and not self.jumping_
            and self.on_ground_
            and not self.attacking_ then


        self.attacking_ = true

        -- jump
        local jump = cc.CallFunc:create(function()
            self.jumping_ = true
        end)


        -- wait
        local delay = cc.DelayTime:create(1)

        -- reset
        local after_attack = cc.CallFunc:create(function()
            self.attacking_ = false
        end)


        local sequence = cc.Sequence:create(delay, jump, after_attack, nil)

        self:runAction(sequence)

    end
end

return mob