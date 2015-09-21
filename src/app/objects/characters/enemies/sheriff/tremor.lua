-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local sprite           = import("app.objects.graphical.sprite")
local enemy                 = import("app.objects.characters.enemies.base.enemy")
local tremor                = class("tremor", enemy)

function tremor:onCreate()
    self.default_health_ = 80

    self.kinematic_body_size_   = cc.size(40.0, 40.0) -- default is cc.size(16.0, 16.0)
    self.kinematic_body_offset_ = cc.p(0.0, 0.0)      -- default is cc.p(0, 0)
end

function tremor:animate(cname)

    local head_action   =  { name = "head",  animation = { name = cname .. "_" .. "head",  forever = false, delay = 0.10 } }

    self.sprite_:load_action(head_action, false)
    self.sprite_:set_animation(cname .. "_" .. "head")
    self.sprite_:run_action("head")
    self.sprite_:reverse_action()


    self.body_sprites_ = {}

    local y_offset = self.sprite_:getPositionY()

    local x_offset = 5

    for i = 1, 5 do
        self.body_sprites_[i] = sprite:create("sprites/enemy/common/sheriff/tremor/tremor")
                                      :addTo(self, -i)

        y_offset = y_offset - self.body_sprites_[i]:getContentSize().height * 0.75

        self.body_sprites_[i]:setPosition(cc.p(x_offset, y_offset))
    end

    return self
end

function tremor:on_after_init() -- should be called after attached to parent

    local tail_action_a =  { name = "tail_a",  animation = { name = "tremor_tail_a",  forever = false, delay = 0.04 } }
    local tail_action_b =  { name = "tail_b",  animation = { name = "tremor_tail_b",  forever = true, delay = 0.04 } }

    self.tail_ = cc.Node:create()
                        :setPosition(self:getPositionX(), self:getPositionY() - 256)
                        :addTo(self:getParent())

    self.tail_.drill_ = sprite:create("sprites/enemy/common/sheriff/tremor/tremor")
                                :setAnchorPoint(cc.p(0.5, 0.5))
                                :setPosition(cc.p(0, 0))
                                :addTo(self.tail_)

    self.tail_.drill_:load_action(tail_action_a, false)
    self.tail_.drill_:load_action(tail_action_b, false)
    self.tail_.drill_:set_animation("tremor_tail_a")

    local x_offset = 0
    local y_offset = 0

    for i = 1, 5 do
        local tail_body = sprite:create("sprites/enemy/common/sheriff/tremor/tremor")
                                :addTo(self.tail_, -i)

        y_offset = y_offset - tail_body:getContentSize().height * 0.75

        tail_body:setPosition(cc.p(x_offset, y_offset))
    end
end

function tremor:on_respawn()
    self.shooting_ = false
    self.moving_ = false
    self.move_count_ = 0
    self.cannon_attack_count_ = 0
    self.attacking_ = false
    self.sprite_:run_action("head")
    self.sprite_:reverse_action()
end

function tremor:on_tail_attack_end() -- prepare to move again

end

function tremor:on_cannon_attack_end() -- prepare tail attack
    self.cannon_attack_count_ = self.cannon_attack_count_ + 1
    self.attacking_ = false

    self.sprite_:reverse_action()

    if self.cannon_attack_count_ % 8 == 0 then
        local player_xy = cc.MoveTo:create(1, cc.p(self.player_:getPositionX(), self.player_:getPositionY()))

        local screen_xy = cc.MoveTo:create(1, cc.p(self:getPositionX(), self:getPositionY() - 256))

        local delay = cc.DelayTime:create(self.tail_.drill_:get_action_duration("tail_a") * 8)

        local sequence = cc.Sequence:create(player_xy,
                                            cc.CallFunc:create(function()
                                                self.tail_.drill_:run_action("tail_a")
                                            end),
                                            delay,
                                            cc.CallFunc:create(function()
                                                self.tail_.drill_:run_action("tail_b")
                                            end),
                                            delay,
                                            screen_xy,
                                            nil)

        self.tail_:stopAllActions()
        self.tail_:runAction(sequence)
    end
end

function tremor:on_move_end() -- prepare cannon attack
    self.move_count_ = self.move_count_ + 1
    self.moving_ = false
end

function tremor:walk()

    if not self.moving_ and self.move_count_ < 0 then
       self.moving_ = true

       local move_left  = cc.MoveTo:create(1, cc.p(cc.bounds_:left() + cc.bounds_:width() * 0.25, self:getPositionY()))
       local move_right = cc.MoveTo:create(1, cc.p(cc.bounds_:right() - cc.bounds_:width() * 0.25, self:getPositionY()))
       local move_delay = cc.DelayTime:create(1)

       local sequence   = cc.Sequence:create(move_left, move_delay, move_right, move_delay, cc.CallFunc:create(self.on_move_end), nil)
       --local action     = cc.RepeatForever:create(sequence)

       self:stopAllActions()
       self:runAction(sequence)

    end

end

function tremor:jump()
    self.current_speed_.y = 0 -- to make him float
end

function tremor:attack()

    if self.move_count_ >= 0 and self.cannon_attack_count_ < 99 and not self.attacking_ then

        self.attacking_ = true

        local locate_player_y  = cc.MoveTo:create(1, cc.p(self:getPositionX(), self.player_:getPositionY()))

        local animate_attack = cc.CallFunc:create(function()
            self.sprite_:run_action("head")
        end)

        local fire_callback = cc.CallFunc:create(function()

            local offset = cc.p(20, -10)

            local laser = self:fire({
                            sfx = nil,
                            offset = offset,
                            weapon = import("app.objects.weapons.tremor_laser")
                          })

            laser:setPositionX(laser:getPositionX() + (laser.kinematic_body_size_.width * 0.5 * self:get_sprite_normal().x))

        end)

        local attack_delay = cc.DelayTime:create(1)

        local attack_end_callback = cc.CallFunc:create(self.on_cannon_attack_end)

        local sequence = cc.Sequence:create(locate_player_y,
                                            animate_attack,
                                            fire_callback,
                                            attack_delay,
                                            attack_end_callback,
                                            nil)

        self:runAction(sequence)

    end
end

--function tremor:step(dt)
--    self:kinematic_step(dt)
--    self.current_speed_.y = 0
--end

return tremor