-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local block = import("app.objects.gameplay.level.environment.core.block")
local free_scroll = class("free_scroll", block)

function free_scroll:ctor(position, size)
    self:setup(position, size)
    self:getPhysicsBody():getShapes()[1]:setTag(cc.tags.free_scroll)
end

function free_scroll:prepare(raw_element)
    --[[
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

    ]]--
    return self
end

return free_scroll





