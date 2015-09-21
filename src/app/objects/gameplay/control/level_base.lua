-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local level_base = import("app.core.gameplay.control.layout_base").create("level_base")

local level_controller  = import("app.objects.gameplay.control.level_controller")

local camera            = import("app.objects.gameplay.level.environment.core.camera")
local bounds            = import("app.objects.gameplay.level.environment.core.bounds")
local block             = import("app.objects.gameplay.level.environment.core.block")

local cody              = import("app.objects.characters.player.cody")

function level_base:onLoad()
    self.status_ = cc.level_status_.init_
end

function level_base:calculate_tmx_position(tmx_object, tmx_map)

    local block_tmx_y = (tmx_map:getMapSize().height * tmx_map:getTileSize().height) - tmx_object["y"]

    local block_tmx_real_y = block_tmx_y - tmx_object["height"] * 0.5

    local position = cc.p(tmx_object["x"] + tmx_object["width"] * 0.5, display.top - block_tmx_real_y)
    return position
end

function level_base:offset_position(position, enemy, tmx_element) -- used for enemies, to acquire center

    local body_offset = enemy:getPhysicsBody():getShapes()[1]:getCenter()
    local y_offset = body_offset.y
    y_offset = y_offset + tmx_element.height * 0.5

    position.y = position.y + enemy:getPhysicsBody():getShapes()[1].size_.height * 0.5 - y_offset
    return position
end

function level_base:load_intro()

end

