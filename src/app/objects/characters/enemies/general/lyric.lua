-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local enemy   = import("app.objects.characters.enemies.base.enemy")
local mob     = class("lyric", enemy)

function mob:onCreate()
    self.super:onCreate()
    self.default_health_ = 2
    self.moving_    = false
end

function mob:animate(cname)
    local still =  { name = "still",    animation = { name = cname .. "_" .. "still", forever = false, delay = 0.10} }
    local fly   =  { name = "fly",      animation = { name = cname .. "_" .. "fly",   forever = true,  delay = 0.10} }

    self.sprite_:load_action(still, false)
    self.sprite_:load_action(fly, false)
    self.sprite_:set_animation(still.animation.name)

    return self
end

function mob:onRespawn()
    self.moving_ = false
    self.sprite_:run_action("still")
end

function mob:walk()
    self.current_speed_.y = 0

    if self.sprite_:current_action() ~= self.sprite_:get_action("fly") then
        self.sprite_:run_action("fly")
    end

end

function mob:jump()

    if not self.moving_ then
        self.moving_ = true

        local move_x = 0
        local move_y = 0

        if self.player_:getPositionX() > self:getPositionX() then
            move_x = 1
        elseif self.player_:getPositionX() < self:getPositionX() then
            move_x = -1
        end

        if self.player_:getPositionY() > self:getPositionY() then
            move_y = 1
        elseif self.player_:getPositionY() < self:getPositionY() then
            move_y = -1
        end

        local move = cc.MoveBy:create(0.05, cc.p(move_x, move_y))
        local callback = cc.CallFunc:create(function() self.moving_ = false end)

        local sequence = cc.Sequence:create(move, callback)
        self:runAction(sequence)
    end

end

return mob



