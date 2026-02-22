if SERVER then
    hook.Add("InitPostEntity", "arch_build_flatgrass_setup", function()
        if game.GetMap() ~= "gm_flatgrass" then return end

        for i = 1, 10 do
            local prop = ents.Create("prop_physics")
            if not IsValid(prop) then continue end
            prop:SetModel("models/props_c17/oildrum001.mdl")
            prop:SetPos(Vector(math.random(-4000, 4000), math.random(-4000, 4000), math.random(20, 55)))
            prop:Spawn()
            prop:GetPhysicsObject():EnableMotion(false)
        end

        local building = ents.Create("prop_dynamic")
        if IsValid(building) then
            building:SetModel("models/props_buildings/building_002a.mdl")
            building:SetPos(Vector(3200, 2800, 0))
            building:SetAngles(Angle(0, 210, 0))
            building:Spawn()
        end

        timer.Create("arch_build_spawn_black_figure", 35, 0, function()
            local ply = player.GetHumans()[1]
            if not IsValid(ply) then return end
            if not ply:GetNWBool("arch_build_horror_live", false) then return end

            local fig = ents.Create("model_player_stariy")
            if not IsValid(fig) then return end

            local pos = ply:GetPos() + Vector(math.random(-500, 500), math.random(-500, 500), 0)
            if math.random(1, 3) == 1 then
                pos = pos + Vector(0, 0, -50) -- sometimes inside walls/floor
            end

            fig:SetPos(pos)
            fig:Spawn()
        end)
    end)
end
