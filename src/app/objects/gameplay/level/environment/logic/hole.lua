--
-- Created by Victor on 8/22/2015 5:50 PM
--

local block = import("app.objects.gameplay.level.environment.core.block")

local hole = class("hole", block)

function hole:ctor(position, size)
    self:setup(position, size)
    self:getPhysicsBody():getFirstShape():setTag(cc.tags.hole)
end

function hole:init(raw_element)
    return self
end

return hole







