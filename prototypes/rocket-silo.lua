local Utils = require("utility/utils")

local rocketSilo = data.raw["rocket-silo"]["rocket-silo"]
rocketSilo.rocket_result_inventory_size = 25000

data:extend({Utils.CreateLandPlacementTestEntityPrototype(rocketSilo, "wills_spaceship_repair-rocket_silo_place_test")})
