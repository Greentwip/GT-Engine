-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local MyApp = class("MyApp", cc.load("mvc").AppBase)

function MyApp:onCreate()
    math.randomseed(os.time())
    self:setup()
end

function MyApp:setup()
    self:initiate()

    --cc.lite_edition_ = true
    display.setAutoScale({autoscale = "SHOW_ALL", width = 256, height = 224}, {width = display.width, height = display.height})
end

function cc.key_down(key)
    return cc.keys_[key].status_ == cc.KEY_STATUS.DOWN
end

function cc.key_pressed(key)
    return cc.keys_[key].pressed_
end

function cc.pause(freeze)
    if freeze then
        cc.game_status_ = cc.GAME_STATUS.PAUSED
    else
        cc.game_status_ = cc.GAME_STATUS.RUNNING
    end
end

function MyApp:initiate()

    self:setup_application()
    self:setup_tags()
    self:setup_callbacks()
    self:setup_keyboard()
    self:setup_camera()
    self:setup_player()
    self:setup_enemy()
    self:setup_special()
    self:setup_battle()
    self:setup_items()
    self:setup_levels()
    self:setup_browners()

end

function MyApp:setup_callbacks()

    cc.callbacks_ = {}

    function cc.callbacks_.pre_fill()
        cc.pause(true)
        audio.playSound("sounds/sfx_getenergy.wav", false)
    end

    function cc.callbacks_.post_fill()
        cc.pause(false)
        cc.fill_amount_ = 0
        if cc.fill_object_.resume_actions then
            cc.fill_object_:resume_actions()
        end
        cc.sender_:stopAllActions()
        if cc.on_post_fill_callback_ ~= nil then
           cc:on_post_fill_callback_()
        end
    end

    function cc.callbacks_.fill_health_()
        if cc.fill_amount_ > 0 and cc.fill_object_.health_ <= 28 then
            cc.callbacks_.pre_fill()
            cc.fill_object_.health_ = cc.fill_object_.health_ + 1
            cc.fill_amount_ = cc.fill_amount_ - 1
        else
            cc.callbacks_.post_fill()
        end
    end

    function cc.callbacks_.fill_energy_()
        if cc.fill_object_.energy_ ~= nil then
            if cc.fill_amount_ > 0 and cc.fill_object_.energy_ < 28 then
                cc.callbacks_.pre_fill()
                cc.fill_object_.energy_ = cc.fill_object_.energy_ + 1
                cc.fill_amount_ = cc.fill_amount_ - 1
            else
                cc.callbacks_.post_fill()
            end
        else
            cc.callbacks_.post_fill()
        end
    end

    function cc.callbacks_.energy_fill(sender, object, amount, property, on_post_fill_callback)
        cc.fill_amount_ = amount
        cc.fill_object_ = object

        if cc.fill_object_.pause_actions then
            cc.fill_object_:pause_actions()
        end

        cc.sender_ = sender

        cc.on_post_fill_callback_ = on_post_fill_callback

        local fill_callback = cc.callbacks_.fill_health_

        if property.energy_ then
            fill_callback = cc.callbacks_.fill_energy_
        end

        local delay = cc.DelayTime:create(0.06)
        local fill_callback = cc.CallFunc:create(fill_callback)

        local fill_sequence = cc.Sequence:create(delay, fill_callback, nil)

        local sequence = cc.RepeatForever:create(fill_sequence)

        cc.sender_:runAction(sequence)
    end
end

function MyApp:setup_application()

    cc.texture_formats_ = {}
    cc.texture_formats_.pvr_ = 0
    cc.texture_formats_.png_ = 1

    cc.texture_format_ = cc.texture_formats_.pvr_


    cc.GAME_STATUS = {}
    cc.GAME_STATUS.PAUSED = 0
    cc.GAME_STATUS.RUNNING = 1

    cc.PAUSE_STATUS = {}
    cc.PAUSE_STATUS.NONE    = 0
    cc.PAUSE_STATUS.SCREEN  = 1

    cc.game_status_  = cc.GAME_STATUS.RUNNING
    cc.pause_status_ = cc.PAUSE_STATUS.NONE

    cc.frames_cache_ = {}
    cc.animations_cache_ = {}
end

function MyApp:setup_tags()

    cc.tags = {}
    cc.tags.none         = -1
    cc.tags.player       = 1
    cc.tags.item         = 2
    cc.tags.enemy        = 3
    cc.tags.block        = 4
    cc.tags.camera       = 5
    cc.tags.scroll       = 6
    cc.tags.check_point  = 7
    cc.tags.teleporter   = 8
    cc.tags.bounds       = 9
    cc.tags.hole         = 10
    cc.tags.door         = 11
    cc.tags.ladder       = 12
    cc.tags.weapon = {}
    cc.tags.weapon.player = 13
    cc.tags.weapon.enemy  = 14
    cc.tags.weapon.none   = 15

    cc.tags.logic = {}
    cc.tags.logic.check_point = {}
    cc.tags.logic.check_point.first_ = 16

    cc.tags.actions = {}
    cc.tags.actions.animation   = 17
    cc.tags.actions.color       = 18

    cc.tags.free_scroll       = 19

    cc.tags.actions.visibility  = 20



    cc.level_status_ = {}
    cc.level_status_.init_ = 1
    cc.level_status_.run_  = 2
