if SERVER then
	AddCSLuaFile("shared.lua")
	SWEP.Weight = 5
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false
else
	SWEP.PrintName = "Lighter"
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
	SWEP.ViewModelFOV = 70
	SWEP.ViewModelFlip = false
	SWEP.DrawSecondaryAmmo = false
end

SWEP.Author = "Unrealomega"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "Left Click: Fire."

SWEP.ViewModel = "models/weapons/v_lighter.mdl"
SWEP.WorldModel = "models/weapons/w_lighter.mdl"
SWEP.HoldType = "normal"

SWEP.Sounds_Draw = Sound("lighter/lighter_draw.wav")
SWEP.Sounds_Holster = Sound("lighter/lighter_holster.wav")

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
	PrecacheParticleSystem("lighter_flame")
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:Holster()	
	self:EmitSound(self.Sounds_Holster, 100, 100)
	return true
end

function SWEP:Deploy()
	self:EmitSound(self.Sounds_Draw, 100, 100)
	ParticleEffectAttach( "lighter_flame", PATTACH_POINT_FOLLOW, self.Owner:GetViewModel(), 1 )
	
	return true
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	
	self:ToggleLighter()
	
	self:SetNextPrimaryFire(CurTime() + self:SequenceDuration())
end

function SWEP:CanPrimaryAttack()
	return self:GetNextPrimaryFire() <= CurTime()
end

function SWEP:SecondaryAttack()
	if !self:CanSecondaryAttack() || !self:IsLit() then return end
	
	local pos = self.Owner:EyePos()
	local trace = util.TraceLine({
			["start"] = pos,
			["endpos"] = pos + (self.Owner:GetAimVector() * 128),
			["filter"] = self.Owner
		})
	
	if trace.Hit && ValidEntity(trace.Entity) && !trace.Entity:IsWorld() then
		local success = false		
		
		if trace.Entity:GetClass() == "ent_candle" then
			if SERVER then
				local action = !trace.Entity:IsLit()
				
				if action then // If it's going to light the candle, it should do the animation.
					self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
				end
				
				setLight(trace.Entity, action) // Toggle
			end
			
			success = true
		elseif EVIL_CHEAT_CONVAR:GetBool() && trace.Entity:GetClass() != "ent_loading_door" then
			if SERVER then
				trace.Entity:Ignite(100, 0)
			end
			
			success = true
		end
		
		if success then
			self:SetNextPrimaryFire(CurTime() + 1)
		end
	end
end

function SWEP:CanSecondaryAttack()
	return self:CanPrimaryAttack()
end

function SWEP:Reload() end

function SWEP:ToggleLighter()
	if self:IsLit() then
		// Put Lighter away
		self:SendWeaponAnim(ACT_VM_HOLSTER)
		
		self.Owner:GetViewModel():StopParticles()
		
		timer.Simple(self:SequenceDuration(), function(wep)
				wep:SetNWBool("Light", false)
			end, self)
			
		self:Holster()
	else			
		// Take Lighter Out
		self:SendWeaponAnim(ACT_VM_DRAW)
		self:SetNWBool("Light", true)
	
		timer.Simple(self:SequenceDuration(), function(wep)
				wep:SendWeaponAnim(ACT_VM_IDLE)
			end, self)
		
		self:Deploy()
	end
end

function SWEP:IsLit()
	return self:GetNWBool("Light", true)
end

function SWEP:GetLightColor()
	return 212, 131, 43
end

if SERVER then
	if game.GetMap() == "gm_apartment" then
		hook.Add("PlayerSwitchFlashlight", "DisableFlashLight", function(ply, SwitchOn)
				return false
			end)
	end
else
	local m_DrawInstruction = false
	local COLOR_BLUE = Color(0, 183, 235, 200)
	local m_Crosshair = Material("effects/softglow")

	function SWEP:DrawHUD()
		if LocalPlayer():ShouldDrawCrosshair() then
			local pos = LocalPlayer():EyePos()
			local trace = util.TraceLine({
					["start"] = pos, 
					["endpos"] = pos + (LocalPlayer():GetAimVector() * 128), 
					["filter"] = LocalPlayer()
				})
			
			if trace.Fraction < 1 then
				local alpha, pos, size = (1 - trace.Fraction) * 255, trace.HitPos:ToScreen(), ScreenScale(8)
				local radius = size / 2				
				
				surface.SetDrawColor(COLOR_BLUE.r, COLOR_BLUE.g, COLOR_BLUE.b, alpha)
				surface.SetMaterial(m_Crosshair)
				surface.DrawTexturedRect(pos.x - radius, pos.y - radius, size, size)
			
				if self:IsLit() && trace.Hit && ValidEntity(trace.Entity) && trace.Entity:GetClass() == "ent_candle" then
					draw.SimpleText("Secondary: " .. ((trace.Entity:IsLit() && "Extinguish") || "Light"), "HudHintTextLarge", pos.x, pos.y + radius + 10, COLOR_BLUE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end		
			end	
		end		
	end
	
	function SWEP:Think()
		if self:IsLit() then
		
			local pos = self.Owner:EyePos()

			if self.Owner:GetViewModel() then
				local attach = self.Owner:GetViewModel():GetAttachment(self:LookupAttachment("lighter_fire_point"))

				if attach then
					local lighterPos = attach.Pos

					if lighterPos then
						// pos lies at the midpoint of the player's eyes and the lighter
						// in order to light the visible portion of the view model and
						// to allow for some visual light movement upon holstering
						pos = (lighterPos+pos)/2
					end
				end
			end
		
			// dynamic lights
			local dlight = DynamicLight(self:EntIndex())
			
			if dlight then
				
				local r, g, b = self:GetLightColor()
				
				dlight.Pos = pos
				dlight.r = r
				dlight.g = g
				dlight.b = b
				dlight.Brightness = 2
				dlight.Size = 128
				//dlight.Decay = dlight.Size * 5
				dlight.DieTime = CurTime() + .01
				dlight.Style = 1
			end
		
		end
		
		self:NextThink(CurTime() + .01)
		return true
	end
	
	function SWEP:ViewModelDrawn()
		if !testvm then
			PrecacheParticleSystem("lighter_flame")
		end
	end
	
end

function SWEP:ShouldDropOnDie()
	return false
end