-- anything related to physics should be created here
function level_base:load(tmx_map, load_arguments)

    display.removeUnusedSpriteFrames()

    --------------------------------
    -- the tmx level
    local map = ccexp.TMXTiledMap:create(tmx_map)
                                 :setAnchorPoint(cc.p(0,1))
                                 :setPosition(display.left_top)
                                 :addTo(self, 0)

    --------------------------------
    -- the physics components
    if CC_DRAW_PHYSICS then
        self:getParent():getPhysicsWorld():setDebugDrawMask(1)
    end
    self:getParent():getPhysicsWorld():setGravity(cc.p(0, -1000))

    -- add groups - block group, player group and navigation group
    local group_array = map:getObjectGroup("blocks"):getObjects()

    for  i = 1, #group_array do
        local block_size = cc.size(group_array[i].width, group_array[i].height)
        block:create(self:calculate_tmx_position(group_array[i], map), block_size)
             :addTo(self)
    end

    -- add logic group
    group_array = map:getObjectGroup("logic"):getObjects()

    local first_check_point

    local built_logical = {}
    for  i = 1, #group_array do
        local block_size = cc.size(group_array[i].width, group_array[i].height)

        local logical = import("app.objects.gameplay.level.environment.logic." .. group_array[i].name)
                        :create(self:calculate_tmx_position(group_array[i], map), block_size)
                        :prepare(group_array[i])
                        :addTo(self)

        built_logical[#built_logical + 1] = logical
    end

    for i = 1, #built_logical do
       if built_logical[i]:getPhysicsBody():getShapes()[1]:getTag() == cc.tags.check_point then
           if built_logical[i].type_ == cc.tags.logic.check_point.first_ then
               first_check_point = built_logical[i]
           end
       end
    end

    cc.bounds_ = bounds:create()
                       :setPosition(cc.p(first_check_point:getPositionX(), first_check_point:getPositionY()))
                       :addTo(self, 1024)


    --------------------------------
    -- player
    local player = cody:create()
                       :setup("characters", "player", "regular", "browners")
                       :addTo(self, 512)


    --------------------------------
    -- camera
    local camera = camera:create()
                         :setup("gameplay", "level", "internal", "camera")
                         :prepare(player)
                         :addTo(cc.bounds_)

    camera:setPosition(0, camera:getPhysicsBody():getShapes()[1].size_.height * 0.25)


    --------------------------------
    -- the scene components
    local scene_components = {}

    -- add enemy group
    local enemy_group = map:getObjectGroup("enemies")

    if enemy_group ~= nil then
        group_array = enemy_group:getObjects()

        for  i = 1, #group_array do

            local enemy = import("app.objects.characters.enemies." .. group_array[i].type   .. "." .. group_array[i].name)
                          :create()
                          :setup("characters", "enemy", group_array[i].type, group_array[i].name)
                          :addTo(self, 128)

            enemy:prepare(self:offset_position(self:calculate_tmx_position(group_array[i], map), enemy, group_array[i]), player)

            scene_components[#scene_components + 1] = enemy
        end
    end

    -- add special group
    local special = map:getObjectGroup("special")

    if special ~= nil then
        group_array = special:getObjects()
        for  i = 1, #group_array do

            local creation_args = {}
            creation_args.real_position_     = self:calculate_tmx_position(group_array[i], map)
            creation_args.raw_object_        = group_array[i]
            creation_args.map_               = map


            local special_recipe = import("app.objects.gameplay.level.special." .. group_array[i].type   .. "." .. group_array[i].name)

            local special_element = special_recipe:create(creation_args)
                                                  :setup("gameplay", "level", "special" .. "/" ..group_array[i].type, group_array[i].name)
                                                  :addTo(self)

            creation_args.anchored_position_ = self:offset_position(self:calculate_tmx_position(group_array[i], map), special_element, group_array[i])


            if special_element.onAfterAnimate then
                special_element:onAfterAnimate(creation_args)
            end

            scene_components[#scene_components + 1] = special_element
        end
    end

    self.animations_    = {}


    -- add animations group
    local animations = map:getObjectGroup("animations")

    if animations ~= nil then
        group_array = animations:getObjects()
        for  i = 1, #group_array do

            local creation_args = {}
            creation_args.real_position_    = self:calculate_tmx_position(group_array[i], map)
            creation_args.raw_object_       = group_array[i]

            local animation = import("app.objects.gameplay.level.animations." .. group_array[i].type   .. "." .. group_array[i].name)
                            :create(creation_args)
                            :setup("gameplay", "level", "animations" .. "/" ..group_array[i].type, group_array[i].name)
                            :addTo(self, -64)

            self.animations_[animation] = animation
        end
    end

    -- add boss group
    local boss_group = map:getObjectGroup("boss")

    if boss_group ~= nil then
        group_array = boss_group:getObjects()
        for  i = 1, #group_array do

            local creation_args = {}
            creation_args.real_position_    = self:calculate_tmx_position(group_array[i], map)
            creation_args.raw_object_       = group_array[i]

            if group_array[i].name == "boss" then
                creation_args.player_ = player
                creation_args.type_ = group_array[i].type

                local boss = import("app.objects.characters.enemies.boss")
                            :create(creation_args)
                            :setup("characters", "enemy", "regular", "browners-enemy")
                            :addTo(self, 768)

                creation_args.anchored_position_ = self:offset_position(self:calculate_tmx_position(group_array[i], map), boss, group_array[i])

                if boss.onAfterAnimate then
                    boss:onAfterAnimate(creation_args)
                end

                scene_components[#scene_components + 1] = boss

            elseif group_array[i].name == "teleporter" then
                local block_size = cc.size(group_array[i].width, group_array[i].height)

                local teleporter = import("app.objects.gameplay.level.environment.logic." .. group_array[i].name)
                local logical = teleporter:create(self:calculate_tmx_position(group_array[i], map), block_size)

                logical:prepare(group_array[i])
                logical:addTo(self)
            end
        end
    end


    self.level_controller_ = level_controller:create(player, camera, scene_components, self.level_bgm_, self.load_arguments_)
                                             :addTo(self)

    self.level_controller_.check_point_ = first_check_point
    self.level_controller_:setup()

    self.bullets_       = {}

    self.status_ = cc.level_status_.run_
end

function level_base:schedule_component(component)
    component:addTo(self)
    self.level_controller_:schedule_component(component)
end

function level_base:step(dt)

    if self.status_ == cc.level_status_.init_ then
        self:load(self.tmx_map_, self.load_arguments_)
    else
        self.level_controller_:step(dt)
        self:post_step(dt)

        for _, bullet in pairs(self.bullets_) do
            bullet:step(dt)
            bullet:post_step(dt)

            if bullet.disposed_ then
                self.bullets_[bullet]:removeSelf()
                self.bullets_[bullet] = nil
            end

        end

        for _, animation in pairs(self.animations_) do
            animation:step(dt)
            animation:post_step(dt)

            if animation.disposed_ then
                self.animations_[animation]:removeSelf()
                self.animations_[animation] = nil
            end
        end
    end

    return self
end


return level_base