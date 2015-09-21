-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local sprite    = import("app.core.graphical.sprite")

local weapon        = import("app.objects.weapons.base.weapon")
local tremor_laser  = class("tremor_laser", weapon)

function tremor_laser:onAfterCreate()
    self.sprite_ = sprite:create("sprites/gameplay/weapon/tremor_laser", cc.p(1, 0.5))
                         :setPosition(cc.p(0,0))
                         :addTo(self)

    local actions = {}
    actions[#actions + 1] = {name = "charge",  animation = { name = "tremor_laser_charge", forever = true,  delay = 0.05} }
    actions[#actions + 1] = {name = "shot",   animation = { name = "tremor_laser_shot",    forever = false, delay = 0.10} }

    self.sprite_:load_actions_set(actions, false)

    self.sprite_:set_animation("tremor_laser_shot")
    self:swap("shot")

    self.power_ = 8

    self.kinematic_body_size_ = cc.size(self.sprite_:getContentSize().width, self.sprite_:getContentSize().height)

    self.sprite_:setPositionX(0 + self.sprite_:getContentSize().width * 0.5)
    self.sprite_:set_animation("tremor_laser_charge")
    self:swap("charge")

    return self
end

function tremor_laser:on_after_init()
    self.speed_.x = 0
    self.speed_.y = 0

    self:setTag(cc.tags.weapon.none)

    local charge_delay = cc.DelayTime:create(1)

    local weaponize_callback = cc.CallFunc:create(function()
                                                        self.speed_ = cc.p(260 * self.x_normal_, 0)
                                                        self:setTag(self.weapon_tag_)
                                                  end)

    local animation_callback = cc.CallFunc:create(function() self.sprite_:run_action("shot") end)

    local sequence = cc.Sequence:create(charge_delay, weaponize_callback, animation_callback, nil)

    self:runAction(sequence)

    return self
end

function tremor_laser:step(dt)
    self.current_speed_ = self.speed_
    return self
end


return tremor_laser

