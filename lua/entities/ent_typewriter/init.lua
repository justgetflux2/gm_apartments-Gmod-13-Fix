AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.PossiblePhrases = {}

function ENT:Initialize()
	self:SetModel("models/sunabouzu/typewriter.mdl")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	local camera = self:InitializeCameraEntity()

	if IsValid(camera) then
		camera:UpdateView(Vector(25, 0, 50))
	end
end

function ENT:Use(activator, caller)
	if IsValid(activator) && activator:IsPlayer() && self:GetUserID() == 0 then
		self:TriggerOutput("OnUse", activator)

		self:SetUser(activator)

		umsg.Start("eviltyper_use", activator)
			umsg.Bool(true)
			umsg.Entity(self)
		umsg.End()
	end
end

function ENT:CheckPhrase(ply, value)

	if IsValid(ply) then
		value = self.PossiblePhrases[string.lower(tostring(value))]

		if value then
			self:TriggerOutput(value, ply)

			self:SetUser(NULL)

			umsg.Start("eviltyper_use", activator)
				umsg.Bool(false)
			umsg.End()

			return
		end
	end

	// Failed to find any phrase related to this.
	self:TriggerOutput("OnFailure", ply)
end

function ENT:KeyValue(key, value)
	local isEmpty = !value || string.len(value) <= 0

	if string.Left(key, 8) == "OnPhrase" || key == "OnFailure" then
		self:StoreOutput(key, value)
	end

	if !isEmpty then
		if key == "collide" then
			local shouldCollide = tobool(value)

			if !shouldCollide then
				self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			end
		elseif key == "disableshadows" then
			local disableShadow = tobool(value)

			if disableShadow then
				self:DrawShadow(false)
			end
		elseif key == "skin" then
			local skin = tonumber(value)

			if skin && skin > 0 then
				self:SetSkin(skin)
			end

		elseif string.Left(key, 6) == "phrase" then
			local num = tonumber(string.Right(key, string.len(key) - 6))

			if num then
				self.PossiblePhrases[string.lower(value)] = "OnPhrase" .. num
			else
				MsgN("Error retrieving phrase(" .. value .. ") from typewriter " .. self:EntIndex())
			end
		end
	end
end

concommand.Add("evil_typer", function(ply, cmd, args)
		if !args[1] then return end

		local veh = ply:GetScriptedVehicle()

		if IsValid(veh) then
			veh = veh:GetParent()

			if IsValid(veh)
				&& veh:GetClass() == "ent_typewriter"
				&& veh:GetPos():Distance(ply:GetPos()) <= 256 then
				veh:CheckPhrase(ply, args[1])
			end
		end
	end)

concommand.Add("evil_typerleave", function(ply, cmd, args)
		local veh = ply:GetScriptedVehicle()

		if IsValid(veh) then
			veh = veh:GetParent()

			if IsValid(veh)	&& veh:GetClass() == "ent_typewriter" then
				veh:SetUser(NULL)

				umsg.Start("eviltyper_use", activator)
					umsg.Bool(false)
				umsg.End()
			end
		end
	end)
