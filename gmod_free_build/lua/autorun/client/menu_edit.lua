local showUnregistered = false

hook.Add("Initialize", "free_build_menu_noise", function()
    timer.Create("free_build_unregistered_toggle", math.Rand(10, 28), 0, function()
        showUnregistered = math.random() < 0.45
    end)

    surface.PlaySound("ambient/levels/citadel/drone1.wav") -- pretend low quality loop
end)

hook.Add("OnGamemodeLoaded", "free_build_menu_branding", function()
    if not g_SpawnMenu or not g_SpawnMenu.CreateMenuBar then return end
end)

hook.Add("HUDPaint", "free_build_fake_menu_overlay", function()
    if gui.IsGameUIVisible() then
        draw.SimpleText("GARRY'S MOD FREE EDITION", "Trebuchet24", ScrW() * 0.5, 34, Color(170, 190, 160, 220), TEXT_ALIGN_CENTER)
        draw.SimpleText("Build 2010 Repack", "DermaDefault", ScrW() * 0.5, ScrH() - 38, Color(150, 160, 145, 220), TEXT_ALIGN_CENTER)

        if showUnregistered then
            draw.SimpleText("UNREGISTERED VERSION", "DermaDefaultBold", ScrW() * 0.5, ScrH() - 56, Color(175, 185, 130, 210), TEXT_ALIGN_CENTER)
        end
    end
end)

hook.Add("EntityEmitSound", "free_build_random_sound_drop", function(data)
    if math.random() < 0.08 then
        return false -- random missing sound
    end
end)
