-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local sprite = import("app.core.graphical.sprite")
local violet_bullet = import("app.objects.weapons.browners.violet.violet_bullet")

local browner       = class("browner", cc.Node)

function browner:ctor(sprite)

    self.sprite_ = sprite

    self.energy_ = 28

    self.charge_power_      = "low"
    self.charge_fx_color_   = 0

    self.sound_effects_ = {}

    self:init_constraints()
    self:init_variables()

    self.base_name_ = "violet"

    self.sprite_color_ = self.sprite_:getColor()

    local definitions_path  = "definitions/characters/player/regular/browners/browners"
    self.sprite_:load_definitions(definitions_path)


end

function browner:init_constraints()
    -- constraints
    self.can_walk_       = true
    self.can_jump_       = true
    self.can_dash_jump_  = true
    self.can_slide_      = true
    self.can_climb_      = true
    self.can_attack_     = true
    self.can_charge_     = true
end

function browner:init_variables()
    self.walking_           = false -- action variables
    self.jumping_           = false
    self.dash_jumping_      = false
    self.sliding_           = false
    self.climbing_          = false
    self.attacking_         = false
    self.charging_          = false
    self.stunned_           = false
    self.flashing_          = false
    self.speed_             = cc.p(0, 0)    -- behavior variables
    self.on_ground_         = false
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

function browner:spawn()
    self.energy_ = 28
end

function browner:activate()
    self.sprite_:setVisible(true)
end

function browner:deactivate()
    self.sprite_:stopAllActions()
    self.sprite_:setVisible(false)
end

function browner:run_action(action)
    local basename = self.base_name_
    self.sprite_:set_animation(action .. "/" .. self.base_name_ .. "_" .. action)
    self.sprite_:run_action(action, self.base_name_)
end

function browner:get_action_duration(action)
    local duration = self.sprite_:get_action_duration(action, self.base_name_)
    return duration
end

function browner:stop_actions()
    self.sprite_:stop_actions()
end

function browner:pause_actions()
    self.sprite_:pause_actions()
end

function browner:resume_actions()
    self.sprite_:resume_actions()
end

function browner:walk()

    if  not self.climbing_ and not self.sliding_ and not self.stunned_ then
        if self:getParent():walk_right_condition() then
            self.sprite_:setFlippedX(false)
            self.speed_.x = self.walk_speed_
            self.walking_ = true
        elseif self:getParent():walk_left_condition() then
            self.sprite_:setFlippedX(true)
            self.speed_.x = -self.walk_speed_
            self.walking_ = true
        else
            self.speed_.x = 0
            self.walking_ = false
        end

    else
        self.walking_ = false
    end
end

function browner:jump()

    if self:getParent():start_jump_condition() and self.on_ground_ and not self.sliding_ and not self.stunned_ then
        self.speed_.y  = self.jump_speed_
        self.on_ground_ = false
        self.jumping_ = true
    end

    if self:getParent():stop_jump_condition() and self.speed_.y >= 0 and not self.climbing_ and not self.on_ground_ then
        self.speed_.y = 0
    end

end

function browner:dash_jump()
    if self:getParent():start_dash_jump_condition() and self.on_ground_ and not self.sliding_ and not self.stunned_ then
        self.speed_.y  = self.dashjump_speed_
        self.on_ground_ = false
        self.jumping_ = true
        self.dash_jumping_ = true
    end

    if self:getParent():stop_dash_jump_condition() and self.speed_.y >= 0 and not self.climbing_ and not self.on_ground_ then
        self.speed_.y = 0
        self.dash_jumping_ = false
    elseif not self:getParent():stop_dash_jump_condition() and self.speed_.y <= 0 and not self.climbing_ and not self.on_ground_ then
        self.dash_jumping_ = false
    elseif self:getParent():stop_dash_jump_condition() and self.speed_.y <= 0 and not self.climbing_ and not self.on_ground_ then
        self.dash_jumping_ = false
    end
end

