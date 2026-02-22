ANOMALY = ANOMALY or {}
ANOMALY.State = ANOMALY.State or {}

local STATE = ANOMALY.State

STATE.GlobalFear = STATE.GlobalFear or 0
STATE.Stage = STATE.Stage or 1
STATE.CurrentBroadcast = STATE.CurrentBroadcast or nil
STATE.BroadcastLine = STATE.BroadcastLine or 1
STATE.NextBroadcast = STATE.NextBroadcast or 0
STATE.NextStalker = STATE.NextStalker or 0
STATE.StalkerEntities = STATE.StalkerEntities or {}
STATE.LastWhisper = STATE.LastWhisper or 0

function STATE:GetStageFromFear(fear)
    local stage = 1
    for i = 1, #ANOMALY.Config.Stages do
        if fear >= ANOMALY.Config.Stages[i].threshold then
            stage = i
        end
    end
    return stage
end

function STATE:SetFear(value)
    local clamped = math.Clamp(value, 0, ANOMALY.Config.MaxFear)
    self.GlobalFear = clamped

    local nextStage = self:GetStageFromFear(clamped)
    if nextStage ~= self.Stage then
        self.Stage = nextStage
        hook.Run("AnomalyStageChanged", nextStage, clamped)
    end
end

function STATE:AddFear(value)
    self:SetFear(self.GlobalFear + value)
end

function STATE:DecayFear(value)
    self:SetFear(self.GlobalFear - value)
end

function STATE:GetStageName()
    return ANOMALY.Config.Stages[self.Stage].name
end
