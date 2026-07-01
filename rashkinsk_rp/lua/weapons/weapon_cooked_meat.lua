if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_bigconsumable"
SWEP.PrintName = "Жареное мясо"
SWEP.Instructions = "Хорошо прожаренное мясо. Отлично утоляет голод."
SWEP.Category = "ZCity Cooking"
SWEP.Spawnable = true

SWEP.WorldModel = "models/foodnhouseholditems/steak2.mdl"
SWEP.FoodModels = {
	"models/foodnhouseholditems/steak2.mdl"
}
SWEP.DoNotDropModels = {
	["models/foodnhouseholditems/steak2.mdl"] = true
}

function SWEP:InitializeAdd()
	self:SetHold(self.HoldType)
	self:SetModel(self.WorldModel)
	self:SetCurModel(self.WorldModel)
	if SERVER then
		timer.Simple(0, function() 
			self:PhysicsInit(SOLID_VPHYSICS)
			if IsValid(self:GetPhysicsObject()) then
				self:GetPhysicsObject():Wake()
			end
		end)
	end
end

if SERVER then
	function SWEP:Heal(ent, mode)
		if ent:IsNPC() then
			if not self.DoNotDropModels[self:GetCurModel()] then
				self:SpawnGarbage(self:GetCurModel() or nil)
			end
			self:NPCHeal(ent, 0.2, "snd_jack_hmcd_eat"..math.random(4)..".wav")
		end

		local org = ent.organism
		if not org then return end

		if self.CDEating and self.CDEating > CurTime() then return end

		local owner = self:GetOwner()
		if ent == hg.GetCurrentCharacter(owner) and GetConVar("hg_healanims"):GetBool() then
			self:SetHolding(math.min(self:GetHolding() + 10, 100))

			if self:GetHolding() < 100 then
				return
			end
		end

		org.satiety = math.min(org.satiety + 50, 100)

		owner:ViewPunch(Angle(6, 0, 0))
		
		ent:EmitSound("snd_jack_hmcd_eat"..math.random(4)..".wav", 60, math.random(95, 105))
		self.CDEating = CurTime() + 0.5
		self.Eating = (self.Eating or 0) + 1

		if self.Eating > 4 then
			owner:SelectWeapon("weapon_hands_sh")
			if not self.DoNotDropModels[self:GetCurModel()] then
				self:SpawnGarbage(self:GetCurModel() or nil)
			end
			self:Remove()
		end
		
		return true
	end
end
