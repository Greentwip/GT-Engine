-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local special   = import("app.core.physics.kinematic_character").create("falling_block")

function special:onCreate(args)
    self.player_contact_ = false
    self.movement_is_non_blockable_ = true

    self.time_to_fall_ = 0.7
    self.falling_ = false
    self.start_position_ = args.real_position_
    self:setPosition(self.start_position_)
    self.status_ = cc.special_.status_.on_screen_
end

function special:animate(cname)
    self.start_bbox_ = self.sprite_:getBoundingBox()
    local real_position = self:convertToWorldSpace(cc.p(self.start_bbox_.x, self.start_bbox_.y))

    self.start_bbox_.x = real_position.x
    self.start_bbox_.y = real_position.y
end

function special:solve_collisions()
    local collisions = self.kinematic_body_:get_collisions()

    for _, collision in pairs(collisions) do
        if collision:getPhysicsBody():getShapes()[1]:getTag() == cc.tags.player then
            if not self.player_contact_ then
                self.player_contact_ = true
                local delay = cc.DelayTime:create(self.time_to_fall_)

                local callback = cc.CallFunc:create(function()
                    self.falling_ = true
                end)

                local sequence = cc.Sequence:create(delay, callback, nil)

                self:runAction(sequence)

            end
        end
    end

end


function special:jump() -- override in children
    self:solve_collisions()

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
end

return special



