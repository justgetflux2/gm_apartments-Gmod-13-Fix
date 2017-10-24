ENT.Type = "anim"
ENT.Base = "ent_puzzle_base"

hook.Add("PlayerBindPress", "StopInput", function(ply, bind, pressed)
		local veh = ply:GetScriptedVehicle()
		
		if ValidEntity(veh) then
			veh = veh:GetParent() 
			
			if ValidEntity(veh) && veh:GetClass() == "ent_typewriter" then 
				return true 
			end
		end
	end)