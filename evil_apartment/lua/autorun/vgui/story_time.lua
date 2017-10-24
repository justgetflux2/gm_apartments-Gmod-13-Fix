local PANEL = {}
local m_NextButton = Material("sunabouzu/mouse_left_prompt")
local m_ButtonSize

function PANEL:Init()
	surface.CreateFont("Calibri", ScreenScale(20), 500, true, false, "storytime")

	self.StoryText = vgui.Create("DLabel", self)
	self.StoryText:SetWrap(true)
	self.StoryText:SetTextColor(Color(255, 255, 255))
	self.StoryText:SetFont("storytime")
	self.StoryText:SetAutoStretchVertical(true)
	
	self.ButtonAlpha = 0
end

function PANEL:Paint()
	if self:HasStory() then
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, ScrW(), ScrH())
		
		if self:IsTyping() then
			self:DoType()
		else
			// Draw Blinking button in corner
			self:DoPrompt()
			
			// Catch input
			if input.IsMouseDown(MOUSE_LEFT) then
				self.ContentIndex = self.ContentIndex + 1
				
				if #self.Story:GetContent() >= self.ContentIndex then
					self:ClearText()
				else
					if self.Story:GetBrother() then
						self:PlayStory(self.Story:GetBrother())
					else
						self:StopStory(true, true)
					end
				end
			end
		end
	end
end

function PANEL:PlayStory(id)
	if self:HasStory() then
		self:StopStory()
	end
	
	local story = getStoryByID(id)
	
	if story then
		self:ClearText()
		
		self.Story = story
		self.ContentIndex = 1
		
		if story:GetSound() then
			self.Sound = CreateSound(LocalPlayer(), story:GetSound())		
			self.Sound:SetSoundLevel(0) // Plays it EVERYWHERE
			self.Sound:Play(self.Story:GetVolume(), self.Story:GetPitch())
		end
		
		self:SetVisible(true)
		
		enableVignette(false)
	end
end

function PANEL:StopStory(hide, tellServer)
	self.Story = nil
	self.SoundNextLoop = nil
	self.ContentIndex = nil
	
	self.Buffer = nil

	if self.Sound then
		self.Sound:Stop()
	end
	
	self.Sound = nil
	
	if hide then
		enableVignette(true)
		self:SetVisible(false)
	end
	
	if tellServer then
		//RunConsoleCommand("evil_story_done")
	end
end

function PANEL:HasStory()
	return self.Story != nil
end

function PANEL:IsTyping()
	return self.Story 
		&& self.Story:GetContent()
		&& self.Story:GetContent()[self.ContentIndex] 
		&& #self.Buffer < #self.Story:GetContent()[self.ContentIndex] 
end

function PANEL:DoType()
	if !self.NextType || self.NextType <= CurTime() then
		local rate = self.Story:GetRate()
		
		if input.IsKeyDown(KEY_SPACE) then
			rate = rate / 4
		end
		
		self.NextType = CurTime() + rate
		
		// Add the next character
		self:AddText(self.Story:GetContent()[self.ContentIndex][#self.Buffer + 1])
	end
end

function PANEL:DoPrompt()	
	self.ButtonAlpha = math.WrapNumber(self.ButtonAlpha + .01, 0, 2 * math.pi)

	surface.SetDrawColor(255, 255, 255, math.abs(math.sin(self.ButtonAlpha)) * 255)
	surface.SetMaterial(m_NextButton)
	surface.DrawTexturedRect(ScrW() - m_ButtonSize, ScrH() - m_ButtonSize - 10, m_ButtonSize, m_ButtonSize)
end

function PANEL:DoFade()

end

function PANEL:ClearText()
	self.Buffer = ""
	self.StoryText:SetText(self.Buffer)
end

function PANEL:AddText(v)
	self.Buffer = self.Buffer .. v
	self.StoryText:SetText(self.Buffer)
end

function PANEL:PerformLayout()
	local buffer = ScreenScale(10, true)
	
	self.StoryText:SetPos(buffer, buffer)
	self.StoryText:SetSize(ScrW() - buffer, ScrH() * .95)
	
	m_ButtonSize = ScreenScale(32, true)
	
	self:SetPos(0, 0)
	self:SetSize(ScrW(), ScrH())
end

vgui.Register("story_time", PANEL)