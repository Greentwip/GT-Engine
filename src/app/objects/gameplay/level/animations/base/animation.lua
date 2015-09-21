-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local animation    = import("app.core.physics.kinematic_character").create("animation")
local sprite  = import ("app.core.graphical.sprite")

function animation:onCreate(args)
    self.movement_is_non_blockable_ = true
    self:setPosition(args.real_position_)
end

function animation:setup(category, subcategory, package, cname)
    local sprite_path  = "sprites/" .. category .. "/" .. subcategory .. "/" .. package .. "/" .. cname .. "/" .. cname
    local physics_path = "physics/" .. category .. "/" .. subcategory .. "/" .. package .. "/" .. cname .. "/" .. cname


    self:load(sprite_path)

    if cc.FileUtils:getInstance():isFileExist(physics_path .. ".plist") then
        self:articulate(physics_path, cname)
    end


    if self.animate then
        self:animate(cname)
    end

    return self
end

function animation:animate(cname) -- should override in children
    return self
end

function animation:step(dt)
    if self.kinematic_body ~= nil then
        self:kinematic_step(dt)
    end
    return self
end

function animation:post_step(dt)
    if self.kinematic_body ~= nil then
        self:kinematic_post_step(dt)
    end
    return self
end

return animation