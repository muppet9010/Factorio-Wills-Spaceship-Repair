local Constants = require("constants")

data:extend(
    {
        {
            type = "technology",
            name = "wills_spaceship_repair-exterminate_biters",
            icon_size = 128,
            icon = Constants.AssetModName .. "/graphics/technology/exterminate_biters.png",
            effects = {
                {
                    type = "unlock-recipe",
                    recipe = "wills_spaceship_repair-exterminate_biters"
                }
            },
            prerequisites = {"artillery", "space-science-pack", "atomic-bomb"},
            unit = {
                count = "50000",
                ingredients = {
                    {"automation-science-pack", 1},
                    {"logistic-science-pack", 1},
                    {"military-science-pack", 4},
                    {"chemical-science-pack", 2},
                    {"production-science-pack", 1},
                    {"utility-science-pack", 1},
                    {"space-science-pack", 2}
                },
                time = 60
            },
            order = "zzz"
        },
        {
            type = "item",
            name = "wills_spaceship_repair-exterminate_biters",
            icon = Constants.AssetModName .. "/graphics/icons/exterminate_biters.png",
            icon_size = 32,
            subgroup = "ammo",
            order = "e[flamethrower]a",
            stack_size = 1
        },
        {
            type = "recipe",
            name = "wills_spaceship_repair-exterminate_biters",
            energy_required = 60,
            enabled = false,
            category = "crafting",
            ingredients = {
                {"poison-capsule", 25000},
                {"atomic-bomb", 1000}
            },
            result = "wills_spaceship_repair-exterminate_biters",
            requester_paste_multiplier = 1
        }
    }
)
