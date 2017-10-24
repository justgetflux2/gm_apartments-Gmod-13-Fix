AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_camera.lua")
include("shared.lua")

function ENT:InitializeCameraEntity()
	self.CameraEntity = ents.Create("ent_puzzlecamera")
	self.CameraEntity:SetParent(self)
	self.CameraEntity:Spawn()
	
	return self.CameraEntity
end

function ENT:GetCameraEntity()
	return self.CameraEntity
end