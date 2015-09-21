-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local weapon_controller = class("weapon_controller", cc.Node)

local intro = import("app.scenes.special.intro")


function weapon_controller:ctor(args)

    self.player_ = args.player_
    self.demo_browner_id_ = args.demo_browner_id_

    self.player_.walk_right_condition       = function() return false end
    self.player_.walk_left_condition        = function() return false end
    self.player_.start_jump_condition       = function() return false end
    self.player_.stop_jump_condition        = function() return true end
    self.player_.start_dash_jump_condition  = function() return false end
    self.player_.stop_dash_jump_condition   = function() return true end
    self.player_.slide_condition            = function() return false end
    self.player_.attack_condition           = function()
                                                local can_attack = self:check_attack()
                                                return can_attack
                                              end
    self.player_.charge_condition           = function() return false end
    self.player_.discharge_condition        = function() return true end

    self.player_morphing_   = false
    self.player_morphed_    = false
    self.player_attacking_  = false

    self.send_attack_signal_ = false
    self.attack_signal_sent_ = false

    self.ready_ = false

    local parallax_arguments = { category_ = "gameplay",
        sub_category_ = "screens",
        package_ = "weapon",
        cname_ = "cody",
        bgm_ = nil, -- set up in level base
        on_end_callback_ = self.on_intro_complete,
        sender_ = self}

    self.intro_ = intro:create(parallax_arguments)
                       :setPosition(display.left_bottom)
                       :addTo(self)


end


function weapon_controller:on_intro_complete()
    self.ready_ = true
end

function weapon_controller:check_attack()
    local attack = false

    if self.player_.current_browner_.on_ground_ and self.player_morphed_ and not self.player_attacking_ then
        self.player_attacking_ = true

        local attack_delay = cc.DelayTime:create(self.player_.current_browner_:get_action_duration("standshoot") + 2)

        local attack_callback = cc.CallFunc:create(function()
            self.send_attack_signal_ = true
        end)

        local exit_callback = cc.CallFunc:create(function()
            local arguments = {}
            arguments.is_level_complete_ = true
            self.player_:exit(arguments)
        end)

        local sequence = cc.Sequence:create(attack_callback, attack_delay, exit_callback)

        self:runAction(sequence)

    else
        if self.send_attack_signal_ and not self.attack_signal_sent_ then
            self.attack_signal_sent_ = true
            attack =  true
        end
    end

    return attack
end

function weapon_controller:check_morph()
    if self.player_.current_browner_.on_ground_ and not self.player_morphing_ then
        self.player_morphing_ = true


        self.player_:switch_browner(cc.browners_.violet_.id_)

        self.player_.current_browner_.morphing_ = true

        local pre_delay = cc.DelayTime:create(self.player_.current_browner_:get_action_duration("morph"))

        local callback = cc.CallFunc:create(function()
            self.player_:switch_browner(self.demo_browner_id_)
        end)

        local post_delay = cc.DelayTime:create(0.5)

        local attack_callback = cc.CallFunc:create(function()
            self.player_morphed_ = true
        end)

        local sequence = cc.Sequence:create(pre_delay, callback, post_delay, attack_callback, nil)

        self:runAction(sequence)

    end
end

function weapon_controller:step(dt)

    self.intro_:step(dt)

    if self.ready_ then
        self.player_:kinematic_step(dt)

        if self.player_.spawning_ and self.player_.alive_ then
            self.player_:solve_collisions()
        elseif self.player_.alive_ then
            if cc.game_status_ == cc.GAME_STATUS.RUNNING then
                self.player_:solve_collisions()
                self.player_:attack()

    --            self.player_:charge()
    --            self.player_:slide()
    --            self.player_:climb()
    --            self.player_:check_health()
            end
        end

        self:check_morph()
    end
end


return weapon_controller

