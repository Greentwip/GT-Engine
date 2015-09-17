--
-- Created by Victor on 8/22/2015 5:49 PM
--

local block = import("app.objects.gameplay.level.environment.core.block")
local teleporter = class("teleporter", block)

function teleporter:ctor(position, size)
    self:setup(position, size)
    self:getPhysicsBody():getFirstShape():setTag(cc.tags.teleporter)
end

function teleporter:prepare(raw_element)
    return self
end

return teleporter





