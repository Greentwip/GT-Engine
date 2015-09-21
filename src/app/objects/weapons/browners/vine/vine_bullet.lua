-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local weapon      = import("app.objects.weapons.base.weapon")
local vine_bullet = class("violet_bullet", weapon)

function vine_bullet:animate(cname)

    local actions = {}
    actions[#actions + 1] = {name = "vine_a",   animation = {name = cname .. "_a",  forever = false, delay = 0.10} }
    actions[#actions + 1] = {name = "vine_b",   animation = {name = cname .. "_b",  forever = true, delay = 0.10}  }
    actions[#actions + 1] = {name = "vine_c",   animation = {name = cname .. "_c",  forever = false, delay = 0.04} }

    self.sprite_:load_actions_set(actions, false)

    self.sprite_:set_animation(cname .. "_b")
    self.sprite_:run_action("vine" .. "_b")

    self.rising_ = false
    self.rise_speed_ = 380
    self.move_speed_ = 60

    self.on_ground_ = false

    self.power_ = 4

    return self
end

function vine_bullet:walk()
    if self.sprite_:isFlippedX() then
        self.current_speed_.x = -self.move_speed_
    else
        self.current_speed_.x = self.move_speed_
    end
end

function vine_bullet:jump()
    if not self.rising_  then
        self.rising_ = true
        self.current_speed_.y  = self.rise_speed_
    end

    if self.contacts_[cc.kinematic_contact_.down] and self.current_speed_.y <= 0 then

        self.current_speed_.x = 0

        if not self.on_ground_  then
            self.on_ground_ = true

            local pre_callback = cc.CallFunc:create(function()
                self.sprite_:run_action("vine" .. "_" .. "c")
            end)

            local post_callback = cc.CallFunc:create(function()
                self.sprite_:reverse_action()
            end)

            local on_end = cc.CallFunc:create(function()
                self.disposed_ = true
            end)


            local duration = cc.DelayTime:create(self.sprite_:get_action_duration("vine" .. "_" .. "c"))

            local sequence = cc.Sequence:create(pre_callback, duration, post_callback, duration, on_end, nil)

            self:runAction(sequence)
        end
    end
end



return vine_bullet

