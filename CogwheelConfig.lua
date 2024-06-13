--[[---------------------------------------------------------------------------
TODOs:  

  [ ] add help description above buttons for help with right click, drag, etc

  [ ] handle in combat type stuff proper with new settings

  [ ] use inventory
    [ ] need to sort by name or something to have something consistent
	    that doesn't change with bag placement
  [ ] update when inventory does
  [ ] update when to/from bank

  [ ] API
    [ ] SetDisabled
	[ ] SetLabel
	[ ] SetList
	[ ] SetValue
	[ ] Callback OnValueChanged(value), fired when a value is selected, this must be a key from the list table.

  [ ] need to call into updateMacro stuff when list is changing
  [ ] have main part of app use the setting gem list instead of fixed list
    
  [ ] first run without being configured, button should have special icon/text
    [ ] maybe even have it handle on click being configure 

  [ ] Cleanup DBG
  [ ] Cleanup Other
-----------------------------------------------------------------------------]]

local Type, Version = "CogwheelConfig", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

BUTTONS = {}
selectedButtonIndex = nil
isDragging = false

-- Allows for the drag event to go outside the container
local dragBackdrop = CreateFrame("Frame") do
	dragBackdrop:Hide()
	dragBackdrop:SetFrameStrata("BACKGROUND")
	dragBackdrop:SetAllPoints()
	dragBackdrop:EnableMouse(true)
	dragBackdrop:SetScript("OnMouseDown", dragBackdrop.Hide)
end

local function setTexture(frame, texName)
	frame:SetNormalTexture("interface\\icons\\" .. texName)
	frame.texName = texName
end

local function getFinalEnabledSlot()
	local slot = 1
	for i = 1, #BUTTONS do
		if BUTTONS[i].inUse then
			slot = i
		end
	end
	return slot
end 

local function moveBtn(source, dest)	
	-- print("MOVING: " .. tostring(source) .. " => " .. tostring(dest))	
	local btn = BUTTONS[source]
	table.insert(btn.obj.gems, dest, table.remove(btn.obj.gems, source))
	
	if selectedButtonIndex == source then selectedButtonIndex = dest end
		
	btn.obj:UpdateIconButtons()
end

local function toggleCog(btn)
	-- when toggling, just clear selected, its confusing
	btn:SetChecked(false)

	local id = btn:GetID()
	local cog = btn.obj.gems[id]

	if cog.isEquipped then
		UIErrorsFrame:AddMessage(RED_FONT_COLOR:WrapTextInColorCode("RemixCogwheel: Cannot disable currently equipped cogwheel."))
		return
	end

	if not cog.isOwned then
		UIErrorsFrame:AddMessage(RED_FONT_COLOR:WrapTextInColorCode("RemixCogwheel: Cannot enable gem you don't have in inventory"))
		return
	end

	local isEnabled = not cog.isEnabled
	local dest = #BUTTONS

	if isEnabled then 
		-- find the first disabled spot to move it to, run before we update the enabled state
		dest = getFinalEnabledSlot() + 1
	end

	-- toggle enabled
	cog.isEnabled = isEnabled
	btn.inUse = isEnabled
	
	-- move the button 
	moveBtn(btn:GetID(), dest)
end

local function onEnter(btn)	
	if isDragging then return end

	local tooltip = AceGUI.tooltip	
	tooltip:SetOwner(btn, "ANCHOR_NONE")	
	tooltip:SetPoint("BOTTOMLEFT",btn,"TOPLEFT", 0, 5)

	local cog = btn.obj.gems[btn:GetID()]
	if cog.isEquipped then 
		tooltip:SetSpellByID(cog.spellId, nil, false)
		tooltip:AddLine(" ")
		tooltip:AddLine("Equipped", 0, .7, 0)
		tooltip:AddLine("Currently equipped cogwheel, cannot be disabled.", GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true)
	elseif not cog.isOwned then 
		tooltip:SetSpellByID(cog.spellId, nil, false)
		tooltip:AddLine(" ")
		tooltip:AddLine("Missing Cogwheel", 1, 0, 0)
		tooltip:AddLine("Disabled from use until you have this in your inventory.", GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true)
	else
		tooltip:SetSpellByID(cog.spellId, nil, false)
	end	

	tooltip:Show()
