--
-- Created by Victor on 6/28/2015 12:21 PM
--

local cody = import("app.core.physics.kinematic_character").create("cody")

local violet_browner    = import("app.objects.characters.player.browners.violet_browner")
local fuzzy_browner     = import("app.objects.characters.player.browners.fuzzy_browner")
local helmet_browner    = import("app.objects.characters.player.browners.helmet_browner")
local vine_browner      = import("app.objects.characters.player.browners.vine_browner")
local military_browner  = import("app.objects.characters.player.browners.military_browner")
local night_browner     = import("app.objects.characters.player.browners.night_browner")
local sheriff_browner   = import("app.objects.characters.player.browners.sheriff_browner")
local extreme_browner   = import("app.objects.characters.player.browners.extreme_browner")
local teleport_browner  = import("app.objects.characters.player.browners.teleport_browner")

function cody:onCreate()
    self.health_bar_ = nil -- level controllers sets this up for us
    self.energy_bar_ = nil -- level controllers sets this up for us
    self:init_variables()
end

function cody:animate(cname)    -- called after physics have been created
    self:init_browners()
end

function cody:center()
    local center = self.kinematic_body_:center()
    return center
end

function cody:top()
    local shape  = self.kinematic_body_.body_:getShapes()[1]
    local top    = self:center().y + shape.size_.height * 0.5
    return top
end

function cody:bottom()
    local shape     = self.kinematic_body_.body_:getShapes()[1]
    local bottom    = self:center().y - shape.size_.height * 0.5
    return bottom
end

function cody:init_variables()
    self.on_end_battle_     = false
    self.on_exit_           = false
    self.demo_mode_         = false
    self.can_move_          = true
    self.spawning_          = false
    self.vulnerable_        = true
    self.accomplishing_     = false
    self.max_fall_speed_    = 400
    self.bubble_timer_      = 0
    self.health_            = 28            -- player
    self.alive_             = false         -- level starts up player
    self.hole_door_         = false         -- environment
    self.in_water_          = false
    self.in_door_           = nil
    self.active_ladder_     = nil

    self.previous_free_scroll_ = nil
    self.free_scroll_ = nil
end

function cody:init_browners()

    self.browners_ = {}

    self.browners_[cc.browners_.violet_.id_] = violet_browner:create(self.sprite_)
                                                             :addTo(self)

    self.browners_[cc.browners_.fuzzy_.id_] = fuzzy_browner:create(self.sprite_)
                                                           :addTo(self)

    self.browners_[cc.browners_.sheriff_.id_] = sheriff_browner:create(self.sprite_)
                                                               :addTo(self)

    self.browners_[cc.browners_.military_.id_] = military_browner:create(self.sprite_)
                                                                 :addTo(self)

    self.browners_[cc.browners_.vine_.id_] = vine_browner:create(self.sprite_)
                                                         :addTo(self)

    self.browners_[cc.browners_.night_.id_] = night_browner:create(self.sprite_)
                                                           :addTo(self)

    self.browners_[cc.browners_.helmet_.id_] = helmet_browner:create(self.sprite_)
                                                             :addTo(self)

    self.browners_[cc.browners_.extreme_.id_] = extreme_browner:create(self.sprite_)
                                                               :addTo(self)

    for _, v in pairs(self.browners_) do
        v:deactivate()
        v:setPosition(cc.p(0, 0))
        v:run_action("stand")
        v.weapon_tag_ = cc.tags.weapon.player
    end

    -- teleport browner has no stand action
    self.browners_[cc.browners_.teleport_.id_] = teleport_browner:create(self.sprite_)
                                                                 :setPosition(cc.p(0, 0))
                                                                 :addTo(self)

    self:switch_browner(cc.browners_.teleport_.id_)

    self.current_browner_:activate()
    self.current_browner_:run_action("jump")

    -- we need the player's collision contact information for a certain set of browners
    -- violet, helmet and fuzzy need them for sliding
    self.browners_[cc.browners_.violet_.id_].contacts_ = self.contacts_
    self.browners_[cc.browners_.helmet_.id_].contacts_ = self.contacts_
    self.browners_[cc.browners_.fuzzy_.id_].contacts_ = self.contacts_
end

function cody:spawn()
    self:switch_browner(cc.browners_.teleport_.id_)

    for _, v in pairs(self.browners_) do
        v:deactivate()
        v.charging_ = false
        v.charge_power_ = "low"
        v.stunned_ = false
        v:setPosition(cc.p(0, 0))
        v:run_action("stand")
        v.weapon_tag_ = cc.tags.weapon.player
    end

    self.vulnerable_ = true


    self.sprite_:setFlippedX(false)
    self.sprite_:setVisible(true)
    self.current_browner_:activate()

    self.alive_ = true

end

