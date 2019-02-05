
-- Included here for simplification
-- Original:
-- https://github.com/Exho1/Hitmarkers

if SERVER then
	resource.AddFile("hitmarkers/mlg.wav")

	util.AddNetworkString("DrawHitMarker")
	util.AddNetworkString("OpenMixer")

	hook.Add("EntityTakeDamage","HitmarkerDetector",function( ply, dmginfo )
		local att = dmginfo:GetAttacker()
		local dmg = dmginfo:GetDamage()
		
		if (IsValid(att) and att:IsPlayer() and att ~= ply) then
			if (ply:IsPlayer() or ply:IsNPC()) then -- Only players and NPCs show hitmarkers
				net.Start("DrawHitMarker")
				net.Send(att) -- Send the message to the attacker
			end
		end
	end)

	hook.Add( "PlayerSay", "ColorMixerOpen", function(ply, text, public)
		local text = string.lower(text)
		if (string.sub(text, 1, 8) == "!hmcolor") then
				net.Start("OpenMixer")
				net.Send(ply)
			return ""
		end
	end)
else -- CLIENT
	-- Declare our convars and variables
	local hm_toggle = CreateClientConVar("hm_enabled", "1", true, true)	
	local hm_type = CreateClientConVar("hm_hitmarkertype", "lines", true, true)
	local hm_color = CreateClientConVar("hm_hitmarkercolor", "255, 255, 0", true, true)
	local hm_sound = CreateClientConVar("hm_hitsound", "1", true, true)	
	local DrawHitM = false
	local CanPlayS = true
	local alpha = 0

	local function GrabColor() -- Used for retrieving the console color
		local coltable = string.Explode( ",", hm_color:GetString() )
		local newcol = {}

		for k,v in pairs(coltable) do
			v = tonumber(v)
			if v == nil then -- Fixes missing values
				coltable[k] = 0
			end
		end

		newcol[1], newcol[2], newcol[3] = coltable[1] or 0, coltable[2] or 0, coltable[3] or 0 -- Fixes missing keys
		return Color(newcol[1], newcol[2], newcol[3]) -- Returns the finished color
	end

	net.Receive( "OpenMixer", function( len, ply ) -- Receive the server message
		-- Creating the color mixer panel
		local Frame = vgui.Create( "DFrame" )
		Frame:SetTitle( "Hitmarker Color Config" )
		Frame:SetSize(300,400)
		Frame:Center()			
		Frame:MakePopup()

		local colMix = vgui.Create( "DColorMixer", Frame )
		colMix:Dock(TOP)
		colMix:SetPalette( true ) 
		colMix:SetAlphaBar( false )	
		colMix:SetWangs( false )
		colMix:SetColor( GrabColor() ) -- Sets the default color to your current one

		local Butt = vgui.Create("DButton", Frame)
		Butt:SetText("Set Color")
		Butt:SetSize( 150,70 )
		Butt:SetPos( 70, 290 )
		Butt.DoClick = function( Butt ) -- Concatenate your choices together and set the color
			local colors = colMix:GetColor()
			local colstring = tostring(colors.r .. ", " .. colors.g .. ", "..colors.b)
			RunConsoleCommand("hm_hitmarkercolor", colstring ) 
		end

	end)

	net.Receive( "DrawHitMarker", function( len, ply )
		DrawHitM = true
		CanPlayS = true
		alpha = 255 
	end)

	gHitsound = "hitmarkers/mlg.wav"
	hook.Add("HUDPaint", "HitmarkerDrawer", function() 
		if hm_toggle:GetBool() == false then return end -- Enables/Disables the hitmarkers
		if alpha == 0 then DrawHitM = false CanPlayS = true end -- Removes them after they decay 

		if DrawHitM == true then
			if CanPlayS and hm_sound:GetBool() == true then
				surface.PlaySound(gHitsound)
				sound.PlayURL(gHitsound, "mono", function(station)
					if IsValid(station) then
						station:Play()
					end
				end)
				CanPlayS = false
			end

			local x = ScrW() / 2
			local y = ScrH() / 2

			alpha = math.Approach(alpha, 0, 5 )
			local col = GrabColor() -- Grabs HM color and draws your design
			col.a = alpha 
			surface.SetDrawColor( col )

			local sel = string.lower(hm_type:GetString())
			-- The drawing part of the hitmarkers and the various types you can choose
			if sel == "lines" then 
				surface.DrawLine( x - 6, y - 5, x - 11, y - 10 )
				surface.DrawLine( x + 5, y - 5, x + 10, y - 10 )
				surface.DrawLine( x - 6, y + 5, x - 11, y + 10 )
				surface.DrawLine( x + 5, y + 5, x + 10, y + 10 )
			elseif sel == "sidesqr_lines" then
				surface.DrawLine( x - 15, y, x, y + 15 )
				surface.DrawLine( x + 15, y, x, y - 15 )
				surface.DrawLine( x, y + 15, x + 15, y)
				surface.DrawLine( x, y - 15, x - 15, y)
				surface.DrawLine( x - 5, y - 5, x - 10, y - 10 )
				surface.DrawLine( x + 5, y - 5, x + 10, y - 10 )
				surface.DrawLine( x - 5, y + 5, x - 10, y + 10 )
				surface.DrawLine( x + 5, y + 5, x + 10, y + 10 )
			elseif sel == "sqr_rot" then
				surface.DrawLine( x - 15, y, x, y + 15 )
				surface.DrawLine( x + 15, y, x, y - 15 )
				surface.DrawLine( x, y + 15, x + 15, y)
				surface.DrawLine( x, y - 15, x - 15, y)
			else -- Defaults to 'lines' in case of an incorrect type
				surface.DrawLine( x - 6, y - 5, x - 11, y - 10 )
				surface.DrawLine( x + 5, y - 5, x + 10, y - 10 )
				surface.DrawLine( x - 6, y + 5, x - 11, y + 10 )
				surface.DrawLine( x + 5, y + 5, x + 10, y + 10 )
			end
		end
	end)
end
