-- Copyright 2014-2015 Greentwip. All Rights Reserved.


local definition = class("definition")

function definition:point_from_string(point_string)

    local str_point = {}

    for str in string.gmatch(point_string, "(-*[0-9]+.[0-9]+)") do
        str_point[#str_point + 1] = tonumber(str)
    end

    local point = cc.p(str_point[1], str_point[2])
    return point
end

function definition:size_from_string(size_string)

    local str_point = {}

    for str in string.gmatch(size_string, "(-*[0-9]+.[0-9]+)") do
        str_point[#str_point + 1] = tonumber(str)
    end

    local point = cc.size(str_point[1], str_point[2])
    return point
end

function definition:ctor(data_filename)
    local plist_dict = cc.FileUtils:getInstance():getValueMapFromFile(data_filename .. ".plist")

    self.definitions_ = {}

    for definition_name, definition in pairs(plist_dict["definitions"]) do

        self.definitions_[definition_name] = {
            size_ = self:size_from_string(definition.size),
            anchor_ = self:point_from_string(definition.anchor)
        }
    end

end

function definition:get(name)
    return self.definitions_[name]
end

return definition



