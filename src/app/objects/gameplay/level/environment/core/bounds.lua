-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local bounds = class("bounds", cc.Node)

function bounds:ctor()

    self.size_   =  cc.Director:getInstance():getVisibleSize()

    self.body_ = cc.PhysicsBody:createEdgeBox(self.size_, cc.PhysicsMaterial(0.0, 0.0, 0.0), 1, cc.p(0.0, 0.0))
                               :setDynamic(false)
                               :setCollisionBitmask(0x00000000)
                               :setContactTestBitmask(0xFFFFFFFF)
                               :setRotationEnable(false)

    self:setPhysicsBody(self.body_)

    self.body_:getShapes()[1]:setTag(cc.tags.bounds)

end

function bounds:is_point_inside(point)
    return cc.rectContainsPoint(self:bbox_rect(), point)
end

function bounds:is_rect_inside(rect)
    return cc.rectIntersectsRect(self:bbox_rect(), rect)
end


function bounds:bbox_rect()
    local rect = cc.rect(self:left(), self:bottom(), self:right() - self:left(), self:top() - self:bottom())
    return rect
end

function bounds:width()
    return self.size_.width
end

function bounds:height()
    return self.size_.height
end

function bounds:top()
    local bound = self:getPositionY() + self.size_.height * 0.5
    return bound --self:convertToWorldSpace(cc.p(0, bound)).y
end

function bounds:bottom()
    local bound = self:getPositionY() - self.size_.height * 0.5
    return bound --self:convertToWorldSpace(cc.p(0, bound)).y
end

function bounds:left()
    local bound = self:getPositionX() - self.size_.width * 0.5
    return bound --self:convertToWorldSpace(cc.p(bound, 0)).x
end

function bounds:right()
    local bound = self:getPositionX() + self.size_.width * 0.5

    return bound --self:convertToWorldSpace(cc.p(bound, 0)).x
end

function bounds:center()
    local shape_center = cc.p(self:getPositionX(), self:getPositionY())
    return shape_center --self:convertToWorldSpace(shape_center)
end

function bounds:left_top()
    return cc.p(self:left(), self:top())
end


return bounds