end

function MyApp:setup_keyboard()

    cc.KEY_STATUS       = {}
    cc.KEY_STATUS.UP    = 0
    cc.KEY_STATUS.DOWN  = 1

    cc.key_code_ = {}
    cc.key_code_.a      = 1
    cc.key_code_.b      = 2
    cc.key_code_.start  = 3
    cc.key_code_.up     = 4
    cc.key_code_.down   = 5
    cc.key_code_.left   = 6
    cc.key_code_.right  = 7


    cc.keys_ = {}

    local key_list = {cc.key_code_.a,
                      cc.key_code_.b,
                      cc.key_code_.start,
                      cc.key_code_.up, cc.key_code_.down, cc.key_code_.left, cc.key_code_.right}

    for i = 1, #key_list do
        local key = {}
        key.status_ = cc.KEY_STATUS.UP
        key.pressed_ = false
        key.released_ = false

        cc.keys_[i] = key
    end

end

function MyApp:setup_camera()
    cc.CAMERA = {}
    cc.CAMERA.MODE = {}
    cc.CAMERA.SCROLL = {}
    cc.CAMERA.SHIFT  = {}

    cc.CAMERA.MODE.SCREEN = 1
    cc.CAMERA.MODE.SCROLL = 2
    cc.CAMERA.MODE.SHIFT  = 3

    cc.CAMERA.SCROLL.UP     = 1
    cc.CAMERA.SCROLL.DOWN   = 2
    cc.CAMERA.SCROLL.LEFT   = 3
    cc.CAMERA.SCROLL.RIGHT  = 4
    cc.CAMERA.SCROLL.MOVING = 5
    cc.CAMERA.SCROLL.NONE   = 6


    cc.CAMERA.SHIFT.UP      = 1
    cc.CAMERA.SHIFT.DOWN    = 2
    cc.CAMERA.SHIFT.LEFT    = 3
    cc.CAMERA.SHIFT.RIGHT   = 4
    cc.CAMERA.SHIFT.NONE    = 5
end

function MyApp:setup_player()

    cc.player_ = {}
    cc.player_.climb_direction_ = {}
    cc.player_.climb_direction_.up_ = 0
    cc.player_.climb_direction_.down_ = 1
    cc.player_.climb_direction_.none_ = 2
    cc.player_.lives_ = 3

    cc.player_.e_tanks_ = 0
    cc.player_.m_tanks_ = 0

    cc.unlockables_ = {}

    cc.unlockables_.helmet_ = {id_ = 2, acquired_ = false }
    cc.unlockables_.head_   = {id_ = 3, acquired_ = false }
    cc.unlockables_.chest_  = {id_ = 4, acquired_ = false }
    cc.unlockables_.fist_   = {id_ = 5, acquired_ = false }
    cc.unlockables_.boot_   = {id_ = 6, acquired_ = false }

    cc.unlockables_.helmet_acquired_ = function()
        return cc.unlockables_.helmet_.acquired_
    end

    cc.unlockables_.extreme_acquired_ = function()
        local acquired = true

        for _, unlockable in pairs(cc.unlockables_) do
            if not unlockable.acquired_ then
               acquired = false
            end
        end

        return acquired

    end

    cc.game_options_ = {}

    cc.game_options_.extreme_activated_ = false
    cc.game_options_.helmet_activated_  = false

    cc.kinematic_contact_ = {}
    cc.kinematic_contact_.up    = 1
    cc.kinematic_contact_.down  = 2
    cc.kinematic_contact_.left  = 3
    cc.kinematic_contact_.right = 4

end

function MyApp:setup_enemy()
    cc.enemy_ = {}
    cc.enemy_.status_ = {}

    cc.enemy_.status_.active_   = 1
    cc.enemy_.status_.fighting_ = 2
    cc.enemy_.status_.defeated_ = 3
    cc.enemy_.status_.inactive_ = 4

end

function MyApp:setup_special()
    cc.special_ = {}
    cc.special_.status_ = {}

    cc.special_.status_.on_screen_   = 1
    cc.special_.status_.off_screen_  = 2

end

function MyApp:setup_battle()
    cc.battle_status_ = {}
    cc.battle_status_.waiting_  = 1
    cc.battle_status_.startup_  = 2
    cc.battle_status_.intro_    = 3
    cc.battle_status_.fighting_ = 4
    cc.battle_status_.defeated_ = 5

end

