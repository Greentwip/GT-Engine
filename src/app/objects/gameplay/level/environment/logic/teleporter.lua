-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local block = import("app.objects.gameplay.level.environment.core.block")
local teleporter = class("teleporter", block)

function teleporter:ctor(position, size)
    self:setup(position, size)
    self:getPhysicsBody():getShapes()[1]:setTag(cc.tags.teleporter)
end

function teleporter:prepare(raw_element)
    return self
end

return teleporter





