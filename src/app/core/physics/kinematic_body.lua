-- Copyright 2014-2015 Greentwip. All Rights Reserved.


local kinematic_body    = class("kinematic_body", cc.Node)

function kinematic_body:ctor(body)
    self.body_ = body

    self.contacts_ = {}
    self.collisions_ = {}

    self.contacts_[cc.kinematic_contact_.up] = false
    self.contacts_[cc.kinematic_contact_.down] = false
    self.contacts_[cc.kinematic_contact_.left]  = false
    self.contacts_[cc.kinematic_contact_.right] = false

    self.bbox_ = {}

    self.collision_callback_ = function(world, shape)
        self:solve_collisions(world, shape)
        return true
    end

    self.non_blocking_collision_callback_ = function(world, shape)
        self:non_blocking_solve_collisions(world, shape)
        return true
    end

    self.manual_collision_callback_ = function(world, shape)
        self:manual_solve_collisions(world, shape)
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

function kinematic_body:prepare()
    self:compute_bounding_box()
end

function kinematic_body:swap_shape(index)
    self.shape_index_ = index
    self.current_shape_ = self.shapes_[self.shape_index_]
    self:compute_bounding_box()
end

function kinematic_body:get_shape_index()
    return self.shape_index_
end

function kinematic_body:center()
    local center = self.current_shape_:getCenter()
    local world_center = self:convertToWorldSpace(center)
    return world_center

end

function kinematic_body:bbox()
    local rect = cc.rect(self.bbox_[7].x, self.bbox_[7].y, self.current_shape_.size_.width, self.current_shape_.size_.height)
    return rect
end


-- swap tiles
-----------------
-- 1 -- 2 -- 3 --
-- 4 -- 5 -- 6 --
-- 7 -- 8 -- 9 --
-----------------

-----------------
-- 5 -- 2 -- 6 --
-- 3 --   -- 4 --
-- 7 -- 1 -- 8 --
-----------------

function kinematic_body:compute_bounding_box()
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

function kinematic_body:update_bounding_box()
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

--[[

function kinematic_body:update_bounding_box()

    local body_center  = self:center()

    local move_amount_x = self:getParent():getPositionX() - body_center.x
    local move_amount_y = self:getParent():getPositionY() - body_center.y

    body_center.x = body_center.x - move_amount_x
    body_center.y = body_center.y - move_amount_y

    local x_difference = self.body_center_.x - body_center.x
    local y_difference = self.body_center_.y - body_center.y

    if x_difference ~= 0 or y_difference ~= 0 then
        for i = 1, #self.bbox_ do
            self.bbox_[i].x = self.bbox_[i].x - x_difference
            self.bbox_[i].y = self.bbox_[i].y - y_difference
        end
        self.body_center_ = body_center
    end

end

]]--

--[[

function kinematic_body:recompute_bounding_box()
    local body_center  = self:center()

    local move_amount_x = self:getParent():getPositionX() - self:center().x
    local move_amount_y = self:getParent():getPositionY() - self:center().y

    body_center.x = body_center.x + move_amount_x
    body_center.y = body_center.y + move_amount_y

    local x_difference = self.body_center_.x - body_center.x
    local y_difference = self.body_center_.y - body_center.y

    if x_difference ~= 0 or y_difference ~= 0 then
        for i = 1, #self.bbox_ do
            self.bbox_[i].x = self.bbox_[i].x - x_difference
            self.bbox_[i].y = self.bbox_[i].y - y_difference
        end
        self.body_center_ = body_center
    end
end
]]--


function kinematic_body:recompute_bounding_box(new_center)

    local x_offset
    local y_offset

    if new_center.x ~= nil then
        x_offset = self.body_center_.x - new_center.x
        self.body_center_.x = new_center.x
    end

    if new_center.y ~= nil then
        y_offset = self.body_center_.y - new_center.y
        self.body_center_.y = new_center.y
    end

    for i = 1, #self.bbox_ do
        if x_offset ~= nil then
            self.bbox_[i].x = self.bbox_[i].x - x_offset
        end

        if y_offset ~= nil then
            self.bbox_[i].y = self.bbox_[i].y - y_offset
        end
    end
end

