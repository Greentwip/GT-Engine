-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local pause_menu = class("pause_menu", cc.Node)

local sprite                = import("app.core.graphical.sprite")
local label                 = import("app.core.graphical.label")

local selector              = import("app.objects.gameplay.level.ui.selector")
local pause_interruptor     = import("app.objects.gameplay.level.ui.pause_interruptor")

local energy_bar            = import("app.objects.gameplay.level.ui.energy_bar")
local pause_animation      = import("app.objects.gameplay.level.ui.pause_animation")


function pause_menu:ctor(settings)

    self.player_        = settings.player_

    self:setup_variables()

    self.background_ = sprite:create("sprites/gameplay/screens/pause_menu/pause_background/pause_background", cc.p(0, 1))
                             :setPosition(cc.p(0,0))
                             :addTo(self)

    self.selector_ = selector:create("arrow", "down")
                             :setPosition(cc.p(0,0))
                             :addTo(self, 20)

    self:setup_browners()

    self.e_tank_  = pause_interruptor:create("e_tank")
                               :setPosition(cc.p(12, -198))
                               :addTo(self)

    self.m_tank_  = pause_interruptor:create("m_tank")
                               :setPosition(cc.p(60, self.e_tank_:getPositionY()))
                               :addTo(self)


    local lives = pause_interruptor:create("life")
                             :setPosition(cc.p(112, self.m_tank_:getPositionY()))
                             :visit()
                             :addTo(self)

    self.lives_label_ = label:create("0"..tostring(cc.player_.lives_),
                                     "fonts/megaman_2.ttf",
                                     8,
                                     cc.TEXT_ALIGNMENT_LEFT,
                                     cc.VERTICAL_TEXT_ALIGNMENT_TOP)
                             :setPosition(lives.sprite_:getContentSize().width + 1, -lives.sprite_:getContentSize().height * 0.5 + 1)
                             :addTo(lives)

    self.e_tank_label_ = label:create("0"..tostring(cc.player_.e_tanks_),
                                      "fonts/megaman_2.ttf",
                                      8,
                                      cc.TEXT_ALIGNMENT_LEFT,
                                      cc.VERTICAL_TEXT_ALIGNMENT_TOP)
                              :setPosition(self.e_tank_.sprite_:getContentSize().width + 1, -self.e_tank_.sprite_:getContentSize().height * 0.5 + 1)
                              :addTo(self.e_tank_)


    self.m_tank_label_ = label:create("0"..tostring(cc.player_.m_tanks_),
                                      "fonts/megaman_2.ttf",
                                      8,
                                      cc.TEXT_ALIGNMENT_LEFT,
                                      cc.VERTICAL_TEXT_ALIGNMENT_TOP)
                              :setPosition(self.m_tank_.sprite_:getContentSize().width + 1, -self.m_tank_.sprite_:getContentSize().height * 0.5 + 1)
                              :addTo(self.m_tank_)

    -- unlockables
    local head = pause_interruptor:create("extreme_helmet")
                            :setPosition(cc.p(196, -176))
                            :addTo(self)

    local fist = pause_interruptor:create("extreme_fist")
                            :setPosition(cc.p(head:getPositionX() - 16, head:getPositionY() - 16))
                            :addTo(self)

    local chest = pause_interruptor:create("extreme_chest")
                             :setPosition(cc.p(fist:getPositionX() + 16, fist:getPositionY()))
                             :addTo(self)

    local boot  = pause_interruptor:create("extreme_boot")
                             :setPosition(cc.p(chest:getPositionX() + 16, chest:getPositionY()))
                             :addTo(self)

    -- buttons
    self.ex_switch_ = pause_interruptor:create("ex")
                                 :set_visitable(false)
                                 :setPosition(cc.p(head:getPositionX(), -144))
                                 :addTo(self)

    self.helmet_switch_ = pause_interruptor:create("helmet")
                                     :set_visitable(false)
                                     :setPosition(cc.p(self.ex_switch_:getPositionX() - 20, self.ex_switch_:getPositionY()))
                                     :addTo(self)

    self.exit_switch_ = pause_interruptor:create("exit")
                                   :setPosition(cc.p(self.ex_switch_:getPositionX() + 20, self.ex_switch_:getPositionY()))
                                   :addTo(self)

    self.weapon_animation_ = pause_animation:create()
                                             :setPosition(cc.p(204, -128))
                                             :swap(self.default_browner_.pause_item_)
                                             :addTo(self)

    self.items_[#self.items_ + 1] = self.e_tank_
    self.items_[#self.items_ + 1] = self.m_tank_
    self.items_[#self.items_ + 1] = self.ex_switch_
    self.items_[#self.items_ + 1] = self.helmet_switch_
    self.items_[#self.items_ + 1] = self.exit_switch_

    self:init_callbacks()

    self:prepare()
end

function pause_menu:setup_variables()
    self.ready_ = false

    self.items_ = {}
    self.browners_  = {}

end

function pause_menu:setup_browners()

    local y_offset = -48

    local pause_browners = {}

    for _, browner in pairs(cc.browners_) do
        if browner.pause_item_ ~= nil then
            pause_browners[browner.id_] = browner
        end
    end

    self.default_browner_ = nil

    for i = 2, #pause_browners do -- because teleport browner is the first one

    local browner = pause_browners[i]

    local browner_location = cc.p(80, y_offset)

    if browner.id_ % 2 == 0 then
        browner_location.x = 12
    end

    local new_interruptor = pause_interruptor:create(browner.pause_item_ .. "_" .. "weapon")
    :setPosition(browner_location)
    :addTo(self)

    local interruptor_label = label:create(browner.pause_item_,
        "fonts/megaman_2.ttf",
        8,
        cc.TEXT_ALIGNMENT_LEFT,
        cc.VERTICAL_TEXT_ALIGNMENT_TOP)
    :addTo(new_interruptor)

    interruptor_label:setPosition(cc.p(new_interruptor.sprite_:getContentSize().width + 1, 0))

    new_interruptor.browner_id_ = browner.id_
    new_interruptor.pause_item_ = browner.pause_item_

    new_interruptor.energy_bar_ = energy_bar:create(true)
                                            :setPosition(cc.p(new_interruptor.sprite_:getContentSize().width,
                                                -new_interruptor.sprite_:getContentSize().height))
                                            :setRotation(-90)
                                            :setScaleY(0.75)
                                            :addTo(new_interruptor)

    if self.player_.browners_[new_interruptor.browner_id_] ~= nil then
        new_interruptor.energy_bar_:set_meter(self.player_.browners_[new_interruptor.browner_id_].energy_)
    end

    if browner.acquired_ == true then
        new_interruptor:setVisible(true)
    else
        new_interruptor:setVisible(false)
    end

    self.items_[#self.items_ + 1] = new_interruptor
    self.browners_[new_interruptor.browner_id_] = new_interruptor

    if browner_location.x == 80 then
        y_offset  = y_offset - 24
    end

    if new_interruptor.browner_id_ == self.player_.current_browner_.browner_id_ then
        self.default_browner_ = new_interruptor
    end
    end
end


function pause_menu:init_callbacks()

    -- variables
    self.filling_m_tank_ = false

    -- callbacks
    self.on_e_tank_triggered_ = function(sender)
        if self.player_.health_ < 28 and cc.player_.e_tanks_ > 0 then
            self.ready_ = false
            cc.callbacks_.energy_fill(self, self.player_, 28, {health_ = true, energy_ = false}, function()
                self.ready_ = true
                cc.player_.e_tanks_ = cc.player_.e_tanks_ - 1
                self.e_tank_label_.label_:setString("0"..tostring(cc.player_.e_tanks_))
                cc.pause(true)
            end)
        else
            audio.playSound("sounds/sfx_error.wav", false)
        end
    end

    self.on_m_tank_triggered_ = function(sender)

        if cc.player_.m_tanks_ > 0 then
            self.filling_m_tank_ = true
            self.items_ = self.browner_items_
            self.selector_:set_selected_item(self.default_browner_)
        else
            audio.playSound("sounds/sfx_error.wav", false)
        end

    end

    self.on_browner_triggered_ = function(sender)

        if self.filling_m_tank_ then
            if self.player_.current_browner_.energy_ ~= nil then
                if self.player_.current_browner_.energy_ < 28 then

                    self.ready_ = false

                    local browner = self.selector_:get_selected_item()

                    cc.callbacks_.energy_fill(self, self.player_.browners_[browner.browner_id_], 28, {health_ = false, energy_ = true}, function()
                        self.ready_ = true
                        cc.player_.m_tanks_ = cc.player_.m_tanks_ - 1
                        self.m_tank_label_.label_:setString("0"..tostring(cc.player_.m_tanks_))
                        cc.pause(true)
                    end)
                else
                    audio.playSound("sounds/sfx_error.wav", false)
                end
            else
                audio.playSound("sounds/sfx_error.wav", false)
            end

            self.filling_m_tank_ = false
            self.items_ = self.all_items_

        end

    end

    self.on_switch_triggered_ = function(sender)
        self:switch_triggered(sender)
        self:validate_weapons()
    end

    self.e_tank_:set_triggered_callback(self.on_e_tank_triggered_)
    self.m_tank_:set_triggered_callback(self.on_m_tank_triggered_)

    for _, browner in pairs(self.browners_) do
        browner:set_triggered_callback(self.on_browner_triggered_)
    end

    self.ex_switch_:set_triggered_callback(self.on_switch_triggered_)
    self.helmet_switch_:set_triggered_callback(self.on_switch_triggered_)
    self.exit_switch_:set_triggered_callback(self.on_switch_triggered_)

end

function pause_menu:prepare()
    self:validate_weapons()

    self.all_items_ = self.items_
    self.browner_items_ = self.browners_

    self.items_ = self.all_items_

    self.selector_:set_selected_item(self.default_browner_)
end


function pause_menu:switch_triggered(sender)

    local visit_target = false
    local visit_sender = false

    local target_value = 1
    local sender_value = 1

    local target

    if sender == self.helmet_switch_ then
        if cc.game_options_.helmet_activated_ then
            cc.game_options_.helmet_activated_ = false
            visit_sender = true
        else
            if cc.game_options_.extreme_activated_ then
                cc.game_options_.extreme_activated_ = false
                visit_target = true
                target = self.ex_switch_
            end

            cc.game_options_.helmet_activated_ = true
            visit_sender = true
            sender_value = 2
        end
    elseif sender == self.ex_switch_ then
        if cc.game_options_.extreme_activated_ then
            cc.game_options_.extreme_activated_ = false
            visit_sender = true
        else
            if cc.game_options_.helmet_activated_ then
                cc.game_options_.helmet_activated_ = false
                visit_target = true
                target = self.helmet_switch_
            end

            cc.game_options_.extreme_activated_ = true
            visit_sender = true
            sender_value = 2
        end
    elseif sender == self.exit_switch_ then
        audio.playSound("sounds/sfx_selected.wav", false)
        self:setVisible(false)
        self.player_:getParent():setVisible(false)
        self.player_
            :getParent()
            :getApp()
            :enterScene("screens.stage_select", "FADE", 1, {physics = false})
        return self
    end

    if visit_target then
        target.sprite_:set_image_index(target_value)
    end

    if visit_sender then
        sender.sprite_:set_image_index(sender_value)
    end

    local violet = self.browners_[cc.browners_.violet_.id_]
    local helmet  = self.browners_[cc.browners_.helmet_.id_]
    local extreme  = self.browners_[cc.browners_.extreme_.id_]

    local new_default_browner

    if cc.game_options_.helmet_activated_ then
        if self.default_browner_ == violet or self.default_browner_ == extreme then
            new_default_browner = helmet
        end
    else
        if cc.game_options_.extreme_activated_ then
            if self.default_browner_ == violet or self.default_browner_ == helmet then
                new_default_browner = extreme
            end
        else
            if self.default_browner_ == helmet or self.default_browner_ == extreme then
                new_default_browner = violet
            end
        end
    end

    if new_default_browner ~= nil then
        self.default_browner_ = new_default_browner
    end
end

function pause_menu:validate_weapons()

    local helmet_switch_index = 1
    local ex_switch_index     = 1

    if cc.game_options_.helmet_activated_ then
        helmet_switch_index = 2
    end

    if cc.game_options_.extreme_activated_ then
        ex_switch_index = 2
    end

    self.helmet_switch_.sprite_:set_image_index(helmet_switch_index)
    self.ex_switch_.sprite_:set_image_index(ex_switch_index)

    local violet = self.browners_[cc.browners_.violet_.id_]
    local helmet  = self.browners_[cc.browners_.helmet_.id_]
    local extreme  = self.browners_[cc.browners_.extreme_.id_]

    violet:setVisible(not (cc.game_options_.helmet_activated_ or cc.game_options_.extreme_activated_))
    helmet:setVisible(cc.game_options_.helmet_activated_)
    extreme:setVisible(cc.game_options_.extreme_activated_)

    helmet:setPosition(cc.p(violet:getPositionX(), violet:getPositionY()))
    extreme:setPosition(cc.p(violet:getPositionX(), violet:getPositionY()))

end

function pause_menu:ex_triggered()
    local violet = self.browners_[cc.browners_.violet_.id_]
    local extreme  = self.browners_[cc.browners_.extreme_.id_]
    local helmet  = self.browners_[cc.browners_.helmet_.id_]

    if cc.game_options_.extreme_activated_ then
        violet:setVisible(false)
        extreme:setVisible(true)
    else
        violet:setVisible(true)
        extreme:setVisible(false)
    end

    if not cc.game_options_.helmet_activated_ then
        helmet:setVisible(false)
    end

end

function pause_menu:step(dt)

    for _, browner in pairs(self.browners_) do
        if self.player_.browners_[browner.browner_id_] ~= nil then
           browner.energy_bar_:set_meter(self.player_.browners_[browner.browner_id_].energy_)
        end
    end

    if self.ready_ then

        self.selector_:select_from(self.items_)

        if self.selector_:get_selected_item().pause_item_ ~= nil then
            self.weapon_animation_:swap(self.selector_:get_selected_item().pause_item_)
        else
            self.weapon_animation_:swap(self.default_browner_.pause_item_)
        end

        if self.selector_:get_selected_item().browner_id_ ~= nil then
            self.selected_browner_ = self.selector_:get_selected_item()
        else
            self.selected_browner_ = nil
        end

    end
end

return pause_menu