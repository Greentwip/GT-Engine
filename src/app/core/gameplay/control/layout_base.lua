-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local joypad = import("app.core.gameplay.ui.joypad")

local layout_base = {}

function layout_base.create(class_name)

    local layout = class(class_name, cc.load("mvc").ViewBase)

    function layout:onCreate()
        -- add keypad layer
--        self.keypad_layer_ = display.newLayer()
--                                    :onKeypad(handler(self, self.onKeypad))
--                                    :addTo(self)

        -- binding to the "event" component
        cc.bind(self, "event")

        -- schedule update
        self:start()

        if self.onLoad then
            self:onLoad()
        end
    end

    function layout:onAfterCreate()
        self.joypad_ = joypad:create(self):addTo(self, 4096)
    end

    function layout:start()
        self:scheduleUpdate(handler(self, self.step))
        return self
    end

    function layout:stop()
        self:unscheduleUpdate()
        return self
    end

    function layout:onCleanup()
        self:removeAllEventListeners()
    end

    function layout:post_step(dt)
        self.joypad_:step(dt)
    end


    return layout
end

return layout_base

