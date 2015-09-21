-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local enemy     = import("app.objects.characters.enemies.base.enemy")
local barrel    = class("jetbird", enemy)

function barrel:onCreate()
    self.default_health_ = 5
    self.still_ = true
    self.walking_ = false

    self.kinematic_body_size_   = cc.size(40.0, 28.0) -- default is cc.size(16.0, 16.0)
    self.kinematic_body_offset_ = cc.p(0.0, 0.0)       -- default is cc.p(0, 0)
end

function barrel:animate(cname)

    local still = {name = "still",  animation = {name = cname .. "_" .. "still", forever = true, delay = 0.10} }
    local stand = {name = "stand",  animation = {name = cname .. "_" .. "stand", forever = false, delay = 0.10} }
    local walk  = {name = "walk",   animation = {name = cname .. "_" .. "walk", forever = true, delay = 0.10} }

    self.sprite_:load_action(still, false)
    self.sprite_:load_action(stand, false)
    self.sprite_:load_action(walk, false)
    self.sprite_:set_animation(still.animation.name)

    return self
end

function barrel:onRespawn()
    self.still_ = true
    self.walking_ = false
    self.sprite_:run_action("still")
end

function barrel:walk()

    if self.walking_ then
        if self.player_:getPositionX() > self:getPositionX() then
            self.current_speed_.x = self.walk_speed_
        elseif self.player_:getPositionX() < self:getPositionX() then
            self.current_speed_.x = -self.walk_speed_
        else
            self.current_speed_.x = 0
        end
    else
        self.current_speed_.x = 0
    end

end

function barrel:attack()
    if cc.pGetDistance(cc.p(self:getPositionX(), self:getPositionY()),
        cc.p(self.player_:getPositionX(), self.player_:getPositionY())) < 64 and self.still_  then
        self.still_ = false
        self.walking_ = false

        local stand_up = cc.CallFunc:create(function() self.sprite_:run_action("stand") end)

        local stand_delay = cc.DelayTime:create(self.sprite_:get_action_duration("stand") * 2)

        local walk  = cc.CallFunc:create(function()
            self.walking_ = true
            self.sprite_:run_action("walk")
        end)

        local walk_delay  = cc.DelayTime:create(self.sprite_:get_action_duration("walk"))

        local sit_down = cc.CallFunc:create(function()
            self.walking_ = false
            self.sprite_:run_action("stand")
            self.sprite_:reverse_action()
        end)

        local on_end = cc.CallFunc:create(function()
            self.still_ = true
            self.sprite_:run_action("still")
        end)

        local sequence = cc.Sequence:create(stand_up , stand_delay, walk, walk_delay, sit_down, stand_delay, on_end, nil)

        self:stopAllActions()
        self:runAction(sequence)

    end
end


return barrel