function kinematic_body:solve_collisions(_, shape)

    if shape ~= self.current_shape_ and shape ~= nil then
        local shape_node = shape:getBody():getNode()
        if shape:getTag() == cc.tags.block then

            local new_origin = {x = nil, y = nil}

            local body_w       = self.current_shape_.size_.width
            local body_h       = self.current_shape_.size_.height

            local shape_center = shape_node:convertToWorldSpace(shape:getCenter())
            local shape_size   = shape.size_

            local shape_left    = shape_center.x - (shape_size.width * 0.5)
            local shape_bottom  = shape_center.y - (shape_size.height * 0.5)
            local shape_top     = shape_bottom + shape_size.height
            local shape_right   = shape_left   + shape_size.width

            local shape_box = cc.rect(shape_left, shape_bottom, shape_size.width , shape_size.height)

            for i = 1, 8 do

                if cc.rectIntersectsRect(self.bbox_[i], shape_box) then

                    local intersection = cc.rectIntersection(self.bbox_[i], shape_box)

                    if i == 1 then
                        new_origin.y = shape_top + body_h * 0.5
                        intersection.width = 0
                        self.contacts_[cc.kinematic_contact_.down] = true
                    elseif i == 2 then
                        new_origin.y = shape_bottom - (body_h * 0.5)

                        intersection.width = 0
                        intersection.height = -intersection.height
                        self.contacts_[cc.kinematic_contact_.up] = true
                    elseif i == 3 then
                        new_origin.x = shape_right + (body_w * 0.5)

                        intersection.height = 0
                        self.contacts_[cc.kinematic_contact_.left] = true
                    elseif i == 4 then
                        new_origin.x = shape_left - (body_w * 0.5)

                        intersection.height = 0
                        intersection.width = -intersection.width
                        self.contacts_[cc.kinematic_contact_.right] = true
                    else

                        if intersection.width >= intersection.height then
                            -- tile is diagonal, but resolving collision vertically
                            local resolution_height

                            if i == 5 or i == 6 then
                                resolution_height = shape_bottom - (body_h * 0.5)

                                intersection.width  = 0
                                intersection.height = -intersection.height
                                self.contacts_[cc.kinematic_contact_.up] = true
                            else -- 7 and 8
                                resolution_height = shape_top + (body_h * 0.5)

                                intersection.width = 0
                                self.contacts_[cc.kinematic_contact_.down] = true
                            end

                            new_origin.y = resolution_height

                        else
                            -- tile is diagonal, but resolving horizontally
                            local resolution_width

                            if i == 7 or i == 5 then
                                resolution_width = shape_right + (body_w * 0.5)

                                intersection.height = 0
                                self.contacts_[cc.kinematic_contact_.left] = true
                            else
                                resolution_width = shape_left - (body_w * 0.5)

                                intersection.height = 0
                                intersection.width = -intersection.width
                                self.contacts_[cc.kinematic_contact_.right] = true
                            end
                            new_origin.x = resolution_width

                        end
                    end

                    self:recompute_bounding_box(new_origin)

                    if --intersection.width ~= 0
                            --and
                            new_origin.x ~= nil
                    then
                        self:getParent():setPositionX(new_origin.x - self.current_shape_:getCenter().x)
                        --self:getParent():setPositionX(self:getParent():getPositionX() - self.current_shape_:getCenter().x - intersection.width)
                    end

                    if --intersection.height ~= 0
                            --and
                            new_origin.y ~= nil
                    then
                        self:getParent():setPositionY(new_origin.y - self.current_shape_:getCenter().y)
                        --self:getParent():setPositionY(self:getParent():getPositionY() - body_offset.height + intersection.height)
                    end

                end

            end
        else
            if shape:getTag() ~= cc.tags.bounds then -- you don't need the bounds, in this video game, yet.
                self.collisions_[shape:getBody():getNode()] = shape:getBody():getNode()
            end
        end
    end

end

function kinematic_body:non_blocking_solve_collisions(_, shape)
    if shape ~= self.current_shape_ and shape ~= nil then
        if shape:getTag() ~= cc.tags.bounds then -- you don't need the bounds, in this video game, yet.
            self.collisions_[shape:getBody():getNode()] = shape:getBody():getNode()
        end
    end
end

function kinematic_body:non_blocking_compute_position()
    self:update_bounding_box()

    for i = 1, #self.contacts_ do
        self.contacts_[i] = false
    end

    self.collisions_ = {}

    local rect = cc.rect(self.bbox_[7].x, self.bbox_[7].y, self.current_shape_.size_.width, self.current_shape_.size_.height)

    self:getScene():getPhysicsWorld():queryRect(self.non_blocking_collision_callback_, rect)
end

function kinematic_body:compute_position()
    self:update_bounding_box()

    for i = 1, #self.contacts_ do
        self.contacts_[i] = false
    end

    self.collisions_ = {}

    local rect = cc.rect(self.bbox_[7].x, self.bbox_[7].y, self.current_shape_.size_.width, self.current_shape_.size_.height)

    self:getScene():getPhysicsWorld():queryRect(self.collision_callback_, rect)

end

function kinematic_body:get_collisions()
    return self.collisions_
end

-- special, collision checking only, called manually
-- you should define and call your own update_bounding_box before calling manual_update_collisions
function kinematic_body:manual_solve_collisions(world, shape)
    if shape ~= self.body_:getShapes()[1] and shape ~= nil then
        if shape:getTag() == self.collision_tag_ then
            self.collisions_[shape:getBody():getNode()] = shape:getBody():getNode()
        end
    end
end

function kinematic_body:manual_update_collisions(tag)
    self.collisions_ = {}

    self.collision_tag_ = tag

    local rect = cc.rect(self.bbox_[7].x, self.bbox_[7].y, self.current_shape_.size_.width, self.current_shape_.size_.height)

    self:getScene():getPhysicsWorld():queryRect(self.manual_collision_callback_, rect)

end


return kinematic_body
