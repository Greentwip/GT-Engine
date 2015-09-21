-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local enemy = import("app.objects.characters.enemies.base.enemy")
local mob   = class("taban", enemy)

function mob:onCreate()
    self.super:onCreate()
    self.default_health_ = 2
    self.still_ = true
    self.flying_ = false

    self.weapon_ = import("app.objects.weapons.enemies.general.directional_bullet")
    self.weapon_parameters_ = {
        category_ = "gameplay",
        sub_category_ = "level",
        package_ = "weapon",
        cname_ = "directional_bullet"
    }
end

function mob:animate(cname)

    local still = {name = "still",  animation = {name = cname .. "_" .. "still", forever = false, delay = 0.10} }
    local wake  = {name = "wake",  animation = {name = cname .. "_" .. "wake", forever = false, delay = 0.5} }
    local fly   = {name = "fly",  animation = {name = cname .. "_" .. "fly", forever = true, delay = 0.10} }

    self.sprite_:load_action(still, false)
    self.sprite_:load_action(wake, false)
    self.sprite_:load_action(fly, false)
    self.sprite_:set_animation(still.animation.name)

    return self
end

function mob:onRespawn()
    self.sprite_:run_action("still")

    self.moving_ = false
    self.still_  = true
    self.flying_ = false
end

function mob:walk()
    self.current_speed_.y = 0

    if cc.pGetDistance(cc.p(self:getPositionX(), 0),
        cc.p(self.player_:getPositionX(), 0)) < 100 and self.still_  then
        self.still_ = false

        local wake_up = cc.CallFunc:create(function()  self.sprite_:run_action("wake") end)

        local delay = cc.DelayTime:create(self.sprite_:get_action_duration("wake") * 2)
        local callback = cc.CallFunc:create(function()
            audio.playSound("sounds/sfx_taban.wav", false)
            self.sprite_:run_action("fly")
            self.flying_ = true
        end)

        local sequence = cc.Sequence:create(wake_up, delay, callback, nil)

        self:stopAllActions()
        self:runAction(sequence)

    end
end

function mob:jump()
    if self.flying_ and not self.moving_ then
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

function mob:attack()
    if self.flying_ and not self.attacking_ then

        self.attacking_ = true

        local delay = cc.DelayTime:create(2.0)
        local callback = cc.CallFunc:create(function()

            local player_position = cc.p(self.player_:getPositionX(), self.player_:getPositionY())

            local bullet = self:fire({  sfx = nil,
                offset = cc.p(4, 0),
                weapon = self.weapon_,
                parameters = self.weapon_parameters_})

            bullet:setup_movement(player_position)


            self.attacking_ = false

        end)

        local sequence = cc.Sequence:create(delay, callback, nil)

        self:runAction(sequence)
    end




end

return mob





