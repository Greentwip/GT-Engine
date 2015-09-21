-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local special   = import("app.core.physics.kinematic_character").create("falling_block")

local RoundBy   = import("app.core.actions.RoundBy")

function special:onCreate(args)
    self.player_contact_ = false
    self.duration_ = 4.0
    self.rotating_ = false
    self.start_position_ = args.real_position_
    self:setPosition(self.start_position_)

    self.previous_x_ = self:getPositionX()
    self.new_x_      = self:getPositionX()

    self.previous_y_ = self:getPositionY()
    self.new_y_      = self:getPositionY()


    self.status_ = cc.special_.status_.on_screen_

    if args.raw_object_.radius ~= nil then
        self.radius_ = args.raw_object_.radius
    else
        self.radius_ = 16
    end

    if args.raw_object_.direction ~= nil then
        if args.raw_object_.direction == "right" then
            self.direction_ = 1
        else
            self.direction_ = -1
        end
        --
    end


end

function special:respawn()

end

function special:animate(cname)

    self.round_by_ = RoundBy:create(4, self.direction_, self.start_position_, self.radius_)
                            :start(self)

--    local bbox = self.sprite_:getBoundingBox()

--    self.sprite_:setPositionX(self.sprite_:getPositionX() - self.ratio_ - bbox.width * 0.5)
--    self.kinematic_body_:setPositionX(self.kinematic_body_:getPositionX() - self.ratio_ - bbox.width * 0.5)

--[[
    self.start_bbox_ = self.sprite_:getBoundingBox()
    local real_position = self:convertToWorldSpace(cc.p(self.start_bbox_.x, self.start_bbox_.y))

    self.start_bbox_.x = real_position.x
    self.start_bbox_.y = real_position.y
    ]]--



end


function special:solve_collisions()
    local collisions = self.kinematic_body_:get_collisions()

    self.player_collision_ = nil

    for _, collision in pairs(collisions) do
        if collision:getPhysicsBody():getShapes()[1]:getTag() == cc.tags.player then
--            if not collision.current_browner_.on_ground_ then

                self.player_collision_ = collision

--            end

        end
    end

end

function special:fix_position()
    if self.player_collision_ ~= nil then

        local collision = self.player_collision_
        collision.current_browner_.on_ground_ = true
        collision.current_browner_.dash_jumping_ = false
        collision.current_browner_.jumping_      = false
        collision.on_platform_ = true
        collision.current_browner_.speed_.y = 0

        local body_h       = collision.kinematic_body_.current_shape_.size_.height

        local shape_center = self:convertToWorldSpace(self.kinematic_body_.current_shape_:getCenter())
        local shape_size   = self.kinematic_body_.current_shape_.size_

        local shape_top     = shape_center.y - (shape_size.height * 0.5)
        local shape_left    = shape_center.x - (shape_size.width * 0.5)
        local shape_right   = shape_left   + shape_size.width

        local new_origin_y = shape_top + body_h * 0.5

        local final_y = new_origin_y - collision.kinematic_body_.current_shape_:getCenter().y  --to clamp player's position
        --final_y = math.floor(final_y)

        if collision:bottom() >= shape_top and collision:getPositionX() >= shape_left and collision:getPositionX() <= shape_right then

            local new_y
            if self.previous_y_ >= self.new_y_ then
                local diff = self.new_y_ - self.previous_y_

                if math.abs(diff) < 1 then
                    diff = -1
                end

                new_y = math.floor(collision:getPositionY() + diff)
                collision:setPositionY(new_y)
            else
                local diff = self.new_y_ - self.previous_y_

                if math.abs(diff) < 1 then
                    diff = 1
                end

                new_y = math.floor(collision:getPositionY() - (diff))
                collision:setPositionY(new_y)
            end


            collision:setPositionX(collision:getPositionX() - (self.previous_x_ - self.new_x_))
        end
    end
end


function special:jump() -- override in children


    self.previous_x_ = self:getPositionX()
    self.previous_y_ = self:getPositionY()


    self.current_speed_.y = 0

    self:solve_collisions()


    self.round_by_:update(1/60.0)

    self.new_x_ = self:getPositionX()
    self.new_y_ = self:getPositionY()



    self:fix_position()


    if self.rotating_ then
    else
        self.rotating_ = true


--[[

        local callback = cc.CallFunc:create(function()
            self.rotating_ = false
        end)

        ]]--

--        local sequence = cc.Sequence:create(rotation, callback, nil)

--        self:runAction(sequence)
    end


--[[    self:solve_collisions()

    if not self.falling_ then
        self.current_speed_.y = 0
    end

    local bbox = self.sprite_:getBoundingBox()
    local real_position = self:convertToWorldSpace(cc.p(bbox.x, bbox.y))

    bbox.x = real_position.x
    bbox.y = real_position.y

    if cc.bounds_:is_rect_inside(bbox) then
        if self.status_ == cc.special_.status_.off_screen_ then
            self.status_ = cc.special_.status_.on_screen_
        end
    else
        if self.status_ == cc.special_.status_.on_screen_ then
            if not cc.bounds_:is_rect_inside(self.start_bbox_) then
                self.sprite_:setVisible(true)
                self:setPosition(self.start_position_)
                self.status_ = cc.special_.status_.off_screen_
                self.player_contact_ = false
                self.falling_ = false
                self.current_speed_.y = 0
            end

        end

    end
    ]]--
end

return special



