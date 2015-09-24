-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local title = import("app.core.gameplay.control.layout_base").create("title")

local sprite    = import("app.core.graphical.sprite")
local label     = import("app.core.graphical.label")
local selector  = import("app.objects.gameplay.level.ui.selector")

function title:onLoad()


    self.background_ = sprite:create("sprites/gameplay/screens/title_screen/title_screen", cc.p(0, 0))
                             :setPosition(cc.p(0,0))
                             :addTo(self)

    self.selector_ = selector:create("arrow", "right")
                             :setPosition(cc.p(64,96))
                             :addTo(self, 128)

    self.text_ = label:create("start game",
                              "fonts/megaman_2.ttf",
                              8,
                              cc.TEXT_ALIGNMENT_LEFT,
                              cc.VERTICAL_TEXT_ALIGNMENT_TOP)
                      :addTo(self, 128)

    self.text_:setPosition(cc.p(self.selector_:getPositionX() + self.selector_.sprite_:getContentSize().width,
                                self.selector_:getPositionY() + self.text_.label_:getContentSize().height * 0.5))

    if device.platform == "android" then

        local tex_path = "sprites/core/social"

        self.social_button_ = ccui.Button:create()
        self.social_button_:setTouchEnabled(true)
        self.social_button_:loadTextures(tex_path.."/facebook/facebook_share.png", tex_path.."/facebook/facebook_share.png", "")
        self.social_button_:setPosition(cc.p(display.left_top.x + self.social_button_:getContentSize().width,
                                             display.left_top.y - self.social_button_:getContentSize().height))

        self.social_button_:setPressedActionEnabled(true)
        self.social_button_:onTouch(function(event)
            if event.name == "began" then
                --[[
                                local tex_path = "sprites/core/social"

                                local info
                                info.type  = "photo"
                                info.title = "I'm playing a Greentwip game!"
                                info.image = tex_path .. "/greentwip/greentwip_share.png"
                                sdkbox.PluginFacebook:share(info)
                                ]]--

            end
        end)

        self.social_button_:addTo(self)

--        print("----------------------------")
--        print(FB_PERM_PUBLISH_POST)

        if sdkbox.PluginFacebook:isLoggedIn() then
            self:post_to_profile()
        else
            sdkbox.PluginFacebook:login()
            self:post_to_profile()
        end

    end

    audio.playMusic("sounds/bgm_title.mp3", true)

    -- self variables
    self.triggered_ = false


end

function title:post_to_profile()
    sdkbox.PluginFacebook:requestPublishPermissions({"publish_actions"})
--[[
     local info = {};
    info.type  = "link";
    info.link  = "http://www.cocos2d-x.org";
    info.title = "cocos2d-x";
    info.text  = "Best Game Engine";
    info.image = "http://cocos2d-x.org/images/logo.png";
    sdkbox.PluginFacebook:share(info);
]]--
--[[
    local info;
    info.type  = "link";
    info.link  = "http://www.cocos2d-x.org";
    info.title = "cocos2d-x";
    info.text  = "Best Game Engine";
    info.image = "http://cocos2d-x.org/images/logo.png";
    sdkbox.PluginFacebook:dialog(info);]]--

end

function title:post_photo()

    local info = {}
    info.type  = "photo"
    info.title = "I'm playing a Greentwip game!"
    info.image = tex_path .. "/greentwip/greentwip_share.png"
    sdkbox.PluginFacebook:share(info)
end

function title:onSocial(event)

end

function title:step(dt)
    if not self.triggered_ then
        if cc.key_pressed(cc.key_code_.a) then
            self.triggered_ = true
            audio.playSound("sounds/sfx_selected.wav")

            self.exit_arguments_ = {}
            self.exit_arguments_.demo_browner_id_ = cc.browners_.violet_.id_

            self:getApp()
--            :enterScene("levels.level_weapon", "FADE", 0.5, {physics = true})
            :enterScene("screens.stage_select", "FADE", 0.5)
--                :prepare(self.exit_arguments_)
        end
    end

    self:post_step(dt)

    return self
end



return title