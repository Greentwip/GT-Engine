-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local camera      = import("app.core.physics.kinematic_character").create("camera")

function camera:onCreate()
    self.camera_mode_ = cc.CAMERA.MODE.SCREEN
    self.scroll_ = cc.CAMERA.SCROLL.NONE
    self.shift_direction_ = cc.CAMERA.SHIFT.NONE
    self.shift_speed_ = 4
    self.boss_door_shift_ = false
    self.target_door_ = nil
    self.boss_door_working_ = false

    self.proto_shift_speed_ = 0.3
    self.shift_move_count_ = 0
end

function camera:animate(cname)
    return self
end

function camera:prepare(player)
    self.player_ = player
    self.speed_ = cc.p(0, 0)
    self.tolerance_ = 16
    self:getPhysicsBody():getShapes()[1]:setTag(cc.tags.camera)
    self.free_scroll_ = nil

    return self
end

function camera:update_bounding_box()
    local body_center  = self.kinematic_body_:center()

    local move_amount_x = self:getParent():getPositionX() - body_center.x
    local move_amount_y = self:getParent():getPositionY() - body_center.y

    body_center.x = body_center.x - move_amount_x
    body_center.y = body_center.y - move_amount_y

    local x_difference = self.kinematic_body_.body_center_.x - body_center.x
    local y_difference = self.kinematic_body_.body_center_.y - body_center.y

    if x_difference ~= 0 or y_difference ~= 0 then
        for i = 1, #self.kinematic_body_.bbox_ do
            self.kinematic_body_.bbox_[i].x = self.kinematic_body_.bbox_[i].x - x_difference
            self.kinematic_body_.bbox_[i].y = self.kinematic_body_.bbox_[i].y - y_difference
        end
        self.kinematic_body_.body_center_ = body_center
    end

end

function camera:solve_collisions()

    self.kinematic_body_:manual_update_collisions(cc.tags.scroll)

    self.scroll_collision_ = nil

    local collisions = self.kinematic_body_:get_collisions()

    for _, collision in  pairs(collisions) do

        if self.scroll_ == cc.CAMERA.SCROLL.MOVING then
            self.scroll_ = cc.CAMERA.SCROLL.NONE
            self.camera_mode_ = cc.CAMERA.MODE.SCREEN
        end
        if self.camera_mode_ == cc.CAMERA.MODE.SCREEN then
            self.camera_mode_ = cc.CAMERA.MODE.SCROLL
            self.scroll_ = collision.scroll_
        end


        self.scroll_collision_ = collision
        self.tolerance_        = collision.tolerance_
    end

    if self.free_scroll_ ~= self.player_.free_scroll_ then
        self.free_scroll_ = self.player_.free_scroll_

        self.scroll_collision_ = nil

--        self.camera_mode_   = cc.CAMERA.MODE.SCROLL
--        self.scroll_        = cc.CAMERA.SCROLL.MOVING
        self:setPositionX(self:getPositionX() + self.player_:getPositionX() - cc.bounds_:getPositionX())
    end

end

