local Events = require("utility/events")
local Utils = require("utility/utils")
local ExterminateBiters = require("scripts/exterminate-biters")
local RecruitWorkforce = require("scripts/recruit-workforce")
local Investments = require("scripts/investments")
local Orders = require("scripts/orders")
local Financials = require("scripts/financials")
local Gui = require("scripts/gui")

local function OnStartup()
    Utils.DisableIntroMessage()
    ExterminateBiters.OnStartup()
    RecruitWorkforce.OnStartup()
    Financials.OnStartup()
    Investments.OnStartup()
    Orders.OnStartup()

    Gui.OnStartup()
end

local function OnLoad()
    Utils.DisableSiloScript()
    ExterminateBiters.OnLoad()
    RecruitWorkforce.OnLoad()
    Financials.OnLoad()
    Investments.OnLoad()
    Orders.OnLoad()

    Gui.OnLoad()
end

local function On60Ticks()
    Events.RaiseEvent({name = "on60ticks"})
end

script.on_init(OnStartup)
script.on_configuration_changed(OnStartup)
script.on_load(OnLoad)
Events.RegisterEvent("on60ticks")
script.on_nth_tick(60, On60Ticks)
Events.RegisterEvent(defines.events.on_runtime_mod_setting_changed)
Events.RegisterEvent(defines.events.on_rocket_launched)
Events.RegisterEvent(defines.events.on_research_finished)
Events.RegisterEvent(defines.events.on_player_joined_game)
