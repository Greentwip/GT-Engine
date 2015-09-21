-- Copyright 2014-2015 Greentwip. All Rights Reserved.


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

        local function onKeyPressed(keycode, event)
            self:onKeypad(keycode, true)
        end

        local function onKeyReleased(keycode, event)
            self:onKeypad(keycode, false)
        end


        local listener = cc.EventListenerKeyboard:create()
        listener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
        listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)
        self:getScene():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self:getScene())
    end

    function layout:onKeyPressed(keycode, event)
        print(cc.KeyCodeKey[keycode + 1])
    end

    function layout:onKeypad(keycode, keydown)

        local key = cc.KeyCodeKey[keycode + 1]
        local translated_key
        if key == "KEY_KP_ENTER" or key == "KEY_ENTER" then
            translated_key = cc.key_code_.start
        elseif key == "KEY_UP_ARROW" then
            translated_key = cc.key_code_.up
        elseif key == "KEY_DOWN_ARROW" then
            translated_key = cc.key_code_.down
        elseif key == "KEY_LEFT_ARROW" then
            translated_key = cc.key_code_.left
        elseif key == "KEY_RIGHT_ARROW" then
            translated_key = cc.key_code_.right
        elseif key == "KEY_Z" then
            translated_key = cc.key_code_.a
        elseif key == "KEY_X" then
            translated_key = cc.key_code_.b
        end

        if translated_key ~= nil then
            if keydown then
                cc.keys_[translated_key].status_  = cc.KEY_STATUS.DOWN
                cc.keys_[translated_key].pressed_ = true
            else
                cc.keys_[translated_key].status_ = cc.KEY_STATUS.UP
                cc.keys_[translated_key].released_ = true
            end

        end

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

        for i = 1, #cc.keys_ do
            if cc.keys_[i].pressed_ then
                cc.keys_[i].pressed_ = false
            end

            if cc.keys_[i].released_ then
                cc.keys_[i].released_ = false
            end
        end

        return self
    end


    return layout
end

return layout_base

