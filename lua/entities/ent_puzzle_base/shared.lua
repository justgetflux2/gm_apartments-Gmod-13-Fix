ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

include("sh_camera.lua")

function ENT:SetupDataTables()
    self:DTVar("Int", 0, "User")
	self:DTVar("Bool", 0, "Disabled")
end

function ENT:SetDisabled(isDisabled)
	self:SetDTBool(0, tobool(isDisabled))
end

function ENT:IsDisabled()
	return self:GetDTBool(0)
end

function ENT:SetUser(user)
  print("SetUser called")
  print(self)
  print(user)
	local oldUser = self:GetUserID()
  print(oldUser)
  print(user:EntIndex())
	if oldUser == user:EntIndex() then return end

	oldUser = ents.GetByIndex(oldUser)
  	print(oldUser)

	local isCorrect = user && true

	if SERVER then
    	print("SERVER is true")
		if IsValid(oldUser) then
      		print("olduer is valid")
			oldUser:ExitVehicle()

			oldUser:UnSpectate()
			oldUser:Spawn()

			if oldUser.LastKnownPos then
				oldUser:SetPos(oldUser.LastKnownPos.pos)
				oldUser:SetEyeAngles(oldUser.LastKnownPos.ang)

				oldUser.LastKnownPos = nil
			end

			if oldUser.SetDrawCrosshair then
				oldUser:SetDrawCrosshair(true)
			end
		end

		if isCorrect && user:IsPlayer() then
			print("If it's correct and user isPlayer")
			//SetScriptedVehicle changed to EnterVehicle
			user:EnterVehicle(self:GetCameraEntity())
			user.LastKnownPos = {pos = user:GetPos(), ang = user:EyeAngles()}

			user:StripWeapons()

			user:Spectate(OBS_MODE_FIXED)

			if user.SetDrawCrosshair then
				user:SetDrawCrosshair(false)
			end
		end
	end

	self:SetDTInt(0, ((isCorrect && user:EntIndex()) || 0))
end

function ENT:GetUserID()
	return self:GetDTInt(0)
end
