-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local block = import("app.objects.gameplay.level.environment.core.block")
local scroll = class("scroll", block)

function scroll:ctor(position, size)
    self:setup(position, size)
    self:getPhysicsBody():getShapes()[1]:setTag(cc.tags.scroll)
end

function scroll:prepare(raw_element)
    local scroll_direction = cc.CAMERA.SCROLL.RIGHT

    if raw_element.type == "left" then
        scroll_direction = cc.CAMERA.SCROLL.LEFT
    end

    if raw_element.tolerance ~= nil then
        self.tolerance_ = tonumber(raw_element.tolerance)
    else
        self.tolerance_ = 16
    end

    self.scroll_ = scroll_direction
    return self
end

return scroll