end

local function onLeave(btn)
	AceGUI.tooltip:Hide()
end

local function onClick(self, button, down)	
    -- print("## BTN onClk")
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)    

	if button == "RightButton" then
		-- clear selection when enabling or disabling as there are weird states otherwise
		-- might need to revist
		selectedButtonIndex = nil
		onLeave(self)
		toggleCog(self)
		return
	end
	
	local checked = self:GetChecked()
	if not checked then
		selectedButtonIndex = nil
		self.obj:UpdateIconButtons()
		return
	end
	
	if selectedButtonIndex then
		BUTTONS[selectedButtonIndex]:SetChecked(nil)	
	end	
	selectedButtonIndex = self:GetID()
end

local function onDragStart(self)
	-- print("## BTN dragStart: " .. tostring(self:GetID()) .. " inUse: " .. tostring(self.inUse))
	if not self.inUse then return end
	isDragging = true

	-- hide any tooltips
	onLeave(self)

    PlaySound(832)
    self.source = self:GetID()
    dragBackdrop:Show()   
	_G.SetCursor(GetFileIDFromPath("interface\\icons\\" .. self.texName))
end

local function onDragAbort(self)
	-- print("## BTN dragAbort: " .. tostring(self:GetID()))
    local src = self.source
    if src then
        _G.SetCursor(nil)
        dragBackdrop:Hide()
        self.source = nil
    end
    return src
end

