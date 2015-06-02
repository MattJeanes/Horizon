include('shared.lua')

function ENT:Draw( )
	hznFactoryEnt = self
	if entID == nil then
		entID = 0
	end
	self:DrawModel()
end

local VGUI = {}

function VGUI:Init()
	-- get factory entries from gamemode
	local entries = GAMEMODE:GetFactoryEntries()
	-- create factory window
	local frame_w, frame_h = 768, 512
	local FactoryMenu = vgui.Create( "DFrame" )
		FactoryMenu:SetPos( 64, 64 )
		FactoryMenu:SetSize( frame_w, frame_h )
		FactoryMenu:SetTitle( "Horizon Factory" )
		FactoryMenu:SetVisible( true )
		FactoryMenu:SetDraggable( true )
		FactoryMenu:ShowCloseButton( true )
		FactoryMenu:MakePopup()
	MainPanel = vgui.Create( "DPanel" )
		MainPanel:SetParent( FactoryMenu )
		MainPanel:SetPos( 1, 24 )
		MainPanel:SetSize( FactoryMenu:GetWide() - 2, FactoryMenu:GetTall() - 26 )
	ItemListPanel = vgui.Create( "DPanel" )
		ItemListPanel:SetParent( MainPanel )
		ItemListPanel:SetPos( 0, 0 )
		ItemListPanel:SetSize( 192, MainPanel:GetTall() )
	-- create available items scroll list
	ItemList = vgui.Create("DListView")
		ItemList:SetParent( ItemListPanel )
		ItemList:SetPos( 0, 0 )
		ItemList:SetSize( ItemListPanel:GetWide(), ItemListPanel:GetTall() )
		ItemList:SetMultiSelect(false)
		ItemList:AddColumn("Schematics") -- Add column
		-- fill list with available items
		for k, _ in pairs( entries ) do
			ItemList:AddLine( k )
		end
		ItemList:SortByColumn( 1, false )
		ItemList.OnRowSelected = function( panel, line )
			item = panel:GetLine(line):GetValue(1)
			local entry = entries[item]
			-- TODO: clear other ListViews and refresh content
			ItemNamePanel:Clear()
			ItemNamePanel:AddLine( entry.DisplayName )
			ItemDescriptionPanel:Clear()
			for _, v in pairs( entry.Description ) do
				ItemDescriptionPanel:AddLine( v )
			end
			ItemResourceList:Clear()
			for k, v in pairs( entry.Costs ) do
				ItemResourceList:AddLine( k, v )
			end
		end
	ItemDetailPanel = vgui.Create( "DPanel" )
		ItemDetailPanel:SetParent( MainPanel )
		ItemDetailPanel:SetPos( ItemListPanel:GetWide(), 0 )
		ItemDetailPanel:SetSize( MainPanel:GetWide() - ItemListPanel:GetWide(), MainPanel:GetTall() )
	-- create item name box
	ItemNamePanel = vgui.Create( "DListView", DermaFrame )
		ItemNamePanel:SetParent( ItemDetailPanel )
		ItemNamePanel:SetPos( 0, 0 )
		ItemNamePanel:SetSize( ItemDetailPanel:GetWide(), 64 )
		ItemNamePanel:AddColumn( "Name" )
	-- create desciption box
	ItemDescriptionPanel = vgui.Create( "DListView", DermaFrame )
		ItemDescriptionPanel:SetMultiSelect( false )
		ItemDescriptionPanel:SetParent( ItemDetailPanel )
		ItemDescriptionPanel:SetPos( 0, ItemNamePanel:GetTall() )
		ItemDescriptionPanel:SetSize( ItemDetailPanel:GetWide(), 256 )
		ItemDescriptionPanel:AddColumn( "Description" )
		ItemDescriptionPanel.Columns[1].DoClick = function() end 
	-- create resource box
	ItemResourceList = vgui.Create( "DListView", DermaFrame )
		ItemResourceList:SetMultiSelect( false )
		ItemResourceList:SetParent( ItemDetailPanel )
		ItemResourceList:SetPos( 0, ItemNamePanel:GetTall() + ItemDescriptionPanel:GetTall() )
		ItemResourceList:SetSize( ItemDetailPanel:GetWide(), 128 )
		ItemResourceList:AddColumn( "Resource" )
		ItemResourceList:AddColumn( "Amount" )
	-- create button panel
	ButtonsPanel = vgui.Create( "DPanel" )
		ButtonsPanel:SetParent( ItemDetailPanel )
		ButtonsPanel:SetPos( 0, ItemNamePanel:GetTall() + ItemDescriptionPanel:GetTall() + ItemResourceList:GetTall() )
		ButtonsPanel:SetSize( ItemDetailPanel:GetWide(), ItemDetailPanel:GetTall() )
	-- create cancel button
	cancelButton = vgui.Create( "DButton" )
		cancelButton:SetParent( ButtonsPanel )
		cancelButton:SetText( "Cancel" )
		cancelButton:SetPos( 0, 0 )
		cancelButton:SetSize( 128 + 64, 42 )
		cancelButton.DoClick = function()
			FactoryMenu:Remove()
		end
	-- create fill button
	storageButton = vgui.Create( "DButton" )
		storageButton:SetParent( ButtonsPanel )
		storageButton:SetText( "Fill Crate" )
		storageButton:SetPos( ButtonsPanel:GetWide() / 3, 0 )
		storageButton:SetSize( 128 + 64, 42 )
		storageButton.DoClick = function ()
			RunConsoleCommand("fillcrate", entID)
			FactoryMenu:Remove()
		end
	-- create build button
	okButton = vgui.Create( "DButton" )
		okButton:SetParent( ButtonsPanel )
		okButton:SetText( "Build" )
		okButton:SetPos( ButtonsPanel:GetWide() * 2 / 3, 0 )
		okButton:SetSize( 128 + 64, 42 )
		okButton.DoClick = function ()
			if ItemList:GetSelected() and ItemList:GetSelected()[1] then
				RunConsoleCommand( "builditem", ItemList:GetSelected()[1]:GetValue(1), entID  )
				FactoryMenu:Remove()
			end
		end
end
vgui.Register( "FactoryMenu", VGUI )

function hznFactoryTrigger( um )
	local Window = vgui.Create( "FactoryMenu" )
	Window:SetMouseInputEnabled( true )
	Window:SetVisible( true )
	
	entID = um:ReadString()
	e = um:ReadEntity()	
	
	--if(not ValidEntity(e)) then return end;
end
usermessage.Hook("hznFactoryTrigger", hznFactoryTrigger)

