AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "cityrp_base"
ENT.PrintName = "Quran"
ENT.Category = "Holy Books"
ENT.Spawnable = true
ENT.Model = "models/props_lab/bindergreen.mdl"

if SERVER then
	function ENT:Use(activator, caller)
		if IsValid(caller) and caller:IsPlayer() then
			caller:SetNWInt("quran_amount", math.min(caller:GetNWInt("quran_amount", 0) + 1, 20))
			caller:ChatPrint("When you die, you will explode.\nRead the quran more times to increase the damage.")
			SafeRemoveEntity(self)
		end
	end
end
