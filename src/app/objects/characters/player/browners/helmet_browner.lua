-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local browner = import("app.objects.characters.player.browners.base.browner")

local helmet_browner = class("helmet_browner", browner)

function helmet_browner:ctor(sprite)
    self.super:ctor(sprite)

    self.base_name_ = "helmet"

    local actions = {}
    actions[#actions + 1] = {name = "stand",      animation = {name = "helmet_stand",       forever = false, delay = 0.10} }
    actions[#actions + 1] = {name = "slide",      animation = {name = "helmet_slide",       forever = true,  delay = 0.10} }
    actions[#actions + 1] = {name = "jump",       animation = {name = "helmet_jump",        forever = false, delay = 0.10} }
    actions[#actions + 1] = {name = "dashjump",   animation = {name = "helmet_dashjump",    forever = false, delay = 0.10} }
    actions[#actions + 1] = {name = "walk",       animation = {name = "helmet_walk",        forever = true,  delay = 0.12} }
    actions[#actions + 1] = {name = "hurt",       animation = {name = "helmet_hurt",        forever = false, delay = 0.02} }
    actions[#actions + 1] = {name = "standshoot", animation = {name = "helmet_standshoot",  forever = false, delay = 0.10} }
    actions[#actions + 1] = {name = "walkshoot",  animation = {name = "helmet_walkshoot",   forever = true,  delay = 0.12} }
    actions[#actions + 1] = {name = "jumpshoot",  animation = {name = "helmet_jumpshoot",   forever = false, delay = 0.10} }

    self.sprite_:load_actions_set(actions, true, self.base_name_)

    self.browner_id_ = cc.browners_.helmet_.id_       -- overriden from parent
end

function helmet_browner:spawn()
    self.energy_ = nil
end

return helmet_browner