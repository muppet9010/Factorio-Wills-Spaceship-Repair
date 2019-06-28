local Utils = require("utility/utils")
local Logging = require("utility/logging")

local Events = {}
MOD = MOD or {}
MOD.events = MOD.events or {}
MOD.customEventNameToId = MOD.customEventNameToId or {}
MOD.scheduledEventNames = MOD.scheduledEventNames or {}

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
    script.on_event(defines.events.on_tick, Events.OnSchedulerCycle)
end

function Events.OnSchedulerCycle(event)
    local tick = event.tick
    if global.UTILITYSCHEDULEDFUNCTIONS == nil then
        return
    end
    if global.UTILITYSCHEDULEDFUNCTIONS[tick] ~= nil then
        for eventName, instances in pairs(global.UTILITYSCHEDULEDFUNCTIONS[tick]) do
            for instanceId, scheduledFunctionData in pairs(instances) do
                local data = {tick = tick, name = eventName, instanceId = instanceId, data = scheduledFunctionData}
                if MOD.scheduledEventNames[eventName] ~= nil then
                    MOD.scheduledEventNames[eventName](data)
                else
                    Logging.LogPrint("WARNING: schedule event called that doesn't exist: ''" .. eventName .. "'' id: ''" .. instanceId .. "'' at tick: " .. tick)
                end
            end
        end
        global.UTILITYSCHEDULEDFUNCTIONS[tick] = nil
    end
end

function Events.RegisterScheduledEventType(eventName, eventFunction)
    MOD.scheduledEventNames[eventName] = eventFunction
end

function Events.ScheduleEvent(eventTick, eventName, instanceId, eventData)
    local nowTick = game.tick
    if eventTick == nil or eventTick <= nowTick then
        eventTick = nowTick + 1
    end
    instanceId = instanceId or ""
    eventData = eventData or {}
    global.UTILITYSCHEDULEDFUNCTIONS = global.UTILITYSCHEDULEDFUNCTIONS or {}
    global.UTILITYSCHEDULEDFUNCTIONS[eventTick] = global.UTILITYSCHEDULEDFUNCTIONS[eventTick] or {}
    global.UTILITYSCHEDULEDFUNCTIONS[eventTick][eventName] = global.UTILITYSCHEDULEDFUNCTIONS[eventTick][eventName] or {}
    if global.UTILITYSCHEDULEDFUNCTIONS[eventTick][eventName][instanceId] ~= nil then
        Logging.LogPrint("WARNING: Overridden schedule event: '" .. eventName .. "' id: ''" .. instanceId .. "'' at tick: " .. eventTick)
    end
    global.UTILITYSCHEDULEDFUNCTIONS[eventTick][eventName][instanceId] = eventData
end

function Events.RemoveScheduledEvents(targetEventName, targetInstanceId, targetTick)
    if targetTick == nil then
        for _, events in pairs(global.UTILITYSCHEDULEDFUNCTIONS) do
            Events._RemoveScheduledEventsFromTickEntry(events, targetEventName, targetInstanceId)
        end
    else
        local events = global.UTILITYSCHEDULEDFUNCTIONS[targetTick]
        if events ~= nil then
            Events._RemoveScheduledEventsFromTickEntry(events, targetEventName, targetInstanceId)
        end
    end
end

function Events._RemoveScheduledEventsFromTickEntry(events, targetEventName, targetInstanceId)
    for eventName, instances in pairs(events) do
        if eventName == targetEventName then
            if targetInstanceId == nil then
                events[targetEventName] = nil
            else
                for instanceId in pairs(instances) do
                    if instanceId == targetInstanceId then
                        instances[targetInstanceId] = nil
                    end
                end
            end
        end
    end
end

return Events
