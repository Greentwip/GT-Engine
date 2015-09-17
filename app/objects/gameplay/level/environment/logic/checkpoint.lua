--
-- Created by Victor on 8/22/2015 5:48 PM
--

local block = import("app.objects.gameplay.level.environment.core.block")
local checkpoint = class("checkpoint", block)

function checkpoint:ctor(position, size)
    self:setup(position, size)
    self:getPhysicsBody():getFirstShape():setTag(cc.tags.check_point)
end

function checkpoint:prepare(raw_element)
    if raw_element.type == "first" then
    self.type_ = cc.tags.logic.check_point.first_
    end
    return self
end

return checkpoint



