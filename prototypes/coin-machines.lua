local Constants = require("constants")
local Utils = require("utility/utils")
--local Logging = require("utility/logging")

local genericCoinMachine = {
    type = "assembling-machine",
    name = "generic_coin_machine",
    icons = {
        {
            icon = "__base__/graphics/icons/assembling-machine-0.png",
            icon_size = 32
        }
    },
    order = "zzz",
    flags = {"placeable-player"},
    max_health = 400,
    dying_explosion = "medium-explosion",
    corpse = "medium-remnants",
    alert_icon_shift = util.by_pixel(-3, -12),
    resistances = {
        {
            type = "fire",
            percent = 70
        }
    },
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    working_sound = {
        sound = {
            {
                filename = "__base__/sound/assembling-machine-t3-1.ogg",
                volume = 0.8
            },
            {
                filename = "__base__/sound/assembling-machine-t3-2.ogg",
                volume = 0.8
            }
        },
        idle_sound = {filename = "__base__/sound/idle1.ogg", volume = 0.6},
        apparent_volume = 1.5
    },
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    drawing_box = {{-1.5, -1.7}, {1.5, 1.5}},
    animation = {
        layers = {
            {
                filename = "__base__/graphics/entity/assembling-machine-0/assembling-machine-0.png",
                priority = "high",
                width = 108,
                height = 114,
                frame_count = 32,
                line_length = 8,
                shift = util.by_pixel(0, 2),
                hr_version = {
                    filename = "__base__/graphics/entity/assembling-machine-0/hr-assembling-machine-0.png",
                    priority = "high",
                    width = 214,
                    height = 226,
                    frame_count = 32,
                    line_length = 8,
                    shift = util.by_pixel(0, 2),
                    scale = 0.5
                }
            },
            {
                filename = "__base__/graphics/entity/assembling-machine-0/assembling-machine-0-shadow.png",
                priority = "high",
                width = 95,
                height = 83,
                frame_count = 1,
                line_length = 1,
                repeat_count = 32,
                draw_as_shadow = true,
                shift = util.by_pixel(8.5, 5.5),
                hr_version = {
                    filename = "__base__/graphics/entity/assembling-machine-0/hr-assembling-machine-0-shadow.png",
                    priority = "high",
                    width = 190,
                    height = 165,
                    frame_count = 1,
                    line_length = 1,
                    repeat_count = 32,
                    draw_as_shadow = true,
                    shift = util.by_pixel(8.5, 5),
                    scale = 0.5
                }
            }
        }
    },
    crafting_categories = {"coins"},
    crafting_speed = 1,
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = 2
    },
    energy_usage = "500kW",
    allowed_effects = nil,
    map_color = data.raw["utility-constants"].default.chart.default_friendly_color
}

local function MakeSpecificCoinMachine(coinChestType)
    local coinMachine = Utils.DeepCopy(genericCoinMachine)
    local coinChestTypeItemPrototype = data.raw["item"][Constants.ModName .. "-" .. coinChestType]
    coinMachine.name = Constants.ModName .. "-" .. coinChestType .. "_assembling_machine"
    coinMachine.fixed_recipe = Constants.ModName .. "-" .. coinChestType
    table.insert(coinMachine.icons, {icon = coinChestTypeItemPrototype.icon, icon_size = coinChestTypeItemPrototype.icon_size, scale = (coinMachine.icons[1].icon_size / coinChestTypeItemPrototype.icon_size) / 2})
    data:extend({coinMachine})
end

MakeSpecificCoinMachine("wooden_coin_chest")
MakeSpecificCoinMachine("iron_coin_chest")
MakeSpecificCoinMachine("steel_coin_chest")

data:extend({Utils.CreateLandPlacementTestEntityPrototype(genericCoinMachine, "wills_spaceship_repair-coin_machine_place_test")})
