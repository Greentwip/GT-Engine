-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local stage_select = import("app.core.gameplay.control.layout_base").create("stage_select")

local label  = import("app.core.graphical.label")
local sprite        = import("app.core.graphical.sprite")

function stage_select:onLoad()

    if cc.player_.lives_ <= 0 then
        cc.player_.lives_ = 3
    end

    -- controller array, node container, previous controller, current controller and controller index
    self.scene_components_ = {}

    self.background_ = sprite:create("sprites/gameplay/screens/stage_select/stage_select_lite", cc.p(0, 0))
                             :setPosition(cc.p(0,0))
                             :addTo(self)

    self.cursor_ = sprite:create("sprites/gameplay/level/ui/selector/selector", cc.p(0, 1))
                         :setPosition(cc.p(104, 144))
                         :addTo(self, 128)

    self.cursor_:set_animation("square_small")

    local blink = cc.Blink:create(0.5, 4)
    local sequence = cc.RepeatForever:create(blink)
    self.cursor_:runAction(sequence)

    self.text_ = label:create("stage select",
                                "fonts/megaman_2.ttf",
                                8,
                                cc.TEXT_ALIGNMENT_LEFT,
                                cc.VERTICAL_TEXT_ALIGNMENT_TOP,
                                cc.p(0.5, 1))
                             :setAnchorPoint(0.5, 0.5)
                             :addTo(self, 100)

    self.text_:setPosition(cc.p(display.center.x, display.top - self.text_:getBoundingBox().height * 0.5))

    local sprite_path = "sprites/gameplay/screens/stage_select"
    self.cody_sprite_   = sprite:create(sprite_path .. "/spr_stage_select_cody", cc.p(0, 1))
                                :setPosition(cc.p(104, 144))
                                :addTo(self)


    self.cursor_.x_position = "middle"
    self.cursor_.y_position = "middle"

    audio.playMusic("sounds/bgm_stage_select.mp3", true)


    -- self variables
    self.triggered_ = false

    self:setup_mugs()
end

