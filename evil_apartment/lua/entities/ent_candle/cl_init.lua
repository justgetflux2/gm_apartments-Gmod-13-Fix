include("shared.lua")

function ENT:Think()
	if self:IsLit() && LocalPlayer():GetPos():Distance(self:GetPos()) <= self:GetRenderDistance() then
		local dlight = DynamicLight(self:EntIndex())
		
		if dlight then
			local r, g, b, bright = self:GetLightColor()
			local pos = self:GetAttachment(self:LookupAttachment("wick"))
			
			if pos then			
				pos = pos.Pos
			else
				pos = self:GetPos()
			end
			
			dlight.Pos = pos + (self:GetUp() * 10)
			dlight.r = r
			dlight.g = g
			dlight.b = b
			dlight.Brightness = (bright <= 0 && 2) || bright
			dlight.Size = 128
			//dlight.Decay = dlight.Size * 5
			dlight.DieTime = CurTime() + .01
			dlight.Style = 1
		end
	end
	
	self:NextThink(CurTime() + .01)
	return true
end