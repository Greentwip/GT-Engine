-- Copyright 2014-2015 Greentwip. All Rights Reserved.


local spairs = import("app.core.system.spairs")
local definition = import("app.core.graphical.definition")

local sprite = class("sprite", function(sprite_name, anchor)

    local data_filename = sprite_name .. ".plist"
    local image_filename

    if cc.texture_format_ == cc.texture_formats_.pvr_ then
        image_filename =  sprite_name .. ".pvr.ccz"
    end

    local plist_dict = cc.FileUtils:getInstance():getValueMapFromFile(data_filename)

    local setantasiete
    local frames = {}
    local animations = {}
    local current_animation = ""

    if not cc.SpriteFrameCache:getInstance():isSpriteFramesWithFileLoaded(data_filename) then
        display.loadSpriteFrames(data_filename, image_filename)
    end

    for k, v in spairs(plist_dict["frames"]) do

        local tokens = {}

        for token in string.gmatch(k, "([^_]+)") do
            tokens[#tokens + 1] = token
        end

        local animation_name = ""

        for i = 1, #tokens - 1 do

            if animation_name ~= "" then
                animation_name = animation_name .. "_" .. tokens[i]
            else
                animation_name = tokens[i]
            end

        end

        if current_animation ~= animation_name then
            current_animation = animation_name
            animations[#animations + 1] = current_animation
        end

        if frames[current_animation] == nil then
            frames[current_animation] = {}
        end

        frames[current_animation][tokens[#tokens] + 1] = k
    end


    local sprite = display.newSprite(display.newSpriteFrame(frames[animations[1]][1]))

    sprite.frames_ = frames
    sprite.animations_ = animations
    sprite.image_index_ = 1
    sprite.current_animation_ = animations[1]
    sprite:getTexture():setAliasTexParameters()
    sprite.touchRange_ = 0
    sprite:setPosition(display.center)
    sprite.actions_      = {}
    sprite.definitions_  = {}
    sprite.default_anchor_ = anchor
    sprite.current_action_ = nil

    if anchor ~= nil then
        sprite:setAnchorPoint(anchor)
    end

    return sprite
end)

function sprite:set_image_index(image_index)
    self.image_index_ = image_index

    self:setSpriteFrame(self.frames_[self.current_animation_][self.image_index_])
end

function sprite:set_animation(animation_name)
    if animation_name ~= self.current_animation_ then
        if self.frames_[animation_name] ~= nil then
            self.current_animation_ = animation_name
            self:set_image_index(1)
        end
    end

    return self
end

function sprite:get_animation_frames(animation_name)

    local frames = {}
    for _, v in spairs(self.frames_[animation_name]) do
        frames[#frames + 1] = cc.SpriteFrameCache:getInstance():getSpriteFrame(v)
    end

    return frames

end

function sprite:get_image_index()
    return self.image_index_
end

function sprite:get_sprite_frame_name()
    return self.frames_[self.current_animation_][self.image_index_]
end

function sprite:check_touch(point)
    local dx, dy = point.x - self:getPositionX(), point.y - self:getPositionY()
    local offset = math.sqrt(dx * dx + dy * dy)
    return offset <= self.touchRange_
end

function sprite:load_action(action, prepend_action, base_name)
    local built_actions = self.actions_

    if built_actions == nil then
        built_actions = {}
    end

    local animation_name

    if prepend_action then
        animation_name = action.name .. "/" .. action.animation.name
    else
        animation_name = action.animation.name
    end

    local animation_frames = display.newAnimation(self:get_animation_frames(animation_name),
                                                  action.animation.delay)

    local animation

    if action.animation.forever then
        animation = cc.RepeatForever:create(cc.Animate:create(animation_frames))
    else
        animation = cc.Animate:create(animation_frames)
    end

    animation:retain()

    local animation_base_name = ""
    if base_name ~= nil then
        animation_base_name = base_name .. "_"
    end

    animation:setTag(cc.tags.actions.animation)

    built_actions[animation_base_name .. action.name] =  animation
    built_actions[animation_base_name .. action.name].duration_ = animation_frames:getDuration()

    self.actions_ = built_actions
end

function sprite:load_actions_set(set, prepend_action, base_name)

    local built_actions = self.actions_

    if built_actions == nil then
        built_actions = {}
    end

    for _, action in pairs(set) do
        local animation_name

        if prepend_action then
            animation_name = action.name .. "/" .. action.animation.name
        else
            animation_name = action.animation.name
        end

        local animation_frames = display.newAnimation(self:get_animation_frames(animation_name),
                                                                                action.animation.delay)
        local animation

        if action.animation.forever then
            animation = cc.RepeatForever:create(cc.Animate:create(animation_frames))
        else
            animation = cc.Animate:create(animation_frames)
        end

        animation:retain()

        local animation_base_name = ""
        if base_name ~= nil then
            animation_base_name = base_name .. "_"
        end

        animation:setTag(cc.tags.actions.animation)

        built_actions[animation_base_name .. action.name] =  animation
        built_actions[animation_base_name .. action.name].duration_ = animation_frames:getDuration()
    end

    self.actions_ = built_actions
end

function sprite:load_definitions(path)
    if cc.FileUtils:getInstance():isFileExist(path .. ".plist") then
        local sprite_definition = definition:create(path)

        for definition_name, definition in pairs(sprite_definition.definitions_) do

            self.definitions_[definition_name] = {
                size_ = definition.size_,
                anchor_ = definition.anchor_
            }
        end
    end

end

function sprite:current_action()
    return self.current_action_
end

function sprite:get_action(name, base_name)
    if base_name ~= nil then
        return self.actions_[base_name .. "_" .. name]
    else
        return self.actions_[name]
    end
end

function sprite:get_definition(name)
    return self.definitions_[name]
end

function sprite:run_action(name, base_name)
    local new_action

    local definition_anchor

    if base_name ~= nil then
        if self:get_definition(base_name .. "_" .. name) ~= nil then
            local anchor = self:get_definition(base_name .. "_" .. name).anchor_
            definition_anchor = cc.p(anchor.x, anchor.y)
        end
    else
        if self:get_definition(name) ~= nil then
            local anchor = self:get_definition(name).anchor_
            definition_anchor = cc.p(anchor.x, anchor.y)
        end
    end

    if definition_anchor == nil then
        local anchor = self.default_anchor_
        if anchor ~= nil then
            definition_anchor = cc.p(anchor.x, anchor.y)
        else
            definition_anchor = cc.p(0.5, 0.5)
        end
    end

    if base_name ~= nil then
        new_action = self:get_action(base_name .. "_" .. name)
    else
        new_action = self:get_action(name)
    end

    if new_action ~= nil and self.current_action_ ~= new_action then
        self.current_action_ = new_action
        self:stopAllActionsByTag(cc.tags.actions.animation)

        if self:isFlippedX() then
           definition_anchor.x = 1.0 - definition_anchor.x
        end

        self:setAnchorPoint(definition_anchor)
        self:runAction(self.current_action_)
    end
end

function sprite:get_action_duration(name, base_name)
    if base_name ~= nil then
        return self.actions_[base_name .. "_" .. name].duration_
    else
        return self.actions_[name].duration_
    end
end

function sprite:reverse_action()
    self.current_action_ = self.current_action_:reverse()
    self:stopAllActionsByTag(cc.tags.actions.animation)
    self:runAction(self.current_action_)
end

function sprite:pause_actions()

    if self:getActionByTag(cc.tags.actions.animation) ~= nil then
       self:stopAllActionsByTag(cc.tags.actions.animation)
    end

end

function sprite:resume_actions()

    if self:getActionByTag(cc.tags.actions.animation) == nil then
        self:runAction(self.current_action_)
    end

end

function sprite:stop_actions()
    self.current_action_ = nil
    self:stopAllActionsByTag(cc.tags.actions.animation)
end

return sprite