local function onDragStop(self)
    -- print("## BTN dragStop: " .. tostring(self:GetID()))
	if not self.inUse then return end
	isDragging = false

    local source = onDragAbort(self)
    local x, y = GetCursorPosition()

    PlaySound(833)

    local scale, l, b, w, h = self:GetEffectiveScale(), self:GetRect()
    local dx,dy = math.floor((x / scale - l - h-1)/(h+2)), y / scale - self:GetTop()    
    
	local dest = self:GetID() + dx + 1
	local destOrig = self:GetID() + dx + 1
	local min = 1
	local max = 1
	
	-- figure out max based on how many are disabled
	max = getFinalEnabledSlot()	
	
	-- adjust for any outside min/max
	if dest > max then
		dest = max	
	elseif dest < min then
		dest = min
	end

    if dest ~= source then
		moveBtn(source, dest)
    end
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
        -- print("## OnAcquire")
		self:SetDisabled(false)
		self:SetLabel()
	end,

	["OnRelease"] = function(self)
		-- print("## OnRelease")
	end,

	["SetValue"] = function(self, value)
		-- print("## SetValue: " .. tostring(value))
	end,

	["SetList"] = function(self, list)
		-- print("## SetList")
		self.gems = list
		self:UpdateIconButtons()
	end,

	["SetDisabled"] = function(self, disabled)
		-- print("## SetDisabled: " .. tostring(disabled))
        
		-- TODO: work

        self.disabled = disabled
		if disabled then
			self.label:SetTextColor(0.5,0.5,0.5)
		else
			self.label:SetTextColor(1,.82,0)
		end
	end,

	["SetLabel"] = function(self, text)
		-- print("## SetLabel: " .. tostring(text))

		-- TODO: figure out real differences here
        if text and text ~= "" then
			self.label:SetText(text)
			self.label:Show()
		else
			self.label:SetText("")
			self.label:Hide()
		end
	end,
	
	["UpdateIconButtons"] = function(self)
		-- print("## UpdateIconButtons")
		if #self.gems ~= #BUTTONS then
			for i = #BUTTONS+1, #self.gems do
				self:CreateButton(i, self.gems[i].texture)
			end
		end

		for i = 1, #self.gems do
			local btn = BUTTONS[i]
			local cog = self.gems[i]
			local t = btn:GetNormalTexture()

			setTexture(btn, cog.texture)
			btn:SetChecked(selectedButtonIndex == i)
			btn.inUse = cog.isEnabled and cog.isOwned	
			btn.lock:Hide()
			btn.bag:Hide()

			-- set saturation based on enabled state of cog
			if cog.isEquipped then
				btn.lock:Show()
				t:SetDesaturated(false)
				t:SetAlpha(1)				
			elseif not cog.isOwned then				
				btn.bag:Show()
				t:SetDesaturated(true)
				t:SetAlpha(.4)
			elseif cog.isEnabled then
				t:SetDesaturated(false)
				t:SetAlpha(1)
			else
				t:SetDesaturated(true)
				t:SetAlpha(.4)
			end
		end

		NOTIFY_GEMS:SendMessage("BUTTONS_UPDATED")
	end,

	["CreateButton"] = function(self, i, texture)
		local ico = CreateFrame("CheckButton", "IconButton"..i, self.myFrame, nil, i)
		ico.obj = self	

		ico:SetSize(32,32)
		ico:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square")
		ico:GetHighlightTexture():SetBlendMode("ADD")
		ico:SetCheckedTexture("Interface/Buttons/CheckButtonHilight")
		ico:GetCheckedTexture():SetBlendMode("ADD")
		ico:SetPoint("TOPLEFT", 34*(i-1), -5)
		setTexture(ico, texture)
	
		ico.lock = ico:CreateTexture()
		ico.lock:SetPoint("CENTER", 7, -6)
		ico.lock:SetTexture("Interface/PetBattles/PetBattle-LockIcon")
		ico.lock:SetSize(16,16)
		ico.lock:SetDrawLayer("OVERLAY")
		ico.lock:Hide()

		ico.bag = ico:CreateTexture()
		ico.bag:SetPoint("CENTER", 7, -6)
		ico.bag:SetTexture("Interface/GossipFrame/VendorGossipIcon")		
		ico.bag:SetSize(16,16)
		ico.bag:SetDrawLayer("OVERLAY")
		ico.bag:SetDesaturated(true)
		ico.bag:Hide()

		ico:RegisterForDrag("LeftButton")
		ico:RegisterForClicks("AnyUp")		
		ico:SetScript("OnClick", onClick)
		ico:SetScript("OnDragStart", onDragStart)
		ico:SetScript("OnDragStop", onDragStop)
		ico:SetScript("OnHide", onDragAbort)
		ico:SetScript("OnEnter", onEnter)
		ico:SetScript("OnLeave", onLeave)		
	
		-- structures to track button ui elements
		ico.inUse = true
		BUTTONS[i] = ico
	end,	
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
    -- print("## Constructor")
	local self = {}

	local frame = CreateFrame("Frame", nil, UIParent)   
    frame:SetHeight(100)
    frame:Hide()
        
    self.myFrame = CreateFrame("Frame", "RemixCogwheelFrame", frame)
	self.myFrame:SetPoint("TOPLEFT", 0, -18)
	self.myFrame:SetPoint("BOTTOMRIGHT")	

    -- local tex = frame:CreateTexture()
    -- tex:SetAllPoints()
    -- tex:SetColorTexture(24/255, 101/255, 121/255)
    -- local tex = self.frame:CreateTexture()
    -- tex:SetAllPoints()
	-- tex:SetColorTexture(118/255, 181/255, 197/255)	
    
	local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	label:SetPoint("TOPLEFT", 0, -2)
	label:SetPoint("TOPRIGHT", 0, -2)
	label:SetJustifyH("LEFT")
	label:SetHeight(18)	

	self.type = Type
	self.frame = frame
	self.label = label	
	for method, func in pairs(methods) do
		self[method] = func
	end

	AceGUI:RegisterAsWidget(self)
	return self
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)