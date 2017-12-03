ITEM.ID = 1
ITEM.Skin = 0
ITEM.Name = "Vitamin Blend"
ITEM.Model = "models/Items/HealthKit.mdl"
ITEM.PickupSound = "sunabouzu/Vitamin_pickup_"..math.random(1,3)..".wav"
ITEM.Description = "It's a popular sports drink, I see advertisements for it everywhere. Some kid died by drinking too much of this junk, it was a big news story a while ago."
ITEM.Use = function(self, ply)
		local maxHealth = ply:GetMaxHealth()

		if ply:Health() >= maxHealth then return false end

		local newHealth = math.Clamp((ply:Health() / 2) + ply:Health(), 1, maxHealth)

		ply:SetHealth(newHealth)

		return true
	end
