local Constants = require("constants")

data:extend(
    {
        {
            type = "technology",
            name = "wills_spaceship_repair-order_decryption-1",
            icon_size = 128,
            icon = Constants.AssetModName .. "/graphics/spacex/technology/ftl.png",
            prerequisites = {"wills_spaceship_repair-dry_dock-1"},
            unit = {
                count_formula = "1000",
                ingredients = {
                    {"automation-science-pack", 1},
                    {"logistic-science-pack", 1},
                    {"military-science-pack", 1},
                    {"chemical-science-pack", 1},
                    {"production-science-pack", 1},
                    {"utility-science-pack", 1},
                    {"space-science-pack", 1}
                },
                time = 60
            },
            effects = {
                {
                    type = "nothing",
                    effect_description = {"technology-effect.wills_spaceship_repair-order_decryption"}
                }
            },
            enabled = false,
            visible_when_disabled = true,
            upgrade = true,
            max_level = "infinite",
            order = "zzz"
        }
    }
)
