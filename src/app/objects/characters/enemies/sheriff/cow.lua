-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local enemy  = import("app.objects.characters.enemies.base.enemy")
local mob    = class("cow", enemy)

function mob:onCreate()
    self.super:onCreate()
    self.default_health_ = 12
    self.jump_speed_ = cc.p(60, 260)

    self.weapon_ = import("app.objects.weapons.enemies.general.directional_bullet")
    self.weapon_parameters_ = {
        category_ = "gameplay",
        sub_category_ = "level",
        package_ = "weapon",
        cname_ = "directional_bullet"
    }
end

function mob:animate(cname)

    local stand  =  { name = "stand",  animation = { name = cname .. "_" .. "stand",  forever = false, delay = 0.10} }
    local morph  =  { name = "morph",  animation = { name = cname .. "_" .. "morph",  forever = false, delay = 0.20} }
    local attack =  { name = "attack", animation = { name = cname .. "_" .. "attack", forever = false, delay = 0.10} }

    self.sprite_:load_action(stand,  false)
    self.sprite_:load_action(morph,  false)
    self.sprite_:load_action(attack, false)
    self.sprite_:set_animation(stand.animation.name)

    self.stand_ = stand

    return self
end

function mob:onRespawn()
    self.morphing_ = false
    self.morphed_  = false
    self.attacking_ = false

    self.sprite_:set_animation(self.stand_.animation.name)
    self.sprite_:run_action("stand")

end

function mob:walk()

    if cc.pGetDistance(cc.p(self:getPositionX(), self:getPositionY()),
        cc.p(self.player_:getPositionX(), self.player_:getPositionY())) < 64 then

        if not self.morphing_ then
            self.morphing_ = true

            if self.sprite_:current_action() ~= self.sprite_:get_action("morph") then

                local morph  = cc.CallFunc:create(function()
                    self.sprite_:run_action("morph")
                end)

                local action_delay = cc.DelayTime:create(self.sprite_:get_action_duration("morph"))

                local on_end = cc.CallFunc:create(function()
                    self.morphed_ = true
                end)

                local sequence = cc.Sequence:create(morph, action_delay, on_end, nil)

                self:stopAllActions()
                self:runAction(sequence)
            end
        end

    end

end

function mob:attack()

    if not self.attacking_ and self.morphed_ and self.player_.current_browner_.on_ground_ then
        self.attacking_ = true

        local attack  = cc.CallFunc:create(function()
            self.sprite_:run_action("attack")
        end)

        local action_delay = cc.DelayTime:create(self.sprite_:get_action_duration("attack"))

        self.player_position_ = cc.p(self.player_:getPositionX(), self.player_:getPositionY())

        local attack_callback   = cc.CallFunc:create(function()

            local bullet = self:fire({  sfx = nil,
                offset = cc.p(30, 24),
                weapon = self.weapon_,
                parameters = self.weapon_parameters_})

            bullet:setup_movement(self.player_position_)

        end)

        local shoot_delay  = cc.DelayTime:create(1)

        local reverse_attack  = cc.CallFunc:create(function()
            self.sprite_:run_action("attack")
            self.sprite_:reverse_action()
        end)

        local on_end = cc.CallFunc:create(function()
            self.attacking_ = false
        end)

        local sequence = cc.Sequence:create(attack,
                                            action_delay,
                                            attack_callback,
                                            shoot_delay,
                                            reverse_attack,
                                            action_delay,
                                            shoot_delay,
                                            on_end,
                                            nil)

        self:stopAllActions()
        self:runAction(sequence)
    end

end

return mob








