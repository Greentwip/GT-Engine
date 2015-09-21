-- Copyright 2014-2015 Greentwip. All Rights Reserved.


local label = class("label", cc.Node)

function label:ctor(text, font, size, halign, valign, anchor, animation)

    self.label_ = cc.Label:createWithTTF(text, font, size, cc.size(0,0), halign, valign)
                          :addTo(self)

    if anchor == nil then
        anchor = cc.p(0,1)
    end

    self.label_:setAnchorPoint(anchor)

--    self.label_:getFontAtlas()
--               :setAliasTexParameters()

    if animation ~= nil then
        self.text_ = text
        self.char_count_ = 0
        self.delay_ = animation.delay_
        self.on_animate_end_callback_ = animation.callback_
        self.label_:setString("")
        self:setVisible(false)
    end

end

function label:start_animation()
    self:setVisible(true)
    local delay = cc.DelayTime:create(self.delay_)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(self.on_new_string_character))
    local forever = cc.RepeatForever:create(sequence)
    self:runAction(forever)
end

function label:on_new_string_character()

    if self.char_count_ < #self.text_ then
        self.char_count_ = self.char_count_ + 1
        self.label_:setString(string.sub(self.text_, 1, self.char_count_))
    else
        self:stopAllActions()
        if self.on_animate_end_callback_ then
            self:on_animate_end_callback_()
        end
    end

    return self
end

function label:step(dt)
    return self
end

return label


