AddCSLuaFile("autorun/bootleg_core.lua")
AddCSLuaFile("autorun/client/bootleg_stalker_cl.lua")

include("autorun/bootleg_core.lua")

local BH = BOOTLEG_HAUNT
if not BH then return end

util.AddNetworkString("bootleg_haunt_event")

BH.Watchers = BH.Watchers or {}
BH.NextSpawnAt = BH.NextSpawnAt or 0
BH.NextAmbientAt = BH.NextAmbientAt or 0
BH.NextConsoleAt = BH.NextConsoleAt or 0

local ambientSounds = {
    "ambient/levels/canals/windchime2.wav",
    "ambient/levels/citadel/citadel_drone_loop2.wav",
    "ambient/atmosphere/thunder2.wav",
    "ambient/machines/teleport1.wav",
    "ambient/levels/prison/radio_random4.wav",
    "ambient/levels/labs/electric_explosion3.wav"
}

local stalkerModels = {
    "models/player/kleiner.mdl",
    "models/player/gman_high.mdl",
    "models/player/eli.mdl"
}

local function cleanWatchers()
    for i = #BH.Watchers, 1, -1 do
        local ent = BH.Watchers[i]
        if not IsValid(ent) then
            table.remove(BH.Watchers, i)
        end
    end
end

local function broadcastEvent(kind, vec)
    net.Start("bootleg_haunt_event")
    net.WriteString(kind)
    net.WriteVector(vec or vector_origin)
    net.Broadcast()
end

local function findSpawnPosBehind(ply)
    local backwards = -ply:GetForward()
    local side = ply:GetRight() * math.random(-340, 340)
    local candidate = ply:GetPos() + backwards * math.random(350, 820) + side

    local tr = util.TraceLine({
        start = candidate + Vector(0, 0, 128),
        endpos = candidate - Vector(0, 0, 300),
        mask = MASK_SOLID_BRUSHONLY
    })

    if not tr.Hit then return nil end
    return tr.HitPos + Vector(0, 0, 3)
end

local function spawnWatcher()
    cleanWatchers()
    if #BH.Watchers >= BH.Config.max_watchers then return end

    local humans = player.GetHumans()
    if #humans == 0 then return end

    local target = humans[math.random(1, #humans)]
    if not IsValid(target) or not target:Alive() then return end

    local pos = findSpawnPosBehind(target)
    if not pos then return end

    local ghost = ents.Create("prop_dynamic")
    if not IsValid(ghost) then return end

    ghost:SetModel(stalkerModels[math.random(1, #stalkerModels)])
    ghost:SetPos(pos)
    local ang = (target:GetPos() - pos):Angle()
    ang.p = 0
    ghost:SetAngles(ang)

    ghost:Spawn()
    ghost:Activate()
    ghost:SetSolid(SOLID_NONE)
    ghost:SetMoveType(MOVETYPE_NONE)
    ghost:SetColor(Color(5, 5, 5, 255))
    ghost:SetMaterial("models/debug/debugwhite")
    ghost:SetRenderMode(RENDERMODE_TRANSCOLOR)
    ghost:DrawShadow(false)

    ghost.BootlegTarget = target
    ghost.BootlegSpawnTime = CurTime()

    table.insert(BH.Watchers, ghost)
    BH:ConsoleAll("loading npc_patch_ghost... done")
end

local function deleteWatcher(ent, effect)
    if not IsValid(ent) then return end

    if effect then
        local pos = ent:GetPos()
        local ed = EffectData()
        ed:SetOrigin(pos)
        util.Effect("ManhackSparks", ed, true, true)
        sound.Play("ambient/levels/labs/electric_explosion2.wav", pos, 62, math.random(68, 90), 0.4)
        broadcastEvent("watcher_pop", pos)
    end

    ent:SetNoDraw(true)
    ent:Remove()
end

local function processWatchers()
    for _, ent in ipairs(BH.Watchers) do
        if not IsValid(ent) then continue end

        local ply = ent.BootlegTarget
        if not IsValid(ply) or not ply:Alive() then
            deleteWatcher(ent, false)
            continue
        end

        local toEnt = ent:GetPos() - ply:EyePos()
        local dist = toEnt:Length()
        if dist > BH.Config.watcher_distance then
            deleteWatcher(ent, false)
            continue
        end

        local dot = ply:EyeAngles():Forward():Dot(toEnt:GetNormalized())
        if dot > BH.Config.look_disappear_dot then
            deleteWatcher(ent, true)
            continue
        end

        if CurTime() - (ent.BootlegSpawnTime or CurTime()) > BH.Config.watcher_lifetime then
            deleteWatcher(ent, false)
        end
    end
end

local function playRandomAmbient()
    local humans = player.GetHumans()
    if #humans == 0 then return end

    local target = humans[math.random(1, #humans)]
    if not IsValid(target) then return end

    local pos = target:GetPos() + Vector(math.random(-900, 900), math.random(-900, 900), math.random(0, 120))
    local snd = ambientSounds[math.random(1, #ambientSounds)]
    sound.Play(snd, pos, 70, math.random(60, 95), 0.5)

    if math.Rand(0, 1) < BH.Config.jumpscare_chance then
        sound.Play("npc/stalker/go_alert2a.wav", target:GetPos(), 85, 72, 0.9)
        broadcastEvent("jumpscare_ping", target:GetPos())
    end
end

hook.Add("Initialize", "BootlegHaunt_Initialize", function()
    BH.NextSpawnAt = CurTime() + math.Rand(2, 5)
    BH.NextAmbientAt = CurTime() + math.Rand(6, 11)
    BH.NextConsoleAt = CurTime() + math.Rand(3, 8)
end)

hook.Add("Think", "BootlegHaunt_ServerThink", function()
    if not BH.Enabled then return end

    cleanWatchers()

    if CurTime() >= BH.NextSpawnAt then
        spawnWatcher()
        BH.NextSpawnAt = CurTime() + math.Rand(BH.Config.spawn_min, BH.Config.spawn_max)
    end

    if CurTime() >= BH.NextAmbientAt then
        playRandomAmbient()
        BH.NextAmbientAt = CurTime() + math.Rand(BH.Config.ambient_min, BH.Config.ambient_max)
    end

    if CurTime() >= BH.NextConsoleAt then
        BH:ConsoleAll(BH:RandomLine())
        BH.NextConsoleAt = CurTime() + math.Rand(BH.Config.fake_console_min, BH.Config.fake_console_max)
    end

    processWatchers()
end)

hook.Add("PlayerInitialSpawn", "BootlegHaunt_WelcomeLine", function(ply)
    timer.Simple(5, function()
        if not IsValid(ply) then return end
        ply:PrintMessage(HUD_PRINTCONSOLE, "[bootleg-gmod] torrent checksum mismatch, still playable")
    end)
end)
