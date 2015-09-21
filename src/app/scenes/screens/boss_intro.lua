-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local boss_intro = import("app.core.gameplay.control.layout_base").create("boss_intro")

local label  = import("app.core.graphical.label")
local sprite = import("app.core.graphical.sprite")

local intro = import("app.scenes.special.intro")

function boss_intro:onLoad()

    self.boss_ = sprite:create("sprites/gameplay/screens/boss_intro/boss_animation/boss_animation", cc.p(0.5, 0.0))
                       :setPosition(display.center)
                       :setVisible(false)
                       :addTo(self, 256)

    self.boss_:setPositionY(self.boss_:getPositionY() - 16)

    local boss_animation = {name = "animate",  animation = { name = "boss_animation_" .. cc.current_level_.mug_,  forever = false, delay = 0.10} }

    self.boss_:load_action(boss_animation, false)


    self.text_ = label:create(string.gsub(cc.current_level_.mug_, "man", " man"),
                              "fonts/megaman_2.ttf",
                              8,
                              cc.TEXT_ALIGNMENT_CENTER,
                              cc.VERTICAL_TEXT_ALIGNMENT_TOP,
                              cc.p(0.5, 0.5),
                              {delay_ = 0.2, callback_ = nil})
                       :setPosition(display.center)
                       :addTo(self, 256)

    self.text_:setPositionY((self.text_:getPositionY() - self.text_:getContentSize().height * 0.5) -
                             self.boss_:getContentSize().height * 0.5)

    local parallax_arguments = { category_ = "gameplay",
                                 sub_category_ = "screens",
                                 package_ = "boss_intro",
                                 cname_ = cc.current_level_.mug_,
                                 bgm_ = "sounds/bgm_boss_intro.mp3",
                                 on_end_callback_ = self.on_intro_complete,
                                 sender_ = self}

    self.intro_ = intro:create(parallax_arguments)
                       :setPosition(display.left_bottom)
                       :addTo(self)
end


function boss_intro:on_intro_complete()

    local boss_animate = cc.CallFunc:create(function()
        self.boss_:setVisible(true)
        self.boss_:run_action("animate")
    end)

    local delay = cc.DelayTime:create(self.boss_:get_action_duration("animate"))

    local text_animation = cc.CallFunc:create(self.on_boss_intro_complete)

    local sequence = cc.Sequence:create(boss_animate, delay, text_animation, nil)

    self:runAction(sequence)
end

function boss_intro:on_boss_intro_complete()
    self.text_:start_animation()
end

function boss_intro:step(dt)

    self.intro_:step(dt)

    if not audio.isMusicPlaying() and not self.triggered_  then
        self.triggered_ = true

        self:getApp()
            :enterScene("levels.level", "FADE", 1, {physics = true})
            :prepare()

    end

    self:post_step(dt)
    return self
end

return boss_intro