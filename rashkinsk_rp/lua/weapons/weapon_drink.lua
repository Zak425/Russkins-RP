if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_bigconsumable"
SWEP.PrintName = "Напиток"
SWEP.Instructions = "Освежающий напиток."
SWEP.Category = "ZCity Cooking"
SWEP.Spawnable = true
SWEP.WorldModel = "models/jorddrink/the_bottle_of_water.mdl"

function SWEP:InitializeAdd()
	self.FoodModels = {
		"models/jorddrink/the_bottle_of_water.mdl",
		"models/foodnhouseholditems/juice.mdl",
		"models/foodnhouseholditems/cola.mdl",
		"models/jorddrink/sprcan01a.mdl",
		"models/jorddrink/pepcan01a.mdl"
	}
	self:SetHold(self.HoldType)
	if SERVER then
		local model = self.FoodModels[math.random(#self.FoodModels)]
		self:SetModel(model)
		self:SetCurModel(model)
		self.WorldModel = model
		
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
		end
	end
end

if SERVER then
	function SWEP:Heal(ent, mode)
		if ent:IsNPC() then
			if not self.DoNotDropModels[self:GetCurModel()] then
				self:SpawnGarbage(self:GetCurModel() or nil)
			end
			self:NPCHeal(ent, 0.2, "snd_jack_hmcd_drink"..math.random(3)..".wav")
		end

		local org = ent.organism
		if not org then return end

		if self.CDEating and self.CDEating > CurTime() then return end

		local owner = self:GetOwner()
		if ent == hg.GetCurrentCharacter(owner) and GetConVar("hg_healanims"):GetBool() then
			self:SetHolding(math.min(self:GetHolding() + 10, 100))
			if self:GetHolding() < 100 then return end
		end

		org.satiety = math.min(org.satiety + 15, 100)

		owner:ViewPunch(Angle(6, 0, 0))
		ent:EmitSound("snd_jack_hmcd_drink"..math.random(3)..".wav", 60, math.random(95, 105))
		
		self.CDEating = CurTime() + 0.5
		self.Eating = (self.Eating or 0) + 1

		if self.Eating > 3 then
			owner:SelectWeapon("weapon_hands_sh")
			if not self.DoNotDropModels[self:GetCurModel()] then
				self:SpawnGarbage(self:GetCurModel() or nil)
			end
			self:Remove()
		end
		
		return true
	end
end
