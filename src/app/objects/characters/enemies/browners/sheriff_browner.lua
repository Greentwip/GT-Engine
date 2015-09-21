-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local browner                   = import("app.objects.characters.enemies.browners.base.browner")
local directional_star_bullet     = import("app.objects.weapons.browners.sheriff.directional_star_bullet")

local sheriff_browner = class("sheriff_browner-enemy", browner)

function sheriff_browner:ctor(sprite)
    self.super:ctor(sprite)

    -- constraints
    self.can_slide_         = false
    self.can_charge_        = false
    self.can_dash_jump_     = false
    self.can_walk_shoot_    = false
    self.can_jump_shoot_    = false

    self.base_name_ = "sheriff"

    local actions = {}
    actions[#actions + 1] = {name = "intro",       animation = {name = "sheriff_intro",      forever = false, delay = 0.10} }
    actions[#actions + 1] = {name = "stand",      animation = {name = "sheriff_stand",       forever = false, delay = 0.10} }
    actions[#actions + 1] = {name = "jump",       animation = {name = "sheriff_jump",        forever = false, delay = 0.10} }
    actions[#actions + 1] = {name = "walk",       animation = {name = "sheriff_walk",        forever = true,  delay = 0.12} }
    actions[#actions + 1] = {name = "standshoot", animation = {name = "sheriff_standshoot",  forever = false, delay = 0.10} }
    actions[#actions + 1] = {name = "climb",      animation = {name = "sheriff_climb",       forever = true,  delay = 0.16} }
    actions[#actions + 1] = {name = "hurt",       animation = {name = "sheriff_hurt",        forever = false, delay = 0.02} }

    self.sprite_:load_actions_set(actions, true, self.base_name_)

    self.browner_id_ = cc.browners_.sheriff_.id_       -- overriden from parent
end

function sheriff_browner:walk()    --@TODO implement walk_condition()

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

function sheriff_browner:jump()

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


function sheriff_browner:attack()

    if cc.key_pressed(cc.key_code_.b) and not self.jumping_ and not self.walking_ and not self.stunned_ and not self.attacking_ then

        if self.energy_ > 0 then

            self.energy_ = self.energy_ - 1

            self.attacking_ = true

            local pre_delay = cc.DelayTime:create(self:get_action_duration("standshoot"))

            local pre_callback = cc.CallFunc:create(function()
                self:fire()
            end)

            local post_delay = cc.DelayTime:create(self:get_action_duration("standshoot") * 0.50)

            local post_callback = cc.CallFunc:create(function()
                self.attacking_ = false
            end)

            local sequence = cc.Sequence:create(pre_delay, pre_callback, post_delay, post_callback, nil)

            self:runAction(sequence)

        end

    end

end

function sheriff_browner:fire()

    local bullet_offset = 24

    audio.playSound("sounds/sfx_buster_shoot_mid.wav", false)

    local bullet_position_a = cc.p(self:getParent():getPositionX() + (bullet_offset * self:get_sprite_normal().x),
                                   self:getParent():getPositionY() + 14)

    local bullet_position_b = cc.p(self:getParent():getPositionX() + (bullet_offset * self:get_sprite_normal().x * -1),
                                   self:getParent():getPositionY() + 14)


    local bullet_a = directional_star_bullet:create()
                                         :setPosition(bullet_position_a)
                                         :setup("weapons", "browners", "sheriff", "directional_star_bullet")
                                         :init_weapon(self:get_sprite_normal().x, self.weapon_tag_)
                                         :addTo(self:getParent():getParent())

    local bullet_b = directional_star_bullet:create()
                                            :setPosition(bullet_position_b)
                                            :setup("weapons", "browners", "sheriff", "directional_star_bullet")
                                            :init_weapon(self:get_sprite_normal().x * -1, self.weapon_tag_)
                                            :addTo(self:getParent():getParent())

    self:getParent():getParent().bullets_[bullet_a] = bullet_a
    self:getParent():getParent().bullets_[bullet_b] = bullet_b

end

return sheriff_browner





