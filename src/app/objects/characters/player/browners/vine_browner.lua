-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local browner       = import("app.objects.characters.player.browners.base.browner")
local vine_bullet   = import("app.objects.weapons.browners.vine.vine_bullet")

local vine_browner = class("vine_browner", browner)

function vine_browner:ctor(sprite)
    self.super:ctor(sprite)

    -- constraints
    self.can_slide_         = false
    self.can_charge_        = false
    self.can_dash_jump_     = false
    self.can_walk_shoot_    = false
    self.can_jump_shoot_    = false

    self.base_name_ = "vine"

    local actions = {}
    actions[#actions + 1] = {name = "stand",      animation = {name = "vine_stand",       forever = false, delay = 0.10} }
    actions[#actions + 1] = {name = "jump",       animation = {name = "vine_jump",        forever = false, delay = 0.10} }
    actions[#actions + 1] = {name = "walk",       animation = {name = "vine_walk",        forever = true,  delay = 0.12} }
    actions[#actions + 1] = {name = "standshoot", animation = {name = "vine_standshoot",  forever = false, delay = 0.10} }
    actions[#actions + 1] = {name = "climb",      animation = {name = "vine_climb",       forever = true,  delay = 0.16} }
    actions[#actions + 1] = {name = "hurt",       animation = {name = "vine_hurt",        forever = false, delay = 0.02} }

    self.sprite_:load_actions_set(actions, true, self.base_name_)

    self.browner_id_ = cc.browners_.vine_.id_       -- overriden from parent
end

function vine_browner:attack()

    if self:getParent():attack_condition() and not self.jumping_ and not self.walking_ and not self.stunned_ and not self.attacking_ then

        if self.energy_ > 0 then

            self.energy_ = self.energy_ - 1

            self.attacking_ = true

            local pre_delay = cc.DelayTime:create(self:get_action_duration("standshoot") * 0.20)

            local pre_callback = cc.CallFunc:create(function()
                self:fire()
            end)

            local post_delay = cc.DelayTime:create(self:get_action_duration("standshoot") * 0.30)

            local post_callback = cc.CallFunc:create(function()
                self.attacking_ = false
            end)

            local sequence = cc.Sequence:create(pre_delay, pre_callback, post_delay, post_callback, nil)

            self:runAction(sequence)

        end

    end

end

function vine_browner:fire()

    local bullet_offset = 0

    audio.playSound("sounds/sfx_buster_shoot_mid.wav", false)

    local bullet_position = cc.p(self:getParent():getPositionX() + (bullet_offset * self:get_sprite_normal().x),
                                 self:getParent():getPositionY() + 26)


    local bullet = vine_bullet:create()
                              :setPosition(bullet_position)
                              :setup("gameplay", "level", "weapon", "vine_bullet")
                              :init_weapon(self:get_sprite_normal().x, self.weapon_tag_)
                              :addTo(self:getParent():getParent(), 512)

    self:getParent():getParent().bullets_[bullet] = bullet
end

return vine_browner





