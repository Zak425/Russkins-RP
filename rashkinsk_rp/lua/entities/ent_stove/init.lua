AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_c17/furniturestove001a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end
    
    self.IsCooking = false
    self.CookTime = 15
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    if self.IsCooking then
        return
    end

    local wep = activator:GetActiveWeapon()
    if IsValid(wep) and wep:GetClass() == "weapon_raw_meat" then
        activator:StripWeapon("weapon_raw_meat")
        
        self.IsCooking = true
        
        self.SizzleSound = CreateSound(self, "ambient/levels/canals/toxic_slime_sizzle3.wav")
        self.SizzleSound:Play()
        
        self.DummyMeat = ents.Create("prop_dynamic")
        self.DummyMeat:SetModel("models/foodnhouseholditems/steak1.mdl")
        self.DummyMeat:SetPos(self:GetPos() + self:GetUp() * 37 + self:GetRight() * -5)
        self.DummyMeat:SetAngles(self:GetAngles())
        self.DummyMeat:SetParent(self)
        self.DummyMeat:Spawn()

        timer.Create("StoveCooking_" .. self:EntIndex(), self.CookTime, 1, function()
            if IsValid(self) then
                self:FinishCooking()
            end
        end)
    else
        activator:ChatPrint("Возьмите сырое мясо в руки, чтобы начать готовить.")
    end
end

function ENT:FinishCooking()
    self.IsCooking = false
    if self.SizzleSound then self.SizzleSound:Stop() end
    self:EmitSound("buttons/bell1.wav", 75, 100)
    
    if IsValid(self.DummyMeat) then
        self.DummyMeat:Remove()
    end
    
    local meat = ents.Create("weapon_cooked_meat")
    if IsValid(meat) then
        local pos = self:GetPos() + self:GetUp() * 40 + self:GetRight() * -5
        meat:SetPos(pos)
        meat:SetAngles(self:GetAngles())
        meat:Spawn()
    end
end

function ENT:OnRemove()
    if self.SizzleSound then self.SizzleSound:Stop() end
    timer.Remove("StoveCooking_" .. self:EntIndex())
end
