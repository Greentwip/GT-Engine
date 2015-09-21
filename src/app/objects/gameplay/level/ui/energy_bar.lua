-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local energy_bar = class("energy_bar", cc.Node)
local sprite = import("app.core.graphical.sprite")


function energy_bar:ctor(inverse)

    self.sprite_ = sprite:create("sprites/gameplay/level/ui/energy_bar/bar/bar", cc.p(0, 1))
                         :setPosition(cc.p(0,0))
                         :addTo(self)


    self.bar_meter_sprites_ = {}

    local x_position = 1

    local y_position = -self.sprite_:getContentSize().height

    if inverse then
        y_position = 0
    end


    for i = 1, 28 do

        if inverse then
            y_position = y_position - 2
        else
            y_position = y_position + 2
        end

        self.bar_meter_sprites_[#self.bar_meter_sprites_ + 1] = sprite:create("sprites/gameplay/level/ui/energy_bar/meter/meter", cc.p(0, 1))
                                                                      :setPosition(cc.p(x_position, y_position))
                                                                      :addTo(self)
    end

    self.bar_meter_ = 28

    self.sound_effects_ = {}
end

function energy_bar:set_color()

end


function energy_bar:set_meter(value)

    if value ~= self.bar_meter_ and value ~= nil then

        if not self:isVisible() then
            self:setVisible(true)
        end

        if value <= 0 then
            for i = 1, #self.bar_meter_sprites_ do
                self.bar_meter_sprites_[i]:setVisible(false)
            end
        elseif value >= 28 then
            for i = 1, #self.bar_meter_sprites_ do
                self.bar_meter_sprites_[i]:setVisible(true)
            end
        else
            for i = 1, #self.bar_meter_sprites_ do
                if i <= value then
                    self.bar_meter_sprites_[i]:setVisible(true)
                else
                    self.bar_meter_sprites_[i]:setVisible(false)
                end
            end
        end

        self.bar_meter_ = value
    elseif value == nil then
        self:setVisible(false)
        self.bar_meter_ = value
    end

end

return energy_bar