function camera:step(dt)

    self.current_speed_ = self.speed_
    self:kinematic_post_step(dt)

    self:update_bounding_box()

    if self.camera_mode_ ~= cc.CAMERA.MODE.SHIFT then
        self:solve_collisions()
    end

    if not self.player_.alive_ then
        return
    end

    if self.static_mode_ then
            self:getScene():getDefaultCamera():setPositionX(self.static_position_.x)
            self:getScene():getDefaultCamera():setPositionY(self.static_position_.y)
        return
    end


    if self.camera_mode_ == cc.CAMERA.MODE.SCROLL then

        if self.scroll_ == cc.CAMERA.SCROLL.LEFT and self.player_:getPositionX() < cc.bounds_:center().x then
            self.scroll_ = cc.CAMERA.SCROLL.MOVING
        end

        if self.scroll_ == cc.CAMERA.SCROLL.RIGHT and self.player_:getPositionX() > cc.bounds_:center().x then
            self.scroll_ = cc.CAMERA.SCROLL.MOVING
        end

        if self.scroll_ == cc.CAMERA.SCROLL.MOVING then

            local position = cc.p(self:getPositionX(), self:getPositionY())
            position = self:convertToWorldSpace(position)

            local diff = self.player_:getPositionX() - position.x

            if self.player_:getPositionX() > position.x + self.tolerance_ then
                if self.player_:getPositionX() - self.tolerance_ > position.x then
                    cc.bounds_:setPositionX(cc.bounds_:getPositionX() + diff - self.tolerance_)
                end
            elseif self.player_:getPositionX() < position.x - self.tolerance_ then
                if self.player_:getPositionX() + self.tolerance_ < position.x then
                    cc.bounds_:setPositionX(cc.bounds_:getPositionX() + diff + self.tolerance_)
                end
            end

        end

    end

    if self.camera_mode_ ~= cc.CAMERA.MODE.SHIFT then

        local player_bbox_bottom = self.player_:bottom()
        local player_bbox_top    = self.player_:top()

        if self.player_:getPositionX() >= cc.bounds_:right() then
            self.shift_direction_ = cc.CAMERA.SHIFT.RIGHT
        elseif self.player_:getPositionX() <= cc.bounds_:left() then
            self.shift_direction_ = cc.CAMERA.SHIFT.LEFT
        elseif player_bbox_bottom < cc.bounds_:bottom() then
            self.shift_direction_ = cc.CAMERA.SHIFT.DOWN
            if not self.player_.climbing_ then
                --image_speed = 0;
            end
        elseif player_bbox_top > cc.bounds_:top() and self.player_.current_browner_.climbing_ then
            self.shift_direction_ = cc.CAMERA.SHIFT.UP
        else
            self.shift_direction_ = cc.CAMERA.SHIFT.NONE
        end

        if self.player_.in_door_ ~= nil then
            if self.player_.in_door_:getPositionX() > self.player_:getPositionX() and not self.boss_door_shift_ then
                self.shift_direction_ = cc.CAMERA.SHIFT.RIGHT
            elseif self.player_.in_door_:getPositionX() < self.player_:getPositionX() and not self.boss_door_shift_ then
                self.shift_direction_ = cc.CAMERA.SHIFT.LEFT
            end
        end

        if self.shift_direction_ ~= cc.CAMERA.SHIFT.NONE then
            self.camera_mode_ = cc.CAMERA.MODE.SHIFT
        end

        if self.shift_direction_ == cc.CAMERA.SHIFT.RIGHT or self.shift_direction_ == cc.CAMERA.SHIFT.LEFT then
            self.shift_move_count_ = 256
        elseif self.shift_direction_ == cc.CAMERA.SHIFT.UP or self.shift_direction_ == cc.CAMERA.SHIFT.DOWN then
            self.shift_move_count_ = 224
        end

    end

    if self.scroll_collision_ ~= nil and self.camera_mode_ ~= cc.CAMERA.MODE.SHIFT then

        local camera_shape_size = self:getPhysicsBody():getShapes()[1].size_
        local scroll_shape_size = self.scroll_collision_:getPhysicsBody():getShapes()[1].size_

        if self.scroll_collision_.scroll_ == cc.CAMERA.SCROLL.RIGHT then
            if cc.bounds_:getPositionX() - camera_shape_size.width * 0.5 < self.scroll_collision_:getPositionX() + scroll_shape_size.width * 0.5 then
                cc.bounds_:setPositionX(self.scroll_collision_:getPositionX() + camera_shape_size.width * 0.5 + scroll_shape_size.width * 0.5)
            end
        end

        if self.scroll_collision_.scroll_ == cc.CAMERA.SCROLL.LEFT then
            if cc.bounds_:getPositionX() + camera_shape_size.width * 0.5 > self.scroll_collision_:getPositionX() - scroll_shape_size.width * 0.5 then
                cc.bounds_:setPositionX(self.scroll_collision_:getPositionX() - camera_shape_size.width * 0.5 - scroll_shape_size.width * 0.5)
            end
        end
    end

    if self.camera_mode_ == cc.CAMERA.MODE.SHIFT then
        if cc.game_status_ == cc.GAME_STATUS.RUNNING then
            cc.pause(true)
        end

        if self.target_door_ == nil then
            if self.player_.in_door_ and not self.boss_door_shift_ then
                self.target_door_ = self.player_.in_door_
                self.boss_door_shift_ = true
                self.boss_door_working_ = true
                self.target_door_:unlock(function()
                    self.boss_door_working_ = false
                end)
            end
        end

        if not self.boss_door_working_ and self.shift_move_count_ > 0 then
            if self.shift_direction_ == cc.CAMERA.SHIFT.RIGHT then

                cc.bounds_:setPositionX(cc.bounds_:getPositionX() + self.shift_speed_)
                self:getScene():getDefaultCamera():setPositionX(cc.bounds_:getPositionX())

                self.shift_move_count_ = self.shift_move_count_ - self.shift_speed_
                if self.boss_door_shift_ then
                    self.player_:setPositionX(self.player_:getPositionX() + self.proto_shift_speed_ + 0.5)
                else
                    self.player_:setPositionX(self.player_:getPositionX() + self.proto_shift_speed_)
                end

            elseif self.shift_direction_ == cc.CAMERA.SHIFT.LEFT then
                cc.bounds_:setPositionX(cc.bounds_:getPositionX() - self.shift_speed_)
                self:getScene():getDefaultCamera():setPositionX(cc.bounds_:getPositionX())

                self.shift_move_count_ = self.shift_move_count_ - self.shift_speed_
                if self.boss_door_shift_ then
                    self.player_:setPositionX(self.player_:getPositionX() - self.proto_shift_speed_ - 0.5)
                else
                    self.player_:setPositionX(self.player_:getPositionX() - self.proto_shift_speed_)
                end

            elseif self.shift_direction_ == cc.CAMERA.SHIFT.UP then

                cc.bounds_:setPositionY(cc.bounds_:getPositionY() + self.shift_speed_)
                self:getScene():getDefaultCamera():setPositionY(cc.bounds_:getPositionY())

                self.shift_move_count_ = self.shift_move_count_  - self.shift_speed_
                self.player_:setPositionY(self.player_:getPositionY() + self.proto_shift_speed_ + 0.15)

            elseif self.shift_direction_ == cc.CAMERA.SHIFT.DOWN then

                cc.bounds_:setPositionY(cc.bounds_:getPositionY() - self.shift_speed_)
                self:getScene():getDefaultCamera():setPositionY(cc.bounds_:getPositionY())

                self.shift_move_count_ = self.shift_move_count_  - self.shift_speed_
                self.player_:setPositionY(self.player_:getPositionY() - self.proto_shift_speed_ - 0.15)
            end
        end

        if self.shift_move_count_ <= 0 then

            if self.boss_door_shift_ then
                self.boss_door_shift_ = false

                self.target_door_:lock(function()
                    self.camera_mode_ = cc.CAMERA.MODE.SCREEN

                    self.boss_door_shift_ = false
                    self.target_door_ = nil
                    self.boss_door_working_ = false
                    if cc.game_status_ == cc.GAME_STATUS.PAUSED then
                        cc.pause(false)
                    end
                end)
            else
                if not self.boss_door_working_ and self.target_door_ == nil then
                    self.camera_mode_ = cc.CAMERA.MODE.SCREEN

                    if cc.game_status_ == cc.GAME_STATUS.PAUSED then
                        cc.pause(false)
                    end
                end

            end

        end

    end

    self:getScene():getDefaultCamera():setPositionX(cc.bounds_:getPositionX())
    self:getScene():getDefaultCamera():setPositionY(cc.bounds_:getPositionY())


    return self
end

return camera