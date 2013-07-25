TOOL.Category = "Networking"
TOOL.Name = "Link Tool"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.Tab = "Horizon"
TOOL.ClientConVar[ "width" ] = "1.5"
TOOL.ClientConVar[ "material" ] = "cable/cable"

if ( CLIENT ) then
    language.Add( "Tool.new_link_tool.name", "New Link Tool" );
    language.Add( "Tool.new_link_tool.desc", "New Link Horizon Devices" );
	language.Add( "Tool.new_link_tool.0", "Left click to link two devices. Reload to reset." );
	language.Add( "Tool.new_link_tool.1", "Left click annother device to link them.")
end

function TOOL:Deploy()
	self:ClearObjects()
end

function TOOL:LeftClick( trace )
	if (not trace.Entity:IsValid()) or (trace.Entity:IsPlayer()) then return false end
	if CLIENT then return true end
	-- stage 0
	if self:GetStage() == 0 then
		self.FirstEnt = trace.Entity
		self:SetStage( 1 )
		return true
	end
	-- stage 1
	if trace.Entity:GetClass() == 'link_hub' then
		trace.Entity:AddDevice(self.FirstEnt)
		local length = (trace.Entity:GetPos() - self.FirstEnt:GetPos()):Length()
		local width = self:GetClientNumber( "width" ) or 1.5
		local material   = self:GetClientInfo( "material" )
		constraint.Rope( trace.Entity, self.FirstEnt, 0, 0, Vector(0,0,0), Vector(0,0,0), length, 100, 0, width, material, false ) 
		self.FirstEnt = nil
		self:SetStage( 0 )
		return true
	end
	self:SetStage( 0 )
	return false
end

function TOOL:Reload( trace )
	if (not trace.Entity:IsValid()) or (trace.Entity:IsPlayer()) then return false end
	if CLIENT then return true end
	-- clear link_hub
	if trace.Entity:GetClass() == "link_hub" then
		trace.Entity:ClearDevices()
		return true
	end
	-- clear other entities
	if trace.Entity.Link == nil then return true end
	trace.Entity.Link:RemoveDevice( trace.Entity )
	return true
end


function TOOL.BuildCPanel( CPanel )
	CPanel:AddControl( "ComboBox", 
	{ 
		Label = "#tool.presets",
		MenuButton = 1,
		Folder = "link",
		Options =	{ Default = {	link_tool_width='1',	link_tool_material='cable/cable' } },
		CVars =		{				"link_tool_width",		"link_tool_material" } 
	})
	CPanel:AddControl( "Slider", 		{ Label = "Width",		Type = "Float", 	Command = "link_tool_width", 		Min = "0", 	Max = "10" }  )
	CPanel:AddControl( "RopeMaterial", 	{ Label = "Link Material",	convar	= "link_tool_material" }  )
end

