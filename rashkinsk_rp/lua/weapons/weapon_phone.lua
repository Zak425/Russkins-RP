if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_base"
SWEP.PrintName = "Телефон"
SWEP.Instructions = "ЛКМ - Открыть контакты для вызова спецслужб."
SWEP.Category = "ZCity Other"
SWEP.Spawnable = true
SWEP.Slot = 5
SWEP.SlotPos = 2

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Wait = 1
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.WorldModel = "models/ivancorn/gtaiv/electrical/phones/cellphone_whiz_highspeed.mdl"
SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.UseHands = true

SWEP.Offset = {
    Pos = {
        x = 3,
        y = -1.5,
        z = -3
    },
    Ang = {
        x = 0,
        y = 100,
        z = 180
    }
}

function SWEP:DrawWorldModel()
    local owner = self:GetOwner()
    if IsValid(owner) then
        local boneid = owner:LookupBone("ValveBiped.Bip01_R_Hand")
        if not boneid then self:DrawModel() return end
        
        local matrix = owner:GetBoneMatrix(boneid)
        if not matrix then self:DrawModel() return end
        
        local newPos, newAng = LocalToWorld(
            Vector(self.Offset.Pos.x, self.Offset.Pos.y, self.Offset.Pos.z),
            Angle(self.Offset.Ang.x, self.Offset.Ang.y, self.Offset.Ang.z),
            matrix:GetTranslation(),
            matrix:GetAngles()
        )
        
        self:SetRenderOrigin(newPos)
        self:SetRenderAngles(newAng)
        self:DrawModel()
    else
        self:SetRenderOrigin(nil)
        self:SetRenderAngles(nil)
        self:DrawModel()
    end
end

function SWEP:Initialize()
	self:SetHoldType("slam")
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 1)
	
	if CLIENT then
		if IsValid(RP_PhoneMenu) then
			RP_PhoneMenu:Remove()
		end
		
		RP_PhoneMenu = vgui.Create("DFrame")
		RP_PhoneMenu:SetSize(300, 200)
		RP_PhoneMenu:SetTitle("Мобильный телефон")
		RP_PhoneMenu:Center()
		RP_PhoneMenu:MakePopup()
		
		local btnPolice = vgui.Create("DButton", RP_PhoneMenu)
		btnPolice:SetPos(10, 30)
		btnPolice:SetSize(280, 70)
		btnPolice:SetText("Вызвать Полицию")
		btnPolice.DoClick = function()
			net.Start("RP_CallService")
			net.WriteUInt(TEAM_POLICE, 8)
			net.SendToServer()
			LocalPlayer():ChatPrint("Вы вызвали полицию. Ожидайте.")
			RP_PhoneMenu:Remove()
		end
		
		local btnMedic = vgui.Create("DButton", RP_PhoneMenu)
		btnMedic:SetPos(10, 110)
		btnMedic:SetSize(280, 70)
		btnMedic:SetText("Вызвать Скорую Помощь")
		btnMedic.DoClick = function()
			net.Start("RP_CallService")
			net.WriteUInt(TEAM_MEDIC, 8)
			net.SendToServer()
			LocalPlayer():ChatPrint("Вы вызвали скорую. Ожидайте.")
			RP_PhoneMenu:Remove()
		end
	end
end

function SWEP:SecondaryAttack()
end
