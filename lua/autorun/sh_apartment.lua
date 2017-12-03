if string.sub(game.GetMap(),1,12) == "gm_apartment" then
	if !game.SinglePlayer() then
		print("THIS WAS A BAD IDEA, WHY DID I STICK IT IN THE TOASTER")
		RunConsoleCommand("killserver")
		return
	end


	EVIL_CHEAT_CONVAR = CreateConVar("sv_evil_cheats", "0", {FCVAR_REPLICATED, FCVAR_CHEAT}, "Enable Evil Apartment cheats.")

	hook.Add("PlayerSwitchFlashlight", "DisableFlashLight", function(ply, SwitchOn)
				return false
			end)
	--for _, v in pairs(file.Find("autorun/vgui/*.lua", "LUA" )) do include("vgui/" .. v) end

	if CLIENT then
	include("inventory/sh_init.lua")
	include("vgui/item_display.lua")
	include("vgui/story_time.lua")
	include("vgui/typewriter_paper.lua")
	include("stories/sh_init.lua")
  end

	 game.AddParticles("particles/lighter.pcf")
	 game.AddParticles("particles/weather.pcf")
	 PrecacheParticleSystem("lighter_flame")

	local metaPlayer = FindMetaTable("Player")

	function metaPlayer:ShouldDrawCrosshair()
		return self:GetNWBool("DrawCrosshair", true)
	end

	function metaPlayer:SetDrawCrosshair(shouldDraw)
		self:SetNWBool("DrawCrosshair", shouldDraw)
	end

	metaPlayer = nil

	if SERVER then
		local itemsToGive = {
				"item_lighter"
			}

		hook.Add("PlayerLoadout", "RemoveAll", function(ply)
				for _, wep in pairs(itemsToGive) do
					ply:Give(wep)
				end

				if !ply:HasItem(2) then
					// Give the "lighter" item
					ply:GiveItem(2)
				end

				return true
			end)

		hook.Add("PlayerSpawn", "PickupNoticeFix", function(ply)
			ply:SetSuppressPickupNotices(true)
		end)

		local speedfix = false
		hook.Add("Think", "ChangeSpeed", function(ply)
			if !speedfix then
				for _, ply in ipairs(player.GetAll()) do
					if IsValid(ply) && ply:Alive() then
						GAMEMODE:SetPlayerSpeed( ply, 200, 200 )
						ply:SetJumpPower(120)
						speedfix = true
					end
				end
			end
		end)

		/*hook.Add("PlayerCanPickupWeapon", "NoPickingUp", function(ply, wep)
				return table.HasValue(itemsToGive, wep:GetName())
			end)*/

		        hook.Add("EntityTakeDamage", "NoDamagePlease", function(ent, dmginfo)
			local attacker = dmginfo:GetAttacker()
                        local inflictor = dmginfo:GetInflictor()
                        local amount = dmginfo:GetDamage()
			if ent:IsPlayer() then
			dmginfo:ScaleDamage(0)
				end
			end)

	else
		local metaEntity = FindMetaTable("Entity")

		function metaEntity:Visible(ent)
			return self:VisibleVec(ent:EyePos())
		end

		function metaEntity:VisibleVec(vec)
			local trace = util.TraceLine({
					["start"] = self:EyePos(),
					["endpos"] = vec,
					["filter"] = self,
					["mask"] = MASK_VISIBLE})

			return !trace.Hit
		end

		metaEntity = nil

		local m_DisableDrawing = {
				"CHudDamageIndicator",
				"CHudHealth",
				"CHudWeaponSelection",
				"CHudZoom"
			}

		hook.Add("HUDShouldDraw", "RemoveElements", function(elem)
				if table.HasValue(m_DisableDrawing, elem) then return false end
			end)

		local m_VignetteEnabled = true
		local m_Vignette = Material("sunabouzu/apartment_vignette")

		hook.Add("HUDPaintBackground", "DoVignetteEffects", function()
				if m_VignetteEnabled then
					surface.SetDrawColor(0, 0, 0, 200)
					surface.SetMaterial(m_Vignette)
					surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
				end
			end)

		function enableVignette(enable)
			m_VignetteEnabled = tobool(enable)
		end

		function AspectRatio()
			return ScrW() / ScrH()
		end

		function ScreenScale(size, adjustAspect)
			local scale = size * ( ScrW() / 640.0 )
			local default = 4 / 3

			if adjustAspect && AspectRatio() != default then
				// What this is doing is reducing the scale by x, x being the difference between 4:3 and the other ratios
				local adjustment = 1 - (math.abs(AspectRatio() - default) / default)

				return scale * adjustment
			end

			return scale
		end

		// mirror fix (taken from gmt)
		local scrw, scrh = ScrW(), ScrH()
		local rtw, rth = 0, 0

		hook.Add( "ShouldDrawLocalPlayer", "MirrorFix", function()
			if (rtw == 0 || rth == 0) && (ScrW() < scrw && ScrH() < scrh) then
				rtw = ScrW()
				rth = ScrH()
			end

			if ScrW() == rtw && ScrH() == rth && render.GetRenderTarget():GetName() == "_rt_waterreflection" then
				return true
			end
		end )
	end

	function math.ApproachVector(curr, dist, inc)
		return Vector(math.Approach(curr.x, dist.x, inc),
						math.Approach(curr.y, dist.y, inc),
						math.Approach(curr.z, dist.z, inc))
	end

	function math.ApproachAngleEx(curr, dist, inc)
		return Angle(math.ApproachAngle(curr.p, dist.p, inc),
						math.ApproachAngle(curr.y, dist.y, inc),
						math.ApproachAngle(curr.r, dist.r, inc))
	end

	function math.WrapNumber(num, min, max)
		local result = (num % max)

		if num < min then
			// Wrap to max
			return max - result
		elseif num > max then
			// Wrap to min
			return min + result
		end

		return num
	end

	hook.Add("PlayerNoClip", "DisableNoClip", function(ply) return EVIL_CHEAT_CONVAR:GetBool() end)
end
