-- Copyright 2014-2015 Greentwip. All Rights Reserved.

local animation = import ("app.objects.gameplay.level.animations.base.animation")

local spinner = class("spinner", animation)

function spinner:animate(cname)
    local spin =  { name = "spin", animation = { name = cname .. "_" .. "spin", forever = true, delay = 0.10} }

    self.sprite_:load_action(spin, false)

    self.sprite_:run_action("spin")
    return self
end

return spinner
