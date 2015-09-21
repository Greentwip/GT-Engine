-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local opening = import("app.core.gameplay.control.layout_base").create("opening")

local sprite    = import("app.core.graphical.sprite")

function opening:onLoad()

    local initiate = cc.CallFunc:create(function()
                        self:opening_intro_a()
                     end)

    local sequence = cc.Sequence:create(initiate, nil)
    self:runAction(sequence)

    --audio.playMusic("sounds/bgm_title.mp3", true)

    -- self variables
    self.triggered_ = false
end

function opening:opening_intro_a()
    self.greentwip_logo_ = sprite:create("sprites/gameplay/screens/opening/greentwip/greentwip_logo", cc.p(0, 0))
                                 :setPosition(cc.p(0,0))
                                 :addTo(self)

    local actions = {}
    actions[#actions + 1] = {name = "greentwip_logo",   animation = {name = "greentwip_logo",  forever = false, delay = 0.20} }

    self.greentwip_logo_:load_actions_set(actions, false)

    local pre_callback = cc.CallFunc:create(function()
        self.greentwip_logo_:run_action("greentwip_logo")
    end)

    local duration = cc.DelayTime:create(self.greentwip_logo_:get_action_duration("greentwip_logo"))
    local post_callback = cc.CallFunc:create(function()
        self.greentwip_logo_:stopAllActions()
        self.greentwip_logo_:removeSelf()
        self.greentwip_logo_ = nil
        self:getApp():enterScene("screens.title", "FADE", 1)
    end)

    local sequence = cc.Sequence:create(pre_callback, duration, post_callback, nil)

    self:runAction(sequence)
end

function opening:step(dt)
--    if not self.triggered_ then
--        if cc.key_pressed(cc.key_code_.start) then
--            self.triggered_ = true
--            audio.playSound("sounds/sfx_selected.wav")
--            self:getApp():enterScene("gameplay.stage_select", "FADE", 1)
--        end
--    end

    self:post_step(dt)

    return self
end



return opening