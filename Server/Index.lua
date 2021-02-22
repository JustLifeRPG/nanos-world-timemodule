-- Nanos World Timemodule - Serverscript
-- Author: MarkusSR1984
-- Description: See readme.md


-- Configuration
local timeFactorDay = 60 	-- Defines how many Seconds will go over inGame while 1 Second in real life - at Daytime
local timeFactorNight = 120 -- Defines how many Seconds will go over inGame while 1 Second in real life - at Nighttime
local nightStartHour = 18	-- When should start the Nighttime factor
local nightEndHour = 6		-- When should stop the nighttime factor
local syncInterval = 60 	-- Sync Time with Clients every XX Seconds - Be fine to your server and stay above 1 Minute, its fast enogth
local serverStartTime = 6	-- Initial time on serverstart (hour)


-------------------- HERE BEGINNS THE SCRIPT ITSELV - DO NOT EDIT IF U DONT KNOE WHAT YOU ARE DONING -------------------------------------

local serverTime = {}
serverTime["hour"] = serverStartTime
serverTime["minute"] = 0	
serverTime["factor"] = timeFactorDay
local isDayTime = true
local timeMaster
local syncTimer

-- When package loads start the Timers
Package:Subscribe(
	"Load",
	function()
		timeMaster = Timer:SetTimeout(60000 / serverTime["factor"], NextMinute) -- Add Minutes in given interval
		syncTimer = Timer:SetTimeout(syncInterval * 1000, BroadcastTimeSync) -- Broadcast TimeSyncPackages in given interval
		BroadcastTimeSync()
	end
)

function NextMinute (delay_ms)
		serverTime["minute"] = serverTime["minute"] + 1

		if serverTime["minute"] >= 60 then
			serverTime["hour"] = serverTime["hour"] + 1
			serverTime["minute"] = 0
		end

		if (serverTime["hour"] >= 24) then
			serverTime["hour"] = 0
			serverTime["minute"] = 0
		end

		if (serverTime["hour"] >= nightStartHour and isDayTime) then
			-- its Night
			Events:Call("NightStart", {})
			isDayTime = false
			serverTime["factor"] = timeFactorNight
			ResetTimeMaster()
		elseif (serverTime["hour"] >= nightEndHour and serverTime["hour"] < nightStartHour and not isDayTime) then
			-- its Day
			Events:Call("DayStart", {})
			isDayTime = true
			serverTime["factor"] = timeFactorDay
			ResetTimeMaster()
		end
end

function BroadcastTimeSync()
	local timePackage = JSON.stringify(serverTime)
	Events:BroadcastRemote("UpdateClientTime", {timePackage})
	Events:Call("UpdateTime", {timePackage})
end

function ResetTimeMaster()
	BroadcastTimeSync()
	Timer:ClearTimeout(timeMaster)
	timeMaster = Timer:SetTimeout(60000 / serverTime["factor"], NextMinute)
end

-- a Time Sync Request from a Player
Events:Subscribe("TimeSyncRequest", function(player)
    Events:CallRemote("UpdateClientTime", player, {JSON.stringify(serverTime)})
end)

-- a few Console Commands to control server time
Server:Subscribe("Console", function(input)
	local cmd = string.lower(input)
	if (cmd == "time") then
		local hourTxt = serverTime["hour"]
		local minuteTxt = serverTime["minute"]
		if (serverTime["hour"] < 10) then
			hourTxt = "0" .. serverTime["hour"]
		end
		if (serverTime["minute"] < 10) then
			minuteTxt = "0" .. serverTime["minute"] 
		end
		Package:Log("The current servertime is " .. hourTxt .. ":" .. minuteTxt)
	elseif (cmd == "time set day") then
		serverTime["hour"] = 12
		serverTime["minute"] = 0
		BroadcastTimeSync()
		Package:Log("Setted servertime to 12:00")
	elseif (cmd == "time set noon") then
		serverTime["hour"] = 6
		serverTime["minute"] = 0
		BroadcastTimeSync()
		Package:Log("Setted servertime to 06:00")
	elseif (cmd == "time set night") then
		serverTime["hour"] = 18
		serverTime["minute"] = 0
		BroadcastTimeSync()
		Package:Log("Setted servertime to 18:00")
	elseif (cmd == "time set midnight") then
		serverTime["hour"] = 0
		serverTime["minute"] = 0
		BroadcastTimeSync()
		Package:Log("Setted servertime to 00:00")
	end
end)