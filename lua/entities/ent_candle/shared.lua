ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()
    self:DTVar("Bool", 0, "Lit")
	self:DTVar("Int", 0, "Red")
	self:DTVar("Int", 1, "Green")
	self:DTVar("Int", 2, "Blue")
	self:DTVar("Int", 3, "Brightness")
	self:DTVar("Float", 0, "DistToRender")
end

function ENT:IsLit()
	return self:GetDTBool(0)
end

function ENT:SetLit(lit)
	self:SetDTBool(0, lit)
end

function ENT:SetRenderDistance(dist)
	self:SetDTFloat(0, dist)
end

function ENT:GetRenderDistance()
	return self:GetDTFloat(0)
end

function ENT:GetLightColor()
	return self:GetDTInt(0), self:GetDTInt(1), self:GetDTInt(2), self:GetDTInt(3)
end

function ENT:SetLightColor(r, g, b, bright)
	if r then self:SetDTInt(0, r) end
	if g then self:SetDTInt(1, g) end
	if b then self:SetDTInt(2, b) end
	if bright then self:SetDTInt(3, bright) end
end