function browner:slide()

    if self:getParent():slide_condition() and self.on_ground_ and not self.sliding_ and not self.stunned_ and not self.attacking_ then
        self.sliding_ = true
        self.slide_timer_ = 32

        if self:getParent().kinematic_body_:get_shape_index() ~= 2 then

            self:getParent().kinematic_body_:swap_shape(2) --shall need to force position recomputation here
            self.contacts_[cc.kinematic_contact_.left] = false
            self.contacts_[cc.kinematic_contact_.right] = false
        end
    end

    if self.slide_timer_ > 0 then

        if self.attacking_ then
            self.attack_timer_ = 0
            self.attacking_ = false
        end

        self.slide_timer_ = self.slide_timer_ - 1

        self.large_slide_ = false

        if self.contacts_[cc.kinematic_contact_.up] then
           self.slide_timer_ = self.slide_timer_ + 1
           self.sliding_ = true
           self.large_slide_ = true

           if cc.key_down(cc.key_code_.left) and not cc.key_down(cc.key_code_.right) then
               self.sprite_:setFlippedX(true)
               self.speed_.x = -self.slide_speed_
           elseif cc.key_down(cc.key_code_.right) and not cc.key_down(cc.key_code_.left) then
               self.sprite_:setFlippedX(false)
               self.speed_.x = self.slide_speed_
           end
        end

        if self.sprite_:isFlippedX() then
            if self.contacts_[cc.kinematic_contact_.left] then
                self.speed_.x = 0

                if not self.large_slide_ then
                    self.slide_timer_ = 0
                    self.sliding_ = false
                end
            else
                self.speed_.x = -self.slide_speed_
            end
        else
            if self.contacts_[cc.kinematic_contact_.right] then
                self.speed_.x = 0

                if not self.large_slide_ then
                    self.slide_timer_ = 0
                    self.sliding_ = false
                end
            else
                self.speed_.x = self.slide_speed_
            end
        end

        if not self.on_ground_ then
            self.slide_timer_ = 0
            self.sliding_ = false
            self.speed_.x = 0
        elseif (self.sprite_:isFlippedX() and cc.key_down(cc.key_code_.right) and not cc.key_down(cc.key_code_.left))
                or (not self.sprite_:isFlippedX() and cc.key_down(cc.key_code_.left) and not cc.key_down(cc.key_code_.right))
                or (self.on_ground_ and cc.key_down(cc.key_code_.a) and self.slide_timer_ < 8) then
            if not self.large_slide_ then
                self.slide_timer_ = 0
                self.sliding_ = false
                self.speed_.x = 0
            end
        end

    else
        if self.sliding_ then
            self.sliding_ = false
        end
    end

    if not self.sliding_ then

        if self:getParent().kinematic_body_:get_shape_index() ~= 1 then
            self:getParent().kinematic_body_:swap_shape(1)
        end
    end
end

