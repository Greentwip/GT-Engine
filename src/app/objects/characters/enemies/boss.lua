--
-- Created by Victor on 9/5/2015 11:34 PM
--


local boss = import("app.core.physics.kinematic_character").create("boss")

local energy_bar        = import("app.objects.gameplay.level.ui.energy_bar")


local teleport_browner  = import("app.objects.characters.enemies.browners.teleport_browner")

function boss:onCreate(args)
    self.player_ = args.player_
    self.power_ = 5
    self.health_bar_ = nil -- this will be set up on teleporter collision
    self:init_variables()
    self.battle_status_ = cc.battle_status_.startup_
end

function boss:onAfterAnimate(args)
    self.start_position_ = args.anchored_position_
    self:setPosition(self.start_position_)
    self:init_browners(args)
end


function boss:center()
    local center = self.kinematic_body_:center()
    return center
end

function boss:top()
    local shape  = self.kinematic_body_.body_:getFirstShape()
    local top    = self:center().y + shape.size_.height * 0.5
    return top
end

function boss:bottom()
    local shape     = self.kinematic_body_.body_:getFirstShape()
    local bottom    = self:center().y - shape.size_.height * 0.5
    return bottom
end

function boss:init_variables()
    self.spawning_          = false
    self.vulnerable_        = true
    self.max_fall_speed_    = 400
    self.health_            = 0            -- player
    self.alive_             = false         -- level starts up player
end

function boss:init_browners(args)

    self.browners_ = {}

    local browner      = import("app.objects.characters.enemies.browners." .. args.type_ .. "_" .. "browner")


    local boss_browner = browner:create(self.sprite_)
                                :addTo(self)

    self.browners_[cc.browners_.boss_.id_] = boss_browner

    self.demo_browner_id_ = boss_browner.browner_id_

    for _, v in pairs(self.browners_) do
        v:setPosition(cc.p(0, 0))
        v:run_action("stand")
        v.weapon_tag_ = cc.tags.weapon.enemy
    end

    -- teleport browner has no stand action
    self.browners_[cc.browners_.teleport_.id_] = teleport_browner:create(self.sprite_)
                                                                 :setPosition(cc.p(0, 0))
                                                                 :addTo(self)

    self.current_browner_ = self.browners_[cc.browners_.teleport_.id_]
    self.current_browner_:run_action("jump")
end

function boss:reset()
    for k, v in pairs(self.browners_) do
        local browner = self.browners_[k]
        browner:stop_actions()
        browner:spawn()
        browner:run_action("stand")
        browner.weapon_tag_ = cc.tags.weapon.enemy
    end
end

function boss:spawn()

    self.spawning_ = true
    self:setPosition(self.start_position_)
    self.health_            = 0
    self.current_browner_ = self.browners_[cc.browners_.teleport_.id_]

    self:reset()

    self.vulnerable_ = true

    self.sprite_:setFlippedX(true)
    self.sprite_:setVisible(true)

    self.alive_ = true
end

function boss:switch_browner(id)

    self.current_browner_:stop_actions()

    local new_browner = self.browners_[id]

    new_browner.on_ground_ = self.current_browner_.on_ground_

    self.current_browner_ = new_browner
end

function boss:walk()

    if self.current_browner_.can_walk_ then
        self.current_browner_:walk()
    end

end

function boss:jump()

    if self.current_browner_.can_jump_ then
        self.current_browner_:jump()
    end

end

function boss:dash_jump()

    if self.current_browner_.can_dash_jump_ then
        self.current_browner_:dash_jump()
    end

end

function boss:slide()

    if self.current_browner_.can_slide_ then
        self.current_browner_:slide()
    end

end

function boss:climb()
    if self.current_browner_.can_climb_ then
        self.current_browner_:climb()
    end
end

function boss:attack()
    if self.current_browner_.can_attack_ then
        self.current_browner_:attack()
    end
end

function boss:charge()
    if self.current_browner_.can_charge_ then
        self.current_browner_:charge()
    end
end


function boss:restore_health(amount, callback)
    cc.callbacks_.energy_fill(self, self, amount, {health_ = true, energy_ = false}, callback)
end

function boss:restore_energy(amount)
    cc.callbacks_.energy_fill(self, self.current_browner_, amount, {health_ = false, energy_ = true})
end

function boss:pause_actions()
    self.current_browner_:pause_actions()
end

function boss:resume_actions()
    self.current_browner_:resume_actions()
end

function boss:on_after_blink()
    if not self:isVisible() then
        if self.alive_ then
            self:setVisible(true)
        else
            self:setVisible(false)
        end
    end
end

