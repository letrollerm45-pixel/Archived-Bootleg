AddCSLuaFile("anomaly/shared/sh_anomaly_config.lua")
AddCSLuaFile("anomaly/shared/sh_anomaly_state.lua")
AddCSLuaFile("anomaly/client/cl_anomaly_effects.lua")
AddCSLuaFile("anomaly/client/cl_anomaly_ui.lua")
AddCSLuaFile("autorun/client/cl_anomaly_init.lua")

include("anomaly/shared/sh_anomaly_config.lua")
include("anomaly/shared/sh_anomaly_state.lua")
include("anomaly/server/sv_anomaly_system.lua")

util.AddNetworkString("anomaly_state_sync")
util.AddNetworkString("anomaly_broadcast")
util.AddNetworkString("anomaly_whisper")

hook.Add("Initialize", "AnomalyBootstrapServer", function()
    ANOMALY.State.NextBroadcast = CurTime() + math.Rand(ANOMALY.Config.BroadcastInterval.min, ANOMALY.Config.BroadcastInterval.max)
    ANOMALY.State.NextStalker = CurTime() + math.Rand(ANOMALY.Config.StalkerSpawnInterval.min, ANOMALY.Config.StalkerSpawnInterval.max)
end)
