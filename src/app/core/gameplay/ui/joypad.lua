--
-- Created by Victor on 9/22/2015 3:04 AM
--

local joypad = class("joypad", cc.Node)

function joypad:ctor(layout)
    local platform = device.platform

    local win_debug = false

    if platform == "windows" then
       win_debug = true
    end

    if (platform == "windows" or platform == "mac") and not win_debug then
        local function onKeyPressed(keycode, event)
            self:onKeypad(keycode, true)
        end

        local function onKeyReleased(keycode, event)
            self:onKeypad(keycode, false)
        end

        local listener = cc.EventListenerKeyboard:create()
        listener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
        listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)
        layout:getScene():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, layout:getScene())
    else
        local tex_path = "sprites/core/joystick"

        self.ring_ = ccui.Button:create()
        self.ring_:setTouchEnabled(false)
        self.ring_:loadTextures(tex_path.."/vjoy_ring.png", tex_path.."/vjoy_ring.png", "")
        self.ring_:addTo(self)

        self.ring_:setPositionX(self.ring_:getPositionX() + self.ring_:getContentSize().width * 0.5)
        self.ring_:setPositionY(self.ring_:getPositionY() + self.ring_:getContentSize().height * 0.5)

        self.circle_ = ccui.Button:create()
        self.circle_:setTouchEnabled(true)
        self.circle_:setSwallowTouches(false)
        self.circle_:loadTextures(tex_path.."/vjoy_circle.png", tex_path.."/vjoy_circle.png", "")
        self.circle_:setPosition(cc.p(self.ring_:getPositionX(),
                                      self.ring_:getPositionY()))
        self.circle_:setPressedActionEnabled(true)
        self.circle_:onTouch(function(event) self:onJoystick(event) end)
        self.circle_:addTo(self)

        self.start_ = ccui.Button:create()
        self.start_:setTouchEnabled(true)
        self.start_:loadTextures(tex_path.."/start_button.png", tex_path.."/start_button.png", "")
        self.start_:setPosition(cc.p(display.right_top.x - self.start_:getContentSize().width * 0.5,
                                     display.right_top.y - self.start_:getContentSize().height))
        self.start_:setPressedActionEnabled(true)
        self.start_:onTouch(function(event) self:onButton(event) end)
        self.start_:addTo(self)

        self.a_ = ccui.Button:create()
        self.a_:setTouchEnabled(true)
        self.a_:loadTextures(tex_path.."/a_button.png", tex_path.."/a_button.png", "")
        self.a_:setPosition(cc.p(display.right_bottom.x - self.start_:getContentSize().width * 0.5,
                                 display.right_bottom.y + self.start_:getContentSize().height * 0.5))
        self.a_:setPressedActionEnabled(true)
        self.a_:onTouch(function(event) self:onButton(event) end)
        self.a_:addTo(self)

        self.b_ = ccui.Button:create()
        self.b_:setTouchEnabled(true)
        self.b_:loadTextures(tex_path.."/b_button.png", tex_path.."/b_button.png", "")
        self.b_:setPosition(cc.p(self.a_:getPositionX() - self.b_:getContentSize().width, self.a_:getPositionY()))
        self.b_:setPressedActionEnabled(true)
        self.b_:onTouch(function(event) self:onButton(event) end)
        self.b_:addTo(self)

        local function onTouchBegan(touch, event)
            self:onTouchBegan(touch, event)
            return true
        end

        local function onTouchMoved(touch, event)
            self:onTouchMoved(touch, event)
        end


        if win_debug then
            local listener = cc.EventListenerMouse:create()
            listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_MOUSE_DOWN)
            listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_MOUSE_MOVE)
            layout:getScene():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, layout:getScene())
        else
            local listener = cc.EventListenerTouchOneByOne:create()
            listener:setSwallowTouches(false)
            listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
            listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
            layout:getScene():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, layout:getScene())
        end

        self.moving_joystick_ = false
        self.in_range_ = false
        self.can_move_ = false
        self.dead_zone_ = 5
        self.range_key_ = cc.key_code_.none

        self.joy_keys_ = {}

        self.joy_keys_[#self.joy_keys_ + 1] = cc.key_code_.right
        self.joy_keys_[#self.joy_keys_ + 1] = cc.key_code_.left
        self.joy_keys_[#self.joy_keys_ + 1] = cc.key_code_.up
        self.joy_keys_[#self.joy_keys_ + 1] = cc.key_code_.down

    end
end

function joypad:onTouchBegan(touch, event)
    self.previous_touch_ = touch:getLocation()
end

function joypad:onTouchMoved(touch, event)

    if self.moving_joystick_ then

        local x_move = touch:getLocation().x - self.previous_touch_.x
        local y_move = touch:getLocation().y - self.previous_touch_.y

        local ring_position = cc.p(self.ring_:getPositionX(), self.ring_:getPositionY())
        local new_position  = cc.p(self.circle_:getPositionX() + x_move, self.circle_:getPositionY() + y_move)

        local circle_distance = cc.pGetDistance(new_position, ring_position)

        if circle_distance <= self.ring_:getContentSize().width * 0.5 then
            self.circle_:setPosition(new_position)
        end

        if circle_distance >= self.dead_zone_ then
            self.can_move_ = true
        else
            self.can_move_ = false
        end

    end

    self.previous_touch_ = touch:getLocation()
end

function joypad:onTouchEnded(touch, event)

end

function joypad:onJoystick(event)

    if event.name == "began" then
        self.moving_joystick_ = true
    end

    if event.name == "moved" then
        local translated_key

        local delta_x = self.circle_:getPositionX() - self.ring_:getPositionX()
        local delta_y = self.circle_:getPositionY() - self.ring_:getPositionY()

        local angle = math.atan2(delta_y, delta_x) * 180 / math.pi

        print (angle)

        if self.can_move_ then

            if angle >= 30 and angle <= 60 then
                if not self.in_range_ then
                    cc.keys_[cc.key_code_.up].status_  = cc.KEY_STATUS.DOWN
                    cc.keys_[cc.key_code_.up].pressed_ = true

                    cc.keys_[cc.key_code_.right].status_  = cc.KEY_STATUS.DOWN
                    cc.keys_[cc.key_code_.right].pressed_ = true
                    self.in_range_ = true
                    self.range_key_ = cc.key_code_.up_right
                end
            else
                if self.range_key_ == cc.key_code_.up_right then
                    cc.keys_[cc.key_code_.up].status_ = cc.KEY_STATUS.UP
                    cc.keys_[cc.key_code_.up].released_ = true

                    cc.keys_[cc.key_code_.right].status_ = cc.KEY_STATUS.UP
                    cc.keys_[cc.key_code_.right].released_ = true

                    self.in_range_ = false
                end
            end

            if angle >= 120 and angle <= 150 then
                if not self.in_range_ then
                    cc.keys_[cc.key_code_.up].status_  = cc.KEY_STATUS.DOWN
                    cc.keys_[cc.key_code_.up].pressed_ = true

                    cc.keys_[cc.key_code_.left].status_  = cc.KEY_STATUS.DOWN
                    cc.keys_[cc.key_code_.left].pressed_ = true
                    self.in_range_ = true
                    self.range_key_ = cc.key_code_.up_left
                end
            else
                if self.range_key_ == cc.key_code_.up_left then
                    cc.keys_[cc.key_code_.up].status_ = cc.KEY_STATUS.UP
                    cc.keys_[cc.key_code_.up].released_ = true

                    cc.keys_[cc.key_code_.left].status_ = cc.KEY_STATUS.UP
                    cc.keys_[cc.key_code_.left].released_ = true

                    self.in_range_ = false
                end
            end

            if angle >= -60 and angle <= -30 then
                if not self.in_range_ then
                    cc.keys_[cc.key_code_.down].status_  = cc.KEY_STATUS.DOWN
                    cc.keys_[cc.key_code_.down].pressed_ = true

                    cc.keys_[cc.key_code_.right].status_  = cc.KEY_STATUS.DOWN
                    cc.keys_[cc.key_code_.right].pressed_ = true
                    self.in_range_ = true
                    self.range_key_ = cc.key_code_.down_right
                end
            else
                if self.range_key_ == cc.key_code_.down_right then
                    cc.keys_[cc.key_code_.down].status_ = cc.KEY_STATUS.UP
                    cc.keys_[cc.key_code_.down].released_ = true

                    cc.keys_[cc.key_code_.right].status_ = cc.KEY_STATUS.UP
                    cc.keys_[cc.key_code_.right].released_ = true

                    self.in_range_ = false
                end
            end

            if angle >= -150 and angle <= -120 then
                if not self.in_range_ then
                    cc.keys_[cc.key_code_.down].status_  = cc.KEY_STATUS.DOWN
                    cc.keys_[cc.key_code_.down].pressed_ = true

                    cc.keys_[cc.key_code_.left].status_  = cc.KEY_STATUS.DOWN
                    cc.keys_[cc.key_code_.left].pressed_ = true
                    self.in_range_ = true
                    self.range_key_ = cc.key_code_.down_left
                end
            else
                if self.range_key_ == cc.key_code_.down_left then
                    cc.keys_[cc.key_code_.down].status_ = cc.KEY_STATUS.UP
                    cc.keys_[cc.key_code_.down].released_ = true

                    cc.keys_[cc.key_code_.left].status_ = cc.KEY_STATUS.UP
                    cc.keys_[cc.key_code_.left].released_ = true

                    self.in_range_ = false
                end
            end
            if angle >= -30 and angle <= 30 then
                if not self.in_range_ then
                    cc.keys_[cc.key_code_.right].status_  = cc.KEY_STATUS.DOWN
                    cc.keys_[cc.key_code_.right].pressed_ = true
                    self.in_range_ = true
                    self.range_key_ = cc.key_code_.right
                end
            else
                if self.range_key_ == cc.key_code_.right then
                    cc.keys_[cc.key_code_.right].status_ = cc.KEY_STATUS.UP
                    cc.keys_[cc.key_code_.right].released_ = true

                    self.in_range_ = false
                end
            end

            if angle >= 60 and angle <= 120 then
                if not self.in_range_ then
                    cc.keys_[cc.key_code_.up].status_  = cc.KEY_STATUS.DOWN
                    cc.keys_[cc.key_code_.up].pressed_ = true
                    self.in_range_ = true
                    self.range_key_ = cc.key_code_.up
                end
            else
                if self.range_key_ == cc.key_code_.up then
                    cc.keys_[cc.key_code_.up].status_ = cc.KEY_STATUS.UP
                    cc.keys_[cc.key_code_.up].released_ = true

                    self.in_range_ = false
                end
            end

            if math.abs(angle) >= 150 and math.abs(angle) <= 180 then
                if not self.in_range_ then
                    cc.keys_[cc.key_code_.left].status_  = cc.KEY_STATUS.DOWN
                    cc.keys_[cc.key_code_.left].pressed_ = true
                    self.in_range_ = true
                    self.range_key_ = cc.key_code_.left
                end
            else
                if self.range_key_ == cc.key_code_.left then
                    cc.keys_[cc.key_code_.left].status_ = cc.KEY_STATUS.UP
                    cc.keys_[cc.key_code_.left].released_ = true

                    self.in_range_ = false
                end
            end


            if angle <= -60 and angle >= -120 then
                if not self.in_range_ then
                    cc.keys_[cc.key_code_.down].status_  = cc.KEY_STATUS.DOWN
                    cc.keys_[cc.key_code_.down].pressed_ = true
                    self.in_range_ = true
                    self.range_key_ = cc.key_code_.down
                end
            else
                if self.range_key_ == cc.key_code_.down then
                    cc.keys_[cc.key_code_.down].status_ = cc.KEY_STATUS.UP
                    cc.keys_[cc.key_code_.down].released_ = true

                    self.in_range_ = false
                end
            end


        end
    end


    if event.name == "ended" or event.name == "cancelled" then
        self.moving_joystick_ = false
        self.circle_:setPosition(cc.p(self.ring_:getPositionX(),
                                      self.ring_:getPositionY()))
        self.in_range_ = false
        self.can_move_ = false

        for i = 1, #self.joy_keys_ do
            cc.keys_[self.joy_keys_[i]].status_    = cc.KEY_STATUS.UP
            if cc.keys_[self.joy_keys_[i]].pressed_ then
                cc.keys_[self.joy_keys_[i]].pressed_ = false
                cc.keys_[self.joy_keys_[i]].released_ = true
            end
        end

    end
end

function joypad:onButton(event)

    local translated_key

    if event.target == self.a_ then
        translated_key = cc.key_code_.a
    elseif event.target == self.b_ then
        translated_key = cc.key_code_.b
    elseif event.target == self.start_ then
        translated_key = cc.key_code_.start
    end

    if translated_key ~= nil then
       if event.name == "began" then
           cc.keys_[translated_key].status_  = cc.KEY_STATUS.DOWN
           cc.keys_[translated_key].pressed_ = true
       elseif event.name == "ended" or event.name == "cancelled" then
           cc.keys_[translated_key].status_ = cc.KEY_STATUS.UP
           cc.keys_[translated_key].released_ = true
       end
    end
end


function joypad:onKeypad(keycode, keydown)

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

function joypad:step(dt)
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

return joypad