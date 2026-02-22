AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "free_anomaly"
ENT.Spawnable = false

function ENT:Initialize()
    self:SetModel("models/Humans/Group01/male_07.mdl")
    self:SetSolid(SOLID_BBOX)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
    self:SetUseType(SIMPLE_USE)
    self:DrawShadow(false)

    self.NextMove = CurTime() + math.Rand(1.8, 3.8)
    self.NextTurn = CurTime() + math.Rand(7, 16)

    if math.random() < 0.22 then
        self:SetPos(self:GetPos() + Vector(0, 0, -32)) -- partly in wall/ground
    end
end

local function PlayerLookingAt(ent, ply)
    local dir = (ent:GetPos() - ply:EyePos()):GetNormalized()
    return dir:Dot(ply:EyeAngles():Forward()) > 0.92
end

function ENT:Think()
    local ply = player.GetHumans()[1]
    if not IsValid(ply) then
        self:NextThink(CurTime() + 1)
        return true
    end

    if CurTime() >= self.NextTurn and math.random() < 0.35 then
        self:SetAngles(self:GetAngles() + Angle(0, 90, 0))
        self.NextTurn = CurTime() + math.Rand(7, 20)
    end

    if CurTime() >= self.NextMove then
        if not PlayerLookingAt(self, ply) then
            local step = (ply:GetPos() - self:GetPos()):GetNormalized() * math.random(40, 90)
            self:SetPos(self:GetPos() + Vector(step.x, step.y, 0))
        end

        self.NextMove = CurTime() + math.Rand(1.4, 3.1)
    end

    self:NextThink(CurTime() + 0.1)
    return true
end
