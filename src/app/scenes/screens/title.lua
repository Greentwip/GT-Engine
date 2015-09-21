-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local title = import("app.core.gameplay.control.layout_base").create("title")

local sprite    = import("app.core.graphical.sprite")
local label     = import("app.core.graphical.label")
local selector  = import("app.objects.gameplay.level.ui.selector")

function title:onLoad()


    self.background_ = sprite:create("sprites/gameplay/screens/title_screen/title_screen", cc.p(0, 0))
                             :setPosition(cc.p(0,0))
                             :addTo(self)

    self.selector_ = selector:create("arrow", "right")
                             :setPosition(cc.p(64,96))
                             :addTo(self, 128)

    self.text_ = label:create("start game",
                              "fonts/megaman_2.ttf",
                              8,
                              cc.TEXT_ALIGNMENT_LEFT,
                              cc.VERTICAL_TEXT_ALIGNMENT_TOP)
                      :addTo(self, 128)

    self.text_:setPosition(cc.p(self.selector_:getPositionX() + self.selector_.sprite_:getContentSize().width,
                                self.selector_:getPositionY() + self.text_.label_:getContentSize().height * 0.5))

    audio.playMusic("sounds/bgm_title.mp3", true)

    -- self variables
    self.triggered_ = false
end

function title:step(dt)
    if not self.triggered_ then
        if cc.key_pressed(cc.key_code_.a) then
            self.triggered_ = true
            audio.playSound("sounds/sfx_selected.wav")

            self.exit_arguments_ = {}
            self.exit_arguments_.demo_browner_id_ = cc.browners_.violet_.id_

            self:getApp()
--            :enterScene("levels.level_weapon", "FADE", 0.5, {physics = true})
            :enterScene("screens.stage_select", "FADE", 0.5)
--                :prepare(self.exit_arguments_)
        end
    end

    self:post_step(dt)

    return self
end



return title