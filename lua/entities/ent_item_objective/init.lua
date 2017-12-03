AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	if self:HasSpawnFlags(1) then
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
	else
		self:SetMoveType(MOVETYPE_NONE)
	end

	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	if self:HasSpawnFlags(8) then
		// Starts it transparent, usually use to cue the player to an missing object
		self:SetTransparent(true)
	end
end

function ENT:Use(activator, caller)
	// Allow the user to take the item
	if self:HasSpawnFlags(2) && self:GetItemID() && IsValid(activator) && activator:IsPlayer() then
		self:TriggerOutput("OnPickup", activator)
		--self:SendWeaponAnim(ACT_VM_HITCENTER)

		if self.PickupSound then
			self:EmitSound(self.PickupSound)
		end

		// Give Item
		activator:GiveItem(self:GetItemID())
		self:SetItemID(nil)

		// Make Transparent
		self:SetTransparent(true)
	end
end

function ENT:KeyValue(key, value)
	local isEmpty = !value || string.len(value) <= 0

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
		end

		if self:HasSpawnFlags(2) then
			if key == "itemid" && !self:HasSpawnFlags(8) then
				self:SetItemID(value)
			end

			if key == "pickupsound" then
				self.PickupSound = Sound(value)
			end

			if key == "OnPickup" then
				self:StoreOutput(key, value)
			end

			if !self:HasSpawnFlags(4) && key == "retricteditems" then
				self.RestrictedItems = {}
				local split = string.Explode("%s*,%s*", value, true)
				local item

				for _, itemID in pairs(split) do
					item = tonumber(itemID)

					if item then
						table.insert(self.RestrictedItems, item)
					end
				end
			end
		else
			if key == "model" then
				self:SetModel(Model(value))
			elseif key == "skin" then
				local skin = tonumber(value)

				if skin then
					self:SetSkin(1)
					--self:SetSkin(self:GetSkin())
				end
			end
		end

		self:RetrieveKeyValues(key, value)
	end
end

function ENT:SetItemID(id)
	self.ItemID = tonumber(id)

	if self.ItemID then
		local item = getItemByID(self.ItemID)

		if item then
			self:SetModel(item:GetModel())
			self:SetSkin(item:GetSkin())
		end
	end
end

function ENT:GetItemID()
	return self.ItemID
end

function ENT:OnItemChange(ply, itemID)
	if self:HasSpawnFlags(2) then
		if self:GetItemID() then return false end

		self:SetTransparent(false)
		self:SetItemID(itemID)
	end

	return true
end

function ENT:OnItemAccept(ply, itemID)
	return self:OnItemChange(ply, itemID)
end

function ENT:OnItemDeny(ply, itemID)
	return self:OnItemChange(ply, itemID)
end

function ENT:ShouldIgnoreItem(itemID)
	if self:HasSpawnFlags(4) then
		if self.RestrictedItems && table.HasValue(self.RestrictedItems, itemID) then return false end

		return true
	end

	return false
end

function ENT:TakeItemOnDeny()
	return self:HasSpawnFlags(2)
end

function ENT:SetTransparent(isOn)
	local r, g, b = self:GetColor()
	local alpha

	if isOn then
		// Make Item Transparent
		alpha = 128
		self:SetMaterial("phoenix_storms/gear")
	else
		alpha = 255
		self:SetMaterial(nil)
	end

	self:SetColor(r, g, b, alpha)
end
