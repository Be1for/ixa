local Ixa = require(game.ReplicatedStorage.Ixa)

local window = Ixa:Window({
    title = "Ixa example",
    subtitle = "Starter interface",
    accent = Color3.fromRGB(224, 110, 78),
})

local main = window:Tab({ name = "Main", icon = "house" })
local settings = main:Section({ name = "Settings" })

settings:Toggle({
    text = "Enable option",
    flag = "enabled",
    default = true,
    callback = function(value)
        print("Enabled:", value)
    end,
})

settings:Slider({
    text = "Intensity",
    flag = "intensity",
    min = 0,
    max = 100,
    default = 35,
    callback = function(value)
        print("Intensity:", value)
    end,
})

window:Show()
