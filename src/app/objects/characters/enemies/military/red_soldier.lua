-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local enemy     = import("app.objects.characters.enemies.base.enemy")
local mob       = class("red_soldier", enemy)

function mob:onCreate()
    self.super:onCreate()
    self.default_health_ = 6
    self.shooting_  = false
    self.attacking_ = false
    self.falling_   = false
    self.ready_     = false

    self.weapon_ = import("app.objects.weapons.enemies.general.directional_bullet")
    self.weapon_parameters_ = {
        category_ = "gameplay",
        sub_category_ = "level",
        package_ = "weapon",
        cname_ = "directional_bullet"
    }

end

function mob:animate(cname)

    local stand   =  { name = "stand",   animation = {name = cname .. "_" .. "stand",   forever = false, delay = 0.10} }
    local attack  =  { name = "attack",  animation = {name = cname .. "_" .. "attack",  forever = false, delay = 0.10} }
    local fall    =  { name = "fall",    animation = {name = cname .. "_" .. "fall",    forever = false, delay = 0.10} }
    local morph_a =  { name = "morph_a", animation = {name = cname .. "_" .. "morph_a", forever = false, delay = 0.20} }
    local morph_b =  { name = "morph_b", animation = {name = cname .. "_" .. "morph_b", forever = false, delay = 0.20} }

    self.sprite_:load_action(stand, false)
    self.sprite_:load_action(attack, false)
    self.sprite_:load_action(fall, false)
    self.sprite_:load_action(morph_a, false)
    self.sprite_:load_action(morph_b, false)

    self.sprite_:set_animation(fall.animation.name)
    return self
end

function mob:onRespawn()
    self.attacking_ = false
    self.falling_   = false
    self.ready_     = false
end

function mob:walk()

    if self.on_ground_ then
        if self.falling_ then
           self.falling_ = false
           local fall_delay = cc.DelayTime:create(self.sprite_:get_action_duration("fall"))

           local setup  = cc.CallFunc:create(function()
               self.sprite_:run_action("fall")
           end)

           local morph_a_delay = cc.DelayTime:create(self.sprite_:get_action_duration("morph_a"))

           local morph_a  = cc.CallFunc:create(function()
               self.sprite_:run_action("morph_a")
           end)


           local morph_b_delay = cc.DelayTime:create(self.sprite_:get_action_duration("morph_b"))

           local morph_b  = cc.CallFunc:create(function()
               self.sprite_:run_action("morph_b")
           end)


           local on_end = cc.CallFunc:create(function()
               self.ready_ = true
           end)

           local sequence = cc.Sequence:create(setup, fall_delay,
                                               morph_a, morph_a_delay,
                                               morph_b, morph_b_delay,
                                               on_end, nil)

           self:stopAllActions()
           self:runAction(sequence)


        end
    else
        self.falling_ = true
        self.sprite_:stop_actions()
        self.sprite_:set_animation(mob.__cname .. "_" .. "fall")
    end

end

function mob:attack()

    if not self.attacking_ and self.ready_ then
        self.attacking_ = true

        local action_delay = cc.DelayTime:create(self.sprite_:get_action_duration("attack") * 2.0)

        local attack  = cc.CallFunc:create(function()
            self.sprite_:run_action("attack")
        end)

        self.player_position_ = cc.p(self.player_:getPositionX(), self.player_:getPositionY())

        local attack_callback   = cc.CallFunc:create(function()

            local bullet = self:fire({  sfx = nil,
                offset = cc.p(20, 6),
                weapon = self.weapon_,
                parameters = self.weapon_parameters_})

            bullet:setup_movement(self.player_position_)

        end)


        local on_end = cc.CallFunc:create(function()

            local attack_delay = cc.DelayTime:create(self.sprite_:get_action_duration("attack"))

            local attack_reverse = cc.CallFunc:create(function() self.sprite_:reverse_action() end)

            local morph_delay = cc.DelayTime:create(self.sprite_:get_action_duration("morph_a") * 4)

            local morph_reverse  = cc.CallFunc:create(function()
                self.sprite_:run_action("morph_a")
                self.sprite_:reverse_action()
            end)

            local on_end = cc.CallFunc:create(function()
                self.attacking_ = false
            end)

            local sequence = cc.Sequence:create(attack_reverse,
                                                attack_delay,
                                                morph_reverse,
                                                morph_delay,
                                                on_end, nil)


            self:stopAllActions()
            self:runAction(sequence)


        end)

        local sequence = cc.Sequence:create(attack, action_delay, attack_callback, action_delay, on_end, nil)

        self:stopAllActions()
        self:runAction(sequence)
    end

end

return mob













