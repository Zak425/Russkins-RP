include("shared.lua")

function ENT:Draw()
    self:DrawModel()
    
    local pos = self:GetPos() + Vector(0,0,45)
    local ang = self:GetAngles()
    
    local ply = LocalPlayer()
    if ply:GetPos():DistToSqr(self:GetPos()) > 40000 then return end
    
    ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Forward(), 90)
    
    cam.Start3D2D(pos, ang, 0.1)
        draw.SimpleText("Плита", "ChatFont", 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("E - Готовить мясо", "TargetID", 0, 20, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
    
    ang:RotateAroundAxis(ang:Right(), 180)
    cam.Start3D2D(pos, ang, 0.1)
        draw.SimpleText("Плита", "ChatFont", 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("E - Готовить мясо", "TargetID", 0, 20, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end
