-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local browner       = import("app.objects.characters.enemies.browners.base.browner")
local vine_bullet   = import("app.objects.weapons.browners.vine.vine_bullet")

local vine_browner = class("vine_browner-enemy", browner)

function vine_browner:ctor(sprite)
    self.super:ctor(sprite)

    self.base_name_ = "vine"

    local actions = {}
    actions[#actions + 1] = {name = "intro",      animation = {name = "vine_intro",      forever = false, delay = 0.10} }
    actions[#actions + 1] = {name = "stand",      animation = {name = "vine_stand",       forever = false, delay = 0.10} }
    actions[#actions + 1] = {name = "jump",       animation = {name = "vine_jump",        forever = false, delay = 0.10} }
    actions[#actions + 1] = {name = "walk",       animation = {name = "vine_walk",        forever = true,  delay = 0.12} }
    actions[#actions + 1] = {name = "standshoot", animation = {name = "vine_standshoot",  forever = false, delay = 0.10} }
    actions[#actions + 1] = {name = "climb",      animation = {name = "vine_climb",       forever = true,  delay = 0.16} }
    actions[#actions + 1] = {name = "hurt",       animation = {name = "vine_hurt",        forever = false, delay = 0.02} }

    self.sprite_:load_actions_set(actions, true, self.base_name_)

    self.browner_id_ = cc.browners_.vine_.id_       -- overriden from parent
end

function vine_browner:init_constraints()
    self.super:init_constraints()
    self.can_slide_         = false
    self.can_charge_        = false
    self.can_dash_jump_     = false
    self.can_walk_shoot_    = false
    self.can_jump_shoot_    = false
end

function vine_browner:init_variables()
    self.super:init_variables(self)
end


function vine_browner:walk()    --@TODO implement walk_condition()

    if  not self.climbing_ and not self.stunned_ and not self.attacking_ then
        if cc.key_down(cc.key_code_.right) and not cc.key_down(cc.key_code_.left) then
            self.sprite_:setFlippedX(false)
            self.speed_.x = self.walk_speed_
            self.walking_ = true
        elseif cc.key_down(cc.key_code_.left) and not cc.key_down(cc.key_code_.right) then
            self.sprite_:setFlippedX(true)
            self.speed_.x = -self.walk_speed_
            self.walking_ = true
        else
            self.speed_.x = 0
            self.walking_ = false
        end

        if not cc.key_down(cc.key_code_.right) and not cc.key_down(cc.key_code_.left)  then
            self.speed_.x = 0
            self.walking_ = false
        end

    else
        self.walking_ = false
    end

end

function vine_browner:jump()

    if cc.key_pressed(cc.key_code_.a)
            and not cc.key_down(cc.key_code_.up)
            and not cc.key_down(cc.key_code_.down)
            and self.on_ground_
            and not self.stunned_
            and not self.attacking_ then

        self.speed_.y  = self.jump_speed_
        self.on_ground_ = false
        self.jumping_ = true
    end

    if not cc.key_down(cc.key_code_.a) and self.speed_.y >= 0 and not self.climbing_ and not self.on_ground_ then
        self.speed_.y = 0
    end

end


function vine_browner:attack()

    if cc.key_pressed(cc.key_code_.b) and not self.jumping_ and not self.walking_ and not self.stunned_ and not self.attacking_ then

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
                              :addTo(self:getParent():getParent())

    self:getParent():getParent().bullets_[bullet] = bullet
end

return vine_browner





