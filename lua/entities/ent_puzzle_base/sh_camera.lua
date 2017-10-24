local ENTITY = {}

ENTITY.Type = "anim"
ENTITY.Base = "base_anim"

if SERVER then
	function ENTITY:Initialize()
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_NONE)
		self:SetNoDraw(true)
	end
	
	function ENTITY:UpdateView(vec)
		local parent = self:GetParent()
		
		if parent then
			if vec then self:SetPos(parent:LocalToWorld(vec)) end
			self:PointAtEntity(parent)
		end
	end
else
	function ENTITY:CalcView(ply, origin, ang, fov)
		// The view shouldn't be moving any
		if !self.View then
			self.View = {
					["origin"] = origin,
					["angles"] = ang,
					["fov"] = fov
				}
		end
		
		return self.View
	end
end

scripted_ents.Register(ENTITY, "ent_puzzlecamera", true)
ENTITY = nil