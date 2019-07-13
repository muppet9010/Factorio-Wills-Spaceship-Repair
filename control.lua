local Events = require("utility/events")
local Utils = require("utility/utils")
local RecruitWorkforce = require("scripts/recruit-workforce")
local Investments = require("scripts/investments")
local Orders = require("scripts/orders")
local Financials = require("scripts/financials")
local Gui = require("scripts/gui")
local Market = require("scripts/market")
local Map = require("scripts/map")
local OrderAudit = require("scripts/order-audit")
local EventScheduler = require("utility/event-scheduler")
local StaticData = require("scripts/static-data")

local function UpdateSetting(event)
    local settingName
    if event ~= nil then
        settingName = event.setting
    end
    if settingName == "wills_spaceship_repair-primary_player_name" or settingName == nil then
        global.primaryPlayerName = settings.global["wills_spaceship_repair-primary_player_name"].value
    end
end

local function CreateGlobals()
    global.surface = game.surfaces[1]
    global.playerForce = game.forces[1]
    global.playerForce.research_queue_enabled = true
    global.primaryPlayerName = global.primaryPlayerName or "YOUR NAME HERE"
    global.StaticData = StaticData
    RecruitWorkforce.CreateGlobals()
    Investments.CreateGlobals()
    Orders.CreateGlobals()
    OrderAudit.CreateGlobals()
    Financials.CreateGlobals()
    Map.CreateGlobals()
    Market.CreateGlobals()
    Gui.CreateGlobals()
end

local function OnLoad()
    Events.RegisterHandler(defines.events.on_runtime_mod_setting_changed, "control", UpdateSetting)

    Utils.DisableSiloScript()
    RecruitWorkforce.OnLoad()
    Investments.OnLoad()
    Orders.OnLoad()
    OrderAudit.OnLoad()
    Financials.OnLoad()
    Map.OnLoad()

    Gui.OnLoad()
end

local function OnStartup()
    CreateGlobals()
    OnLoad()

    UpdateSetting(nil)
    Utils.DisableIntroMessage()
    Utils.DisableWinOnRocket()
    Investments.OnStartup()
    Orders.OnStartup()
    Financials.OnStartup()
    Market.OnStartup()
    Map.OnStartup()
    Gui.OnStartup()
end

script.on_init(OnStartup)
script.on_configuration_changed(OnStartup)
script.on_load(OnLoad)
Events.RegisterEvent(defines.events.on_runtime_mod_setting_changed)
Events.RegisterEvent(defines.events.on_rocket_launched)
Events.RegisterEvent(defines.events.on_research_finished)
Events.RegisterEvent(defines.events.on_research_started)
Events.RegisterEvent(defines.events.on_player_joined_game)
Events.RegisterEvent(defines.events.on_chunk_generated)
Events.RegisterEvent(defines.events.on_entity_died)
Events.RegisterEvent(defines.events.script_raised_destroy)
Events.RegisterEvent(defines.events.on_lua_shortcut)
Events.RegisterEvent(defines.events.on_gui_click)
EventScheduler.RegisterScheduler()