function cody:switch_browner(id)

    local ground_backup = false

    if self.current_browner_ ~= nil then
        self.current_browner_:deactivate()
        ground_backup = self.current_browner_.on_ground_
    end

    local new_browner = self.browners_[id]

    new_browner.on_ground_ = ground_backup

    self.current_browner_ = new_browner
    self.current_browner_:activate()

    if new_browner.browner_id_ == cc.browners_.violet_.id_ or new_browner.browner_id_ == cc.browners_.teleport_.id_ then
       if self.energy_bar_ ~= nil then
           self.energy_bar_:setVisible(false)
       end
    else
        if self.energy_bar_ ~= nil then
            self.energy_bar_:setVisible(true)
        end
    end

    self:trigger_actions()
end

function cody:walk()

    if self.current_browner_.can_walk_ then
        self.current_browner_:walk()
    end

end

function cody:jump()

    if self.current_browner_.can_jump_ then
        self.current_browner_:jump()
    end

end

function cody:dash_jump()

    if self.current_browner_.can_dash_jump_ then
        self.current_browner_:dash_jump()
    end

end

function cody:slide()

    if self.current_browner_.can_slide_ then
        self.current_browner_:slide()
    end

end

function cody:climb()
    if self.current_browner_.can_climb_ then
        self.current_browner_:climb()
    end
end

function cody:attack()
    if self.current_browner_.can_attack_ then
        self.current_browner_:attack()
    end
end

function cody:charge()
    if self.current_browner_.can_charge_ then
        self.current_browner_:charge()
    end
end

function cody:restore_sanity(item)

    if item.id_ == cc.item_.health_small_.id_ then
        self:restore_health(3)
    elseif item.id_ == cc.item_.health_big_.id_ then
        self:restore_health(10)
    elseif item.id_ == cc.item_.energy_small_.id_ then
        self:restore_energy(3)
    elseif item.id_ == cc.item_.energy_big_.id_ then
        self:restore_energy(10)
    end

end

function cody:restore_health(amount)
    cc.callbacks_.energy_fill(self, self, amount, {health_ = true, energy_ = false})
end

function cody:restore_energy(amount)
    cc.callbacks_.energy_fill(self, self.current_browner_, amount, {health_ = false, energy_ = true})
end

function cody:pause_actions()
    self.current_browner_:pause_actions()
end

function cody:resume_actions()
    self.current_browner_:resume_actions()
end

function cody:on_after_blink()
    if not self:isVisible() then
        if self.alive_ then
            self:setVisible(true)
        else
            self:setVisible(false)
        end
    end
end

function cody:stun(damage)
    if not self.current_browner_.stunned_ and self.vulnerable_ then
        audio.playSound("sounds/sfx_hit.wav", false)

        self.health_ = self.health_ - damage

        self.current_browner_.stunned_ = true
        self.vulnerable_ = false

        self.current_browner_.charge_power_ = "low"
        self.current_browner_.charging_ = false

        local delay = cc.DelayTime:create(self.sprite_:get_action_duration("hurt"))

        if not self.current_browner_.sliding_ then
            self.current_browner_.speed_.x = -4 * self.current_browner_:get_sprite_normal().x
        end

        local callback = cc.CallFunc:create(function()
            self.current_browner_.stunned_ = false
        end)

        local blink = cc.Blink:create(self.sprite_:get_action_duration("hurt"), 8)

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


function cody:solve_collisions()

    self.hole_door_ = false
    self.active_ladder_ = nil
    self.in_door_ = nil

    local collisions = self.kinematic_body_:get_collisions()

    for _, collision in pairs(collisions) do

        local collision_tag = collision:getPhysicsBody():getShapes()[1]:getTag()

        if collision_tag == cc.tags.hole then

            self.hole_door_= true

        elseif collision_tag == cc.tags.teleporter then

            if self.spawning_ then
                self.spawning_ = false
                self:switch_browner(cc.browners_.violet_.id_)
                audio.playSound("sounds/sfx_teleport1.wav", false)
            end

        elseif collision_tag == cc.tags.item then
            collision.callback_(self, collision)
            collision.disposed_ = true
        elseif collision_tag == cc.tags.ladder then
            self.active_ladder_ = collision
        elseif collision_tag == cc.tags.enemy then
            if collision.status_ == cc.enemy_.status_.fighting_ then
               self:stun(collision.power_)
            elseif collision.battle_status_ ~= nil then
                if collision.battle_status_ >= cc.battle_status_.intro_ and collision.battle_status_ < cc.battle_status_.defeated_ then
                    self:stun(collision.power_)
                end
            end
        elseif collision_tag == cc.tags.weapon.enemy then
            self:stun(collision.power_)
        elseif collision_tag == cc.tags.free_scroll then
            self.free_scroll_ = collision
        elseif collision_tag == cc.tags.door then
            self.in_door_ = collision
        end
    end

end

function cody:walk_right_condition()
    return cc.key_down(cc.key_code_.right) and not cc.key_down(cc.key_code_.left)
end

function cody:walk_left_condition()
    return cc.key_down(cc.key_code_.left) and not cc.key_down(cc.key_code_.right)
end

