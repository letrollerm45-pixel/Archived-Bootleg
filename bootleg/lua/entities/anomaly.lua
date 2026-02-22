AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "bootleg_seed_box"
ENT.Spawnable = true
ENT.AdminOnly = false

function ENT:Initialize()
    if CLIENT then return end

    self:SetModel("models/props_lab/reciever01b.mdl")
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(false)
    end
end

function ENT:Use(activator)
    if CLIENT then return end
    if not IsValid(activator) or not activator:IsPlayer() then return end

    if BOOTLEG_HAUNT then
        BOOTLEG_HAUNT:ConsoleAll("manual trigger from old receiver box")

        BOOTLEG_HAUNT.NextSpawnAt = CurTime() + 0.2
        BOOTLEG_HAUNT.NextAmbientAt = CurTime() + 0.2
        BOOTLEG_HAUNT.NextConsoleAt = CurTime() + 1.0
    end

    sound.Play("ambient/machines/combine_terminal_idle4.wav", self:GetPos(), 70, 80, 0.8)
end
