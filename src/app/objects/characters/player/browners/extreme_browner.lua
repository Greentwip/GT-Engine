-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local browner = import("app.objects.characters.player.browners.base.browner")

local extreme_browner = class("extreme_browner", browner)

local extreme_bullet = import("app.objects.weapons.browners.extreme.extreme_bullet")


function extreme_browner:ctor(sprite)
    self.super:ctor(sprite)

    -- constraints
    self.can_slide_     = false
    self.can_charge_    = false
    self.base_name_ = "extreme"

    local actions = {}
    actions[#actions + 1] = {name = "stand",      animation = {name = "extreme_stand",       forever = true, delay = 0.10} }
    actions[#actions + 1] = {name = "jump",       animation = {name = "extreme_jump",        forever = true, delay = 0.10} }
    actions[#actions + 1] = {name = "dashjump",   animation = {name = "extreme_dashjump",    forever = true, delay = 0.10} }
    actions[#actions + 1] = {name = "walk",       animation = {name = "extreme_walk",        forever = true,  delay = 0.12} }
    actions[#actions + 1] = {name = "standshoot", animation = {name = "extreme_standshoot",  forever = false, delay = 0.10} }
    actions[#actions + 1] = {name = "climb",      animation = {name = "extreme_climb",       forever = true,  delay = 0.16} }
    actions[#actions + 1] = {name = "walkshoot",  animation = {name = "extreme_walkshoot",   forever = true,  delay = 0.12} }
    actions[#actions + 1] = {name = "jumpshoot",  animation = {name = "extreme_jumpshoot",   forever = false, delay = 0.10} }
    actions[#actions + 1] = {name = "hurt",       animation = {name = "extreme_hurt",        forever = false, delay = 0.02} }

    self.sprite_:load_actions_set(actions, true, self.base_name_)

    self.browner_id_ = cc.browners_.extreme_.id_       -- overriden from parent
end


function extreme_browner:fire()

    local bullet_offset = 50
    audio.playSound("sounds/sfx_buster_shoot_high.wav", false)

    local bullet_position = cc.p(self:getParent():getPositionX() + (bullet_offset * self:get_sprite_normal().x),
                                 self:getParent():getPositionY() + 16)

    local bullet = extreme_bullet:create()
                                 :setPosition(bullet_position)
                                 :setup("gameplay", "level", "weapon", "extreme_bullet")
                                 :init_weapon(self:get_sprite_normal().x, self.weapon_tag_)
                                 :addTo(self:getParent():getParent())

    self:getParent():getParent().bullets_[bullet] = bullet
end


return extreme_browner



