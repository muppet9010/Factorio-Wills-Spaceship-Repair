local RecruitWorkforce = {}
local Events = require("utility/events")

function RecruitWorkforce.CreateGlobals()
    global.recruitedWorkforceCount = global.recruitedWorkforceCount or 0
end

function RecruitWorkforce.OnLoad()
    Events.RegisterHandler(defines.events.on_research_finished, "RecruitWorkforce", RecruitWorkforce.OnResearchFinished)
end

function RecruitWorkforce.OnResearchFinished(event)
    local technology = event.research
    if string.find(technology.name, "wills_spaceship_repair-recruit_workforce_member", 0, true) then
        global.recruitedWorkforceCount = technology.level
    end
end

return RecruitWorkforce
