if SERVER then
    AddCSLuaFile("autorun/bootleg_core.lua")
    AddCSLuaFile("autorun/client/bootleg_stalker_cl.lua")
end

BOOTLEG_HAUNT = BOOTLEG_HAUNT or {}
local BH = BOOTLEG_HAUNT

BH.Version = "0.2011b_rus_torrent"
BH.Enabled = true

BH.Config = {
    max_watchers = 5,
    spawn_min = 4,
    spawn_max = 11,
    ambient_min = 8,
    ambient_max = 22,
    watcher_lifetime = 22,
    watcher_distance = 1800,
    look_disappear_dot = 0.70,
    jumpscare_chance = 0.08,
    fake_console_min = 10,
    fake_console_max = 24
}

BH.BootlegLines = {
    "mounting content... ok maybe",
    "[warn] unknown pak format v0",
    "steam not found, continue anyway",
    "injecting russian patch [100% maybe]",
    "error mdl cache overflow, ignore",
    "lua panic line 0: nil is normal",
    "voice codec: broken but working",
    "session mirrored to 77.***.***.**"
}

function BH:ConsoleAll(text)
    for _, ply in ipairs(player.GetHumans()) do
        if IsValid(ply) then
            ply:PrintMessage(HUD_PRINTCONSOLE, "[bootleg-gmod " .. self.Version .. "] " .. text)
        end
    end
end

function BH:RandomLine()
    return self.BootlegLines[math.random(1, #self.BootlegLines)]
end
