-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local block = class("block", cc.Node)

function block:ctor(position, size)
    self:setup(position, size)
end

function block:setup(position, size)
    self:setPosition(cc.p(position.x, position.y))

    local body = cc.PhysicsBody:create()
    body:setDynamic                 (false)
    body:setRotationEnable          (false)
    body:setVelocityLimit           (400)


    -- polygon shape

    local material = cc.PhysicsMaterial(0, 0, 0)


    local polygon = {
        cc.p( size.width * 0.5,  size.height * 0.5),
        cc.p( size.width * 0.5, -size.height * 0.5),
        cc.p(-size.width * 0.5, -size.height * 0.5),
        cc.p(-size.width * 0.5,  size.height * 0.5)
    }

    local shape = cc.PhysicsShapePolygon:create(polygon,
                                                material,
                                                cc.p(0,0))

    shape:setTag                (cc.tags.block)
    shape.size_ = size

    body:addShape(shape)

    --apply physicsBody to the block
    self:setPhysicsBody(body)
end

return block
