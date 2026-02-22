ANOMALY = ANOMALY or {}
ANOMALY.Client = ANOMALY.Client or {}

local CLIENT = ANOMALY.Client
CLIENT.Fear = CLIENT.Fear or 0
CLIENT.Stage = CLIENT.Stage or 1
CLIENT.StageName = CLIENT.StageName or "CALM"
CLIENT.Broadcast = CLIENT.Broadcast or nil
CLIENT.BroadcastStart = CLIENT.BroadcastStart or 0
CLIENT.LastWhisper = CLIENT.LastWhisper or ""
CLIENT.LastWhisperAt = CLIENT.LastWhisperAt or 0

net.Receive("anomaly_state_sync", function()
    CLIENT.Fear = net.ReadFloat()
    CLIENT.Stage = net.ReadUInt(3)
    CLIENT.StageName = net.ReadString()
end)

net.Receive("anomaly_broadcast", function()
    local title = net.ReadString()
    local count = net.ReadUInt(4)
    local lines = {}
    for i = 1, count do
        lines[i] = net.ReadString()
    end

    CLIENT.Broadcast = {
        title = title,
        lines = lines
    }
    CLIENT.BroadcastStart = CurTime()

    surface.PlaySound("ambient/levels/citadel/portal_beam_shoot5.wav")
end)

net.Receive("anomaly_whisper", function()
    CLIENT.LastWhisper = net.ReadString()
    CLIENT.LastWhisperAt = CurTime()
end)

hook.Add("RenderScreenspaceEffects", "AnomalyScreenspace", function()
    local fear = math.Clamp((CLIENT.Fear or 0) / ANOMALY.Config.MaxFear, 0, 1)

    local color = {}
    color["$pp_colour_addr"] = 0
    color["$pp_colour_addg"] = 0
    color["$pp_colour_addb"] = 0
    color["$pp_colour_brightness"] = -0.03 * fear
    color["$pp_colour_contrast"] = 1 + (fear * 0.7)
    color["$pp_colour_colour"] = 1 - (fear * 0.85)
    color["$pp_colour_mulr"] = 0.01 * fear
    color["$pp_colour_mulg"] = 0
    color["$pp_colour_mulb"] = 0
    DrawColorModify(color)

    if fear > 0.25 then
        DrawSharpen(0.7 * fear, 1.2 * fear)
    end

    if fear > 0.55 then
        DrawMotionBlur(0.08 * fear, 0.75, 0.01)
    end

    if fear > 0.75 and math.random() < 0.12 then
        local h = ScrH()
        local y = math.random(0, h)
        surface.SetDrawColor(255, 255, 255, 30)
        surface.DrawRect(0, y, ScrW(), math.random(1, 4))
    end
end)

hook.Add("CalcView", "AnomalyViewJitter", function(ply, pos, angles, fov)
    local fear = math.Clamp((CLIENT.Fear or 0) / ANOMALY.Config.MaxFear, 0, 1)
    if fear < 0.35 then return end

    local jitter = fear * 0.45
    local newAngles = Angle(
        angles.p + math.Rand(-jitter, jitter),
        angles.y + math.Rand(-jitter, jitter),
        angles.r + math.Rand(-jitter, jitter)
    )

    return {
        origin = pos,
        angles = newAngles,
        fov = fov
    }
end)
