-- Loader for separated anomaly template files.

if SERVER then
    AddCSLuaFile("entities/anomaly_template/sh_anomaly_config.lua")
    AddCSLuaFile("entities/anomaly_template/cl_anomaly_effects.lua")

    include("entities/anomaly_template/sh_anomaly_config.lua")
    include("entities/anomaly_template/sv_anomaly_loop.lua")
else
    include("entities/anomaly_template/sh_anomaly_config.lua")
    include("entities/anomaly_template/cl_anomaly_effects.lua")
end
