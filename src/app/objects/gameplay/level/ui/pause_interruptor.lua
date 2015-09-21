-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local pause_interruptor = class("pause_interruptor", cc.Node)
local sprite      = import("app.core.graphical.sprite")

function pause_interruptor:ctor(animation, callback)
    self.sprite_ = sprite:create("sprites/gameplay/screens/pause_menu/pause_interruptor/pause_interruptor", cc.p(0, 1))
                         :setPosition(cc.p(0,0))
                         :addTo(self)

    self.sprite_:set_animation(animation .. "_" .. "interruptor")
    self.on_triggered_ = callback
    self.visitable_ = true

    self:leave()
end

function pause_interruptor:set_visitable(visitable)
    self.visitable_ = visitable
    self.sprite_:set_image_index(1)
    return self
end

function pause_interruptor:visit()
    if self.visitable_ then
        self.sprite_:set_image_index(2)
    end
    return self
end

function pause_interruptor:leave()
    if self.visitable_ then
        self.sprite_:set_image_index(1)
    end
    return self
end

function pause_interruptor:trigger()
    if self.on_triggered_ then
        self.on_triggered_(self)
    end
    return self
end

function pause_interruptor:set_triggered_callback(callback)
    self.on_triggered_ = callback
    return self
end

return pause_interruptor