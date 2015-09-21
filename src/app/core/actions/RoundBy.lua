-- Copyright 2014-2015 Greentwip. All Rights Reserved. 

local RoundBy = class("RoundBy")

function RoundBy:ctor(duration, turn, center, radius)

    self.duration_ = duration
    self.turn_ = turn
    self.center_ = center
    self.radius_ = radius

end

function RoundBy:isTurn()
   return self.turn_
end


function RoundBy:setTurn(turn)
    self.turn_ = turn
end

function RoundBy:getStartAngle()
    return self.start_angle_
end

function RoundBy:setStartAngle(start_angle)
    self.start_angle_ = start_angle;
end

function RoundBy:getRadius()
    return self.radius_
end

function RoundBy:setRadius(radius)
    self.radius_ = radius
end

function RoundBy:getCenter()
    return self.center_
end

function RoundBy:setCenter(center)
    self.center_ = center
end

function RoundBy:start(target)
--    self.super:start(target)

    self.target_ = target
    self.start_angle_ = target:getRotation()

    if self.turn_ == 1 then
        target:setPosition(cc.pAdd(self.center_, cc.p(-self.radius_, 0)))
    elseif self.turn_ == -1 then
        target:setPosition(cc.pAdd(self.center_, cc.p(self.radius_, 0)))
    end

    return self
end

function RoundBy:update(delta)
    -- XXX: shall I add % 360

    local position = cc.p(self.target_:getPositionX(), self.target_:getPositionY())

    local s = math.sin(0.018 * self.turn_)
    local c = math.cos(0.018 * self.turn_)

    position.x = position.x - self.center_.x
    position.y = position.y - self.center_.y

    -- rotate point

    local new_position = cc.p(position.x * c - position.y * s,
                              position.x * s + position.y * c)


    new_position.x = new_position.x + self.center_.x
    new_position.y = new_position.y + self.center_.y

    position.x = new_position.x
    position.y = new_position.y

    self.target_:setPosition(position)
end

function RoundBy:reverse()
    local turn = not self.turn_
    local round_by = RoundBy:create(self.duration_, turn, self.center_, self.radius_)
    return round_by
end

return RoundBy