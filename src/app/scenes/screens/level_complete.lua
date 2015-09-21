-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local level_complete = import("app.core.gameplay.control.layout_base").create("level_complete")

local sprite    = import("app.core.graphical.sprite")
local label     = import("app.core.graphical.label")
local selector  = import("app.objects.gameplay.level.ui.selector")

function level_complete:onLoad() -- weird bug when using onLoad

    self.background_ = sprite:create("sprites/gameplay/screens/level_complete/level_complete", cc.p(0, 0))
                             :setPosition(cc.p(0,0))
                             :addTo(self)


    self.selector_ = selector:create("square", "large")
                             :addTo(self, 128)

    self.selector_:setPosition(cc.p(self.background_:getContentSize().width * 0.5, 66 - self.selector_.sprite_:getContentSize().height * 0.5))

    self.text_continue_ = label:create("continue",
                                "fonts/megaman_2.ttf",
                                8,
                                cc.TEXT_ALIGNMENT_CENTER,
                                cc.VERTICAL_TEXT_ALIGNMENT_TOP, cc.p(0.5, 0.5))
                               :addTo(self, 128)

    self.text_quit_ = label:create("quit",
                                "fonts/megaman_2.ttf",
                                8,
                                cc.TEXT_ALIGNMENT_CENTER,
                                cc.VERTICAL_TEXT_ALIGNMENT_TOP, cc.p(0.5, 0.5))
                           :addTo(self, 128)

    self.text_title_ = label:create("Finish",
                                    "fonts/megaman_2.ttf",
                                    8,
                                    cc.TEXT_ALIGNMENT_CENTER,
                                    cc.VERTICAL_TEXT_ALIGNMENT_TOP, cc.p(0.5, 0.5))
                                :addTo(self, 128)


    self.text_continue_:setPosition(cc.p(self.selector_:getPositionX(), self.selector_:getPositionY()))
    self.text_quit_:setPosition(cc.p(self.selector_:getPositionX(), self.selector_:getPositionY() - self.selector_.sprite_:getContentSize().height))

    self.text_title_:setPosition(cc.p(self.selector_:getPositionX(),
                                      self.background_:getContentSize().height - self.text_title_.label_:getContentSize().height * 1.6))

    audio.playMusic("sounds/bgm_gameover.mp3", false)

    -- self variables
    self.triggered_ = false

    self.items_ = {}
    self.items_[#self.items_ + 1] = self.text_continue_
    self.items_[#self.items_ + 1] = self.text_quit_

    self.text_continue_.trigger = function()
        self:getApp():enterScene("screens.stage_select", "FADE", 0.5)
    end

    self.text_quit_.trigger = function()
        cc.Director:getInstance():endToLua()
    end

    self.selector_:set_selected_item(self.text_continue_)

end

function level_complete:step(dt)
    if not self.triggered_ then
        if cc.key_pressed(cc.key_code_.a) then
            self.triggered_ = true
            audio.playSound("sounds/sfx_selected.wav")
        end


        self.selector_:select_from(self.items_)
    end

    self:post_step(dt)

    return self
end



return level_complete