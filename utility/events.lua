local Utils = require("utility/utils")
local Logging = require("utility/logging")

local Events = {}
if MOD == nil then
    MOD = {}
end
if MOD.events == nil then
    MOD.events = {}
end
if MOD.customEventNameToId == nil then
    MOD.customEventNameToId = {}
end

function Events.RegisterEvent(eventName)
    local eventId
    if Utils.GetTableKeyWithValue(defines.events, eventName) ~= nil then
        eventId = eventName
    elseif MOD.customEventNameToId[eventName] ~= nil then
        eventId = MOD.customEventNameToId[eventName]
    else
        eventId = script.generate_event_name()
        MOD.customEventNameToId[eventName] = eventId
    end
    script.on_event(eventId, Events._HandleEvent)
end

function Events.RegisterHandler(eventName, handlerName, handlerFunction)
    local eventId
    if MOD.customEventNameToId[eventName] ~= nil then
        eventId = MOD.customEventNameToId[eventName]
    else
        eventId = eventName
    end
    if MOD.events[eventId] == nil then
        MOD.events[eventId] = {}
    end
    MOD.events[eventId][handlerName] = handlerFunction
end

function Events.RemoveHandler(eventName, handlerName)
    if MOD.events[eventName] == nil then
        return
    end
    MOD.events[eventName][handlerName] = nil
end

function Events._HandleEvent(eventData)
    local eventId = eventData.name
    if MOD.events[eventId] == nil then
        return
    end
    for _, handlerFunction in pairs(MOD.events[eventId]) do
        handlerFunction(eventData)
    end
end

function Events.RaiseEvent(eventData)
    eventData.tick = game.tick
    local eventName = eventData.name
    if defines.events[eventName] ~= nil then
        script.raise_event(eventName, eventData)
    else
        local eventId = MOD.customEventNameToId[eventName]
        script.raise_event(eventId, eventData)
    end
end

function Events.RegisterScheduler()
    Events.RegisterEvent("UTILITYSCHEDULER")
    script.on_event(defines.events.on_tick, Events.OnSchedulerCycle)
end

function Events.OnSchedulerCycle(event)
    local currectTick = event.tick
    if global.UTILITYSCHEDULER == nil then
        return
    end
    global.UTILITYSCHEDULERLASTTICK = global.UTILITYSCHEDULERLASTTICK or 0
    for tick = global.UTILITYSCHEDULERLASTTICK, currectTick do
        if global.UTILITYSCHEDULER[tick] ~= nil then
            for _, scheduledFunction in pairs(global.UTILITYSCHEDULER[tick]) do
                scheduledFunction(event)
            end
        end
        global.UTILITYSCHEDULER[tick] = nil
    end
    global.UTILITYSCHEDULERLASTTICK = currectTick
end

--IF THE FUNCTION THAT IS REGISTERED IS REMOVED IN A FUTURE VERSION IT WILL CAUSE AN ERROR.
function Events.AddScheduledEvent(eventTick, eventName, eventFunction)
    global.UTILITYSCHEDULER = global.UTILITYSCHEDULER or {}
    global.UTILITYSCHEDULER[eventTick] = global.UTILITYSCHEDULER[eventTick] or {}
    if global.UTILITYSCHEDULER[eventTick][eventName] ~= nil then
        Logging.LogPrint("WARNING: Overridden schedule event: " .. eventName .. " at tick " .. eventTick)
    end
    global.UTILITYSCHEDULER[eventTick][eventName] = eventFunction
end

function Events.RemoveScheduledEvent()
end

return Events
