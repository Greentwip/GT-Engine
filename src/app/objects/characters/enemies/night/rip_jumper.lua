-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local enemy  = import("app.objects.characters.enemies.base.enemy")
local mob    = class("rip_jumper", enemy)

function mob:onCreate()
    self.super:onCreate()

    self.default_health_ = 6
    self.jump_speed_ = cc.p(60, 310)
    self.kinematic_body_size_ = cc.size(32, 50)
end

function mob:animate(cname)

    local stand =  { name = "stand", animation = { name = cname .. "_" .. "stand", forever = false, delay = 0.10} }
    local jump  =  { name = "jump",  animation = { name = cname .. "_" .. "jump",  forever = false,  delay = 0.05} }

    self.sprite_:load_action(stand, false)
    self.sprite_:load_action(jump, false)
    self.sprite_:set_animation(stand.animation.name)

    return self
end

function mob:onRespawn()
    self.attacking_ = false
    self.jumping_   = false
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

        -- wait
        local delay = cc.DelayTime:create(self.sprite_:get_action_duration("jump") * 0.5)

        -- jump
        local jump = cc.CallFunc:create(function()
            self.jumping_ = true
        end)

        -- reset
        local after_attack = cc.CallFunc:create(function()
            self.attacking_ = false
        end)


        local sequence = cc.Sequence:create(delay, jump, after_attack, nil)

        self:runAction(sequence)

    end
end

return mob
