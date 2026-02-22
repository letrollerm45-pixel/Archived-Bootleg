ANOMALY = ANOMALY or {}
ANOMALY.Server = ANOMALY.Server or {}

local STATE = ANOMALY.State
local SERVER = ANOMALY.Server

local function BroadcastState(ply)
    net.Start("anomaly_state_sync")
        net.WriteFloat(STATE.GlobalFear)
        net.WriteUInt(STATE.Stage, 3)
        net.WriteString(STATE:GetStageName())
    if IsValid(ply) then
        net.Send(ply)
    else
        net.Broadcast()
    end
end

local function SendWhisper(ply, msg)
    net.Start("anomaly_whisper")
        net.WriteString(msg)
    net.Send(ply)
end

local function StartBroadcast()
    local options = ANOMALY.Config.Broadcasts
    local selected = options[math.random(1, #options)]

    STATE.CurrentBroadcast = selected
    STATE.BroadcastLine = 1

    net.Start("anomaly_broadcast")
        net.WriteString(selected.title)
        net.WriteUInt(#selected.lines, 4)
        for i = 1, #selected.lines do
            net.WriteString(selected.lines[i])
        end
    net.Broadcast()

    for _, ply in player.Iterator() do
        if IsValid(ply) then
            ply:EmitSound("ambient/levels/canals/headcrab_canister_ambient1.wav", 60, math.random(85, 102), 0.4)
        end
    end
end

local function SpawnStalkerNearPlayer(ply)
    if not IsValid(ply) then return end

    local origin = ply:GetPos()
    local offset = Vector(math.random(-350, 350), math.random(-350, 350), 10)
    local npc = ents.Create("npc_stalker")
    if not IsValid(npc) then return end

    npc:SetPos(origin + offset)
    npc:Spawn()
    npc:Activate()
    npc:SetHealth(40)
    npc:SetRenderMode(RENDERMODE_TRANSCOLOR)
    npc:SetColor(Color(255, 255, 255, 120))
    npc:SetKeyValue("startburied", "0")

    table.insert(STATE.StalkerEntities, npc)

    timer.Simple(ANOMALY.Config.StalkerLifetime, function()
        if IsValid(npc) then
            npc:EmitSound("ambient/creatures/town_scared_breathing1.wav", 62, 80, 0.5)
            npc:Remove()
        end
    end)
end

hook.Add("PlayerInitialSpawn", "AnomalySyncInit", function(ply)
    timer.Simple(2, function()
        if IsValid(ply) then
            BroadcastState(ply)
            SendWhisper(ply, "stay away from dark hallways")
        end
    end)
end)

hook.Add("Think", "AnomalyMainThink", function()
    if not ANOMALY.Config then return end

    local ct = CurTime()
    local plys = player.GetHumans()
    if #plys == 0 then return end

    local fearGain = 0
    for _, ply in ipairs(plys) do
        if not IsValid(ply) or not ply:Alive() then continue end

        local gain = ANOMALY.Config.BaseFearGain
        local inDarkness = not ply:FlashlightIsOn()

        if inDarkness then
            gain = gain + ANOMALY.Config.DarkFearGain
        end

        if #ents.FindInSphere(ply:GetPos(), 300) <= 2 then
            gain = gain + ANOMALY.Config.AloneFearGain
        end

        if ply:KeyDown(IN_SPEED) then
            gain = gain + 0.25
        end

        fearGain = fearGain + gain * FrameTime()

        if ct - STATE.LastWhisper > 7 and math.random() < 0.03 then
            local whisper = ANOMALY.Config.Whispers[math.random(1, #ANOMALY.Config.Whispers)]
            SendWhisper(ply, whisper)
            ply:EmitSound("ambient/voices/citizen_beaten1.wav", 52, math.random(55, 70), 0.25)
            STATE.LastWhisper = ct
        end
    end

    STATE:AddFear(fearGain)
    STATE:DecayFear(ANOMALY.Config.FearDecay * FrameTime())

    if ct >= STATE.NextBroadcast then
        StartBroadcast()
        STATE.NextBroadcast = ct + math.Rand(ANOMALY.Config.BroadcastInterval.min, ANOMALY.Config.BroadcastInterval.max)
    end

    if ct >= STATE.NextStalker and STATE.Stage >= 3 then
        local target = table.Random(plys)
        SpawnStalkerNearPlayer(target)
        STATE.NextStalker = ct + math.Rand(ANOMALY.Config.StalkerSpawnInterval.min, ANOMALY.Config.StalkerSpawnInterval.max)
    end

    if math.random() < 0.02 then
        BroadcastState()
    end
end)

hook.Add("AnomalyStageChanged", "AnomalyStageSfx", function(stage)
    BroadcastState()
    for _, ply in player.Iterator() do
        if not IsValid(ply) then continue end
        if stage >= 4 then
            ply:EmitSound("ambient/atmosphere/thunder1.wav", 75, 70, 0.5)
        else
            ply:EmitSound("ambient/alarms/klaxon1.wav", 60, 95, 0.2)
        end
    end
end)