function cody:start_jump_condition()
    return cc.key_pressed(cc.key_code_.a)
            and not cc.key_down(cc.key_code_.up)
            and not cc.key_down(cc.key_code_.down)
end

function cody:stop_jump_condition()
    return not cc.key_down(cc.key_code_.a)
end

function cody:start_dash_jump_condition()
    return cc.key_pressed(cc.key_code_.a) and cc.key_down(cc.key_code_.up) and not cc.key_down(cc.key_code_.down)
end

function cody:stop_dash_jump_condition()
    return not cc.key_down(cc.key_code_.a)
end

function cody:slide_condition()
    return cc.key_pressed(cc.key_code_.a)
            and cc.key_down(cc.key_code_.down)
end

function cody:attack_condition()
    local condition = cc.key_pressed(cc.key_code_.b)
    return condition
end

function cody:charge_condition()
    local condition = cc.key_down(cc.key_code_.b)
    return condition
end

function cody:discharge_condition()
    return not cc.key_down(cc.key_code_.b)
end

function cody:move()

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

    self:walk()
    self:jump()
    self:dash_jump()

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

function cody:explode(x_offset)

    local y_offset = 16

    local creation_args = {}
    creation_args.real_position_    = cc.p(self:getPositionX(), self:getPositionY())
    creation_args.type_    = "directional"
    creation_args.sprite_color_ =   cc.c3b(153,153,255)

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

function cody:check_health()

    local kill_animation = true

    if  self:bottom() < cc.bounds_:bottom()
            and not self.hole_door_ then
        self.health_ = 0
        kill_animation = false
    end

    if self.health_ <= 0 and self.alive_ then
        cc.pause(true)
        self.current_browner_:deactivate()
        self.health_ = 0
        self.alive_ = false
        audio.stopMusic()
        audio.playSound("sounds/sfx_death.wav", false)

        if kill_animation then

            local explosion_a = cc.CallFunc:create(function()
                self:explode(-16)
            end)

            local delay = cc.DelayTime:create(0.20)

            local explosion_b = cc.CallFunc:create(function()
                self:explode(-12)
            end)

            local kill_delay = cc.DelayTime:create(2)

            local life_callback = cc.CallFunc:create(function()
                cc.player_.lives_ = cc.player_.lives_ - 1
            end)

            local sequence = cc.Sequence:create(explosion_a, delay, explosion_b, kill_delay, life_callback, nil)

            self:runAction(sequence)

        else
            self.sprite_:setVisible(false)
        end
    end

end

function cody:trigger_actions()

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
                elseif self.current_browner_.morphing_ then
                    self.current_browner_:run_action("morph")
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

function cody:exit(args)
    self.exit_arguments_ = args

    self.can_move_ = false
    self.on_exit_ = true
    self.movement_is_non_blockable_ = true

    self:switch_browner(cc.browners_.teleport_.id_)

    audio.playSound("sounds/sfx_teleport2.wav", false)

    local delay = cc.DelayTime:create(4)
    local callback = cc.CallFunc:create(function()

        local level = "levels.level_weapon"
        local physics = true

        local init = true

        if self.exit_arguments_.is_level_complete_ then
                level = "screens.level_complete"
                physics = false
                init = false
        end

        self:getParent().level_controller_.camera_.static_mode_ = true              -- forcing camera reset due to weird bug regarding tmx maps
        self:getParent().level_controller_.camera_.static_position_ = cc.p(128, 112)

        self:getParent():setVisible(false)
        local scene = self:getParent()
                          :getApp()
                          :enterScene(level, "FADE", 1, {physics = physics})

        if init then
            scene:prepare(self.exit_arguments_)
        end
    end)

    local sequence = cc.Sequence:create(delay, callback, nil)

    self:runAction(sequence)

end


function cody:step(dt)

    if self.can_move_ then -- used for boss battles and demo
        self:kinematic_step(dt)

        if self.spawning_ and self.alive_ then
            self:solve_collisions()
        elseif self.alive_ then
            if cc.game_status_ == cc.GAME_STATUS.RUNNING then
                self:solve_collisions()
                self:attack()
                self:charge()
                self:slide()
                self:climb()
                self:check_health()
            end
        end
    else
        if not self.demo_mode_ then
            if not self.on_exit_ then
                self:solve_collisions()
                self.current_browner_.speed_.x = 0
                self.current_browner_.speed_.y = 0
            else
                self.current_browner_.speed_.x = 0
                self.current_browner_.speed_.y = 320
            end
        else
            if self.on_exit_ then
                self.current_browner_.speed_.x = 0
                self.current_browner_.speed_.y = 320
            end
        end
    end

    return self
end

function cody:post_step(dt)
    self.current_speed_ = self.current_browner_.speed_

    self:kinematic_post_step(dt)

    if cc.game_status_ == cc.GAME_STATUS.RUNNING then
        self:trigger_actions()
    else
        if self.alive_ then
            --self:trigger_actions()
        end
    end

end

return cody