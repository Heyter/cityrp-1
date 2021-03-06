AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Bitminer Base"
ENT.Category = "Bitminers"
ENT.Spawnable = false
ENT.Model = "models/props_c17/consolebox01a.mdl"

ENT.IsBitminer = true
ENT.MineSeconds = 5
ENT.MineAmount = 1

local BITCOIN_COST = 2500

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "LastPrint")
	self:NetworkVar("Int", 0, "StoredCoins")
end

if SERVER then
	function ENT:Initialize()
		self:SetModel(self.Model)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:PhysWake()

		self:SetLastPrint(CurTime())
		self:SetStoredCoins(0)
	end

	function ENT:Think()
		if CurTime() - self:GetLastPrint() >= self.MineSeconds then
			self:SetLastPrint(CurTime())
			self:SetStoredCoins(self:GetStoredCoins() + self.MineAmount)
		end

		self:NextThink(CurTime() + 0.2)
		return true
	end

	function ENT:Use(activator, caller)
		if IsValid(caller) and caller:IsPlayer() and self:GetStoredCoins() > 0 then
			local money = self:GetStoredCoins() * BITCOIN_COST
			caller:addMoney(money)
			caller:ChatPrint("Collected " .. self:GetStoredCoins() .. " coins worth " .. DarkRP.formatMoney(money) .. ".")
			self:SetStoredCoins(0)
		end
	end
end

if CLIENT then
	hook.Add("HUDPaint", "BitminerHUD", function()
		if not LocalPlayer():GetEyeTrace().Entity.IsBitminer then return end

		local ent = LocalPlayer():GetEyeTrace().Entity

		local w = ScrW()
		local h = ScrH()
		local x, y, width, height = w / 2 - w / 10, h / 2 + 40, w / 5, h / 15
		draw.RoundedBox(8, x, y, width, height, Color(10, 10, 10, 120))

		local prog = math.Clamp(CurTime() - ent:GetLastPrint(), 0, ent.MineSeconds)
		local status = math.Clamp(prog / ent.MineSeconds, 0, 1)
		local BarWidth = status * (width - 16)
		local cornerRadius = math.Min(8, BarWidth / 3 * 2 - BarWidth / 3 * 2 % 2)
		draw.RoundedBox(cornerRadius, x + 8, y + 8, BarWidth, height - 16, Color(255 - (status * 255), 0 + (status * 255), 0, 255))
		draw.SimpleText("Coins: " .. ent:GetStoredCoins(), "Trebuchet24", w / 2, y + height / 2, color_white, 1, 1)
	end)

	function ENT:Draw()
		self:DrawModel()
	end
end
