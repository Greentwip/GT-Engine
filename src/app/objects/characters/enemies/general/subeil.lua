-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local enemy        = import("app.objects.characters.enemies.base.enemy")
local mob          = class("subeil", enemy)

function mob:onCreate()
    self.super:onCreate()
    self.default_health_ = 1
    self.jump_speed_ = cc.p(60, 90)
    self.walk_speed_ = 60
end

function mob:animate(cname)
    local actions = {}
    actions[#actions + 1] = {name = "stand",  animation = {name = cname .. "_" .. "stand", forever = false,  delay = 0.10    } }
    actions[#actions + 1] = {name = "walk",   animation = {name = cname .. "_" .. "walk",  forever = true,   delay = 0.20    } }
    actions[#actions + 1] = {name = "jump",  animation =  {name = cname .. "_" .. "jump",  forever = true,   delay = 0.04    } }

    self.sprite_:load_actions_set(actions, false)
    self.sprite_:set_animation(cname .. "_" .. "stand")

    return self
end

function mob:walk()

    if self.on_ground_ then
        if self.player_:getPositionY() <= self.kinematic_body_.bbox_[2].y + self.kinematic_body_.bbox_[2].height and
                self.player_:getPositionY() >= self.kinematic_body_.bbox_[1].y + self.kinematic_body_.bbox_[1].height
                then
            if self.sprite_:current_action() ~= self.sprite_:get_action("walk") then
                self.sprite_:run_action("walk")
            end

            self.current_speed_.x = self.walk_speed_ * self:get_sprite_normal().x

        else
            if self.sprite_:current_action() ~= self.sprite_:get_action("stand") then
                self.sprite_:run_action("stand")
                self.current_speed_.x = 0
            end
        end

    end
end

function mob:jump()
    if cc.pGetDistance(cc.p(self:getPositionX(), self:getPositionY()),
                       cc.p(self.player_:getPositionX(), self.player_:getPositionY())) < 32 and self.on_ground_ then
        self.on_ground_ = false
        self.current_speed_.x = self.jump_speed_.x * self:get_sprite_normal().x
        self.current_speed_.y = self.jump_speed_.y

        self.sprite_:stop_actions()
        self.sprite_:run_action("jump")
    end
end

return mob





