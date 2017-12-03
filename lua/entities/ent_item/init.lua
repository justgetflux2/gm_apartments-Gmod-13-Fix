AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	if self:HasSpawnFlags(4) then
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
	else
		self:SetMoveType(MOVETYPE_NONE)
	end
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
end

function ENT:Use(activator, caller)
	// Does +use work on this?
	if self:HasSpawnFlags(1) then
		self:TriggerOutput("OnUse", activator)
		--self.Owner:GetActiveWeapon():SendWeaponAnim(ACT_VM_FIDGET) 

		// Should the player be able to pick it up?
		if self:HasSpawnFlags(2) && IsValid(activator) && activator:IsPlayer() then
			// Give Item
			if self.PickupSound then
				self:EmitSound(self.PickupSound)
			end

			activator:GiveItem(self.ItemID)
			self:Remove()
		end
	end
end

function ENT:AcceptInput(name, activator, caller, data)
    if name == "GiveItem" && IsValid(activator) && activator:IsPlayer() then
		activator:GiveItem(self.ItemID)
		self:Remove()
	end
end

function ENT:KeyValue(key, value)
	local isEmpty = !value || string.len(value) <= 0

	if key == "OnUse" then
		self:StoreOutput(key, value)
	end

	if !isEmpty then
		if key == "collide" then
			local shouldCollide = tobool(value)

			if !shouldCollide then
				self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			end
		elseif key == "enablemotion" then
			if tobool(value) then
				self:SetMoveType(MOVETYPE_VPHYSICS)
			end
		elseif key == "itemid" then
			self:SetItemID(value)
		end
	end
end

function ENT:SetItemID(id)
	local itemID = tonumber(id)
	local item = getItemByID(itemID)

	if item then
		self.ItemID = itemID
		self:SetModel(item:GetModel())
		self:SetSkin(item:GetSkin())

		if item:GetPickupSound() then
			self.PickupSound = item:GetPickupSound()
		end
	end
end

function ENT:GetItemID()
	return self.ItemID
end
