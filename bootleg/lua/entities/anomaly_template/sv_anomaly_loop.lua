util.AddNetworkString("AnomalyTemplate_PlayScaryRU")

hook.Add("InitPostEntity", "AnomalyTemplate_ServerStartLoop", function()
    timer.Create("AnomalyTemplate_ScaryRULoop", AnomalyTemplate.RepeatInterval, 0, function()
        net.Start("AnomalyTemplate_PlayScaryRU")
        net.Broadcast()
    end)
end)

hook.Add("ShutDown", "AnomalyTemplate_CleanupTimers", function()
    timer.Remove("AnomalyTemplate_ScaryRULoop")
end)
