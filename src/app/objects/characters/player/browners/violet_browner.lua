-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local violet_browner = import("app.objects.characters.player.browners.base.browner").create("violet_browner")

function violet_browner:bake()

    self.base_name_ = "violet"

    local actions = {}
    actions[#actions + 1] = {name = "stand",      animation = {name = "violet_stand",       forever = true,  delay = 1.00} }
    actions[#actions + 1] = {name = "slide",      animation = {name = "violet_slide",       forever = true,  delay = 0.10} }
    actions[#actions + 1] = {name = "climb",      animation = {name = "violet_climb",       forever = true,  delay = 0.16} }
    actions[#actions + 1] = {name = "jump",       animation = {name = "violet_jump",        forever = false, delay = 0.10} }
    actions[#actions + 1] = {name = "dashjump",   animation = {name = "violet_dashjump",    forever = false, delay = 0.10} }
    actions[#actions + 1] = {name = "walk",       animation = {name = "violet_walk",        forever = true,  delay = 0.12} }
    actions[#actions + 1] = {name = "standshoot", animation = {name = "violet_standshoot",  forever = false, delay = 0.10} }
    actions[#actions + 1] = {name = "walkshoot",  animation = {name = "violet_walkshoot",   forever = true,  delay = 0.12} }
    actions[#actions + 1] = {name = "jumpshoot",  animation = {name = "violet_jumpshoot",   forever = false, delay = 0.10} }
    actions[#actions + 1] = {name = "climbshoot", animation = {name = "violet_climbshoot",  forever = false, delay = 0.10} }
    actions[#actions + 1] = {name = "hurt",       animation = {name = "violet_hurt",        forever = false, delay = 0.02} }
    actions[#actions + 1] = {name = "morph",      animation = {name = "violet_morph",       forever = false, delay = 0.10} }

    self.sprite_:load_actions_set(actions, false, self.base_name_)
    self.browner_id_ = cc.browners_.violet_.id_       -- overriden from parent
    return self
end

function violet_browner:spawn()
    self.energy_ = nil
end

return violet_browner