-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local weapon_animation  = class("weapon_animation", cc.Node)
local sprite            = import("app.core.graphical.sprite")

function weapon_animation:ctor()

    self.sprite_ = sprite:create("sprites/gameplay/screens/pause_menu/pause_animation/pause_animation", cc.p(0.5, 0))
                         :setPosition(cc.p(0,0))
                         :addTo(self)

    local actions = {}
    actions[#actions + 1] = {name = "violet",   animation = {name = "violet_animation",     forever = true, delay = 0.10} }
    actions[#actions + 1] = {name = "ex",       animation = {name = "ex_animation",         forever = true, delay = 0.10} }
    actions[#actions + 1] = {name = "helmet",   animation = {name = "helmet_animation",     forever = true, delay = 0.10} }
    actions[#actions + 1] = {name = "fuzzy",    animation = {name = "fuzzy_animation",      forever = true, delay = 0.10} }

    actions[#actions + 1] = {name = "sheriff",  animation = {name = "sheriff_animation",    forever = true, delay = 0.10} }

    actions[#actions + 1] = {name = "military", animation = {name = "military_animation",   forever = true, delay = 0.10} }
    actions[#actions + 1] = {name = "vine",     animation = {name = "vine_animation",       forever = true, delay = 0.10} }

    actions[#actions + 1] = {name = "night",    animation = {name = "night_animation",      forever = true, delay = 0.10} }

    self.sprite_:load_actions_set(actions, false)
end

function weapon_animation:swap(animation)
    self.sprite_:run_action(animation)
    return self
end

return weapon_animation