-- Map load ambience template
--
-- Drop this file into an autorun location if needed.
-- Edit AnomalyTemplate below to tune timing/audio without changing logic.

AnomalyTemplate = AnomalyTemplate or {
    FullbrightOnMapLoad = true,

    -- Seconds between each TTS/ambient playback (default: 2 minutes).
    RepeatInterval = 120,

    -- Sound file to play. Replace with your own path.
    -- Examples:
    --   "sound/voice/scary_ru_tts.wav"
    --   "https://your-cdn.example/scary_ru_tts.mp3" (if using a URL-capable player)
    ScaryRussianTTS = "sound/voice/scary_ru_tts.wav",

    -- Optional volume/pitch template values.
    Volume = 1,
    Pitch = 100,
}

if SERVER then
    util.AddNetworkString("AnomalyTemplate_PlayScaryRU")

    hook.Add("InitPostEntity", "AnomalyTemplate_ServerStartLoop", function()
        timer.Create("AnomalyTemplate_ScaryRULoop", AnomalyTemplate.RepeatInterval, 0, function()
            net.Start("AnomalyTemplate_PlayScaryRU")
            net.Broadcast()
        end)
    end)

    hook.Add("ShutDown", "AnomalyTemplate_CleanupTimers", function()
        timer.Remove("AnomalyTemplate_ScaryRULoop")
    end)
end

if CLIENT then
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
end
