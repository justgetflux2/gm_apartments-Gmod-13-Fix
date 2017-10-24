ENT.Type = "anim"
ENT.Base = "ent_puzzle_base"

hook.Remove("PlayerBindPress", "StopInput", function(Vehicle, ply, bind, pressed)
		--local veh = ply:GetScriptedVehicle()
		  local veh = Vehicle:GetVehicleClass()

		if IsValid(veh) then
			veh = veh:GetParent()

			if IsValid(veh) && veh:GetClass() == "ent_typewriter" then
				return true
			end
		end
	end)