function MyApp:setup_items()

    cc.item_                 = {}

    cc.item_.life_            = {id_ = 1,  string_ = "life"   }

    cc.item_.helmet_          = {id_ = 2,  string_ = "helmet" }
    cc.item_.head_            = {id_ = 3,  string_ = "head"   }
    cc.item_.chest_           = {id_ = 4,  string_ = "chest"  }
    cc.item_.fist_            = {id_ = 5,  string_ = "fist"   }
    cc.item_.boot_            = {id_ = 6,  string_ = "boot"   }

    cc.item_.health_small_    = {id_ = 7,  string_ = "health_small" }
    cc.item_.health_big_      = {id_ = 8,  string_ = "health_big"   }

    cc.item_.energy_small_    = {id_ = 9,  string_ = "energy_small" }
    cc.item_.energy_big_      = {id_ = 10, string_ = "energy_big" }

    cc.item_.e_tank_          = {id_ = 11,  string_ = "e_tank" }
    cc.item_.m_tank_          = {id_ = 12,  string_ = "m_tank" }



    local on_item_acquired = function(player, item)

        if item.id_ == cc.item_.life_.id_ then

            if cc.player_.lives_ < 9 then
                cc.player_.lives_ = cc.player_.lives_ + 1
            end

            audio.playSound("sounds/sfx_getlife.wav", false)

        elseif item.id_ >= cc.item_.helmet_.id_ and item.id_ <= cc.item_.boot_.id_ then
            for _, unlockable in pairs(cc.unlockables_) do
                if item.id_ == unlockable.id_ then
                   unlockable.acquired_ = true
                end
            end

            audio.playSound("sounds/sfx_getlife.wav", false)

        elseif item.id_ == cc.item_.e_tank_.id_ then
            if cc.player_.e_tanks_ < 9 then
                cc.player_.e_tanks_ = cc.player_.e_tanks_ + 1
            end

            audio.playSound("sounds/sfx_getlife.wav", false)

        elseif item.id_ == cc.item_.m_tank_.id_ then
            if cc.player_.m_tanks_ < 9 then
                cc.player_.m_tanks_ = cc.player_.m_tanks_ + 1
            end

            audio.playSound("sounds/sfx_getlife.wav", false)

        else
            player:restore_sanity(item)
        end
    end

    for _, item in pairs(cc.item_) do
       item.callback_ = on_item_acquired
    end

end

function MyApp:setup_levels()

    cc.levels_ = {}

    local level_mugs = {}

    level_mugs[#level_mugs + 1] = "freezerman"
    level_mugs[#level_mugs + 1] = "sheriffman"
    level_mugs[#level_mugs + 1] = "boomerman"
    level_mugs[#level_mugs + 1] = "militaryman"
    level_mugs[#level_mugs + 1] = "vineman"
    level_mugs[#level_mugs + 1] = "shieldman"
    level_mugs[#level_mugs + 1] = "nightman"
    level_mugs[#level_mugs + 1] = "torchman"
    level_mugs[#level_mugs + 1] = "test"

    for i = 1, #level_mugs do
        local level_map = {}
        level_map.mug_ = level_mugs[i]
        level_map.defeated_ = false
        cc.levels_[#cc.levels_ + 1] = level_map
    end

    cc.current_level_ = nil

    cc.demo_ = {}
    cc.demo_.level_      = 1
    cc.demo_.get_weapon_ = 2

end

function MyApp:setup_browners()

    cc.browners_ = {
        teleport_   = {id_ = 1,  acquired_ = true,  pause_item_ = nil},
        violet_     = {id_ = 2,  acquired_ = true,  pause_item_ = "violet"},
        fuzzy_      = {id_ = 3,  acquired_ = true,  pause_item_ = "fuzzy"},
        freezer_    = {id_ = 4,  acquired_ = false, pause_item_ = "freezer"},
        sheriff_    = {id_ = 5,  acquired_ = false, pause_item_ = "sheriff"},
        boomer_     = {id_ = 6,  acquired_ = false, pause_item_ = "boomer"},
        military_   = {id_ = 7,  acquired_ = false, pause_item_ = "military"},
        vine_       = {id_ = 8,  acquired_ = false,  pause_item_ = "vine"},
        shield_     = {id_ = 9,  acquired_ = false, pause_item_ = "shield"},
        night_      = {id_ = 10, acquired_ = false, pause_item_ = "night"},
        torch_      = {id_ = 11, acquired_ = false, pause_item_ = "torch"},
        helmet_     = {id_ = 12, acquired_ = false, pause_item_ = "helmet"},
        extreme_    = {id_ = 13, acquired_ = false, pause_item_ = "ex"},
        boss_       = {id_ = 14, acquired_ = nil, pause_item_ = nil }
    }

    for _, v in pairs(cc.browners_) do
        if v.id_ >= 4 and v.id_ <= 11 then
           v.level_ = cc.levels_[v.id_ - 3].mug_
           v.energy_ = 28
        end
    end

    cc.browners_.violet_.energy_    = -1
    cc.browners_.helmet_.energy_    = -1
    cc.browners_.fuzzy_.energy_     = 28
    cc.browners_.extreme_.energy_   = 28
end

return MyApp
