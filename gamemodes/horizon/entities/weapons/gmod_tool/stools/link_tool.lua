TOOL.Category = "Networking"
TOOL.Name = "Link Tool"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.Tab = "Horizon"
TOOL.ClientConVar[ "width" ] = "1.5"
TOOL.ClientConVar[ "material" ] = "cable/cable"

if ( CLIENT ) then
    language.Add( "Tool.link_tool.name", "Link Tool" );
    language.Add( "Tool.link_tool.desc", "Creates a link between two devices." );
	language.Add( "Tool.link_tool.0", "Left click to select first device." );
	language.Add( "Tool.link_tool.1", "Left click to select second device. Reload to clear selection.")
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
	self.SecondEnt = trace.Entity
	if self.FirstEnt == self.SecondEnt then
		-- can not link device to itself
		self:GetOwner():PrintMessage( HUD_PRINTTALK, "Cannot link device to itself!" )
		self:SetStage( 0 )
		return false
	end
	if ( self.FirstEnt:GetClass() == "link_hub" and self.SecondEnt:GetClass() == "link_hub" ) then
		-- can not (yet) link two link_hubs together
		self:GetOwner():PrintMessage( HUD_PRINTTALK, "Cannot link two link_hub devices!" )
		self:SetStage( 0 )
		return false
	end
	if ( ( self.FirstEnt:GetClass() != "link_hub" and self.SecondEnt:GetClass() != "link_hub" ) ) then
		-- can only link entities to link_hubs
		self:GetOwner():PrintMessage( HUD_PRINTTALK, "Cannot link two non link_hub devices!" )
		self:SetStage( 0 )
		return false
	end
	if ( self.FirstEnt:GetClass() == "link_hub" ) then
		self.FirstEnt:AddDevice( self.SecondEnt )
		self:AddRope(self.FirstEnt, self.SecondEnt)
		self:GetOwner():PrintMessage( HUD_PRINTTALK, "Link completed!" )
		self.FirstEnt = nil
		self.SecondEnt = nil
		self:SetStage( 0 )
		return true
	end
	if ( self.SecondEnt:GetClass() == "link_hub" ) then
		self.SecondEnt:AddDevice( self.FirstEnt )
		self:AddRope(self.SecondEnt, self.FirstEnt)
		self:GetOwner():PrintMessage( HUD_PRINTTALK, "Link completed!" )
		self.FirstEnt = nil
		self.SecondEnt = nil
		self:SetStage( 0 )
		return true
	end
	return false
end

function TOOL:AddRope( BeginEnt, EndEnt )
	local length = ( BeginEnt:GetPos() - EndEnt:GetPos() ):Length()
	local width = self:GetClientNumber( "width" ) or 1.5
	local material   = self:GetClientInfo( "material" )
	constraint.Rope( BeginEnt, EndEnt, 0, 0, Vector(0,0,0), Vector(0,0,0), length, 100, 0, width, material, false ) 
end

function TOOL:RightClick( trace )
	if (not trace.Entity:IsValid()) or (trace.Entity:IsPlayer()) then return false end
	if CLIENT then return true end
	local width = self:GetClientNumber( "width" ) or 1.5
	local material   = self:GetClientInfo( "material" )
	local ent = trace.Entity
	if ( ent:GetClass() == "link_hub" ) then
		ent:ClearDevices()
		local inRange = ents.FindInSphere( ent:GetPos(), 128)
		for _, v in pairs( inRange ) do
			if v:GetClass() != "link_hub" and not v:IsPlayer() and v.netUpdate != nil then
				ent:AddDevice( v )
				local length = (ent:GetPos() - v:GetPos()):Length()
				constraint.Rope( ent, v, 0, 0, Vector(0,0,0), Vector(0,0,0), length, 100, 0, width, material, false ) 
			end
		end
		self:GetOwner():PrintMessage( HUD_PRINTTALK, "Links completed!" )
		return true
	end
	return false
end

function TOOL:Reload( trace )
	if (not trace.Entity:IsValid()) or (trace.Entity:IsPlayer()) then return false end
	if CLIENT then return true end
	-- clear link_hub
	if trace.Entity:GetClass() == "link_hub" then
		self:GetOwner():PrintMessage( HUD_PRINTTALK, "Links removed!" )
		trace.Entity:ClearDevices()
		return true
	end
	-- clear other entities
	if trace.Entity.Link == nil then return true end
	trace.Entity.Link:RemoveDevice( trace.Entity )
	self:GetOwner():PrintMessage( HUD_PRINTTALK, "Link removed!" )
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

