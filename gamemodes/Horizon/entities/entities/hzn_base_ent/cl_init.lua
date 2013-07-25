include('shared.lua')

net.Receive( "netEntityInfo", function()
		local entity = net.ReadEntity()
		if entity == nil then return end
		if not IsValid( entity ) or entity.SetStatusTable == nil then return end
		local tab = net.ReadTable()
		if tab == nil then return end
		entity:SetStatusTable( tab )
end )

function ENT:SetStatusTable( tab )
	self.StatusTable = tab
end

function ENT:GetStatusTable()
	return self.StatusTable
end

function DrawInfo()
	local tr = LocalPlayer():GetEyeTrace()
	local ent = tr.Entity
	if ent:IsValid() and ent:GetPos():Distance(LocalPlayer():GetPos()) < 150 and ent.GetStatusTable != nil then
	 	local text = ent.PrintName
		local StatusTable = ent:GetStatusTable() 
		if (StatusTable != nil) then
			for k, v in pairs( StatusTable ) do
				text = text .. "\n" .. tostring( k ) .. ": " .. tostring( v )
			end
		end
	 	local yOffset = 0
	 	local center = ent:LocalToWorld( ent:OBBCenter() + Vector(0, -0.5, yOffset) ):ToScreen()
	 	surface.SetFont("DermaDefaultBold")
		local w, t = surface.GetTextSize(text)
		local boxWide, boxTall = w + 20, t + 8
	 	local gradientUp = surface.GetTextureID("gui/gradient_up")
 		draw.RoundedBox( 4, center.x - (boxWide / 2), center.y - 3, boxWide, boxTall, Color( 0, 0, 0, 255 ) )
 		draw.RoundedBox( 4, (center.x - (boxWide / 2)) + 1, (center.y - 3) + 1, boxWide - 2, boxTall - 2, Color( 75, 75, 75, 255 ) )
 		surface.SetDrawColor(25, 25, 25, 220)
		surface.SetTexture(gradientUp)
		surface.DrawTexturedRect(center.x-((boxWide/2)-1), center.y-3, boxWide-1, boxTall)
 		draw.DrawText(text, "DermaDefaultBold", center.x + 1, center.y + 1, Color(0, 0, 0, 200), 1)
 		draw.DrawText(text, "DermaDefaultBold", center.x, center.y, Color(255, 255, 255, 200), 1)
	end
end
hook.Add( "HUDPaint", "DrawInfo", DrawInfo )