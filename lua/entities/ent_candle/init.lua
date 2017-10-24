AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local IGNITE_SOUND = Sound("sunabouzu/candle_light.wav")

function ENT:Initialize()
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(false)
	
	/*if self:HasSpawnFlags(1) then
		// Hacky way of doing things
		// Lights on creation
		self.NextLightCheck = CurTime() + 1
		self.Think = function(self)
				if self.NextLightCheck <= CurTime() then
					setLight(self, true, true)
					
					self.Think = nil
				end
			end
	end*/
end

function ENT:AcceptInput(name, activator, caller, data)
	local lower = string.lower(name)
	
    if lower == "light" then
		setLight(self, true, true)
	elseif lower == "extinguish" then
		setLight(self, false, true)
	end
end

function ENT:Use(activator, caller)
	if self:IsLit() && ValidEntity(activator) && activator:IsPlayer() then
		setLight(self, false)
	end
end

function ENT:KeyValue(key, value)
	local isEmpty = string.len(value) <= 0
	
	if key == "OnLight" || key == "OnExtinguish" then
		self:StoreOutput(key, value)
	end
	
	if !isEmpty then
		if key == "color" then
			local split = string.Explode(" ", value)
			
			self:SetLightColor(split[1], split[2], split[3], split[4])
		elseif key == "model" then
			self:SetModel(Model(value))
		elseif key == "renderdistance" then
			local dist = tonumber(value)
			
			if dist then
				self:SetRenderDistance(dist)
			end
		end
	end
end

local m_ErrorMessage = "Loading failed! (|)"

local function errorFunc(hasFailed, reason)
	if hasFailed then
		MsgN(string.gsub(m_ErrorMessage, "|", reason))
		
		return true
	end
	
	return false
end

function setLight(ent, state, noFire)
	
	if errorFunc(!ValidEntity(ent), "Light-Entity is missing") then 
		return 
	end
	
	state = tobool(state)
	
	if !noFire then
		ent:Fire(((state && "OnLight") || "OnExtinguish"), "", 0)
	end
	
	if ent:IsLit() != state then
		ent:SetLit(state)
	end
	
	if ent:IsLit() then
		// Play ignite sound
		ent:EmitSound(IGNITE_SOUND, 100, 100)
		
		// Create flame
		ent.FlameEffect = EffectData()
		ent.FlameEffect:SetScale(1)
		ent.FlameEffect:SetAttachment(ent:LookupAttachment("wick"))
		ent.FlameEffect:SetEntity(ent)
		util.Effect("light_flame", ent.FlameEffect)
	else
		ent.FlameEffect = nil
	end
end