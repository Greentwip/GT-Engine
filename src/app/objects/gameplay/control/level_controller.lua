-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local level_controller  = class("level_controller", cc.Node)
local energy_bar        = import("app.objects.gameplay.level.ui.energy_bar")
local ready_object      = import("app.objects.gameplay.level.ui.ready_object")
local pause_menu        = import("app.objects.gameplay.level.ui.pause_menu")
local fade              = import("app.core.graphical.fade")

function level_controller:ctor(player, camera, scene_components, bgm, arguments)

    self.quitting_ = false

    if cc.game_status_ ~= cc.GAME_STATUS.RUNNING then
        cc.pause(false)
    end

    if cc.pause_status_ ~= cc.PAUSE_STATUS.NONE then
        cc.pause_status_ = cc.PAUSE_STATUS.NONE
    end

    self.player_                = player
    self.camera_                = camera
    self.scene_components_      = scene_components
    self.reinit_                = true
    self.check_point_           = nil
    self.level_bgm_             = bgm

    self.is_startup_            = true

    self.pause_menu_            = nil
    self.pausing_               = false

    self.hud_enabled_           = true

    self.ready_object_enabled_  = true
    self.time_to_play_ = 4.0

    if arguments ~= nil then
        if arguments.disable_hud_ then
            self.hud_enabled_ = false
        end

        if arguments.disable_ready_object_ then
            self.ready_object_enabled_ = false
        end

        if arguments.time_to_play_ then
            self.time_to_play_ = arguments.time_to_play_
        end

        if arguments.is_demo_ then
            arguments.player_ = self.player_

            self.player_.can_move_ = false -- everything will be controlled manually
            self.player_.demo_mode_ = true
            self.is_demo_   = true
            self.demo_controller_ = arguments.demo_controller_:create(arguments)
                                                              :addTo(self)
        end
    end



    if self.hud_enabled_ then

        self.hud_ = {}
        self.hud_.health_ = energy_bar:create()
                                      :setPosition(cc.p(-cc.bounds_:width() * 0.5 + 16, cc.bounds_:height() * 0.5 -16))
                                      :addTo(cc.bounds_)     -- node positions are relative to parent's

        self.hud_.energy_ = energy_bar:create()
                                      :setPosition(cc.p(-cc.bounds_:width() * 0.5 + 8, cc.bounds_:height() * 0.5 -16))
                                      :addTo(cc.bounds_)     -- node positions are relative to parent's

        self.hud_.energy_:setVisible(false)

        self.player_.health_bar_ = self.hud_.health_
        self.player_.energy_bar_ = self.hud_.energy_

    end
end

function level_controller:setup()

    cc.bounds_:setPosition(cc.p(self.check_point_:getPositionX(), self.check_point_:getPositionY()))

    self:getScene():getDefaultCamera():setPositionX(cc.bounds_:getPositionX())
    self:getScene():getDefaultCamera():setPositionY(cc.bounds_:getPositionY())

    self.player_.health_ = 29

    for _, browner in pairs(self.player_.browners_) do
        browner:spawn()
    end

    self.player_:setPosition(cc.p(cc.bounds_:getPositionX(), cc.bounds_:top() + 24))
end

function level_controller:start()

    if self.check_point_ ~= nil then
        self.player_.spawning_ = true
        --        local delay = cc.DelayTime:create(4.0)

        local on_fade_in = function()
            cc.pause(true)
            self:setup()
            audio.playMusic(self.level_bgm_, true)
        end

        local on_fade_out = function()
            if self.ready_object_enabled_ then
                ready_object:create(self.player_, function()    cc.pause(false) end)
                            :setPosition(cc.p(cc.bounds_:getPositionX(), cc.bounds_:getPositionY()))
                            :addTo(self)
            else
                cc.pause(false)
                self.player_:spawn()
            end
        end

        if self.is_startup_ then
            self.is_startup_ = false
            fade:create(4, nil, on_fade_in, on_fade_out, {fade_in = false, fade_out = true})
                :addTo(cc.bounds_)
        else

            self.on_fade_in_ = on_fade_in
            self.on_fade_out_ = on_fade_out
            local delay = cc.DelayTime:create(self.time_to_play_)
            local callback = cc.CallFunc:create(function()
                fade:create(self.time_to_play_, nil, self.on_fade_in_, self.on_fade_out_, {fade_in = true, fade_out = true})
                    :setPosition(0, 0)
                    :addTo(cc.bounds_)
            end)

            local sequence = cc.Sequence:create(delay, callback, nil)

            self:runAction(sequence)
        end
        --        local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback), nil)

        --        self:runAction(sequence)

    end

