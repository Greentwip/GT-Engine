-- Copyright 2014-2015 Greentwip. All Rights Reserved.


local static_body    = class("static_body", cc.Node)

function static_body:ctor(body)
    self.body_ = body

    self.collisions_ = {}

    self.bbox_ = {}

    self.collision_callback_ = function(world, shape)
        self:solve_collisions(world, shape)
        return true
    end

    self.shapes_ = self.body_:getShapes()

    self.shape_index_ = 1
    self.current_shape_ = self.shapes_[self.shape_index_]

    for _, shape in pairs(self.shapes_) do

        local points_count = shape:getPointsCount()

        local first_point  = shape:getPoint(0)
        local second_point = shape:getPoint(1)

        local furthest_point = second_point

        local max_distance = cc.pGetDistance(first_point, second_point)

        for i = 2, points_count-1 do
            local other_point = shape:getPoint(i)

            local calculated_distance = cc.pGetDistance(first_point, other_point)
            if calculated_distance > max_distance then
                max_distance = calculated_distance
                furthest_point = other_point
            end
        end

        shape.size_ = cc.size(cc.pGetDistance(cc.p(first_point.x, 0), cc.p(furthest_point.x, 0)),
                              cc.pGetDistance(cc.p(0, first_point.y), cc.p(0, furthest_point.y)))
    end
end

function static_body:prepare()
    self:compute_bounding_box()
end

function static_body:swap_shape(index)
    self.shape_index_ = index
    self.current_shape_ = self.shapes_[self.shape_index_]
    self:compute_bounding_box()
end

function static_body:get_shape_index()
    return self.shape_index_
end

function static_body:center()
    local center = self.current_shape_:getCenter()
    local world_center = self:convertToWorldSpace(center)
    return world_center

end

function static_body:compute_bounding_box()
    local body_center  = self:center()

    local tiles = {}
    for i = 1, 9 do
        local column = (i-1)%3
        local row    = math.floor((i-1)/3)

        local tile_w = self.current_shape_.size_.width / 3
        local tile_h = self.current_shape_.size_.height / 3

        local bbox_left = body_center.x - self.current_shape_.size_.width  * 0.5                             -- getting bbox_left    [[[]]]] bounding
        local bbox_top  = body_center.y + self.current_shape_.size_.height * 0.5                             -- getting bbox_top     ------- bounding

        local point = cc.p(bbox_left + (tile_w * column), bbox_top - (tile_h * row))                                    -- pay no attention to the robot

        tiles[i] = cc.rect(point.x, point.y - tile_h, tile_w, tile_h)
    end

    self.bbox_[1] = tiles[8]
    self.bbox_[2] = tiles[2]
    self.bbox_[3] = tiles[4]
    self.bbox_[4] = tiles[6]
    self.bbox_[5] = tiles[1]
    self.bbox_[6] = tiles[3]
    self.bbox_[7] = tiles[7]
    self.bbox_[8] = tiles[9]

    self.body_center_ = body_center
end

function static_body:update_bounding_box()
    local body_center  = cc.p(self:getParent():getPositionX() + self.current_shape_:getCenter().x,
                              self:getParent():getPositionY() + self.current_shape_:getCenter().y)

    local x_offset = self.body_center_.x - body_center.x
    local y_offset = self.body_center_.y - body_center.y

    if x_offset ~= 0 or y_offset ~= 0 then
        for i = 1, #self.bbox_ do
            self.bbox_[i].x = self.bbox_[i].x - x_offset
            self.bbox_[i].y = self.bbox_[i].y - y_offset
        end

        self.body_center_ = body_center
    end

end

function static_body:solve_collisions(_, shape)
    if shape ~= self.current_shape_ and shape ~= nil then
        if shape:getTag() ~= cc.tags.bounds and shape:getTag() ~= cc.tags.block then
            self.collisions_[shape:getBody():getNode()] = shape:getBody():getNode()
        end
    end
end

function static_body:compute_position()
    self:update_bounding_box()
    self.collisions_ = {}

    local rect = cc.rect(self.bbox_[7].x, self.bbox_[7].y, self.current_shape_.size_.width, self.current_shape_.size_.height)

    self:getScene():getPhysicsWorld():queryRect(self.collision_callback_, rect)
end


function static_body:get_collisions()
    return self.collisions_
end

return static_body


