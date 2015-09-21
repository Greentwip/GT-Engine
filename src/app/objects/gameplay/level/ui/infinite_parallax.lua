-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local animation = import ("app.objects.gameplay.level.animations.base.animation")

local infinite_parallax = class("infinite_parallax", animation)

function infinite_parallax:animate(cname)
    return self
end

function infinite_parallax:organize(speed, path)
    self.scroller_ = self.sprite_:create(path, cc.p(0.5, 0.5))
                                 :setPosition(cc.p(0,
                                                   0 - self.sprite_:getContentSize().height))
                                 :addTo(self)

    self.sprite_limit_   = cc.p(0, 0 + self.sprite_:getContentSize().height)
    self.scroller_startup_ = cc.p(0, 0 - self.sprite_:getContentSize().height)
    self.speed_ = speed
    return self
end

function infinite_parallax:horizontal_scroll()

end

function infinite_parallax:vertical_scroll()
    self.sprite_:setPositionY(self.sprite_:getPositionY() + self.speed_.y)
    self.scroller_:setPositionY(self.scroller_:getPositionY() + self.speed_.y)

    if self.sprite_:getPositionY() >= self.sprite_limit_.y then
       self.sprite_:setPositionY(self.scroller_startup_.y)
    end

    if self.scroller_:getPositionY() >= self.sprite_limit_.y then
        self.scroller_:setPositionY(self.scroller_startup_.y)
    end

end

function infinite_parallax:step(dt)

    if self.speed_.x ~= 0 then
        self:horizontal_scroll()
    elseif self.speed_.y ~= 0 then
        self:vertical_scroll()
    end

    return self
end

return infinite_parallax
