local PANEL = {}
local m_BarMaterial = Material("sunabouzu/inv_bar")
local INV_CLICK = Sound("sunabouzu/inventory_click.wav")
local m_ViewModels = {}

function PANEL:Init()
	surface.CreateFont("sans serif", ScreenScale(20, true), 500, true, true, "evilDescription")
	surface.CreateFont("sans serif", ScreenScale(40, true), 600, true, true, "evilItemName")
	
	self.Icon = vgui.Create("DModelPanel", self)
	self.Icon.SetModel = function(self, strModelName, skin)
			// Note - there's no real need to delete the old
			// entity, it will get garbage collected, but this is nicer.
			if ( IsValid( self.Entity ) ) then
				self.Entity:Remove()
				self.Entity = nil
			end
			
			// Note: Not in menu dll
			if ( !ClientsideModel ) then return end
			
			self.Entity = ClientsideModel( strModelName, RENDER_GROUP_OPAQUE_ENTITY )
			if ( !IsValid(self.Entity) ) then return end
			
			self.Entity:SetNoDraw( true )
			self.Entity:SetSkin(skin || 0)
			
			// Try to find a nice sequence to play
			local iSeq = self.Entity:LookupSequence( "walk_all" );
			if (iSeq <= 0) then iSeq = self.Entity:LookupSequence( "WalkUnarmed_all" ) end
			if (iSeq <= 0) then iSeq = self.Entity:LookupSequence( "walk_all_moderate" ) end
			
			if (iSeq > 0) then self.Entity:ResetSequence( iSeq ) end
		end

	self.PreviousButton = vgui.Create("DImageButton", self)
	self.PreviousButton:SetMaterial("sunabouzu/inv_arrow_left.vmt")
	self.PreviousButton.DoClick = function()
			self:ShiftPosition(-1)
			LocalPlayer():EmitSound(INV_CLICK, 70, 100)
		end
	
	self.NextButton = vgui.Create("DImageButton", self)
	self.NextButton:SetMaterial("sunabouzu/inv_arrow_right.vmt")
	self.NextButton.DoClick = function()
			self:ShiftPosition(1)
			LocalPlayer():EmitSound(INV_CLICK, 70, 100)
		end
	
	self.UseButton = vgui.Create("DImageButton", self)
	self.UseButton:SetMaterial("sunabouzu/temp_use.vmt")
	self.UseButton:SetDrawBorder(false)
	self.UseButton:SetDrawBackground(false)
	self.UseButton:SetDisabled(false)
	self.UseButton.DoClick = function(self)
			local item = self:GetParent().Item
			
			if item then RunConsoleCommand("evil_use_item", item:GetID()) end
		end
	
	self.Description = vgui.Create("DLabel", self)
	self.Description:SetFont("evilDescription")
	self.Description:SetText("")
	self.Description:SetWrap(true)
	self.Description:SetAutoStretchVertical(true)
end

function PANEL:ShiftPosition(dir)
	if dir == 0 then return end
	
	local inv = LocalPlayer():GetInventory()
	if inv then
		local newPos, size = self:GetPosition() + dir, #inv
		
		if size > 0 then
			if newPos < 1 then
				newPos = size
			elseif newPos > size then
				newPos = 1
			end
		else
			newPos = 1
		end
		
		self:SetPosition(newPos)
	end
end

function PANEL:SetPosition(pos)
	if self.ItemPosition != pos then
		local inv = LocalPlayer():GetInventory()
		self.ItemPosition = pos
		
		if inv then
			local item = getItemByID(inv[pos])
			
			if item then
				self.Item = item
				self.Description:SetText(item:GetDescription())
				
				self.Icon:SetModel(item:GetModel(), item:GetSkin())
				self:ResetIcon()
				
				if item:GetCamPos() then self.Icon:SetCamPos(item:GetCamPos()) end
				if item:GetLookAtPos() then self.Icon:SetLookAt(item:GetLookAtPos()) end
				if item:GetFOV() then self.Icon:SetFOV(item:GetFOV()) end
				
				self.UseButton:SetDisabled(!item:CanUse())
			end
		end
	end
end

function PANEL:GetPosition()
	return self.ItemPosition
end

