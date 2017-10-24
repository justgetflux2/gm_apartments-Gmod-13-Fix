ENT.Type = "anim"
ENT.Base = "ent_puzzle_base"

hook.Remove("PlayerBindPress", "StopInput", function(Vehicle, ply, bind, pressed)
		print("hook.remove playerbindpress called")
		//local veh = ply:GetScriptedVehicle()
		  local veh = Vehicle:GetVehicle()

		if IsValid(veh) then
			veh = veh:GetParent()

			if IsValid(veh) && veh:GetClass() == "ent_typewriter" then
				return true
hook.Add("PlayerBindPress", "StopInput", function(ply, bind, pressed)
		local veh = ply:GetScriptedVehicle()
		
		if ValidEntity(veh) then
			veh = veh:GetParent() 
			
			if ValidEntity(veh) && veh:GetClass() == "ent_typewriter" then 
				return true 
			end
		end
	end)
	end)