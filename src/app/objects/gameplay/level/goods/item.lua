-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local item      = import("app.core.physics.kinematic_character").create("item")

function item:onCreate()
    self:setTag(cc.tags.item)
end

function item:animate(cname)

    local actions = {}
    actions[#actions + 1] = {name = "life",         animation = {name = "life",         forever = false, delay = 0.10} }
    actions[#actions + 1] = {name = "helmet",       animation = {name = "helmet",       forever = false, delay = 0.10} }
    actions[#actions + 1] = {name = "head",         animation = {name = "head",         forever = false, delay = 0.10} }
    actions[#actions + 1] = {name = "chest",        animation = {name = "chest",        forever = false, delay = 0.10} }
    actions[#actions + 1] = {name = "fist",         animation = {name = "fist",         forever = false, delay = 0.10} }
    actions[#actions + 1] = {name = "boot",         animation = {name = "boot",         forever = false, delay = 0.10} }

    actions[#actions + 1] = {name = "health_small", animation = {name = "health_small", forever = true,  delay = 0.10} }
    actions[#actions + 1] = {name = "health_big",   animation = {name = "health_big",   forever = true,  delay = 0.10} }

    actions[#actions + 1] = {name = "energy_small", animation = {name = "energy_small", forever = true,  delay = 0.10} }
    actions[#actions + 1] = {name = "energy_big",   animation = {name = "energy_big",   forever = true,  delay = 0.10} }

    actions[#actions + 1] = {name = "e_tank",       animation = {name = "e_tank",       forever = false, delay = 0.10} }
    actions[#actions + 1] = {name = "m_tank",       animation = {name = "m_tank",       forever = false, delay = 0.10} }

    self.sprite_:load_actions_set(actions, false)

    self:swap("life", true)
end

function item:swap(animation, permanent)

    for _, item in pairs(cc.item_) do
        if animation == item.string_ then
            self.id_ = item.id_
            self.callback_ = item.callback_
        end
    end

    if permanent then
        self.sprite_:run_action(animation)
    else
        self.sprite_:run_action(animation)

        local delay = cc.DelayTime:create(2.0)
        local blink = cc.Blink:create(2, 20)
        local callback = cc.CallFunc:create(function()
            self.disposed_ = true
        end)

        local sequence = cc.Sequence:create(delay, blink, callback, nil)

        self:runAction(sequence)
    end
    return self
end

function item:step(dt)
    self:kinematic_step(dt)
    return self
end

function item:post_step(dt)
    self:kinematic_post_step(dt)
    return self
end


return item
