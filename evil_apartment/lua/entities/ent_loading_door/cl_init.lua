include("shared.lua")

local m_DisableView = false
local m_LoadTextures = {
		["normal"] = Material("sunabouzu/load_normal"),
		["special"] = Material("sunabouzu/load_special")
	}
local m_CurrLoadingTexture

hook.Add("RenderScreenspaceEffects", "FadeEffect", function()
		if m_DisableView then
			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawRect(0, 0, ScrW(), ScrH())
			
			if m_CurrLoadingTexture then
				// >Implying that all load textures will be 512x256
				local w, h = ScreenScale(256), ScreenScale(128)
				
				surface.SetMaterial(m_CurrLoadingTexture)
				surface.DrawTexturedRect( ScrW() - w, ScrH() - h, w, h)
			end
		end
	end)

function ENT:SetTransition(isOn)
	m_DisableView = isOn
	
	if isOn then
		local override = self:GetLoadingScreen()
		
		if override && override != "" then
			if !m_LoadTextures[override] then
				m_LoadTextures[override] = Material(override)
			end
			
			m_CurrLoadingTexture = m_LoadTextures[override]
		else
			if math.Rand(0, 1) <= .03 then
				m_CurrLoadingTexture = m_LoadTextures["special"]
			else
				m_CurrLoadingTexture = m_LoadTextures["normal"]
			end
		end
	else
		m_CurrLoadingTexture = nil
	end
end

usermessage.Hook("re_startloading", function(um)		
		local door = ents.GetByIndex(um:ReadShort())
		
		if ValidEntity(door) && door:GetClass() == "ent_loading_door" then
			door:DoTransition(LocalPlayer())
		end
	end)
	
hook.Add("HUDShouldDraw", "RemoveHUDForLoading", function(elem)
		if m_DisableView then return false end
	end)