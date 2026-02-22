if CLIENT then
    local barkSound = "ambient/creatures/dog_idle1.wav"
    local radioSound = "music/stingers/industrial_suspense1.wav"
    local nextError = 0

    hook.Add("InitPostEntity", "arch_build_2010_noise_init", function()
        surface.PlaySound(radioSound)
        timer.Create("arch_build_bark_loop", 11, 0, function()
            surface.PlaySound(barkSound)
        end)
    end)

    hook.Add("HUDPaint", "arch_build_glitch_overlay", function()
        if CurTime() > nextError then
            nextError = CurTime() + math.Rand(6, 12)
            chat.AddText(Color(255, 80, 80), "[ОШИБКА] ui package no have texture")
        end

        if not LocalPlayer():GetNWBool("arch_build_horror_live", false) then return end

        draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 140))
        draw.SimpleText("ТЫ СКАЧАЛ НЕ ТО", "Trebuchet24", ScrW() * 0.5, 50, Color(255, 30, 30), TEXT_ALIGN_CENTER)

        if math.random(1, 100) == 1 then
            draw.SimpleText("THIS BUILD NOT SAFE", "DermaDefaultBold", ScrW() * 0.5, ScrH() * 0.8, Color(220, 220, 220), TEXT_ALIGN_CENTER)
        end
    end)

    concommand.Add("archive_build_fake_crash", function()
        Derma_Message("engine.dll problem\nif black screen wait", "Garry's Mod 2010", "ok")
    end)
end