function browner:climb()
    local active_ladder = self:getParent().active_ladder_
    local climb_direction

    if active_ladder ~= nil and not self.sliding_ and not self.stunned_ then

        if cc.key_down(cc.key_code_.up) and not cc.key_down(cc.key_code_.down) then
            climb_direction = cc.player_.climb_direction_.up_
        elseif cc.key_down(cc.key_code_.down) and not cc.key_down(cc.key_code_.up) then
            climb_direction = cc.player_.climb_direction_.down_
        else
            if self.climbing_ then
                climb_direction = cc.player_.climb_direction_.none_
            end
        end

        if self.speed_.y > 0 and not self.climbing_ then
            climb_direction = nil
        end
    elseif self.stunned_ then
        if self.climbing_ then
            climb_direction = cc.player_.climb_direction_.none_
        end
    end

    if climb_direction ~= nil and active_ladder ~= nil then
        self:resume_actions()

        local x_backup = self.speed_.x
        local ground_backup = self.on_ground_

        self.climbing_ = true
        self.on_ground_ = false

        if self.speed_.x ~= 0 then
            self.speed_.x = 0
        end

        if climb_direction == cc.player_.climb_direction_.up_ then

            if self:getParent():center().y >= active_ladder.top_ then
                if self:getParent():bottom() < active_ladder.top_ then
                    self.climbing_ = false
                    self:getParent():setPositionY(active_ladder.top_ + 2)
                    active_ladder:solidify()
                else
                    self.climbing_ = false
                    self.speed_.x = x_backup
                    self.on_ground_ = ground_backup
                end
            else
                if active_ladder.solidified_ then -- pull the player up in case he's near the ground.
                    self:getParent():setPositionY(self:getParent():getPositionY() + 4)
                end
                active_ladder:unsolidify()
                self.speed_.y = self.climb_speed_
            end
        elseif climb_direction == cc.player_.climb_direction_.down_ then
            if self:getParent():bottom() < active_ladder.bottom_ then
                self.climbing_ = false
                self.speed_.x = x_backup
                self.on_ground_ = ground_backup
                active_ladder:solidify()
            else
                self.speed_.y = -self.climb_speed_
                active_ladder:unsolidify()
            end
        else

            if self.stunned_ then
                self:resume_actions()
                self.speed_.y = -12
            else
                self.speed_.y = 0
                self:pause_actions()
            end
        end

        if self.attacking_ then
            self.speed_.y = 0
        end

    else

        self.climbing_ = false
        self:resume_actions()

    end

    if self.climbing_ then
        if self:getParent():getPositionX() ~= active_ladder.center_.x then
            self:getParent():setPositionX(active_ladder.center_.x)
        end
    end

end

function browner:timed_shoot()

    self:fire()

    if not self.attacking_ then
        self.attacking_ = true

        local delay = cc.DelayTime:create(0.280)
        local callback = cc.CallFunc:create(function()
            self.attacking_ = false
            self.charge_timer_ = 0
            self.charging_ = false
        end)

        local sequence = cc.Sequence:create(delay, callback, nil)

        self:runAction(sequence)
    else
        local delay = cc.DelayTime:create(0.280)
        local callback = cc.CallFunc:create(function()
            self.attacking_ = false
            self.charge_timer_ = 0
            self.charging_ = false
        end)

        local sequence = cc.Sequence:create(delay, callback, nil)

        self:stopAllActions()
        self:runAction(sequence)
    end

end


function browner:attack()

    if self:getParent():attack_condition() and not self.charging_ and not self.sliding_ and not self.stunned_ then

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

    if self:getParent():charge_condition() and not self.charging_ then
        self.charging_ = true
    end

    if (self:getParent():discharge_condition() and not self.sliding_) or (self:getParent():discharge_condition() and self.charging_ and not self.sliding_)
            and not self.stunned_ then

        if self.charge_power_ ~= "low" then
            self:timed_shoot()
            self.charge_power_ = "low"
        end

        self.charging_ = false
    end

end

function browner:charge()

    if self.charging_ then --&& global.current_weapon[? "object"] == buster){
        self.charge_timer_ = self.charge_timer_ + 1
        if self.charge_timer_ == 20 then
            self.charge_power_ = "mid"
            self.sound_effects_[self.charge_power_] = audio.playSound("sounds/sfx_buster_charging_mid.wav", false)

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
                self.sound_effects_[self.charge_power_] = audio.playSound("sounds/sfx_buster_charging_high.wav", false)
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

function browner:get_sprite_normal()
    local x_normal = 1

    if self.sprite_:isFlippedX() then
        x_normal = -1
    end

    local normal = cc.p(x_normal, 1)
    return normal
end

function browner:fire()

    local bullet_offset = 12

    local bullet_power = 1

    if self.charge_power_ == "low" then
        audio.playSound("sounds/sfx_buster_shoot.wav", false)
    elseif self.charge_power_ == "mid" then
        audio.playSound("sounds/sfx_buster_shoot_mid.wav", false)
        bullet_power = 2
    elseif self.charge_power_ == "high" then
        bullet_offset = 26
        audio.playSound("sounds/sfx_buster_shoot_high.wav", false)
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

return browner



