include("shared.lua")

local m_StoryPanel

usermessage.Hook("evil_story", function(um)
		local play = um:ReadBool()
		
		if play then
			local id = um:ReadShort()
			
			if storyExists(id) then
				// Play Story
				if !ValidPanel(m_StoryPanel) then
					m_StoryPanel = vgui.Create("story_time")
				end
				
				m_StoryPanel:PlayStory(id)
			end
		else
			if ValidPanel(m_StoryPanel) then
				m_StoryPanel:StopStory(true)
			end
		end
	end)