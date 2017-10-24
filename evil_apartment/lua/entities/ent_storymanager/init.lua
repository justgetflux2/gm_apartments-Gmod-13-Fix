AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local function lockPlayer(ply, isLocked)
	if isLocked then
		ply:Lock()
	else
		ply:UnLock()
	end
end

local function sendStory(ply, isOn, story)
	umsg.Start("evil_story", ply)
		umsg.Bool(isOn)

		if IsValid(ply) then
			lockPlayer(ply, isOn)
		else
			// Send to all players
			for _, v in pairs(player.GetAll()) do
				if IsValid(v) then
					lockPlayer(v, isOn)
				end
			end
		end

		if isOn then
			umsg.Short(story)
		end
	umsg.End()
end

function ENT:AcceptInput(name, activator, caller, data)
	local temp = string.lower(name)

    if temp == "startstory" then
		temp = tonumber(data)

		if temp then
			local ply

			if IsValid(activator) && activator:IsPlayer() then ply = activator end

			sendStory(ply, true, temp)
		end
	elseif temp == "stopstory" then
		sendStory(ply, false)
	end
end

concommand.Add("evil_story_done", function(ply, cmd, args)
		ply:UnLock()
	end)
