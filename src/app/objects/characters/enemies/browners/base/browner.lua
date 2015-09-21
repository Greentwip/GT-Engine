-- Copyright 2014-2015 Greentwip. All Rights Reserved.


local browner       = class("browner-enemy", cc.Node)

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

    self.browner_id_ = -2       -- override in children

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

function browner:init_variables(subitm)
    local itm = self

    if subitm ~= nil then
       itm = subitm
    end
    itm.walking_           = false -- action variables
    itm.jumping_           = false
    itm.dash_jumping_      = false
    itm.sliding_           = false
    itm.climbing_          = false
    itm.attacking_         = false
    itm.charging_          = false
    itm.stunned_           = false
    itm.flashing_          = false
    self.speed_             = cc.p(0, 0)    -- behavior variables
    itm.on_ground_         = false
    self.walk_speed_        = 60
    self.climb_speed_       = 60
    self.slide_speed_       = 160
    self.jump_speed_        = 320
    self.dashjump_speed_    = 400
    self.stun_timer_        = 0             -- timers
    self.slide_timer_       = 0
    self.charge_timer_      = 0
    self.attack_timer_      = 0
end

function browner:spawn()
    self:init_constraints()
    self:init_variables()
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
    self.sprite_:pause()
end

function browner:resume_actions()
    self.sprite_:resume()
end

function browner:walk()

    if  not self.climbing_ and not self.sliding_ and not self.stunned_ then
        if cc.key_down(cc.key_code_.right) and not cc.key_down(cc.key_code_.left) then
            self.sprite_:setFlippedX(false)
            self.speed_.x = self.walk_speed_
            self.walking_ = true
        elseif cc.key_down(cc.key_code_.left) and not cc.key_down(cc.key_code_.right) then
            self.sprite_:setFlippedX(true)
            self.speed_.x = -self.walk_speed_
            self.walking_ = true
        else
            self.speed_.x = 0
            self.walking_ = false
        end

        if not cc.key_down(cc.key_code_.right) and not cc.key_down(cc.key_code_.left)  then
            self.speed_.x = 0
            self.walking_ = false
        end

    else
        self.walking_ = false
    end
end

function browner:jump()

    if cc.key_pressed(cc.key_code_.a)
            and not cc.key_down(cc.key_code_.up)
            and not cc.key_down(cc.key_code_.down)
            and self.on_ground_
            and not self.sliding_
            and not self.stunned_ then

        self.speed_.y  = self.jump_speed_
        self.on_ground_ = false
        self.jumping_ = true
    end

    if not cc.key_down(cc.key_code_.a) and self.speed_.y >= 0 and not self.climbing_ and not self.on_ground_ then
        self.speed_.y = 0
    end

end

function browner:dash_jump()
    return self
end

function browner:slide()
    return self
end

function browner:climb()
    return self
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
  return self
end

function browner:charge()
    return self
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
    return self
end

return browner



