-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local enemy   = import("app.core.physics.kinematic_character").create("enemy")
local item    = import("app.objects.gameplay.level.goods.item")

function enemy:onCreate() -- should be called from children and values can be changed there.
    self.vulnerable_        = true
    self.attacking_         = false
    self.health_            = 1
    self.default_health_    = 1
    self.power_             = 1

    self.weapon_tag_        = cc.tags.weapon.enemy

    self.status_        = cc.enemy_.status_.inactive_ -- it is not ok for enemies to be in checkpoints
end

--function enemy:animate(cname) -- must be implemented in children for animations
--    return self
--end

function enemy:onRespawn() -- can be overriden in children to custom respawn options for the enemy.
      return self
end

function enemy:get_sprite_normal()
    local x_normal = -1

    if self.sprite_:isFlippedX() then
        x_normal = 1
    end

    local normal = cc.p(x_normal, 1)
    return normal
end

function enemy:prepare(position, player)
    self.start_position_    = position
    self.player_            = player
    self:setPosition(position)

    if self.on_after_init then
        self:on_after_init()
    end

    return self
end

function enemy:normalize_orientation()
    if not self.is_flipping_ then
        if self.player_:getPositionX() <= self:getPositionX() then
            if self.sprite_:isFlippedX() then
                self.is_flipping_ = true

                if self.flip then
                    self:flip(-1)   -- left normal, delegate self.is_flipping_
                else
                    self.sprite_:setFlippedX(false)
                    self.is_flipping_ = false
                end
            end
        else
            if not self.sprite_:isFlippedX() then
                self.is_flipping_ = true

                if self.flip then
                    self:flip(1)   -- right normal, self.is_flipping_
                else
                    self.sprite_:setFlippedX(true)
                    self.is_flipping_ = false
                end
            end
        end
    end
end

function enemy:on_after_blink()
    if not self:isVisible() then
       self:setVisible(true)
    end
end

function enemy:solve_collisions()
    local collisions = self.kinematic_body_:get_collisions()

    for _, collision in pairs(collisions) do
        if collision:getPhysicsBody():getShapes()[1]:getTag() == cc.tags.weapon.player then
            audio.playSound("sounds/sfx_enemyhit.wav", false)

            local blink = cc.Blink:create(0.2, 4)
            local callback = cc.CallFunc:create(self.on_after_blink)
            local sequence = cc.Sequence:create(blink, callback, nil)
            self.sprite_:runAction(sequence)


            self.health_ = self.health_ - collision.power_

            if collision.power_ >= 3 and self.health_ <= 0 then
                collision.disposed_ = false
            else
                collision.disposed_ = true
            end
        end
    end

end

function enemy:attack()
end

function enemy:check_health()
    if self.health_ <= 0 then
       self.health_ = 0
       self.status_ = cc.enemy_.status_.defeated_
    end
end

function enemy:onDefeated()

    audio.playSound("sounds/sfx_explosion1.wav", false)

    local random_item = math.floor(math.random(400))

    local item_array = {}

    if random_item < 4 then
        item_array[1] = "life"
    elseif random_item < 45 then
        local health_kind = {"health_small", "health_big" }
        item_array[1] = health_kind[math.floor(math.random(2))]
    elseif random_item < 100 then
        local energy_kind = {"energy_small", "energy_big" }
        item_array[1] = energy_kind[math.floor(math.random(2))]
    end


    if item_array[1] ~= nil then
        local item_good = item:create()
                              :setup("gameplay", "level", "goods", "item")
                              :setPosition(cc.p(self:getPositionX(), self:getPositionY()))

        item_good:swap(item_array[1], false)

        self:getParent():schedule_component(item_good)
    end

end

function enemy:fight()
    self:solve_collisions()
    self:normalize_orientation()
    self:attack()
    self:check_health()
end

function enemy:check_status()
    local bbox = self.sprite_:getBoundingBox()
    local real_position = self:convertToWorldSpace(cc.p(bbox.x, bbox.y))

    bbox.x = real_position.x
    bbox.y = real_position.y

    if cc.bounds_:is_rect_inside(bbox) then
        if self.status_ == cc.enemy_.status_.active_ then
           self.status_ = cc.enemy_.status_.fighting_
           self.health_ = self.default_health_

           self:onRespawn()
        elseif self.status_ == cc.enemy_.status_.defeated_ then
            self.sprite_:stopAllActions()
            self:stopAllActions()
            self:onDefeated()
            self.sprite_:setVisible(false)
            self:setPosition(self.start_position_)
            self.status_ = cc.enemy_.status_.inactive_
        end
    else
        if self.status_ == cc.enemy_.status_.fighting_ or self.status_ == cc.enemy_.status_.inactive_ then
            self:stopAllActions()
            self.sprite_:stopAllActions()

            if not cc.bounds_:is_point_inside(self.start_position_) then
                self.sprite_:setVisible(true)
                self:setPosition(self.start_position_)
                self.status_ = cc.enemy_.status_.active_
            end

        end

    end
end

function enemy:fire(args)

    if args.sfx ~= nil then
        audio.playSound(args.sfx, false)
    end

    local bullet_position = cc.p(self:getPositionX() + (args.offset.x * self:get_sprite_normal().x),
                                 self:getPositionY() +  args.offset.y)

    local bullet = args.weapon:create()
                              :setPosition(bullet_position)
                              :setup(args.parameters.category_,
                                     args.parameters.sub_category_,
                                     args.parameters.package_,
                                     args.parameters.cname_)
                              :init_weapon(self:get_sprite_normal().x, self.weapon_tag_)
                              :addTo(self:getParent())


    self:getParent().bullets_[bullet] = bullet

    return bullet
end

function enemy:move()
    self.current_speed_ = self.kinematic_body_.body_:getVelocity()

    if self.contacts_[cc.kinematic_contact_.down] then
        self.current_speed_.y = 0
        self.on_ground_ = true
    else
        self.on_ground_ = false
    end

    self:walk()
    self:jump()

    if self.contacts_[cc.kinematic_contact_.up] then
        if self.current_speed_.y > 0 then
            self.current_speed_.y = -1
        end
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


function enemy:step(dt)
    self:check_status()

    if self.status_ == cc.enemy_.status_.fighting_ then

        self:kinematic_step(dt)
        self:fight()

    end

    return self
end

function enemy:post_step(dt)

    if self.status_ ~= cc.enemy_.status_.fighting_ then
        self.current_speed_.x = 0
        self.current_speed_.y = 0
    end

    self:kinematic_post_step(dt)

    return self
end

return enemy

