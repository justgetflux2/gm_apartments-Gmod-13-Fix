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
	local oldUser = self:GetUserID()
	
	if oldUser == user:EntIndex() then return end
	
	oldUser = ents.GetByIndex(oldUser)
	
	local isValid = user && ValidEntity(user)
	
	if SERVER then
		if ValidEntity(oldUser) then
			oldUser:SetScriptedVehicle(NULL)
			
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

		if isValid && user:IsPlayer() then			
			user:SetScriptedVehicle(self:GetCameraEntity())
			
			user.LastKnownPos = {pos = user:GetPos(), ang = user:EyeAngles()}
			
			user:StripWeapons()
			
			user:Spectate(OBS_MODE_FIXED)
			
			if user.SetDrawCrosshair then
				user:SetDrawCrosshair(false)
			end
		end
	end
	
	self:SetDTInt(0, ((isValid && user:EntIndex()) || 0))
end

function ENT:GetUserID()	
	return self:GetDTInt(0)
end