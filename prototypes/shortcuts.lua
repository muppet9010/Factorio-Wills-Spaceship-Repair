local Constants = require("constants")

data:extend(
    {
        {
            type = "shortcut",
            name = "wills_spaceship_repair-investments_gui_button",
            action = "lua",
            icon = {
                filename = Constants.AssetModName .. "/graphics/shortcuts/investments32.png",
                width = 32,
                height = 32
            },
            small_icon = {
                filename = Constants.AssetModName .. "/graphics/shortcuts/investments24.png",
                width = 24,
                height = 24
            },
            disabled_small_icon = {
                filename = Constants.AssetModName .. "/graphics/shortcuts/investments24-disabled.png",
                width = 24,
                height = 24
            }
        },
        {
            type = "shortcut",
            name = "wills_spaceship_repair-orders_gui_button",
            action = "lua",
            icon = {
                filename = Constants.AssetModName .. "/graphics/shortcuts/orders32.png",
                width = 32,
                height = 32
            },
            small_icon = {
                filename = Constants.AssetModName .. "/graphics/shortcuts/orders24.png",
                width = 24,
                height = 24
            },
            disabled_small_icon = {
                filename = Constants.AssetModName .. "/graphics/shortcuts/orders24-disabled.png",
                width = 24,
                height = 24
            }
        }
    }
)
