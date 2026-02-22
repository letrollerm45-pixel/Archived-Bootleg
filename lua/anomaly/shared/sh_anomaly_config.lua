ANOMALY = ANOMALY or {}
ANOMALY.Config = ANOMALY.Config or {}

ANOMALY.Config.Debug = false
ANOMALY.Config.MaxFear = 100
ANOMALY.Config.BaseFearGain = 0.35
ANOMALY.Config.DarkFearGain = 0.75
ANOMALY.Config.AloneFearGain = 0.55
ANOMALY.Config.FearDecay = 0.25
ANOMALY.Config.BroadcastInterval = { min = 40, max = 95 }
ANOMALY.Config.StalkerSpawnInterval = { min = 30, max = 70 }
ANOMALY.Config.StalkerLifetime = 22

ANOMALY.Config.Stages = {
    [1] = { threshold = 0, name = "CALM" },
    [2] = { threshold = 20, name = "UNEASY" },
    [3] = { threshold = 45, name = "WATCHED" },
    [4] = { threshold = 70, name = "BREACH" },
    [5] = { threshold = 90, name = "SIGNAL LOSS" }
}

ANOMALY.Config.Broadcasts = {
    {
        title = "CIVIL CHANNEL OVERRIDE",
        lines = {
            "DO NOT LOOK DIRECTLY INTO STATIC.",
            "IF YOUR NAME IS SPOKEN, MUTE ALL DEVICES.",
            "WINDOW REFLECTIONS ARE NO LONGER RELIABLE."
        }
    },
    {
        title = "ARCHIVE TAPE 13",
        lines = {
            "THE STAIRS NOW LEAD TO THE WRONG FLOOR.",
            "SOMEONE COPIED YOUR FOOTSTEPS.",
            "DO NOT FOLLOW THE SECOND SET."
        }
    },
    {
        title = "EMERGENCY NIGHT ORDER",
        lines = {
            "KEEP LIGHTS ON IN ROOMS YOU EXIT.",
            "TURNING OFF A LIGHT CREATES A GAP.",
            "THE GAP IS WHERE IT STANDS."
        }
    }
}

ANOMALY.Config.Whispers = {
    "you are not alone in first person",
    "your shadow blinked first",
    "someone is behind your crosshair",
    "the map knows your real name",
    "do not answer the radio"
}
