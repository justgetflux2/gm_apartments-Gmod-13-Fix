include("shared.lua")
local LOCAL_TEXT_POSITION, HORIZONTAL_LIMIT, COLOR_BLACK = Vector(-13.5, 0, 15), 10, Color(0, 0, 0)
local m_KeyPressed = {}
local m_Sounds = {
		["keypress"] = Sound("typewriter/keystroke.mp3"),
		["unload"] = Sound("typewriter/roll.mp3")
	}
local m_PaperInterface

//Is the user currently using the typewriter?
local isBeingUsed = false

//Is the typewriter puzzle completed?
local isPuzzleCompleted = false

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

	--self:EmitSound(m_Sounds["keypress"], 100, math.random(90, 100))
	  self:EmitSound("typewriter/keystroke"..math.random(1,4)..".wav", 100, 100)

	m_PaperInterface:AddChar(char)
end

//Adds a new line to the typewriter
function doNewLine(typewriter)
	local text = m_PaperInterface:NewLine()

	if text then
		RunConsoleCommand("evil_typer", text, typewriter:EntIndex())

		typewriter.NextTypeCheck = CurTime() + 1.5
    
		typewriter:EmitSound("typewriter/rollpaper"..math.random(1,4)..".wav", 100, 100)
		--typewriter:EmitSound(m_Sounds["unload"], 100, 100)

		return
	end
end

function ENT:Think()
	//This verification will probably have to change when we go to multiplayer
	if !isBeingUsed || (self.NextTypeCheck && self.NextTypeCheck > CurTime()) then return end

	if input.IsKeyDown(KEY_END) then
		table.Empty(m_KeyPressed)

		m_PaperInterface:ClearLines()

		RunConsoleCommand("evil_typerleave", self:EntIndex())
		return
	end

	if input.IsKeyDown(KEY_ENTER) then
		if !m_KeyPressed[KEY_ENTER] then
			m_KeyPressed[KEY_ENTER] = true

			doNewLine(self)
			return
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
	else
		//If the current line feed is already full, a new line is intered
		/*local text = m_PaperInterface:NewLine()

			if text then
				RunConsoleCommand("evil_typer", text, self:EntIndex())

				self.NextTypeCheck = CurTime() + 1.5
				self:EmitSound(m_Sounds["unload"], 100, 100)

				return
			end
		*/
		doNewLine(self)
	end
end

/*If this is set to true, the typewriter interface will be enabled*/
usermessage.Hook("eviltyper_use", function(um)
		isBeingUsed = um:ReadBool()
		print("eviltyper_use called")
		print("args: bool = " .. tostring(isBeingUsed))
		if ValidPanel(m_PaperInterface) then
			m_PaperInterface:SetVisible(isBeingUsed)
			/*It seems like the typewriter keeps accepting input after
			the player has left and then displays them, a way to circumvent
			a way this is to simply clear the screen when the player reEnters
			the TW; I told you these solutions were VERY bruteforce*/
			//m_PaperInterface:ClearLines()
		end

		local writer = um:ReadEntity()
		print("writer");print(writer);print("\n")

		//Fixes the typewriter registering the user key by delaying input reception
		writer.NextTypeCheck = CurTime() + .4
	end
)

hook.Remove("OnSpawnMenuOpen", "DontOpen", function()
		print("hook.Remove OnSpawnMenuOpen DontOpen called")
		local veh = LocalPlayer():GetScriptedVehicle()

		if IsValid(veh) then
			veh = veh:GetParent()

			if IsValid(veh) && veh:GetClass() == "ent_typewriter" then
				return true
			end
		end
	end
)