function stage_select:setup_mugs()
    self.mugs_ = {}

    local x_offset = 24
    local y_offset = 208

    for i = 1, #cc.levels_ do
        local key = cc.levels_[i]
        if i == 5 then
            x_offset = x_offset + 80;
        end

        local foe_name = key.mug_
        local drawable = false

        if foe_name == "sheriffman" or foe_name == "vineman" or foe_name == "militaryman" or foe_name == "nightman" then
            drawable = true
        end

        if drawable then
            local sprite_path = "sprites/gameplay/screens/stage_select"

            self.mugs_[#self.mugs_ + 1] =   sprite:create(sprite_path .. "/spr_stage_select_mugs", cc.p(0, 1))
                                                  :addTo(self)

            self.mugs_[#self.mugs_]:setPosition(cc.p(x_offset, y_offset))
            self.mugs_[#self.mugs_]:set_image_index(i)

            if key.defeated_ then
                self.mugs_[#self.mugs_]:setVisible(false)
            else
                self.mugs_[#self.mugs_]:setVisible(true)
            end
        end

        if x_offset >= 184 then
            x_offset = 24
            y_offset = y_offset - 64
        else
            x_offset = x_offset + 80
        end
    end
end

function stage_select:set_cody_sprite()

    local cody_sprite = 1

    if self.cursor_.x_position == 'middle' and self.cursor_.y_position == "middle" then

        cody_sprite = 1

    elseif self.cursor_.x_position == 'left' and self.cursor_.y_position == 'top' then

        cody_sprite = 2

    elseif self.cursor_.x_position == 'middle' and self.cursor_.y_position == 'top' then

        cody_sprite = 3

    elseif self.cursor_.x_position == 'right' and self.cursor_.y_position == 'top' then

        cody_sprite = 4

    elseif self.cursor_.x_position == 'right' and self.cursor_.y_position == 'middle' then

        cody_sprite = 5

    elseif self.cursor_.x_position == 'right' and self.cursor_.y_position == 'bottom' then

        cody_sprite = 6

    elseif self.cursor_.x_position == 'middle' and self.cursor_.y_position == 'bottom' then

        cody_sprite = 7

    elseif self.cursor_.x_position == "left" and self.cursor_.y_position == "bottom" then

        cody_sprite = 8

    else

        cody_sprite = 9

    end

    self.cody_sprite_:set_image_index(cody_sprite)

end

function stage_select:move_left()
    local play_fx = true;
    local move = true;

    if self.cursor_.y_position == "top" or self.cursor_.y_position == "bottom" then
        play_fx = false
        move = false
    end

    if move then
        if self.cursor_.x_position == "middle" then
            self.cursor_.x_position = 'left';
            self.cursor_:setPositionX(self.cursor_:getPositionX()-80)
        elseif self.cursor_.x_position == "left" then
            self.cursor_.x_position = 'right';
            self.cursor_:setPositionX(self.cursor_:getPositionX()+160)
        elseif self.cursor_.x_position == "right" then
            self.cursor_.x_position = 'middle';
            self.cursor_:setPositionX(self.cursor_:getPositionX()-80)
        end
    end

    if play_fx then
        audio.playSound("sounds/sfx_select.wav")
    end
end

function stage_select:move_right()
    local play_fx = true;
    local move = true;

    if self.cursor_.y_position == "top" or self.cursor_.y_position == "bottom" then
        play_fx = false
        move = false
    end

    if move then
        if self.cursor_.x_position == "middle" then
            self.cursor_.x_position = 'right';
            self.cursor_:setPositionX(self.cursor_:getPositionX()+80)
        elseif self.cursor_.x_position == "left" then
            self.cursor_.x_position = 'middle';
            self.cursor_:setPositionX(self.cursor_:getPositionX()+80)
        elseif self.cursor_.x_position == "right" then
            self.cursor_.x_position = 'left';
            self.cursor_:setPositionX(self.cursor_:getPositionX()-160)
        end
    end

    if play_fx then
        audio.playSound("sounds/sfx_select.wav")
    end

end

function stage_select:move_up()

    local play_fx = true
    local move = true

    if self.cursor_.x_position == "left" or self.cursor_.x_position == "right" then
        play_fx = false
        move = false
    end

    if move then
        if self.cursor_.y_position == "middle" then
            self.cursor_.y_position = "top"
            self.cursor_:setPositionY(self.cursor_:getPositionY() + 64)
        elseif self.cursor_.y_position == "top" then
            self.cursor_.y_position = "bottom"
            self.cursor_:setPositionY(self.cursor_:getPositionY() - 128)
        elseif self.cursor_.y_position == "bottom" then
            self.cursor_.y_position = "middle"
            self.cursor_:setPositionY(self.cursor_:getPositionY() + 64)
        end
    end

    if play_fx then
        audio.playSound("sounds/sfx_select.wav")
    end

end

function stage_select:move_down()
    local play_fx = true;
    local move = true;

    if self.cursor_.x_position == "left" or self.cursor_.x_position == "right" then
        play_fx = false
        move = false
    end

    if move then
        if self.cursor_.y_position == "middle" then
            self.cursor_.y_position = "bottom"
            self.cursor_:setPositionY(self.cursor_:getPositionY() - 64)
        elseif self.cursor_.y_position == "bottom" then
            self.cursor_.y_position = "top"
            self.cursor_:setPositionY(self.cursor_:getPositionY() + 128)
        elseif self.cursor_.y_position == "top" then
            self.cursor_.y_position = "middle"
            self.cursor_:setPositionY(self.cursor_:getPositionY() - 64)
        end
    end

    if play_fx then
        audio.playSound("sounds/sfx_select.wav")
    end

end

function stage_select:step(dt)

    local switch_sprite = false

    if not self.triggered_ then
        if cc.key_pressed(cc.key_code_.a) then
            local selected_mug

            for _, mug in pairs(self.mugs_) do
                if mug:check_touch(cc.p(self.cursor_:getPositionX(), self.cursor_:getPositionY())) then
                    selected_mug = mug
                end
            end

            if selected_mug ~= nil then

                local mug_index = selected_mug:get_image_index()
                cc.current_level_ = cc.levels_[mug_index]

                audio.playSound("sounds/sfx_selected.wav")

                if cc.current_level_.defeated_ then
                    self:getApp()
                        :enterScene("levels.level", "FADE", 2, {physics = true})
                        :prepare()
                else
                    self:getApp()
                        :enterScene("screens.boss_intro", "FADE", 1, {physics = false})
                end

                self.triggered_ = true
            end
        elseif cc.key_pressed(cc.key_code_.up) then
            switch_sprite = true
            self:move_up()
        elseif cc.key_pressed(cc.key_code_.down) then
            switch_sprite = true
            self:move_down()
        elseif cc.key_pressed(cc.key_code_.left) then
            switch_sprite = true
            self:move_left()
        elseif cc.key_pressed(cc.key_code_.right) then
            switch_sprite = true
            self:move_right()
        end

    end

    if switch_sprite then
        self:set_cody_sprite()
    end

    self:post_step(dt)
    return self
end

return stage_select