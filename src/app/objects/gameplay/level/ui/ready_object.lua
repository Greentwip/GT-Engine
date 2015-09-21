-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local ready_object = class("ready_object", cc.Node)
local sprite = import("app.core.graphical.sprite")

function ready_object:ctor(player, callback)

    local init = function ()
        callback()
        player:spawn()
        self:removeSelf()
    end

    self.sprite_ = sprite:create("sprites/gameplay/level/ui/ready_object/ready_object")
                         :setPosition(cc.p(0, 0))
                         :addTo(self, 10)

    local actions = {}
    actions[#actions + 1] = {name = "ready", animation = {name = "spr_ready", forever = true, delay = 0.10} }

    self.sprite_:load_actions_set(actions, false)
    self.sprite_:run_action("ready")

    local delay = cc.DelayTime:create(2.0)
    local callback = cc.CallFunc:create(init)

    local sequence = cc.Sequence:create(delay, callback, nil)

    self:runAction(sequence)
end

return ready_object