function boss:stun(damage)
    if not self.current_browner_.stunned_ and self.vulnerable_ then
        audio.playSound("sounds/sfx_hit.wav", false)

        self.health_ = self.health_ - damage

        self.current_browner_.stunned_ = true
        self.vulnerable_ = false

        self.current_browner_.charge_power_ = "low"
        self.current_browner_.charging_ = false

        local delay = cc.DelayTime:create(self.current_browner_:get_action_duration("hurt"))

        if not self.current_browner_.sliding_ then
            self.current_browner_.speed_.x = -4 * self.current_browner_:get_sprite_normal().x
        end

        local callback = cc.CallFunc:create(function()
            self.current_browner_.stunned_ = false
        end)

        local blink = cc.Blink:create(self.current_browner_:get_action_duration("hurt"), 8)

        local blink_callback = cc.CallFunc:create(function()
            if not self:isVisible() then
                self:setVisible(true)
            end

            if not self.sprite_:isVisible() then
                self.sprite_:setVisible(true)
            end

            self.vulnerable_ = true
        end)

        local sequence = cc.Sequence:create(delay, callback, blink, blink, blink_callback, nil)

        sequence:setTag(cc.tags.actions.visibility)
        self.sprite_:stopAllActionsByTag(cc.tags.actions.visibility)
        self.sprite_:runAction(sequence)
    end
end


function boss:solve_collisions()

    local collisions = self.kinematic_body_:get_collisions()

    for _, collision in pairs(collisions) do

        local collision_tag = collision:getPhysicsBody():getFirstShape():getTag()

        if collision_tag == cc.tags.teleporter then

            if self.spawning_ then
                self.spawning_ = false
                self:switch_browner(cc.browners_.boss_.id_)
                self.current_browner_:run_action("intro")
                self.current_browner_.is_intro_ = true

                audio.playSound("sounds/sfx_teleport1.wav", false)
                self.battle_status_ = cc.battle_status_.intro_
            end

        elseif collision_tag == cc.tags.weapon.player then
            self:stun(collision.power_)
        end
    end

end

function boss:move()

    self.current_browner_.speed_ = self.kinematic_body_.body_:getVelocity()

    if self.contacts_[cc.kinematic_contact_.down] then
        self.current_browner_.speed_.y = 0

        if not self.current_browner_.on_ground_ and not self.current_browner_.climbing_ then
            self.current_browner_.on_ground_    = true
            self.current_browner_.dash_jumping_ = false
            self.current_browner_.jumping_      = false
            audio.playSound("sounds/sfx_land.wav", false)
        end
    else
        self.current_browner_.on_ground_ = false
        self.current_browner_.jumping_  = true
    end

    if self.contacts_[cc.kinematic_contact_.up] then
        if self.current_browner_.speed_.y > 0 then
            self.current_browner_.speed_.y = -1
        end
    end

    if self.battle_status_ == cc.battle_status_.fighting_ then

        self:walk()
        self:jump()
        self:dash_jump()

    end

    if self.contacts_[cc.kinematic_contact_.right] then
        if self.current_browner_.speed_.x > 0 then
            self.current_browner_.speed_.x = 0
        end
    elseif self.contacts_[cc.kinematic_contact_.left] then
        if self.current_browner_.speed_.x < 0 then
            self.current_browner_.speed_.x = 0
        end
    end
end

function boss:explode(x_offset)

    local y_offset = 16

    local creation_args = {}
    creation_args.real_position_    = cc.p(self:getPositionX(), self:getPositionY())
    creation_args.type_    = "directional"
    creation_args.sprite_color_ =   cc.c3b(255,255,255)

    local explosion = import("app.objects.gameplay.level.fx.explosion")

    for i = 1, 9 do

        if i ~= 5 then
            creation_args.direction_ =  cc.p(creation_args.real_position_.x + x_offset, creation_args.real_position_.y + y_offset)

            local death_explosion = explosion:create(creation_args)
                                             :setup("gameplay", "level", "fx", "explosion")
                                             :addTo(self:getParent(), 1024)

            death_explosion:build(creation_args)

            self:getParent().animations_[death_explosion] = death_explosion

        end

        if i % 3 == 0 then
            x_offset = -16
            y_offset = y_offset - 16
        else
            x_offset = x_offset + 16
        end

    end
end

function boss:finish(full_callback)

    if full_callback then

    end

    self.exit_arguments_ = {}
    self.exit_arguments_.demo_browner_id_ = self.demo_browner_id_

    self.player_.can_move_ = false

    local delay = cc.DelayTime:create(2)

    local audio_callback = cc.CallFunc:create(function()
        audio.playMusic("sounds/bgm_boss_victory.mp3", false)
    end)

    local exit_callback = cc.CallFunc:create(function()
        self.player_:exit(self.exit_arguments_)
    end)


    local sequence = cc.Sequence:create(delay,
                                        audio_callback,
                                        delay,
                                        delay, exit_callback, nil)

    self:runAction(sequence)
end

