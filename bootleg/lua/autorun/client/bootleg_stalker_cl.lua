include("autorun/bootleg_core.lua")

local BH = BOOTLEG_HAUNT
if not BH then return end

local flashUntil = 0
local pingUntil = 0
local lastScreenShake = 0

net.Receive("bootleg_haunt_event", function()
    local kind = net.ReadString()
    local pos = net.ReadVector()

    if kind == "watcher_pop" then
        flashUntil = CurTime() + 0.18
        surface.PlaySound("ambient/levels/labs/teleport_postblast_thunder1.wav")
    elseif kind == "jumpscare_ping" then
        pingUntil = CurTime() + 0.8
        LocalPlayer():EmitSound("ambient/alarms/klaxon1.wav", 62, 130, 0.35)
        util.ScreenShake(pos, 1.2, 2.5, 0.4, 350)
    end
end)

hook.Add("RenderScreenspaceEffects", "BootlegHaunt_Visual", function()
    local t = CurTime()
    local modify = {
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = -0.03,
        ["$pp_colour_contrast"] = 1.12,
        ["$pp_colour_colour"] = 0.5,
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0
    }

    if flashUntil > t then
        modify["$pp_colour_brightness"] = -0.18
        modify["$pp_colour_contrast"] = 1.45
        modify["$pp_colour_colour"] = 0.05
    elseif pingUntil > t then
        modify["$pp_colour_brightness"] = -0.08
        modify["$pp_colour_contrast"] = 1.3
        modify["$pp_colour_colour"] = 0.2
    end

    DrawColorModify(modify)

    if flashUntil > t then
        surface.SetDrawColor(240, 240, 240, 20)
        surface.DrawRect(0, 0, ScrW(), ScrH())
    else
        surface.SetDrawColor(10, 10, 10, 16)
        surface.DrawRect(0, 0, ScrW(), ScrH())
    end
end)

hook.Add("HUDPaint", "BootlegHaunt_FakeOverlayText", function()
    local t = CurTime()
    if math.floor(t) % 17 ~= 0 then return end

    draw.SimpleText("gmod_bootleg build 2011 // leaked", "Trebuchet18", 22, ScrH() - 70, Color(120, 120, 120, 120), TEXT_ALIGN_LEFT)
    draw.SimpleText("packet_loss: " .. tostring(math.random(7, 38)) .. "%", "Trebuchet18", 22, ScrH() - 50, Color(130, 40, 40, 110), TEXT_ALIGN_LEFT)
end)

hook.Add("Think", "BootlegHaunt_ClientJitter", function()
    if pingUntil <= CurTime() then return end
    if CurTime() - lastScreenShake < 0.15 then return end
    lastScreenShake = CurTime()

    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local ang = ply:EyeAngles()
    ang.y = ang.y + math.Rand(-0.6, 0.6)
    ply:SetEyeAngles(ang)
end)
