local Events = require("utility/events")
local Utils = require("utility/utils")
local RecruitWorkforce = require("scripts/recruit-workforce")
local Investments = require("scripts/investments")
local Orders = require("scripts/orders")
local Financials = require("scripts/financials")
local Gui = require("scripts/gui")
local Market = require("scripts/market")
local Map = require("scripts/map")

local function SetTestData()
    global.profitMade = 0
    global.profitTarget = 50000
    global.bankruptcyLimit = 1500000
    global.dividendsPaid = 150000
    global.dividendsTotal = 500000
    global.wagesPaid = 3000
    global.wagesTotal = 6500

    global.orderSlots[1] = {index = 1, state = Orders.SlotStates.waitingItem, item = "wills_spaceship_repair-hull_component", itemCountNeeded = 2, itemCountDone = 1, startTime = 0, nextDeadlineTime = (60 * 60 * 30)}
    global.orderSlots[2] = {index = 2, state = Orders.SlotStates.waitingCustomerDepart, item = nil, itemCountNeeded = nil, itemCountDone = nil, startTime = nil, nextDeadlineTime = (60 * 15)}
    global.orderSlots[3] = {index = 3, state = Orders.SlotStates.waitingDrydock, item = nil, itemCountNeeded = nil, itemCountDone = nil, startTime = nil, nextDeadlineTime = nil}
end

local function OnStartup()
    global.surface = game.surfaces[1]
    Utils.DisableIntroMessage()
    RecruitWorkforce.OnStartup()
    Financials.OnStartup()
    Investments.OnStartup()
    Orders.OnStartup()
    Market.OnStartup()
    Map.OnStartup()

    Gui.OnStartup()

    SetTestData()
end

local function OnLoad()
    Utils.DisableSiloScript()
    RecruitWorkforce.OnLoad()
    Financials.OnLoad()
    Investments.OnLoad()
    Orders.OnLoad()
    Market.OnLoad()
    Map.OnLoad()

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
Events.RegisterEvent(defines.events.on_chunk_generated)
