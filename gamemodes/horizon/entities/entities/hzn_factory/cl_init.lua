include('shared.lua')

function ENT:Draw( )
	hznFactoryEnt = self
	if entID == nil then
		entID = 0
	end
	if self.dispEnergy == nil then
		self.dispEnergy = 0
	end
	if self.dispMorphite == nil then
		self.dispMorphite = 0
	end
	if self.dispNocxium == nil then
		self.dispNocxium = 0
	end
	if self.dispIsogen == nil then
		self.dispIsogen = 0
	end
	self:DrawModel()
end

local VGUI = {}

function VGUI:Init()
	-- get factory entries from gamemode
	local entries = GAMEMODE:GetFactoryEntries()
	-- create factory window
	local FactoryMenu = vgui.Create( "DFrame" )
		FactoryMenu:SetPos( 50,50 )
		FactoryMenu:SetSize( 550, 300 )
		FactoryMenu:SetTitle( "Horizon Factory" )
		FactoryMenu:SetVisible( true )
		FactoryMenu:SetDraggable( true )
		FactoryMenu:ShowCloseButton( true )
		FactoryMenu:MakePopup()
	-- create available items scroll list
	local schematicBox = vgui.Create("DListView")
		schematicBox:SetParent( FactoryMenu )
		schematicBox:SetPos(10, 35)
		schematicBox:SetSize(150, 185)
		schematicBox:SetMultiSelect(false)
		schematicBox:AddColumn("Schematics") -- Add column
	-- fill list with available items
	for k, _ in pairs( entries ) do
		schematicBox:AddLine( k )
	end
	-- create description box
	local infoBox = vgui.Create( "DPanel", DermaFrame ) 
		infoBox:SetPos( 170, 35 )
		infoBox:SetSize( 350, 185)
		infoBox:SetParent( FactoryMenu )
		infoBox.Paint = function()    
			surface.SetDrawColor( 50, 50, 50, 255 )
			surface.DrawRect( 0, 0, infoBox:GetWide(), infoBox:GetTall() )
			if schematicBox:GetSelected() and schematicBox:GetSelected()[1] then 
				local selectedValue = schematicBox:GetSelected()[1]:GetValue(1) 
				-- Get description data
				if entries[selectedValue] == nil then 
					itemDesc = { [1] = "No selection or selection does not have a description" }
				else
					itemDesc = entries[selectedValue].Description
				end	
				--surface.SetFont( "default" )
				surface.SetTextColor( 255, 255, 255, 255 )
				posy = 12
				for _, textLine in pairs ( itemDesc ) do
					surface.SetTextPos( 16, posy )
					surface.DrawText( textLine )
					posy = posy + 12
				end
				
			end	
			surface.SetTextColor( 255, 255, 255, 255 )
		end
	-- create cancel button
	local cancelButton = vgui.Create( "DButton" )
		cancelButton:SetParent( FactoryMenu ) -- Set parent to our "FactoryMenu"
		cancelButton:SetText( "Cancel" )
		cancelButton:SetPos( 440, 250 )
		cancelButton:SetSize( 90, 30 )
		cancelButton.DoClick = function()
			FactoryMenu:Remove()
		end
	-- create deposit button
	local storageButton = vgui.Create( "DButton" )
		storageButton:SetParent( FactoryMenu ) -- Set parent to our "FactoryMenu"
		storageButton:SetText( "Deposit Crate" )
		storageButton:SetPos( 10, 250 )
		storageButton:SetSize( 110, 30 )
		storageButton.DoClick = function ()
			RunConsoleCommand("absorbcrate", entID)
			FactoryMenu:Remove()
		end
	-- create build button
	local okButton = vgui.Create( "DButton" )
		okButton:SetParent( FactoryMenu ) -- Set parent to our "FactoryMenu"
		okButton:SetText( "BUILD" )
		okButton:SetPos( 340, 250 )
		okButton:SetSize( 90, 30 )
		okButton.DoClick = function ()
			if schematicBox:GetSelected() and schematicBox:GetSelected()[1] then
				RunConsoleCommand( "builditem", schematicBox:GetSelected()[1]:GetValue(1), entID  )
				FactoryMenu:Remove()
			end
		end
end
vgui.Register( "FactoryMenu", VGUI )

function hznFactoryTrigger(um)

	local Window = vgui.Create( "FactoryMenu")
	Window:SetMouseInputEnabled( true )
	Window:SetVisible( true )
	
	entID = um:ReadString()
	e = um:ReadEntity()	
	
	--if(not ValidEntity(e)) then return end;
end
usermessage.Hook("hznFactoryTrigger", hznFactoryTrigger)

