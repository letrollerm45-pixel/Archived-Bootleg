-- Shared map ambience template configuration.

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
