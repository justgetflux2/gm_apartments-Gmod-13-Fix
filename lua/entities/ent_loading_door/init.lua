AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		phys:SetMaterial("gmod_silent")
	end
end

function ENT:GetCloseDoorSound()
	return self:GetNWString("closedoorsound", nil)
end

function ENT:SetCloseDoorSound(sound)
	self:SetNWString("closedoorsound", sound)
end

function ENT:AcceptInput(name, activator, caller, data)
	local lower = string.lower(name)

    if lower == "teleport" && IsValid(activator) && activator:IsPlayer() then
		startDoorLoading(activator, self)
	elseif lower == "unlock" || lower == "lock" then
		self:SetLockState(lower == "lock")
	end
end

function ENT:GetTeleportEntity()

	if self.TeleportEnt && type(self.TeleportEnt) == "string" then
		local teleEnt = ents.FindByName(self.TeleportEnt)

		if #teleEnt > 0 && IsValid(teleEnt[1]) then
			self.TeleportEnt = teleEnt[1]
		end
	end

	return self.TeleportEnt
end

function ENT:Use(activator, caller)
	print("Function Use called (activator, caller)")
	print(activator)
	print(caller)
	print("\n")
	self:TriggerOutput("OnUse", activator)

	if self:HasSpawnFlags(1) && IsValid(activator) then
		startDoorLoading(activator, self)
	end
end

function ENT:KeyValue(key, value)
	local isEmpty = !value || string.len(value) <= 0

	if key == "OnTeleport" || key == "OnUnlock" || key == "OnUse" then
		self:StoreOutput(key, value)
	end

	if !isEmpty then
		if key == "teleportentity" then
			self.TeleportEnt = value
		elseif key == "closedoorsound" then
			self:SetCloseDoorSound(Sound(value))
		elseif key == "opendoorsound" then
			self:SetOpenDoorSound(Sound(value))
		elseif key == "lockdoorsound" then
			self:SetLockedDoorSound(Sound(value))
		elseif key == "unlockdoorsound" then
			self:SetUnLockedDoorSound(Sound(value))
		elseif key == "model" then
			self:SetModel(Model(value))
		elseif key == "loadingscreen" then
			self:SetLoadingScreen(value)
		end

		self:RetrieveKeyValues(key, value, function(key)
				if key == "requires" then self:SetLockState(true) end
			end)
	end
end

function ENT:GetUnLockedDoorSound()
	return self.UnLockedDoorSound
end

function ENT:SetUnLockedDoorSound(sound)
	self.UnLockedDoorSound = sound
end

function ENT:GetLockedDoorSound()
	return self.LockedDoorSound
end

function ENT:SetLockedDoorSound(sound)
	self.LockedDoorSound = sound
end

function ENT:IsLocked()
	return self.LockState
end

function ENT:SetLockState(lock)
	self.LockState = tobool(lock)
end

local m_ErrorMessage = "Loading failed! (|)"

local function errorFunc(hasFailed, reason)
	if hasFailed then
		MsgN(string.gsub(m_ErrorMessage, "|", reason))

		return true
	end

	return false
end

function startDoorLoading(ply, door)
	print("startDoorLoading called (ply, door)")
	print(ply)
	print(door)
	print("\n")
  
	if errorFunc(!IsValid(ply) || !IsValid(door), "Door or Player is missing")
		|| errorFunc(ply.IsTeleporting, "Player is already teleporting") then
		return
	end

	if door:IsLocked() then
		if door.LockedDoorSound then
			door:EmitSound(door.LockedDoorSound, 100, 100)
		end
	else
		door:TriggerOutput("OnTeleport", ply)
		door:DoTransition(ply)
		//Added the "door" argument to the DoTeleport
		door:DoTeleport(ply, door)
	end
end

function ENT:OnItemAccept(ply)
	if self:IsLocked() then
		self:SetLockState(false) // Unlock the door
		self:EmitSound(self:GetUnLockedDoorSound(), 100, 100)

		self:TriggerOutput("OnUnlock", ply)
	end

	return true
end

function ENT:DoTeleport(ply, door)
	print("function ENT:DoTeleport running with arguments:")
	print(ply)
	print(door)
	print("\n")
	
	if IsValid(ply) then
	print("ply is valid")
	
	 if SERVER && IsValid(door) then
	 print("Server and door are valid")
	 
		 // If the spawn flag "Teleport player" is 1
		 if door:HasSpawnFlags(2) then
			 print("SpawnFlag set to 2 'Teleport Player'")
			 local teleEnt = door:GetTeleportEntity()

			 if IsValid(teleEnt) then
				 print("teleEnt is valid")
				 ply:SetPos(teleEnt:GetPos())
				 ply:SetEyeAngles(Angle(0, teleEnt:GetAngles().y, 0))
			 end
		 end

	 else
		 if door:GetCloseDoorSound() != "" then
			 surface.PlaySound(door:GetCloseDoorSound())
		 end

		 door:SetTransition(false)
	 end
 end
end--, ply, self)
