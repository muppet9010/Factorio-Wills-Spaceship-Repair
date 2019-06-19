local ExterminateBiters = {}
local Events = require("utility/events")

function ExterminateBiters.OnStartup()
    ExterminateBiters.OnLoad()
end

function ExterminateBiters.OnLoad()
    Events.RegisterHandler(defines.events.on_rocket_launched, "ExterminateBiters", ExterminateBiters.OnRocketLaunched)
end

function ExterminateBiters.OnRocketLaunched(event)
    local rocket = event.rocket
    for name in pairs(rocket.get_inventory(defines.inventory.rocket).get_contents()) do
        if name == "wills_spaceship_repair-exterminate_biters" then
            game.print({"message.wills_spaceship_repair-biters_eliminated"}, {r = 0, g = 1, b = 0, a = 1})
            local surface = game.surfaces[1]
            for key, entity in pairs(surface.find_entities_filtered({force = "enemy"})) do
                entity.destroy()
            end
            local mgs = surface.map_gen_settings
            mgs.autoplace_controls["enemy-base"].size = "none"
            surface.map_gen_settings = mgs
        end
    end
end

return ExterminateBiters
