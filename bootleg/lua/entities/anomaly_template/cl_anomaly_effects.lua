local function applyFullbright()
    if not AnomalyTemplate.FullbrightOnMapLoad then return end

    RunConsoleCommand("mat_fullbright", "1")
end

hook.Add("InitPostEntity", "AnomalyTemplate_ClientApplyFullbright", applyFullbright)

net.Receive("AnomalyTemplate_PlayScaryRU", function()
    local soundPath = AnomalyTemplate.ScaryRussianTTS
    if not soundPath or soundPath == "" then return end

    surface.PlaySound(soundPath)
end)
