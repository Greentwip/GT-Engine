-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local sprite = import("app.core.graphical.sprite")
local violet_bullet = import("app.objects.weapons.browners.violet.violet_bullet")

local graphic_character = {}

function graphic_character.create(class_name)

    local character         = class(class_name, cc.Node)

    function character:ctor(sprite, shared_variables)

        self.sprite_ = sprite
        self.shared_variables_ = shared_variables

        self.energy_ = 28

        self.charge_power_      = "low"
        self.charge_fx_color_   = 0

        self.sound_effects_ = {}

        self:init_constraints()
        self:init_variables()

        self.base_name_ = "violet"

        self.sprite_color_ = self.sprite_:getColor()

        local definitions_path  = "definitions/characters/player/regular/browners/violet/violet"
        self.sprite_:load_definitions(definitions_path)
    end

    function character:init_constraints()
        -- constraints
        self.can_walk_       = true
        self.can_jump_       = true
        self.can_dash_jump_  = true
        self.can_slide_      = true
        self.can_climb_      = true
        self.can_attack_     = true
        self.can_charge_     = true
    end

    function character:init_variables()
        -- unique
        self.walk_speed_        = 60
        self.climb_speed_       = 60
        self.slide_speed_       = 160
        self.jump_speed_        = 320
        self.dashjump_speed_    = 400
        self.stun_timer_        = 0             -- timers
        self.slide_timer_       = 0
        self.charge_timer_      = 0
        self.attack_timer_      = 0

        self.browner_id_ = -2       -- override in children
    end

    function character:spawn()
        self.energy_ = 28
    end

    function character:activate()
        self.sprite_:setVisible(true)
    end

    function character:deactivate()
        self.sprite_:stopAllActions()
        self.sprite_:setVisible(false)
    end

    function character:run_action(action)
        self.sprite_:set_animation(self.base_name_ .. "_" .. action)
        self.sprite_:run_action(action, self.base_name_)
    end

    function character:get_action_duration(action)
        local duration = self.sprite_:get_action_duration(action, self.base_name_)
        return duration
    end

    function character:stop_actions()
        self.sprite_:stop_actions()
    end

    function character:pause_actions()
        self.sprite_:pause_actions()
    end

    function character:resume_actions()
        self.sprite_:resume_actions()
    end

    function character:walk()

        if  not self.shared_variables_.climbing_
                and not self.shared_variables_.sliding_
                and not self.shared_variables_.stunned_ then
            if self:getParent():walk_right_condition() then
                self.sprite_:setFlippedX(false)
                self.shared_variables_.speed_.x = self.walk_speed_
                self.shared_variables_.walking_ = true
            elseif self:getParent():walk_left_condition() then
                self.sprite_:setFlippedX(true)
                self.shared_variables_.speed_.x = -self.walk_speed_
                self.shared_variables_.walking_ = true
            else
                self.shared_variables_.speed_.x = 0
                self.shared_variables_.walking_ = false
            end

        else
            self.shared_variables_.walking_ = false
        end
    end

    function character:jump()

        if self:getParent():start_jump_condition()
                and self.shared_variables_.on_ground_
                and not self.shared_variables_.sliding_
                and not self.shared_variables_.stunned_ then
            self.shared_variables_.speed_.y  = self.jump_speed_
            self.shared_variables_.on_ground_ = false
            self.shared_variables_.jumping_ = true
        end

        if self:getParent():stop_jump_condition()
                and self.shared_variables_.speed_.y >= 0
                and not self.shared_variables_.climbing_
                and not self.shared_variables_.on_ground_ then
            self.shared_variables_.speed_.y = 0
        end

    end

    function character:dash_jump()
        if self:getParent():start_dash_jump_condition()
                and self.shared_variables_.on_ground_
                and not self.shared_variables_.sliding_
                and not self.shared_variables_.stunned_ then
            self.shared_variables_.speed_.y  = self.dashjump_speed_
            self.shared_variables_.on_ground_ = false
            self.shared_variables_.jumping_ = true
            self.shared_variables_.dash_jumping_ = true
        end

        if self:getParent():stop_dash_jump_condition()
                and self.shared_variables_.speed_.y >= 0
                and not self.shared_variables_.climbing_
                and not self.shared_variables_.on_ground_ then
            self.shared_variables_.speed_.y = 0
            self.shared_variables_.dash_jumping_ = false
        elseif not self:getParent():stop_dash_jump_condition()
                and self.shared_variables_.speed_.y <= 0
                and not self.shared_variables_.climbing_
                and not self.shared_variables_.on_ground_ then
            self.shared_variables_.dash_jumping_ = false
        elseif self:getParent():stop_dash_jump_condition()
                and self.shared_variables_.speed_.y <= 0
                and not self.shared_variables_.climbing_
                and not self.shared_variables_.on_ground_ then
            self.shared_variables_.dash_jumping_ = false
        end
    end

    function character:slide()

        if self:getParent():slide_condition()
                and self.shared_variables_.on_ground_
                and not self.shared_variables_.sliding_
                and not self.shared_variables_.stunned_
                and not self.shared_variables_.attacking_ then
            self.shared_variables_.sliding_ = true

            self.slide_timer_ = 32

            if self:getParent().kinematic_body_:get_shape_index() ~= 2 then

                self:getParent().kinematic_body_:swap_shape(2) --shall need to force position recomputation here
                self.contacts_[cc.kinematic_contact_.left] = false
                self.contacts_[cc.kinematic_contact_.right] = false
            end
        end

        if self.slide_timer_ > 0 then

            if self.shared_variables_.attacking_ then
                self.attack_timer_ = 0
                self.shared_variables_.attacking_ = false
            end

            self.slide_timer_ = self.slide_timer_ - 1

            self.large_slide_ = false

            if self.contacts_[cc.kinematic_contact_.up] then
               self.slide_timer_ = self.slide_timer_ + 1
               self.shared_variables_.sliding_ = true
               self.large_slide_ = true

               if cc.key_down(cc.key_code_.left) and not cc.key_down(cc.key_code_.right) then
                   self.sprite_:setFlippedX(true)
                   self.shared_variables_.speed_.x = -self.slide_speed_
               elseif cc.key_down(cc.key_code_.right) and not cc.key_down(cc.key_code_.left) then
                   self.sprite_:setFlippedX(false)
                   self.shared_variables_.speed_.x = self.slide_speed_
               end
            end

            if self.sprite_:isFlippedX() then
                if self.contacts_[cc.kinematic_contact_.left] then
                    self.shared_variables_.speed_.x = 0

                    if not self.large_slide_ then
                        self.slide_timer_ = 0
                        self.shared_variables_.sliding_ = false
                    end
                else
                    self.shared_variables_.speed_.x = -self.slide_speed_
                end
            else
                if self.contacts_[cc.kinematic_contact_.right] then
                    self.shared_variables_.speed_.x = 0

                    if not self.large_slide_ then
                        self.slide_timer_ = 0
                        self.shared_variables_.sliding_ = false
                    end
                else
                    self.shared_variables_.speed_.x = self.slide_speed_
                end
            end

            if not self.shared_variables_.on_ground_ then
                self.slide_timer_ = 0
                self.shared_variables_.sliding_ = false
                self.shared_variables_.speed_.x = 0
            elseif (self.sprite_:isFlippedX() and cc.key_down(cc.key_code_.right) and not cc.key_down(cc.key_code_.left))
                    or (not self.sprite_:isFlippedX() and cc.key_down(cc.key_code_.left) and not cc.key_down(cc.key_code_.right))
                    or (self.shared_variables_.on_ground_ and cc.key_down(cc.key_code_.a) and self.slide_timer_ < 8) then
                if not self.large_slide_ then
                    self.slide_timer_ = 0
                    self.shared_variables_.sliding_ = false
                    self.shared_variables_.speed_.x = 0
                end
            end

        else
            if self.shared_variables_.sliding_ then
                self.shared_variables_.sliding_ = false
            end
        end

        if not self.shared_variables_.sliding_ then

            if self:getParent().kinematic_body_:get_shape_index() ~= 1 then
                self:getParent().kinematic_body_:swap_shape(1)
            end
        end
    end

    function character:climb()
        local active_ladder = self:getParent().active_ladder_
        local climb_direction

        if active_ladder ~= nil
                and not self.shared_variables_.sliding_
                and not self.shared_variables_.stunned_ then

            if cc.key_down(cc.key_code_.up) and not cc.key_down(cc.key_code_.down) then
                climb_direction = cc.player_.climb_direction_.up_
            elseif cc.key_down(cc.key_code_.down) and not cc.key_down(cc.key_code_.up) then
                climb_direction = cc.player_.climb_direction_.down_
            else
                if self.shared_variables_.climbing_ then
                    climb_direction = cc.player_.climb_direction_.none_
                end
            end

            if self.shared_variables_.speed_.y > 0 and not self.shared_variables_.climbing_ then
                climb_direction = nil
            end
        elseif self.shared_variables_.stunned_ then
            if self.shared_variables_.climbing_ then
                climb_direction = cc.player_.climb_direction_.none_
            end
        end

        if climb_direction ~= nil and active_ladder ~= nil then
            self:resume_actions()

            local x_backup = self.shared_variables_.speed_.x
            local ground_backup = self.shared_variables_.on_ground_

            self.shared_variables_.climbing_ = true
            self.shared_variables_.on_ground_ = false

            if self.shared_variables_.speed_.x ~= 0 then
                self.shared_variables_.speed_.x = 0
            end

            if climb_direction == cc.player_.climb_direction_.up_ then

                if self:getParent():center().y >= active_ladder.top_ then
                    if self:getParent():bottom() < active_ladder.top_ then
                        self.shared_variables_.climbing_ = false
                        self:getParent():setPositionY(active_ladder.top_ + 2)
                        active_ladder:solidify()
                    else
                        self.shared_variables_.climbing_ = false
                        self.shared_variables_.speed_.x = x_backup
                        self.shared_variables_.on_ground_ = ground_backup
                    end
                else
                    if active_ladder.solidified_ then -- pull the player up in case he's near the ground.
                        self:getParent():setPositionY(self:getParent():getPositionY() + 4)
                    end
                    active_ladder:unsolidify()
                    self.shared_variables_.speed_.y = self.climb_speed_
                end
            elseif climb_direction == cc.player_.climb_direction_.down_ then
                if self:getParent():bottom() < active_ladder.bottom_ then
                    self.shared_variables_.climbing_ = false
                    self.shared_variables_.speed_.x = x_backup
                    self.shared_variables_.on_ground_ = ground_backup
                    active_ladder:solidify()
                else
                    self.shared_variables_.speed_.y = -self.climb_speed_
                    active_ladder:unsolidify()
                end
            else

                if self.shared_variables_.stunned_ then
                    self:resume_actions()
                    self.shared_variables_.speed_.y = -12
                else
                    self.shared_variables_.speed_.y = 0
                    self:pause_actions()
                end
            end

            if self.shared_variables_.attacking_ then
                self.shared_variables_.speed_.y = 0
            end

        else

            self.shared_variables_.climbing_ = false
            self:resume_actions()

        end

        if self.shared_variables_.climbing_ then
            if self:getParent():getPositionX() ~= active_ladder.center_.x then
                self:getParent():setPositionX(active_ladder.center_.x)
            end
        end

    end

    function character:timed_shoot()

        self:fire()

        if not self.shared_variables_.attacking_ then
            self.shared_variables_.attacking_ = true

            local delay = cc.DelayTime:create(0.280)
            local callback = cc.CallFunc:create(function()
                self.shared_variables_.attacking_ = false
                self.charge_timer_ = 0
                self.shared_variables_.charging_ = false
            end)

            local sequence = cc.Sequence:create(delay, callback, nil)

            self:runAction(sequence)
        else
            local delay = cc.DelayTime:create(0.280)
            local callback = cc.CallFunc:create(function()
                self.shared_variables_.attacking_ = false
                self.charge_timer_ = 0
                self.shared_variables_.charging_ = false
            end)

            local sequence = cc.Sequence:create(delay, callback, nil)

            self:stopAllActions()
            self:runAction(sequence)
        end

    end


    function character:attack()

        if self:getParent():attack_condition()
                and not self.shared_variables_.charging_
                and not self.shared_variables_.sliding_
                and not self.shared_variables_.stunned_ then

            if self:getParent():walk_right_condition() then
                self.sprite_:setFlippedX(false)
            elseif self:getParent():walk_left_condition() then
                self.sprite_:setFlippedX(true)
            end

            local bullet_count = 0
            for _, _ in pairs(self:getParent():getParent().bullets_) do
                bullet_count = bullet_count + 1
            end

            if bullet_count < 3 then
                self:timed_shoot()
            end

            self.charge_timer_ = 0
        end

        if self:getParent():charge_condition() and not self.shared_variables_.charging_ then
            self.shared_variables_.charging_ = true
        end

        if (self:getParent():discharge_condition() and not self.shared_variables_.sliding_)
                or (self:getParent():discharge_condition()
                and self.shared_variables_.charging_
                and not self.shared_variables_.sliding_)
                and not self.shared_variables_.stunned_ then

            if self.charge_power_ ~= "low" then
                self:timed_shoot()
                self.charge_power_ = "low"
            end

            self.shared_variables_.charging_ = false
        end

    end

    function character:charge()

        if self.shared_variables_.charging_ then --&& global.current_weapon[? "object"] == buster){
            self.charge_timer_ = self.charge_timer_ + 1
            if self.charge_timer_ == 20 then
                self.charge_power_ = "mid"
                self.sound_effects_[self.charge_power_] = audio.playSound("sounds/sfx_buster_charging_mid.mp3", false)

                if not self.tint_a_ then
                    local color_a = cc.c3b(188,188,188)
                    local color_b = cc.c3b(220,40,0)

                    local tint_a = cc.TintTo:create(0.01, color_a)
                    local tint_b = cc.TintTo:create(0.01, color_b)
                    local tint_d = cc.TintTo:create(0.01, self.sprite_color_)

                    local sequence = cc.Sequence:create(tint_a, tint_d, tint_b, tint_d, nil)
                    local forever = cc.RepeatForever:create(sequence)

                    forever:setTag(cc.tags.actions.color)

                    self.sprite_:stopAllActionsByTag(cc.tags.actions.color)
                    self.sprite_:runAction(forever)
                    self.tint_a_ = true
                end

            elseif self.charge_timer_ >= 60 then

                if not self.tint_b_ then
                    local color_a = cc.c3b(188,188,188)
                    local color_b = cc.c3b(220,40,0)

                    local tint_a = cc.TintTo:create(0.005, color_a)
                    local tint_b = cc.TintTo:create(0.005, color_b)
                    local tint_d = cc.TintTo:create(0.005, self.sprite_color_)

                    local sequence = cc.Sequence:create(tint_a, tint_d, tint_b, tint_d, nil)
                    local forever = cc.RepeatForever:create(sequence)
                    forever:setTag(cc.tags.actions.color)
                    self.sprite_:stopAllActionsByTag(cc.tags.actions.color)

                    self.sprite_:runAction(forever)
                    self.tint_b_ = true
                end

                if self.charge_timer_ % 18 == 0 then
                    self.sound_effects_[self.charge_power_] = audio.playSound("sounds/sfx_buster_charging_high.mp3", false)
                    self.charge_timer_ = 60
                end

                self.charge_power_ = "high"

            end

        else
            self.charge_timer_ = 0

            self.tint_a_ = false
            self.tint_b_ = false

            self.sprite_:stopAllActionsByTag(cc.tags.actions.color)
            self.sprite_:setColor(self.sprite_color_)
        end

    end

    function character:get_sprite_normal()
        local x_normal = 1

        if self.sprite_:isFlippedX() then
            x_normal = -1
        end

        local normal = cc.p(x_normal, 1)
        return normal
    end

    function character:fire()

        local bullet_offset = 12

        local bullet_power = 1

        if self.charge_power_ == "low" then
            audio.playSound("sounds/sfx_buster_shoot.mp3", false)
        elseif self.charge_power_ == "mid" then
            audio.playSound("sounds/sfx_buster_shoot_mid.mp3", false)
            bullet_power = 2
        elseif self.charge_power_ == "high" then
            bullet_offset = 26
            audio.playSound("sounds/sfx_buster_shoot_high.mp3", false)
            bullet_power = 3
        end

        local bullet_position = cc.p(self:getParent():getPositionX() + (bullet_offset * self:get_sprite_normal().x),
                                     self:getParent():getPositionY()+ 12)

        local bullet = violet_bullet:create()
                                    :setPosition(bullet_position)
                                    :setup("gameplay", "level", "weapon", "violet_bullet" .. "_" .. self.charge_power_)
                                    :init_weapon(self:get_sprite_normal().x, self.weapon_tag_)
                                    :addTo(self:getParent():getParent())

        bullet.power_ = bullet_power

        self:getParent():getParent().bullets_[bullet] = bullet
    end

    return character
end



return graphic_character
