-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local selector      = class("selector", cc.Node)
local sprite        = import("app.core.graphical.sprite")

function selector:ctor(kind, orientation)
    self.sprite_ = sprite:create("sprites/gameplay/level/ui/selector/selector")
                         :setPosition(cc.p(0,0))
                         :addTo(self)

    if kind == "arrow" then
        if orientation == "down" or orientation == "right" then
            self.sprite_:set_animation(kind .. "_" .. orientation)
        else
            self.sprite_ = nil
        end
    elseif kind == "square" then
        if orientation == "small" or orientation == "large" then
            self.sprite_:set_animation(kind .. "_" .. orientation)
        else
            self.sprite_ = nil
        end
    end

    self.kind_ = kind
    self.orientation_ = orientation


    self.selected_item_ = nil

    self.direction          = {}
    self.direction.up       = 0
    self.direction.down     = 1
    self.direction.left     = 2
    self.direction.right    = 3
end


function selector:get_selected_item()
    return self.selected_item_
end

function selector:set_selected_item(item)

    self:setPosition(cc.p(item:getPositionX(), item:getPositionY()))

    if self.kind_ == "arrow" then
        if self.orientation_ == "down" then
            self.sprite_:setPosition(cc.p(item.sprite_:getContentSize().width * 0.5, 3))
        else
            self.sprite_ = nil
        end
    end

    if self.selected_item_ ~= nil then
        if self.selected_item_.leave then
            self.selected_item_:leave()
        end
    end

    self.selected_item_ = item

    if self.selected_item_.visit then
        self.selected_item_:visit()
    end

end

function selector:distance(a, b)
    return math.pow(math.pow(b.x - a.x, 2) + math.pow(b.y - a.y, 2), 0.5)
end

function selector:nearest(items, direction)

    -- self distance
    local point_a = cc.p(self:getPositionX(), self:getPositionY())

    -- get distance
    local distances = {}

    for _, item in pairs(items) do
        --local item = items[i]
        local point_b = cc.p(item:getPositionX(), item:getPositionY())

        local distance

        if item:isVisible() then
            if direction == self.direction.up then
                if point_b.y > point_a.y then
                    distance = self:distance(point_a, point_b)
                end
            elseif direction == self.direction.down then
                if point_b.y < point_a.y then
                    distance = self:distance(point_a, point_b)
                end
            elseif direction == self.direction.left then
                if point_b.x < point_a.x then
                    distance = self:distance(point_a, point_b)
                end
            elseif direction == self.direction.right then
                if point_b.x > point_a.x then
                    distance = self:distance(point_a, point_b)
                end
            end

            if distance ~= nil then
                distances[#distances + 1] = {distance = distance, item = item}
            end
        end
    end


    --print (table.getn(distances))

    -- select
    if #distances > 0 then
        -- sort
        table.sort(distances, function(a,b) return a.distance < b.distance end)
        local item = table.remove(distances,1).item
        return  item
    else
        return nil
    end

end

function selector:select_from(items)
    local nearest

    if cc.key_pressed(cc.key_code_.up) then
        nearest = self:nearest(items, self.direction.up)

    elseif cc.key_pressed(cc.key_code_.down) then
        nearest = self:nearest(items, self.direction.down)

    elseif cc.key_pressed(cc.key_code_.right) then
        nearest = self:nearest(items, self.direction.right)

    elseif cc.key_pressed(cc.key_code_.left) then
        nearest = self:nearest(items, self.direction.left)

    elseif cc.key_pressed(cc.key_code_.a) then
        if self:get_selected_item() ~= nil then
            if self:get_selected_item().trigger then
                self:get_selected_item():trigger()
            end
        end
    end

    if nearest ~= nil then
        audio.playSound("sounds/sfx_select.wav", false)
        self:set_selected_item(nearest)
    end
end

return selector