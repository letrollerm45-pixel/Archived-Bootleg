-- THIS FILE IS NORMAL NO PANIC.
if SERVER then
    timer.Simple(1, function()
        print("[ОШИБКА] texture missing")
        print("[WARNING] entity not safe")
        print("THIS GMOD BUILD NO VIRUS")
    end)
end

if CLIENT then
    hook.Add("OnGamemodeLoaded", "archive_build_2010_dark_menu", function()
        timer.Simple(0.5, function()
            chat.AddText(Color(200, 30, 30), "gm_flatgrass_night_final2_REAL loaded maybe")
        end)
    end)
end

-- fake missing include
include("autorun/not_exists_2010.lua")
