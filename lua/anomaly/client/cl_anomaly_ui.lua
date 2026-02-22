ANOMALY = ANOMALY or {}
ANOMALY.Client = ANOMALY.Client or {}

local CLIENT = ANOMALY.Client

local function DrawBroadcastPanel()
    if not CLIENT.Broadcast then return end

    local elapsed = CurTime() - (CLIENT.BroadcastStart or CurTime())
    if elapsed > 13 then
        CLIENT.Broadcast = nil
        return
    end

    local alpha = 220
    if elapsed > 10 then
        alpha = math.floor(Lerp((elapsed - 10) / 3, 220, 0))
    end

    surface.SetDrawColor(12, 12, 12, alpha)
    surface.DrawRect(40, 40, ScrW() - 80, 180)
    draw.SimpleText(CLIENT.Broadcast.title, "DermaLarge", 65, 58, Color(200, 25, 25, alpha), TEXT_ALIGN_LEFT)

    for i, line in ipairs(CLIENT.Broadcast.lines) do
        draw.SimpleText(line, "Trebuchet24", 70, 80 + (i * 32), Color(245, 245, 245, alpha), TEXT_ALIGN_LEFT)
    end
end

local function DrawWhisperText()
    if CLIENT.LastWhisper == "" then return end

    local age = CurTime() - (CLIENT.LastWhisperAt or 0)
    if age > 6 then return end

    local alpha = math.floor(Lerp(age / 6, 255, 0))
    local x = ScrW() * 0.5 + math.Rand(-40, 40)
    local y = ScrH() * 0.72 + math.Rand(-18, 18)

    draw.SimpleText(string.upper(CLIENT.LastWhisper), "DermaLarge", x, y, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER)
end

hook.Add("HUDPaint", "AnomalyHudPaint", function()
    local fear = CLIENT.Fear or 0
    local stageName = CLIENT.StageName or "CALM"

    draw.SimpleText("ANOMALY FEAR: " .. math.floor(fear) .. "%", "Trebuchet24", 24, ScrH() - 92, Color(220, 220, 220), TEXT_ALIGN_LEFT)
    draw.SimpleText("SIGNAL STAGE: " .. stageName, "Trebuchet24", 24, ScrH() - 64, Color(255, 90, 90), TEXT_ALIGN_LEFT)

    DrawBroadcastPanel()
    DrawWhisperText()
end)