function PANEL:Paint()
	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawRect(0, 0, ScrW(), ScrH())
	
	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(m_BarMaterial)
	surface.DrawTexturedRect((ScrW() / 2) - ScreenScale(128, true), ScreenScale(320, true), ScreenScale(256, true), ScreenScale(16, true))
	
	if self.Item then
		draw.DrawText(self.Item:GetName(), "evilItemName", ScrW() / 2, ScreenScale(285, true), Color(67, 116, 159), TEXT_ALIGN_CENTER)
	end
	
	// DEBUG STUFF
	if EVIL_CHEAT_CONVAR:GetBool() then
		local white, x, debugStr = Color(255, 255, 255, 255), ScrW() - 25, "%s X: %G Y: %G Z: %G"
		local camPos, lookPos = self.Icon:GetCamPos(), self.Icon:GetLookAt()
		
		draw.DrawText(string.format(debugStr, "CamPos", camPos.x, camPos.y, camPos.z), "ConsoleText", x, 25, white, TEXT_ALIGN_RIGHT)
		draw.DrawText(string.format(debugStr, "LookPos", lookPos.x, lookPos.y, lookPos.z), "ConsoleText", x, 40, white, TEXT_ALIGN_RIGHT)
		draw.DrawText("FOV: " .. self.Icon:GetFOV(), "ConsoleText", x, 55, white, TEXT_ALIGN_RIGHT)
		
		if (!self.NextCamCheck || self.NextCamCheck < CurTime()) then
			self.NextCamCheck = CurTime() + .1
			
			if input.IsKeyDown(KEY_R) then
				// Reset the position of the item
				self:ResetIcon()
			end
			
			if input.IsKeyDown(KEY_LBRACKET) then
				self.Icon:SetFOV(self.Icon:GetFOV() - 1)
			elseif input.IsKeyDown(KEY_RBRACKET) then
				self.Icon:SetFOV(self.Icon:GetFOV() + 1)
			end
		end
	end
end

function PANEL:ResetIcon()
	self.Icon:SetCamPos(Vector(50, 50, 50))
	self.Icon:SetLookAt(Vector(0, 0, 40))
	self.Icon:SetFOV(70)
end

function PANEL:PerformLayout()
	local center = ScrW() / 2
	local pos, w, h = ScreenScale(50, true), 
						ScreenScale(128, true), 
						ScreenScale(256, true)
	
	self.Icon:SetPos(center - w, pos)
	self.Icon:SetSize(h, h)
	
	self.PreviousButton:SetPos(center - ScreenScale(257, true), pos)
	self.PreviousButton:SetSize(w, h)
	
    self.NextButton:SetPos(center + ScreenScale(129, true), pos)
	self.NextButton:SetSize(w, h)
	
	self.UseButton:SetPos(ScrW() - (self.UseButton:GetWide() + 30), ScrH() - (self.UseButton:GetTall() + 10))
	self.UseButton:SetSize(ScreenScale(64), ScreenScale(32))
	
	self.Description:SetPos(center - ScreenScale(170, true), ScreenScale(335, true))
	self.Description:SetSize(ScreenScale(340, true), ScreenScale(100))
	
	self:SetPos(0, 0)
    self:SetSize(ScrW(), ScrH())
end

function PANEL:OnCursorMoved(x, y)
	if EVIL_CHEAT_CONVAR:GetBool() then
		local left, right = input.IsMouseDown(MOUSE_LEFT), input.IsMouseDown(MOUSE_RIGHT)
		
		if self.LastX && self.LastY then
			local icon = self.Icon
			local deltaX, deltaY = self.LastX - x, self.LastY - y
			local newVec = Vector(deltaX, deltaY, 0)
			
			if input.IsKeyDown(KEY_LSHIFT) || input.IsKeyDown(KEY_RSHIFT) then
				newVec.y = 0
			end
			
			if input.IsKeyDown(KEY_LCONTROL) || input.IsKeyDown(KEY_RCONTROL) then
				newVec.x = 0
			end
			
			if left then
				icon:SetCamPos(icon:GetCamPos() + newVec)
			end
			
			if right then
				icon:SetLookAt(icon:GetLookAt() + newVec)
			end
		end
		
		if left || right then
			self.LastX = x
			self.LastY = y
		else
			self.LastX = nil
			self.LastY = nil
		end
	end
end

function PANEL:OnMouseWheeled(delta)
	if EVIL_CHEAT_CONVAR:GetBool() then
		local icon = self.Icon
		local newVec = Vector(0, 0, delta)
		
		if input.IsMouseDown(MOUSE_LEFT) then
			icon:SetCamPos(icon:GetCamPos() + newVec)
		end
		
		if input.IsMouseDown(MOUSE_RIGHT) then
			icon:SetLookAt(icon:GetLookAt() + newVec)
		end
	end
end

vgui.Register("item_display", PANEL)