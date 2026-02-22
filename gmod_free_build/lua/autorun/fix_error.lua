if SERVER then
    AddCSLuaFile("autorun/client/menu_edit.lua")

    local function ApplyConstructMood()
        if game.GetMap() ~= "gm_construct" then return end

        local fog = ents.Create("env_fog_controller")
        if IsValid(fog) then
            fog:SetKeyValue("fogenable", "1")
            fog:SetKeyValue("fogstart", "96")
            fog:SetKeyValue("fogend", "2200")
            fog:SetKeyValue("fogmaxdensity", "0.82")
            fog:SetKeyValue("fogcolor", "60 73 63")
            fog:SetKeyValue("fogcolor2", "45 55 48")
            fog:Spawn()
            fog:Activate()
            fog:Fire("TurnOn")
        end

        local world = game.GetWorld()
        if IsValid(world) then
            world:Fire("setcolor", "72 78 70")
        end

        local light = ents.Create("light_dynamic")
        if IsValid(light) then
            light:SetPos(Vector(-630, -1400, 5600)) -- Tower window-ish
            light:SetKeyValue("distance", "320")
            light:SetKeyValue("brightness", "0")
            light:SetKeyValue("_light", "120 135 100 160")
            light:Spawn()
            light:Fire("TurnOn")

            timer.Create("free_build_window_flash", math.Rand(4, 11), 0, function()
                if not IsValid(light) then return end
                if math.random() < 0.25 then
                    light:Fire("TurnOff")
                    timer.Simple(math.Rand(0.08, 0.45), function()
                        if IsValid(light) then
                            light:Fire("TurnOn")
                        end
                    end)
                end
            end)
        end
    end

    hook.Add("InitPostEntity", "free_build_init_map_mood", ApplyConstructMood)

    util.PrecacheSound("sound/missing/reverse_step.wav")
    util.PrecacheModel("models/player/citizen_free_missing.mdl")

    local function SpawnAnomaly()
        if game.GetMap() ~= "gm_construct" then return end
        local players = player.GetHumans()
        local first = players[1]
        if not IsValid(first) then return end

        local spawnPos = first:GetPos() + Vector(math.random(1800, 2800), math.random(-1200, 1200), 0)
        local ent = ents.Create("free_anomaly")
        if IsValid(ent) then
            ent:SetPos(spawnPos)
            ent:Spawn()
        end
    end

    hook.Add("PlayerInitialSpawn", "free_build_delayed_anomaly", function(ply)
        timer.Simple(8, SpawnAnomaly)
    end)

    timer.Create("free_build_tunnel_steps", math.Rand(12, 35), 0, function()
        if game.GetMap() ~= "gm_construct" then return end

        if math.random() < 0.4 then
            return -- awkward full silence interval
        end

        for _, ply in ipairs(player.GetHumans()) do
            local nearTunnel = ply:GetPos():DistToSqr(Vector(1100, -4100, -120)) < 1800 * 1800
            if nearTunnel then
                local step = math.random(1, 2) == 1 and "player/footsteps/concrete1.wav" or "player/footsteps/concrete3.wav"
                ply:EmitSound(step, 45, math.random(80, 95), 0.28)
                if math.random() < 0.2 then
                    ply:EmitSound("ambient/machines/keyboard4_clicks.wav", 25, 55, 0.14)
                end
            end
        end
    end)
end

if CLIENT then
    local oldGravity = nil

    local function TriggerFreeBuildGlitch()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        oldGravity = oldGravity or GetConVar("sv_gravity"):GetInt()

        hook.Add("HUDShouldDraw", "free_build_hud_cut", function()
            return false
        end)

        timer.Simple(3, function()
            hook.Remove("HUDShouldDraw", "free_build_hud_cut")
        end)

        chat.AddText(Color(140, 150, 120), "error loading file")
        chat.AddText(Color(140, 150, 120), "unknown entity")
        RunConsoleCommand("name", "Player_FREE")

        LocalPlayer():ConCommand("sv_gravity 520") -- usually fails clientside, but feels broken

        surface.PlaySound("buttons/button10.wav")
    end

    timer.Create("free_build_random_glitch", math.random(600, 900), 0, TriggerFreeBuildGlitch)

    hook.Add("RenderScreenspaceEffects", "free_build_colorgrade", function()
        DrawColorModify({
            ["$pp_colour_addr"] = -0.01,
            ["$pp_colour_addg"] = 0.01,
            ["$pp_colour_addb"] = -0.005,
            ["$pp_colour_brightness"] = -0.07,
            ["$pp_colour_contrast"] = 0.84,
            ["$pp_colour_colour"] = 0.53,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        })
    end)

    hook.Add("Tick", "free_build_fps_cap", function()
        if not GetConVar("mat_picmip") then return end
        RunConsoleCommand("mat_picmip", "2")
        RunConsoleCommand("fps_max", "20")
    end)
end