end

function level_controller:schedule_component(component)
    self.scene_components_[#self.scene_components_ +1] = component
end

function level_controller:step(dt)

    for i, _ in pairs(self.scene_components_) do

        self.scene_components_[i]:step(dt)
        self.scene_components_[i]:post_step(dt)

        if self.scene_components_[i].disposed_ then
            self.scene_components_[i]:removeSelf()
            self.scene_components_[i] = nil
        end

    end

    if not self.player_.alive_ and not self.player_.spawning_ then

        if cc.player_.lives_ <= 0 then
            if not self.quitting_ then
                self.quitting_ = true
                local delay = cc.DelayTime:create(2)
                local callback = cc.CallFunc:create(function()
                    self:getParent():setVisible(false)
                    self:getParent():getApp():enterScene("screens.level_complete", "FADE", 1.5, {physics = false})
                end)

                local sequence = cc.Sequence:create(delay, callback, nil)

                self:runAction(sequence)
            end
        else
            self:start()
        end

    else

        if self.is_demo_ then
           self.demo_controller_:step(dt)
        end

        self.player_:step(dt)
        self.camera_:step(dt)

        self.player_:post_step(dt)

        if self.hud_enabled_ then
            self.hud_.health_:set_meter(self.player_.health_)
            if self.player_.on_exit_ then
                self.hud_.energy_:setVisible(false)
            else
                self.hud_.energy_:set_meter(self.player_.current_browner_.energy_)
            end
        end

        if self.pause_menu_ ~= nil then
            self.pause_menu_:step(dt)
        end

        if self.player_.alive_ and not self.player_.spawning_ then

            if cc.key_pressed(cc.key_code_.start)  then

                local on_fade_begin
                local on_fade_in
                local on_fade_out

                if cc.game_status_ == cc.GAME_STATUS.RUNNING and cc.pause_status_ == cc.PAUSE_STATUS.NONE and
                        not self.player_.on_exit_ and
                        not self.player_.on_end_battle_ then

                    if self.pause_fade_ == nil then
                        local on_fade_begin = function()
                            cc.pause_status_ = cc.PAUSE_STATUS.SCREEN
                            audio.playSound("sounds/sfx_pause.wav", false)
                            cc.pause(true)
                        end

                        local on_fade_in = function()

                            local pause_settings = {player_ = self.player_}

                            self.pause_menu_ = pause_menu:create(pause_settings)
                                                         :setPosition(cc.p((-cc.bounds_:width() * 0.5), cc.bounds_:height() * 0.5))
                                                         :addTo(cc.bounds_, 100)


                        end

                        local on_fade_out = function()
                            self.pause_menu_.ready_ = true
                            self.pause_fade_ = nil
                        end

                        self.pause_fade_ = fade:create(1.0, on_fade_begin, on_fade_in, on_fade_out, {fade_in = true, fade_out = true})
                                               :addTo(cc.bounds_, 200)

                    end
                elseif cc.pause_status_ == cc.PAUSE_STATUS.SCREEN then
                    if self.pause_fade_ == nil then

                        if self.pause_menu_.ready_ then
                            local on_fade_begin = function()
                                audio.playSound("sounds/sfx_selected.wav", false)
                                self.pause_menu_.ready_ = false
                            end

                            local on_fade_in = function()
                                local new_browner = self.pause_menu_.default_browner_

                                if self.pause_menu_.selected_browner_ ~= nil then
                                    new_browner = self.pause_menu_.selected_browner_
                                end

                                self.player_:switch_browner(new_browner.browner_id_)

                                self.pause_menu_:removeSelf()
                                self.pause_menu_ = nil
                            end

                            local on_fade_out = function()
                                cc.pause(false)
                                cc.pause_status_ = cc.PAUSE_STATUS.NONE
                                self.pause_fade_ = nil
                            end

                            self.pause_fade_ = fade:create(0.25, on_fade_begin, on_fade_in, on_fade_out, {fade_in = true, fade_out = true})
                                                   :addTo(cc.bounds_)
                        end
                    end
                end
            end
        end
    end
end

return level_controller