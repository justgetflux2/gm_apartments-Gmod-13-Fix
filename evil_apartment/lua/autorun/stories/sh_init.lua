local STORYOBJ = {}
local m_StoryDatabase = {}

function STORYOBJ:Init()
	local o = {}

	setmetatable(o, self)
	self.__index = self

	/*o.ID = nil
	o.Sound = nil
	o.Brother = nil
	*/

	o.Content = "WAT"
	o.Rate = .25
	o.Volume = 1 // Float 0-1
	o.Pitch = 100 // Integer 0-100
	return o
end

function STORYOBJ:GetID() return self.ID end
function STORYOBJ:GetContent() return self.Content end
function STORYOBJ:GetRate() return self.Rate end
function STORYOBJ:GetSound() return self.Sound end
function STORYOBJ:GetBrother() return self.Brother end
function STORYOBJ:GetVolume() return self.Volume end
function STORYOBJ:GetPitch() return self.Pitch end

function getStoryByID(id)
	return id && m_StoryDatabase[id]
end

function storyExists(id)
	return getStoryByID(id) != nil
end

local function includeAll()
	local dir = "autorun/stories/stories/"
	local files = file.Find(dir .. "*.lua", "LUA")
	local err

	if #files > 0 then
		for _, v in ipairs(files) do
			STORY = STORYOBJ:Init()

			include(dir .. v)

			err = (!STORY:GetID() && "(No ID given)")
				|| (type(STORY:GetID()) != "number" && "(ID is not a number)")
				|| (STORY:GetID() < 1 && "(ID below positive one)")
				|| false

			if err then
				MsgN("Invalid Story ID!" .. err)
			else
				if !m_StoryDatabase[STORY:GetID()] then
					if SERVER then
						AddCSLuaFile(dir .. v)
					else
						if STORY.Sound then util.PrecacheSound(STORY.Sound) end
						if STORY.Brother == STORY.ID then
							MsgN("Story " .. STORY:GetID() .. " is it's only brother(EWWW, INCEST).")
							STORY.Brother = nil
						end
					end

					m_StoryDatabase[STORY:GetID()] = STORY
				else
					MsgN("Duplicate Story ID: " .. STORY:GetID())
				end
			end

			STORY = nil
		end
	else
		MsgN("There are no stories in the story folder!")
	end

	if SERVER then m_StoryDatabase = nil end // Only used for verifying
	STORYOBJ = nil // This isn't needed anymore. Time to GC it
end

includeAll()
includeAll = nil
