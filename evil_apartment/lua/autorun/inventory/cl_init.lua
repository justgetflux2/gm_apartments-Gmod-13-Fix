local metaPlayer = FindMetaTable("Player")
local ITEMOBJ = {}
local m_UnknownModel = Model("models/props_interiors/pot01a.mdl")
local m_ItemDatabase = {}

function ITEMOBJ:Init()
	local o = {}

	setmetatable(o, self)
	self.__index = self

	/*o.ID = nil
	o.Name = nil
	o.Model = nil
	o.Use = nil
	o.Skin = 0
	o.Description = nil
	o.CamPos = nil
	o.LookAtPos = nil
	o.FOV = nil
	o.PickupSound
	*/

	return o
end

function ITEMOBJ:GetID() return self.ID end
function ITEMOBJ:GetName() return self.Name || "Unknown" end
function ITEMOBJ:GetModel() return self.Model || getDefaultItemModel() end
function ITEMOBJ:GetSkin() return self.Skin end
function ITEMOBJ:CanUse() return !self.DisableUse end
function ITEMOBJ:GetClass() return "evil_item" end
function ITEMOBJ:GetPickupSound() return self.PickupSound end

if CLIENT then
	local m_UnknownDesc = "Oh god how did this get in here I am not good with computers"

	function ITEMOBJ:GetCamPos() return self.CamPos end
	function ITEMOBJ:GetLookAtPos() return self.LookAtPos end
	function ITEMOBJ:GetFOV() return self.FOV end
	function ITEMOBJ:GetDescription() return self.Description || m_UnknownDesc end
end

function getDefaultItemModel()
	return m_UnknownModel
end

function getItemByID(id)
	return id && m_ItemDatabase[id]
end

function getItemByName(name)
	for _, item in ipairs(m_ItemDatabase) do
		if name == item:GetName() then
			return item
		end
	end
end

function itemExists(id)
	return getItemByID(id) != nil
end

function metaPlayer:ModifyItem(itemID, takeItem)
	if !itemID then
		MsgN("Item ID not given.")
		return
	end

	if !self.Inventory then
		self.Inventory = {}
	end

	local success = false

	if takeItem then
		for i, item in pairs(self:GetInventory()) do
			if item == itemID then
				success = true
				table.remove(self:GetInventory(), i)

				break
			end
		end
	else
		table.insert(self:GetInventory(), itemID)
		success = true
	end

	if SERVER && success then
		umsg.Start("InventoryUpdate", self)
			umsg.Short(itemID)
			umsg.Bool(takeItem)
		umsg.End()
	end
end

function metaPlayer:GiveItem(itemID)
	self:ModifyItem(itemID, false)
end

function metaPlayer:TakeItem(itemID)
	self:ModifyItem(itemID, true)
end

function metaPlayer:UseItem(itemID, dontBroadcastToPlayer)
	local item = getItemByID(itemID)

	if item then
		if !item:CanUse() then
			MsgN("Cannot use that item.")
			return
		end

		local itemUsed = false

		if item.Use then
			if item:Use(self) then
				MsgN("Item usage successful, taking item.")
				self:TakeItem(itemID)
				itemUsed = true
			else
				MsgN("Item usage failed. Abandon project.")
			end
		else
			if checkItemRequirement(itemID, self) then
				self:TakeItem(itemID)
				itemUsed = true
			else
				MsgN("Item " .. item:GetID() .. " does not have a valid USE function.")
			end
		end

		if !dontBroadcastToPlayer && itemUsed then
			umsg.Start("ItemUsed", self) umsg.End()
		end
	else
		MsgN("Item " .. item .. " not found")
	end
end

function metaPlayer:HasItem(itemID)
	return self:GetInventory() && table.HasValue(self:GetInventory(), itemID)
end

function metaPlayer:GetInventory()
	return self.Inventory
end

metaPlayer = nil

local function includeAll()
	local dir = "autorun/inventory/items/"
	local files = file.Find(dir .. "*.lua", "LUA")
	local err

	if #files > 0 then
		for _, v in ipairs(files) do
			ITEM = ITEMOBJ:Init()

			include(dir .. v)

			err = (!ITEM:GetID() && "(No ID given)")
				|| (type(ITEM:GetID()) != "number" && "(ID is not a number)")
				|| (ITEM:GetID() < 1 && "(ID below positive one)")
				|| false

			if err then
				MsgN("Invalid Item ID!" .. err)
			else
				if !m_ItemDatabase[ITEM:GetID()] then
					if SERVER then
						AddCSLuaFile(dir .. v)
						ITEM.CamPos = nil
						ITEM.LookAtPos = nil
						ITEM.FOV = nil
						ITEM.Description = nil
					else
						if ITEM.CamPos then ITEM.CamPos = ITEM.CamPos end // Default: Vector(50, 50, 50)
						if ITEM.LookAtPos then ITEM.LookAtPos = ITEM.LookAtPos end // Default: Vector(0, 0, 40)
					end

					if ITEM.Model && type(ITEM.Model) == "string" then util.PrecacheModel(ITEM.Model) end
					if ITEM.PickupSound then util.PrecacheSound(ITEM.PickupSound) end

					m_ItemDatabase[ITEM:GetID()] = ITEM
				else
					MsgN("Duplicate Item ID: " .. ITEM:GetID() .. "(Name: " .. ITEM:GetName() .. ")")
				end
			end

			ITEM = nil
		end
	else
		MsgN("There are no items in the item folder!")
	end

	ITEMOBJ = nil // This isn't needed anymore. Time to GC it
end

includeAll()
includeAll = nil

if SERVER then
	concommand.Add("evil_use_item", function(ply, cmd, args)
			if !args[1] then return end

			local item = tonumber(args[1])

			if item && ply:HasItem(item) then
				ply:UseItem(item)
			end
		end)

	concommand.Add("evil_print_items", function(ply)
			if EVIL_CHEAT_CONVAR:GetBool() then
				ply:PrintMessage(HUD_PRINTCONSOLE, "Syntax: itemid - itemname")

				for _, item in ipairs(m_ItemDatabase) do
					ply:PrintMessage(HUD_PRINTCONSOLE, item:GetID() .. " - " .. item:GetName())
				end
			end
		end)
else
	usermessage.Hook("InventoryUpdate", function(um)
			LocalPlayer():ModifyItem(um:ReadShort(), um:ReadBool())
		end)

	usermessage.Hook("ItemUsed", function(um)
			// Close the inventory
			if IsValid(getInventoryGUI()) then
				getInventoryGUI():SetVisible(false)
				getInventoryGUI():ShiftPosition(-1)
			end
		end)

	local m_Inventory

	local function showInventory(show)

		if IsValid(m_Inventory) then
			if !show then RememberCursorPosition() else RestoreCursorPosition() end
			if m_Inventory:IsVisible() != show then m_Inventory:SetVisible(show) end
			return
		end

		//Initialize it
		m_Inventory = vgui.Create("item_display", window)
		m_Inventory:SetVisible(true)
		m_Inventory:MakePopup()
		m_Inventory:Center()
		m_Inventory:SetPosition(1)
	end


	function getInventoryGUI()
		return m_Inventory
	end

	hook.Add("OnSpawnMenuOpen", "OpenInventory", function()
			showInventory(true)

			return false
		end)

	hook.Add("OnSpawnMenuClose", "CloseInventory", function()
			showInventory(false)

			//return false
		end)
end
