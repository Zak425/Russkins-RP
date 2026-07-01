util.AddNetworkString("RP_CallService")
util.AddNetworkString("RP_SendCallMarker")

net.Receive("RP_CallService", function(len, ply)
    if not IsValid(ply) or not ply:Alive() then return end
    if (ply.NextCall or 0) > CurTime() then
        ply:ChatPrint("Вы не можете вызывать спецслужбы так часто!")
        return
    end

    local teamID = net.ReadUInt(8)
    if teamID ~= TEAM_POLICE and teamID ~= TEAM_MEDIC then return end

    ply.NextCall = CurTime() + 60 -- 1 minute cooldown

    local callPos = ply:GetPos()
    local callerName = ply:Nick()
    local message = (teamID == TEAM_POLICE) and "Вызов Полиции" or "Вызов Скорой"
    local soundType = (teamID == TEAM_POLICE) and "npc/metropolice/vo/on1.wav" or "npc/overwatch/radiovoice/on3.wav"

    for _, v in ipairs(player.GetAll()) do
        if v:Team() == teamID then
            v:ChatPrint("[СИСТЕМА] Поступил новый вызов от " .. callerName .. "! Метка установлена на 5 минут.")
            v:EmitSound(soundType)
            
            net.Start("RP_SendCallMarker")
            net.WriteVector(callPos)
            net.WriteString(message)
            net.WriteString(callerName)
            net.Send(v)
        end
    end
end)
