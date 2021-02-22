-- Nanos World Timemodule - Clientscript
-- Author: MarkusSR1984
-- Description: See readme.md

World:SpawnDefaultSun()

Player:Subscribe("Spawn", function(player)
	Events:CallRemote("TimeSyncRequest", {})
end)

Events:Subscribe("UpdateClientTime", function(data)
    -- Package:Log("Got Time Package from Server: ".. data)
	local timeData = JSON.parse(data)
	World:SetTime(timeData["hour"], timeData["minute"])
	World:SetSunSpeed(timeData["factor"])
end)