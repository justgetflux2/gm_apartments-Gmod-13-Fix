include("shared.lua")
local LOCAL_TEXT_POSITION, HORIZONTAL_LIMIT, COLOR_BLACK = Vector(-13.5, 0, 15), 10, Color(0, 0, 0)
local m_KeyPressed = {}
local m_Sounds = {
		["keypress"] = Sound("typewriter/keystroke.mp3"),
		["unload"] = Sound("typewriter/roll.mp3")
	}
local m_PaperInterface

function ENT:Initialize()
	if !ValidPanel(m_PaperInterface) then
		m_PaperInterface = vgui.Create("typewriter_paper")
		m_PaperInterface:SetVisible(false)
	end
end

function ENT:DoKeyStroke(key, shift)
	// Handle Keys
	
	local char
	
	if key >= KEY_0 && key < KEY_0 + 10 then
		char = (key - KEY_0) + 48
	elseif key >= KEY_A && key < KEY_A + 26 then
		char = (key - KEY_A) + ((shift && 65) || 97)
	elseif key == KEY_SPACE then
		char = 32
	else
		return
	end
	
	self:EmitSound(m_Sounds["keypress"], 100, math.random(90, 100))
	
	m_PaperInterface:AddChar(char)
end

function ENT:Think()
	if self:GetUserID() != LocalPlayer():EntIndex() || (self.NextTypeCheck && self.NextTypeCheck > CurTime()) then return end
	
	if input.IsKeyDown(KEY_END) then
		table.Empty(m_KeyPressed)
		
		m_PaperInterface:ClearLines()
		
		RunConsoleCommand("evil_typerleave")
		
		return
	end
	
	if input.IsKeyDown(KEY_ENTER) then
		if !m_KeyPressed[KEY_ENTER] then
			m_KeyPressed[KEY_ENTER] = true
			
			local text = m_PaperInterface:NewLine()
						
			if text then
				RunConsoleCommand("evil_typer", text)
				
				self.NextTypeCheck = CurTime() + 1.5
				self:EmitSound(m_Sounds["unload"], 100, 100)
				
				return
			end
		end
	else
		if m_KeyPressed[KEY_ENTER] then
			m_KeyPressed[KEY_ENTER] = false
		end
	end
	
	if input.IsKeyDown(KEY_BACKSPACE) then
		if !m_KeyPressed[KEY_BACKSPACE] then
			m_KeyPressed[KEY_BACKSPACE] = true
			
			self:EmitSound(m_Sounds["unload"], 100, 100)
			
			self.NextTypeCheck = CurTime() + 1.5
			m_PaperInterface:ClearLines()
			
			return
		end
	else
		if m_KeyPressed[KEY_BACKSPACE] then
			m_KeyPressed[KEY_BACKSPACE] = false
		end
	end
	
	if m_PaperInterface:AbleToProcessMoreCharacters() then
		local keyBeenPressed = false
		
		if input.IsKeyDown(KEY_SPACE) then
			if !m_KeyPressed[KEY_SPACE] then
				m_KeyPressed[KEY_SPACE] = true
				
				keyBeenPressed = true
				self:DoKeyStroke(KEY_SPACE)
			end
		else
			if m_KeyPressed[KEY_SPACE] then
				m_KeyPressed[KEY_SPACE] = false
			end
		end

		// Determine if there's any modifiers
		local shift = input.IsKeyDown(KEY_LSHIFT) || input.IsKeyDown(KEY_RSHIFT)
		
		// Catch Key presses
		for i=1, 36 do
			if input.IsKeyDown(i) then
				if !m_KeyPressed[i] then
					m_KeyPressed[i] = true
					
					keyBeenPressed = true
					self:DoKeyStroke(i, shift)
				end
			else
				if m_KeyPressed[i] then
					m_KeyPressed[i] = false
				end
			end
		end
		
		if keyBeenPressed then
			self.NextTypeCheck = CurTime() + .05
		end
	end
end

usermessage.Hook("eviltyper_use", function(um)
		if ValidPanel(m_PaperInterface) then
			m_PaperInterface:SetVisible(um:ReadBool())
		end

		// fix bug where the type writer would register use button
		local ent = um:ReadEntity()
		if IsValid( ent ) then ent.NextTypeCheck = CurTime() + .5 end
	end)

hook.Add("OnSpawnMenuOpen", "DontOpen", function()
		local veh = LocalPlayer():GetScriptedVehicle()
		
		if ValidEntity(veh) then
			veh = veh:GetParent()
			
			if ValidEntity(veh) && veh:GetClass() == "ent_typewriter" then 
				return true
			end
		end
	end)