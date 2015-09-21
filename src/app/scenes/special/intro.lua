-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local intro = class("intro", cc.Node)

local sprite = import("app.core.graphical.sprite")

local infinite_parallax = import("app.objects.gameplay.level.ui.infinite_parallax")

function intro:ctor(parallax_arguments)

--    self.flash_ = sprite:create("sprites/gameplay/screens/common/backgrounds/white_background/white_background", cc.p(0.5, 0.5))
--                        :setPosition(cc.p(0, 0))
--                        :addTo(self, -64)

    self.sender_ = parallax_arguments.sender_

    self.bgm_ = parallax_arguments.bgm_


    local package_path = "sprites" .. "/" ..
            parallax_arguments.category_ .. "/" ..
            parallax_arguments.sub_category_ .. "/" ..
            parallax_arguments.package_ .. "/"

    self.on_end_callback_ = parallax_arguments.on_end_callback_

    self.infinite_parallax_ = infinite_parallax:create({real_position_ = display.center})
                                               :setup(parallax_arguments.category_,
                                                      parallax_arguments.sub_category_,
                                                      parallax_arguments.package_ .. "/" .. "parallax",
                                                      parallax_arguments.cname_ .. "_" .. "parallax")
                                               :organize(cc.p(0, 4),
                                                         package_path .. "parallax/" ..
                                                         parallax_arguments.cname_ .. "_" .. "parallax" .. "/" ..
                                                         parallax_arguments.cname_ .. "_" .. "parallax")
                                               :addTo(self)

    self.shadow_ = sprite:create(package_path .. "shadow/" ..
                                      parallax_arguments.cname_ .. "_" .. "shadow" .. "/" ..
                                      parallax_arguments.cname_ .. "_" .. "shadow", cc.p(1, 0))
                              :setPosition(display.left_bottom)
                              :addTo(self, 64)


    self.belt_left_ = sprite:create("sprites/gameplay/screens/common/belt/belt_left/belt_left", cc.p(1, 0.5))
                            :setPosition(display.left_center)
                            :addTo(self, 96)

    self.belt_right_ = sprite:create("sprites/gameplay/screens/common/belt/belt_right/belt_right", cc.p(0, 0.5))
                             :setPosition(display.right_center)
                             :setFlippedY(true)
                             :addTo(self, 72)

    local belt_left_shine   = {name = "shine",  animation = {name = "belt_left_shine",  forever = true, delay = 0.20} }
    local belt_right_shine  = {name = "shine",  animation = {name = "belt_right_shine",  forever = true, delay = 0.20} }


    self.belt_left_:load_action(belt_left_shine, false)
    self.belt_right_:load_action(belt_right_shine, false)

    local shadow_move = cc.MoveTo:create(2, cc.p(display.center.x + self.shadow_:getContentSize().width * 0.5, self.shadow_:getPositionY()))

    local shadow_callback = function()

        local belt_move = function()
            self.ring_count_ = 0

            self.ring_counter_ = function()
                self.ring_count_ = self.ring_count_ + 1
            end

            local boss_callback = function()
                self:ring_counter_()
                self:on_ring_move_complete()
            end

            local belt_left_move   = cc.MoveTo:create(1, cc.p(display.center.x + 13, self.belt_left_:getPositionY()))
            local belt_right_move  = cc.MoveTo:create(1, cc.p(display.center.x - 18, self.belt_right_:getPositionY()))

            local ring_a_sequence = cc.Sequence:create(belt_left_move, cc.CallFunc:create(boss_callback), nil)
            local ring_b_sequence = cc.Sequence:create(belt_right_move, cc.CallFunc:create(boss_callback), nil)

            self.belt_left_:runAction(ring_a_sequence)
            self.belt_right_:runAction(ring_b_sequence)
        end

        local audio_delay = cc.DelayTime:create(0.8)
        local audio_callback = cc.CallFunc:create(function()
            audio.playSound("sounds/screens/common/belt/sfx_belt_join.wav", false)
        end)

        local audio_sequence = cc.Sequence:create(audio_delay, audio_callback, nil)

        local audio_spawn = cc.Spawn:create(cc.CallFunc:create(belt_move), audio_sequence)

        self:runAction(audio_spawn)
    end

    local shadow_sequence = cc.Sequence:create(shadow_move,
                                               cc.DelayTime:create(0.5),
                                               cc.CallFunc:create(shadow_callback), nil)

    self.shadow_:runAction(shadow_sequence)

    if self.bgm_ ~= nil then
        audio.playMusic(self.bgm_, false)
    end
end


function intro:on_ring_move_complete()

    if self.ring_count_ >= 2 then
        self.on_end_callback_(self.sender_)
    end

end

function intro:step(dt)
    self.infinite_parallax_:step(dt)
end

return intro