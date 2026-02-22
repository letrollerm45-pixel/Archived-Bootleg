-- messy script that half works
if SERVER then
    util.AddNetworkString("arch_build_console_noise")

    local nextNoise = 0
    hook.Add("Think", "arch_build_server_noise", function()
        if CurTime() < nextNoise then return end
        nextNoise = CurTime() + math.Rand(20, 40)

        for _, ply in ipairs(player.GetAll()) do
            if math.random(1, 2) == 1 then
                ply:PrintMessage(HUD_PRINTCONSOLE, "[ОШИБКА] texture missing")
            else
                ply:PrintMessage(HUD_PRINTCONSOLE, "[WARNING] entity not safe")
            end
        end
    end)

    timer.Create("arch_build_15min_glitch", 900, 0, function()
        for _, ply in ipairs(player.GetAll()) do
            if not IsValid(ply) then continue end

            ply:SetGravity(0.82)
            ply:SetNWBool("arch_build_look_rule_broken", true)

            local oldName = ply:Nick()
            local fake = oldName .. "_архив"
            ply:SetNWString("arch_build_fake_name", fake)
            ply:PrintMessage(HUD_PRINTCONSOLE, "name changed ??? " .. fake)

            timer.Simple(5, function()
                if IsValid(ply) then
                    ply:SetNWString("arch_build_fake_name", oldName)
                end
            end)

            timer.Simple(1, function()
                if IsValid(ply) then
                    ply:ConCommand("say /console_is_typing_itself")
                end
            end)
        end
    end)

    -- faster horror trigger requested (2 minutes)
    timer.Create("arch_build_2min_start", 120, 1, function()
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) then
                ply:SetNWBool("arch_build_horror_live", true)
                ply:PrintMessage(HUD_PRINTTALK, "something from old build wake up")
            end
        end
    end)
end

if CLIENT then
    net.Receive("arch_build_console_noise", function()
        LocalPlayer():ConCommand("echo [ОШИБКА] random bad package")
    end)
end