function boss:check_health()

    local kill_animation = true

    if self.health_ <= 0 and self.alive_ then
        --cc.pause(true)
        self.battle_status_ = cc.battle_status_.defeated_
        self.current_browner_.speed_.x = 0
        self.current_browner_.speed_.y = 0

        self.current_browner_:deactivate()
        self.health_ = 0
        self.alive_ = false
        --cc.player_.lives_ = cc.player_.lives_ - 1
        audio.stopMusic()
        audio.playSound("sounds/sfx_death.wav", false)

        self:finish(true)


        if kill_animation then

            local explosion_a = cc.CallFunc:create(function()
                self:explode(-16)
            end)

            local delay = cc.DelayTime:create(0.20)

            local explosion_b = cc.CallFunc:create(function()
                self:explode(-12)
            end)

            local sequence = cc.Sequence:create(explosion_a, delay, explosion_b, nil)

            self:runAction(sequence)

        else
            self.sprite_:setVisible(false)
        end
    end

end

function boss:trigger_actions()

    if not self.current_browner_.stunned_ then
        if self.current_browner_.on_ground_ then
            if self.current_browner_.walking_ then
                if self.current_browner_.attacking_ then
                    self.current_browner_:run_action("walkshoot")
                else
                    self.current_browner_:run_action("walk")
                end
            else
                if self.current_browner_.attacking_ then
                    self.current_browner_:run_action("standshoot")
                elseif self.current_browner_.sliding_ then
                    self.current_browner_:run_action("slide")
                elseif self.current_browner_.is_intro_ then
                    self.current_browner_:run_action("intro")
                else
                    self.current_browner_:run_action("stand")
                end
            end
        else
            if self.current_browner_.climbing_ then
                if self.current_browner_.attacking_ then
                    self.current_browner_:run_action("climbshoot")
                else
                    self.current_browner_:run_action("climb")
                end
            else
                if self.current_browner_.attacking_ then
                    self.current_browner_:run_action("jumpshoot")
                else
                    if self.current_browner_.dash_jumping_ then
                        self.current_browner_:run_action("dashjump")
                    elseif self.current_browner_.jumping_ then
                        self.current_browner_:run_action("jump")
                    end
                end
            end
        end
    else
        self.current_browner_:run_action("hurt")
    end

end


function boss:step(dt)
    self:kinematic_step(dt)

    local bbox = self.kinematic_body_:bbox()

    if cc.bounds_:is_rect_inside(bbox) then
        if self.battle_status_ == cc.battle_status_.startup_ then
            audio.playMusic("sounds/bgm_boss_vineman.mp3", true)

            self.player_.can_move_ = false
            self:spawn()
            self.battle_status_ = cc.battle_status_.waiting_

        elseif self.battle_status_ == cc.battle_status_.intro_ then

            self.health_bar_ = energy_bar:create()
                                         :setPosition(cc.p(cc.bounds_:width() * 0.5 - 16, cc.bounds_:height() * 0.5 -16))
                                         :addTo(cc.bounds_)     -- node positions are relative to parent's

            local callback = cc.CallFunc:create(function()
                self.current_browner_.is_intro_ = true
            end)


            local delay = cc.DelayTime:create(self.current_browner_:get_action_duration("intro"))

            local fill_bar = cc.CallFunc:create(function()
                self:restore_health(28, function()
                    self.current_browner_.is_intro_ = false
                    self.player_.can_move_ = true
                    self.battle_status_ = cc.battle_status_.fighting_
                end)

            end)

            local sequence = cc.Sequence:create(callback, delay, fill_bar, nil)

            self:runAction(sequence)

            self.battle_status_ = cc.battle_status_.waiting_

        elseif self.battle_status_ == cc.battle_status_.defeated_ then
            self.health_bar_:removeSelf()
            self.health_bar_ = nil
            self.battle_status_ = cc.battle_status_.waiting_
        end

        if cc.game_status_ == cc.GAME_STATUS.RUNNING then
            if self.spawning_ and self.alive_ then
                self:solve_collisions()
            elseif self.alive_ then

                if cc.game_status_ == cc.GAME_STATUS.RUNNING then
                    self:solve_collisions()
                    if self.battle_status_ == cc.battle_status_.fighting_ then
                        self:attack()
                        self:check_health()
                    end
                end
            end
        end
    else
        if self.battle_status_ ~= cc.battle_status_.startup_ then
            self.battle_status_ = cc.battle_status_.startup_
        end

        self.current_browner_.speed_.x = 0
        self.current_browner_.speed_.y = 0
    end

    if self.battle_status_ ~= cc.battle_status_.defeated_ then
        if self.health_bar_ ~= nil then
            self.health_bar_:set_meter(self.health_)
        end
    end

    return self
end

function boss:post_step(dt)
    self.current_speed_ = self.current_browner_.speed_
    self:kinematic_post_step(dt)

    if cc.game_status_ == cc.GAME_STATUS.RUNNING then
        self:trigger_actions()
    end

end

return boss

