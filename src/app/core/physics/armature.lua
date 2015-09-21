-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local armature = class("armature")

function armature:point_from_string(point_string)

    local str_point = {}

    for str in string.gmatch(point_string, "(-*[0-9]+.[0-9]+)") do
        str_point[#str_point + 1] = tonumber(str)
    end

    local point = cc.p(str_point[1], str_point[2])
    return point
end

function armature:size_from_string(size_string)

    local str_point = {}

    for str in string.gmatch(size_string, "(-*[0-9]+.[0-9]+)") do
        str_point[#str_point + 1] = tonumber(str)
    end

    local point = cc.size(str_point[1], str_point[2])
    return point
end

function armature:ctor(data_filename)
    local plist_dict = cc.FileUtils:getInstance():getValueMapFromFile(data_filename .. ".plist")

    self.bodies_ = {}

    local body_index = 1

    for body_name, body in pairs(plist_dict["bodies"]) do

        self.bodies_[body_name] = {}
        if body.size ~= nil then
            self.bodies_[body_name].size_                   = self:size_from_string(body.size)
        else
            self.bodies_[body_name].size_ = nil
        end
        self.bodies_[body_name].anchor_point_           = self:point_from_string(body.anchorpoint)
        self.bodies_[body_name].is_dynamic_             = body.is_dynamic
        self.bodies_[body_name].affected_by_gravity_    = body.affected_by_gravity
        self.bodies_[body_name].allows_rotation_        = body.allows_rotation
        self.bodies_[body_name].linear_damping_         = body.linear_damping
        self.bodies_[body_name].angular_damping_        = body.angular_damping
        self.bodies_[body_name].velocity_limit_         = body.velocity_limit
        self.bodies_[body_name].angular_velocity_limit_ = body.angular_velocity_limit

        self.bodies_[body_name].fixtures_ = {}

        for fixture_index, fixture in pairs(body["fixtures"]) do

            self.bodies_[body_name].fixtures_[fixture_index] = {}
            local current_fixture = self.bodies_[body_name].fixtures_[fixture_index]

            current_fixture.density_              = fixture.density
            current_fixture.restitution_          = fixture.restitution
            current_fixture.tag_                  = fixture.tag
            current_fixture.group_                = fixture.group
            current_fixture.category_mask_        = fixture.category_mask
            current_fixture.collision_mask_       = fixture.collision_mask
            current_fixture.contact_test_mask_    = fixture.contact_test_mask
            current_fixture.center_               = cc.p(0,0)

            if fixture.fixture_type == "POLYGON" then

                current_fixture.polygons_ = {}

                for polygon_index, polygon in pairs(fixture.polygons) do
                    current_fixture.polygons_[polygon_index] = {}

                    local current_polygon = current_fixture.polygons_[polygon_index]

                    current_polygon.vertices_ = {}
                    current_polygon.num_vertices_ = #polygon

                    for i = 1, #polygon do
                        current_polygon.vertices_[i] = self:point_from_string(polygon[i])
                    end

                end
            else -- not supported

            end

            body_index = body_index + 1

        end

    end

end

function armature:body(name, canvas_size)
    local body = cc.PhysicsBody:create()
    body:setDynamic                 (self.bodies_[name].is_dynamic_)
    body:setRotationEnable          (self.bodies_[name].allows_rotation_)
    body:setLinearDamping           (self.bodies_[name].linear_damping_)
    body:setAngularDamping          (self.bodies_[name].angular_damping_)
    body:setVelocityLimit           (self.bodies_[name].velocity_limit_)
    body:setAngularVelocityLimit    (self.bodies_[name].angular_velocity_limit_)

    local canvas = {width = 0, height = 0}

    if canvas_size ~= nil then
        canvas = canvas_size
    end

    if self.bodies_[name].size_ ~= nil then -- using gt exporter
        canvas = self.bodies_[name].size_
    end

    local anchor = self.bodies_[name].anchor_point_

    for i=1, #self.bodies_[name].fixtures_ do

        -- only polygon shapes
        local fixture = self.bodies_[name].fixtures_[i]

        local material = cc.PhysicsMaterial(fixture.density_, fixture.restitution_, fixture.friction_)

        for j = 1, #fixture.polygons_ do
            local polygon = fixture.polygons_[j]

            local vertices = {}

            for i = 1, #polygon.vertices_ do
                local vertex = polygon.vertices_[i]
                vertices[i] = {
                    x = vertex.x + canvas.width  * (0.5 - anchor.x),
                    y = vertex.y + canvas.height * (0.5 - anchor.y)
                }
            end


            local shape = cc.PhysicsShapePolygon:create(vertices,
                                                        material,
                                                        fixture.center_)

            shape:setGroup              (fixture.group_)
            shape:setCategoryBitmask    (fixture.category_mask_)
            shape:setCollisionBitmask   (fixture.collision_mask_)
            shape:setContactTestBitmask (fixture.contact_test_mask_)
            shape:setTag                (fixture.tag_)

            body:addShape(shape)
        end

    end

    return body
end

function armature:def(name)
    return self.bodies_[name]
end



return armature

