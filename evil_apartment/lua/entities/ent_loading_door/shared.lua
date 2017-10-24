ENT.Type = "anim"
ENT.Base = "ent_item_base"

ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENABLE_FAKE_LOADING = CreateConVar("sv_evil_loading", "1", FCVAR_REPLICATED, "Enables the loading screen.")

function ENT:GetOpenDoorSound()
	return self:GetNWString("opendoorsound", nil)
end

function ENT:SetOpenDoorSound(sound)
	self:SetNWString("opendoorsound", sound)
end

function ENT:GetCloseDoorSound()
	return self:GetNWString("closedoorsound", nil)
end

function ENT:SetCloseDoorSound(sound)
	self:SetNWString("closedoorsound", sound)
end

/*
function ENT:GetLockedDoorSound()
	return self:GetNWString("lockdoorsound", nil)
end

function ENT:SetLockedDoorSound(sound)
	self:SetNWString("lockdoorsound", sound)
end

function ENT:IsLocked()
	return self:GetNWBool("doorlock", false)
end

function ENT:SetLockState(lock)
	self:SetNWBool("doorlock", tobool(lock))
end*/

function ENT:GetLoadingScreen()
	return self:GetNWString("loadingscreen", nil)
end

function ENT:SetLoadingScreen(screen)
	self:SetNWString("loadingscreen", screen)
end

function ENT:DoTransition(ply)
	if !ValidEntity(ply) then return end

	ply:Freeze(true)
	
	if SERVER then
		umsg.Start("re_startloading", ply) 
			umsg.Short(self:EntIndex())
		umsg.End()
	else
		// Play Sound
		if self:GetOpenDoorSound() != "" then
			surface.PlaySound(self:GetOpenDoorSound())
		end
		
		self:SetTransition(true)
	end
	
	timer.Simple(((ENABLE_FAKE_LOADING:GetBool() && 3) || 1.5), function(ply, door)
			if ValidEntity(ply) then

				if SERVER && ValidEntity(door) then
				
					// If the spawn flag "Teleport player" is 1
					if door:HasSpawnFlags(2) then
						local teleEnt = door:GetTeleportEntity()
						
						if ValidEntity(teleEnt) then
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
				
				ply:Freeze(false)
			end
		end, ply, self)
end