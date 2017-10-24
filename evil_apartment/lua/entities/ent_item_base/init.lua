AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:AcceptInput(name, activator, caller, data)
	local lower = string.lower(name)

	if lower == "itemused" then
		self:TriggerOutput("OnItemAccept", activator)
	end
end

function ENT:RetrieveKeyValues(key, value, func)
	local isEmpty = !value || string.len(value) <= 0

	if key == "OnItemAccept" || key == "OnItemDeny" then
		self:StoreOutput(key, value)
	end

	if !isEmpty then
		if key == "requires" then
			local itemID = tonumber(value)

			if itemID then
				self:SetRequiredItem(itemID)

				if func then func(key) end
			end
		end
	end
end

function checkItemRequirement(itemID, ply)
	if IsValid(ply) && ply:IsPlayer() then
		local pos = ply:GetShootPos()
		local ent = util.TraceLine({
				["start"] = pos,
				["endpos"] = pos + (ply:GetAimVector() * 128),
				["filter"] = ply
			}).Entity

		if IsValid(ent) && (ent.GetRequiredItem && ent:GetRequiredItem()) then // Shows it's part of this base
			if ent.ShouldIgnoreItem && ent:ShouldIgnoreItem(itemID) then return false end

			if ((ent.OverrideItemAcception && ent:OverrideItemAcception(itemID)) || ent:GetRequiredItem() == itemID) then
				if ent.OnItemAccept && !ent:OnItemAccept(ply, itemID) then
					return false
				end

				ent:TriggerOutput("OnItemAccept", ply)
				return true
			else
				if ent.OnItemDeny && !ent:OnItemDeny(ply, itemID) then
					return false
				end

				ent:TriggerOutput("OnItemDeny", ply)
				return (ent.TakeItemOnDeny && ent:TakeItemOnDeny())
			end
		end
	end

	return false
end

function ENT:SetRequiredItem(itemID)
	if itemExists(itemID) then
		self.RequiredItem = itemID
	end
end

function ENT:GetRequiredItem()
	return self.RequiredItem
end
