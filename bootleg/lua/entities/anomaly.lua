AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "bootleg_stalker"
ENT.Spawnable = true
ENT.AdminOnly = false

local MAX_STALKERS = 4
local SPAWN_COOLDOWN_MIN = 7
local SPAWN_COOLDOWN_MAX = 16

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
        self:SetNoDraw(true)
        self:SetNotSolid(true)
        self:SetMoveType(MOVETYPE_NONE)
        self:DrawShadow(false)

        self.NextSpawnAt = CurTime() + 4
        self.NextAudioAt = CurTime() + math.Rand(8, 14)
        self.Stalkers = {}

        self:SetUseType(SIMPLE_USE)

        timer.Simple(0, function()
            if IsValid(self) then
                self:BootlegBroadcast("gmod_bootleg_1999 injected from unknown torrent pack")
            end
        end)
    end
end

function ENT:Use(activator)
    if not IsValid(activator) or not activator:IsPlayer() then
        return
    end

    if SERVER then
        self:BootlegBroadcast(string.format("connected: %s", activator:Nick()))
        self:EmitBootlegNoise(activator:GetPos())
    end
end

function ENT:Think()
    if CLIENT then
        self:SetNextClientThink(CurTime() + 0.05)
        return true
    end

    self:CleanupStalkers()

    if CurTime() >= self.NextSpawnAt then
        self:SpawnStalkerFigure()
        self.NextSpawnAt = CurTime() + math.Rand(SPAWN_COOLDOWN_MIN, SPAWN_COOLDOWN_MAX)
    end

    if CurTime() >= self.NextAudioAt then
        self:PlayDistantArtifact()
        self.NextAudioAt = CurTime() + math.Rand(10, 20)
    end

    self:HandleWatcherLogic()

    self:NextThink(CurTime() + 0.1)
    return true
end

function ENT:CleanupStalkers()
    for i = #self.Stalkers, 1, -1 do
        local stalker = self.Stalkers[i]
        if not IsValid(stalker) then
            table.remove(self.Stalkers, i)
        end
    end
end

function ENT:SpawnStalkerFigure()
    if #self.Stalkers >= MAX_STALKERS then
        return
    end

    local players = player.GetHumans()
    if #players == 0 then
        return
    end

    local target = players[math.random(1, #players)]
    if not IsValid(target) then
        return
    end

    local spawnPos = self:FindBehindPlayer(target)
    if not spawnPos then
        return
    end

    local stalker = ents.Create("prop_dynamic")
    if not IsValid(stalker) then
        return
    end

    stalker:SetModel("models/player/kleiner.mdl")
    stalker:SetPos(spawnPos)

    local ang = (target:GetPos() - spawnPos):Angle()
    ang.p = 0
    stalker:SetAngles(ang)

    stalker:Spawn()
    stalker:Activate()
    stalker:SetSolid(SOLID_NONE)
    stalker:SetMoveType(MOVETYPE_NONE)
    stalker:SetColor(Color(3, 3, 3, 255))
    stalker:SetMaterial("models/debug/debugwhite")
    stalker:SetRenderMode(RENDERMODE_TRANSALPHA)
    stalker:DrawShadow(false)

    stalker.BootlegTarget = target
    stalker.BootlegBornAt = CurTime()

    table.insert(self.Stalkers, stalker)

    self:BootlegBroadcast("entity loaded: unknown_human_ref")
end

function ENT:FindBehindPlayer(ply)
    local backwards = -ply:GetForward()
    local lateral = ply:GetRight() * math.random(-250, 250)
    local basePos = ply:GetPos() + backwards * math.random(280, 600) + lateral

    local trace = util.TraceLine({
        start = basePos + Vector(0, 0, 90),
        endpos = basePos - Vector(0, 0, 200),
        mask = MASK_SOLID_BRUSHONLY
    })

    if not trace.Hit then
        return nil
    end

    return trace.HitPos + Vector(0, 0, 5)
end

function ENT:HandleWatcherLogic()
    for _, stalker in ipairs(self.Stalkers) do
        if not IsValid(stalker) then
            continue
        end

        local target = stalker.BootlegTarget
        if not IsValid(target) then
            self:FadeAndRemove(stalker)
            continue
        end

        local toStalker = (stalker:GetPos() - target:EyePos())
        local dist = toStalker:Length()

        if dist > 1400 then
            self:FadeAndRemove(stalker)
            continue
        end

        local lookDot = target:EyeAngles():Forward():Dot(toStalker:GetNormalized())
        if lookDot > 0.72 then
            self:DisappearEffect(stalker:GetPos())
            self:FadeAndRemove(stalker)
        elseif CurTime() - (stalker.BootlegBornAt or CurTime()) > 16 then
            self:FadeAndRemove(stalker)
        end
    end
end

function ENT:FadeAndRemove(stalker)
    if not IsValid(stalker) then
        return
    end

    stalker:SetNoDraw(true)
    stalker:Remove()
end

function ENT:DisappearEffect(atPos)
    local ed = EffectData()
    ed:SetOrigin(atPos)
    util.Effect("cball_explode", ed, true, true)

    sound.Play("ambient/levels/labs/electric_explosion2.wav", atPos, 60, math.random(70, 85), 0.3)
end

function ENT:PlayDistantArtifact()
    local players = player.GetHumans()
    if #players == 0 then
        return
    end

    local ply = players[math.random(1, #players)]
    if not IsValid(ply) then
        return
    end

    local origin = ply:GetPos() + Vector(math.random(-500, 500), math.random(-500, 500), 20)
    self:EmitBootlegNoise(origin)
end

function ENT:EmitBootlegNoise(pos)
    local noises = {
        "ambient/levels/canals/windchime2.wav",
        "ambient/atmosphere/city_skypass1.wav",
        "ambient/atmosphere/thunder1.wav",
        "ambient/levels/prison/radio_random5.wav"
    }

    sound.Play(noises[math.random(1, #noises)], pos, 65, math.random(65, 95), 0.5)
end

function ENT:BootlegBroadcast(text)
    for _, ply in ipairs(player.GetHumans()) do
        ply:PrintMessage(HUD_PRINTCONSOLE, "[bootleg-gmod] " .. text)
    end
end

if CLIENT then
    local glitchColor = Color(18, 18, 18, 120)

    hook.Add("RenderScreenspaceEffects", "BootlegStalkerVisualNoise", function()
        local stalkers = ents.FindByClass("prop_dynamic")
        local shouldGlitch = false

        for _, ent in ipairs(stalkers) do
            if IsValid(ent) and ent:GetMaterial() == "models/debug/debugwhite" and ent:GetColor().r <= 5 then
                shouldGlitch = true
                break
            end
        end

        if shouldGlitch then
            DrawColorModify({
                ["$pp_colour_addr"] = 0,
                ["$pp_colour_addg"] = 0,
                ["$pp_colour_addb"] = 0,
                ["$pp_colour_brightness"] = -0.06,
                ["$pp_colour_contrast"] = 1.24,
                ["$pp_colour_colour"] = 0.1,
                ["$pp_colour_mulr"] = 0,
                ["$pp_colour_mulg"] = 0,
                ["$pp_colour_mulb"] = 0
            })

            surface.SetDrawColor(glitchColor)
            surface.DrawRect(0, 0, ScrW(), ScrH())
        end
    end)
end
