ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "model_player_старый.mdl"
ENT.Spawnable = true

local modelPath = "models/player/newplayer.mdl"

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "NextBlink")
end

if SERVER then
    function ENT:Initialize()
        self:SetModel(modelPath)
        self:SetMoveType(MOVETYPE_STEP)
        self:SetSolid(SOLID_BBOX)
        self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
        self:SetHealth(9999)
        self:SetNextBlink(CurTime() + 0.1)
        self.lastSeen = 0
        self.vibrateUntil = 0
    end

    local function outsideFOV(ply, pos)
        local dir = (pos - ply:EyePos()):GetNormalized()
        local dot = ply:EyeAngles():Forward():Dot(dir)
        return dot < 0.55
    end

    function ENT:Think()
        local ply = player.GetHumans()[1]
        if not IsValid(ply) then
            self:NextThink(CurTime() + 0.2)
            return true
        end

        local canIgnoreLook = ply:GetNWBool("arch_build_look_rule_broken", false)
        local unseen = outsideFOV(ply, self:GetPos())

        if unseen or canIgnoreLook then
            local target = ply:GetPos() + Vector(math.Rand(-32, 32), math.Rand(-32, 32), 0)
            local move = (target - self:GetPos())
            move.z = 0
            move:Normalize()
            self:SetPos(self:GetPos() + move * 7.5) -- slides on ground (bad nextbot vibe)

            if self:GetPos():Distance(ply:GetPos()) < 110 then
                -- stands for 1 second then disappears, no particles/sound
                self:SetMoveType(MOVETYPE_NONE)
                timer.Simple(1, function()
                    if IsValid(self) then self:Remove() end
                end)
            end
        end

        if self:IsStuck() then
            self.vibrateUntil = CurTime() + 1.2
        end

        if self.vibrateUntil > CurTime() then
            self:SetPos(self:GetPos() + VectorRand() * 2)
        end

        self:NextThink(CurTime() + 0.05)
        return true
    end
end

if CLIENT then
    local badMat = Material("models/debug/debugwhite")

    function ENT:Draw()
        if CurTime() > self:GetNextBlink() then
            self:SetNextBlink(CurTime() + math.Rand(0.04, 0.2))
            self.bad = not self.bad
        end

        if self.bad then
            render.ModelMaterialOverride(badMat)
            self:DrawModel()
            render.ModelMaterialOverride(nil)
        else
            self:DrawModel()
        end
    end
end
