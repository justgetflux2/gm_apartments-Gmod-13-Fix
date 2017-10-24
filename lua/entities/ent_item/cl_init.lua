include("shared.lua")
		
local SHINE_SPARK = Material("sunabouzu/item_shine1")

function ENT:Draw()
	
	// To avoid making any expensive checks
	if (!self.NextCheck || self.NextCheck < CurTime()) then
		self.NextCheck = CurTime() + .25
		self.VisibleToPlayer = LocalPlayer():GetPos():Distance(self:GetPos()) < 128 && LocalPlayer():Visible(self)
	end
	
	if self.VisibleToPlayer then		
		cam.Start3D(EyePos(), EyeAngles())
			render.ClearStencil()
			render.SetStencilEnable(true)
		 
			render.SetStencilFailOperation(STENCILOPERATION_KEEP)
			render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)
			render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
			render.SetStencilReferenceValue(1)
			
			self:DrawModel()
			
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
			render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
			
			// Further away we are, the less obvious the effect should be.
			render.SetMaterial(SHINE_SPARK)
			render.DrawScreenQuad()
		 
			render.SetStencilEnable(false)
		cam.End3D()
	else
		// Just draw the model
		self:DrawModel()
	end
end

/*
function ENT:OnPickUp()
	
end

hook.Add("HUDPaint", "DrawItemPickup", function()
		
	end)*/