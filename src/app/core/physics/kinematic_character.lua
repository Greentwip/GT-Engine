-- Copyright 2014-2015 Greentwip. All Rights Reserved.


local sprite  = import ("app.core.graphical.sprite")
local armature = import ("app.core.physics.armature")

local kinematic_character = {}

function kinematic_character.create(class_name)

    local kinematic_body    = import("app.core.physics.kinematic_body")
    local character         = class(class_name, cc.Node)

    function character:ctor(args)
        self.current_speed_ = cc.p(0,0)

        self.on_ground_ = false

        self.jump_speed_ = cc.p(60, 320)
        self.walk_speed_ = 60

        self.movement_is_non_blockable_ = false

        if self.onCreate then
            self:onCreate(args)
        end
    end

    function character:setup(category, subcategory, package, cname)

        local sprite_path       = "sprites/" .. category .. "/" .. subcategory .. "/" .. package .. "/" .. cname .. "/" .. cname
        local physics_path      = "physics/" .. category .. "/" .. subcategory .. "/" .. package .. "/" .. cname .. "/" .. cname

        self:load(sprite_path)
        self:articulate(physics_path, cname)

        if self.animate then
            self:animate(cname)
        end

        return self
    end

    function character:load(sprite_path)

        if cc.FileUtils:getInstance():isFileExist(sprite_path .. ".plist") then
            self.sprite_ = sprite:create(sprite_path, cc.p(0.5, 0.5))
                                 :setPosition(cc.p(0, 0))
                                 :addTo(self)
        else
            self.sprite_ = nil
        end

    end

    -- must implement function character:animate in children if children has animations.

    function character:articulate(physics_path, cname)

        local armature = armature:create(physics_path)

        local armature_anchor = armature:def(cname).anchor_point_

        if self.sprite_ ~= nil then

            self.sprite_:setAnchorPoint(armature_anchor)
                        :setPosition(cc.p(0,0))

            self.sprite_.default_anchor_ = armature_anchor

            self.kinematic_body_ = kinematic_body:create(armature:body(cname, self.sprite_:getContentSize()))
                                                 :setAnchorPoint(armature_anchor)
                                                 :setPosition(cc.p(0,0))
                                                 :addTo(self)

            --self.sprite_:setPositionX(self.sprite_:getPositionX() - self.kinematic_body_.current_shape_:getCenter().x)
            --self.sprite_:setPositionY(self.sprite_:getPositionY() - self.kinematic_body_.current_shape_:getCenter().y)
        else
            self.kinematic_body_ = kinematic_body:create(armature:body(cname, nil))
                                                 :setPosition(cc.p(0,0))
                                                 :setAnchorPoint(armature_anchor)
                                                 :addTo(self)
        end

        self.contacts_ = self.kinematic_body_.contacts_
        self:setPhysicsBody(self.kinematic_body_.body_)

--        self.kinematic_body_.body_:setAnchorPoint(armature_anchor)

--        self.kinematic_body_:setPosition()
--        self:setAnchorPoint(armature:def(cname).anchor_point_)

        self.kinematic_body_:prepare()
    end

    function character:compute_position()
        if self.movement_is_non_blockable_ then
            self.kinematic_body_:non_blocking_compute_position()
        else
            self.kinematic_body_:compute_position()
        end

    end

    function character:walk() -- override in children
    end

    function character:jump() -- override in children
    end

    function character:move()
        self.current_speed_ = self.kinematic_body_.body_:getVelocity()

        if self.contacts_[cc.kinematic_contact_.down] then
            self.current_speed_.y = 0
        end

        self:walk()
        self:jump()

        if self.contacts_[cc.kinematic_contact_.up] then
            self.current_speed_.y = -1
        end

        if self.contacts_[cc.kinematic_contact_.right] then
            if self.current_speed_.x > 0 then
                self.current_speed_.x = 0
            end
        elseif self.contacts_[cc.kinematic_contact_.left] then
            if self.current_speed_.x < 0 then
                self.current_speed_.x = 0
            end
        end

    end

    function character:kinematic_step(dt)
        if cc.game_status_ == cc.GAME_STATUS.RUNNING then
            self:compute_position()
            self:move()
        end
    end

    function character:kinematic_post_step(dt)

        if cc.game_status_ == cc.GAME_STATUS.RUNNING then

            if self.kinematic_body_.body_:getVelocity().x ~= self.current_speed_.x
                or self.kinematic_body_.body_:getVelocity().y ~= self.current_speed_.y then

                self.kinematic_body_.body_:setVelocity(self.current_speed_)

            end

        else
            self.kinematic_body_.body_:setVelocity(cc.p(0, 0))
            self.kinematic_body_.collisions_ = {}
        end

    end

    function character:step(dt)
        self:kinematic_step(dt)
        return self
    end

    function character:post_step(dt)
        self:kinematic_post_step(dt)
        return self
    end

    return character
end


return kinematic_character



