-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local browner           = import("app.objects.characters.player.browners.base.browner")
local teleport_browner  = class("teleport_browner", browner)

function teleport_browner:ctor(sprite)
    self.super:ctor(sprite)

    -- constraints
    self.can_attack_    = false
    self.can_slide_     = false
    self.can_jump_      = true
    self.can_dash_jump_ = false
    self.can_walk_      = false
    self.can_charge_    = false

    self.base_name_ = "teleport"

    local actions = {}
    actions[#actions + 1] = {name = "jump",      animation = {name = "teleport_jump",       forever = true, delay = 0.12} }
    self.sprite_:load_actions_set(actions, true, self.base_name_)

    self.browner_id_ = cc.browners_.teleport_.id_       -- overriden from parent
end

function teleport_browner:spawn()
    self.energy_ = nil
end


return teleport_browner


