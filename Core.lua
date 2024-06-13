--[[---------------------------------------------------------------------------

TODO:

   [ ] BUG: handle case where you manual equip and its not in our list or is disabled
   [x] Macro: does it still work if disabled on list?

   [ ] All gems added but disabled?   

  TESTING:
    [ ] boots dont have socket

  COOLDOWN:
    [ ] it shows GCD right now, might now want that or maybe setting?

  FUTURE:
      [ ] Add Macro from settings
      [ ] Keybinding next gem
      [ ] FALLBACK: maybe support for a fallback gem if all cooldown, like the move fast one 

-----------------------------------------------------------------------------]]

-- DBG: DevTools_Dump
--   /script print(DevTools_Dump(GetInventoryItemLink("player", 8)))

local APPNAME = "RemixCogwheel"
RemixCogwheel = LibStub("AceAddon-3.0"):NewAddon("RemixCogwheel", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local contextMenuFrame = CreateFrame("Frame", APPNAME .. "ContextMenuFrame", UIParent, "UIDropDownMenuTemplate")
local isRunning = false

-- local CAST_MACRO = "/script print('would have cast ' .. _G.RC.equipped.name)\n/script SocketInventoryItem(8)\n/click ItemSocketingSocket1\n/script CloseSocketInfo()"
local NOOP_MACRO = "/script SocketInventoryItem(8)\n/click ItemSocketingSocket1\n/script CloseSocketInfo()"
local CAST_MACRO = 
[[/cast {1}
/script SocketInventoryItem(8)
/click ItemSocketingSocket1
/script CloseSocketInfo()
]]

_G.RC = RemixCogwheel
_G.BINDING_CATEGORY = "Remix Cogwheel"
_G["BINDING_NAME_CLICK RemixCogwheelButton:LeftButton"] = "Activate"

local options = {
   name = "Remix Cogwheel",
   handler = RemixCogwheel,
   type = "group",
   args = {
      showButton = {
         name = "Show Button",
         desc = "Whether to show the button or not",
         type = "toggle",
         order = 1,
         set = function(info,val)
            RemixCogwheel.db.char.btnVisible = val
            RemixCogwheel:SettingsChanged()
         end,
         get = function(info) return RemixCogwheel.db.char.btnVisible end
       },       
      lockButton = {
         name = "Lock Button",
         desc = "Whether button is movable or not",
         type = "toggle",
         order = 2,
         set = function(info,val) RemixCogwheel.db.char.btnLocked = val end,
         get = function(info) return RemixCogwheel.db.char.btnLocked end
      },
      buttonScale = {
         type = "range",
         name = "Button Scale",
         desc = "The scale of the button",
         min = 0.25, max = 2, step = 0.01,
         set = function(info,val) 
            RemixCogwheel.db.char.scale = val
            RemixCogwheel.f:SetScale(val)
         end,
         get = function(info) return RemixCogwheel.db.char.scale end,
         order = 3,
      },
   
      break01 = {
         type = "description",
         name = " ",
         order = 3.1,
         width = "full"
      },

      cogwheels = { 
         type = "select",
         name = "Cog Wheels",
         dialogControl = "CogwheelConfig",
         order = 4,
         width = "full",
         values = function() return RemixCogwheel.db.char.GEMS end
      },
   },
}

local defaults = {
   char = {
      btnVisible = true,
      btnLocked = false,
      btnX = 0,
      btnY = 0,
      scale = 1,
   },
}

local contextMenu = {
   { text = "Options", isTitle = true, notCheckable = true, isNotRadio = true },
   { 
      text = "Show Button", 
      isNotRadio = true,
      checked = options.args.showButton.get,
      func = function(self, arg1, arg2, checked)
         options.args.showButton.set(nil, not checked)
      end
   },
   {  
      text = "Lock Button",
      isNotRadio = true, 
      checked = options.args.lockButton.get,
      func = function(self, arg1, arg2, checked)
         options.args.lockButton.set(nil, not checked)
      end
   },   
}

NOTIFY_GEMS:RegisterMessage("BUTTONS_UPDATED", function()
   -- Update the next item since it could have changed in settings
   RemixCogwheel.next = RemixCogwheel:GetNextGem()
end)

local function strtemplate(str, vars, ...)
   if type(vars) ~= 'table' then
       vars = { vars, ... }
   end
   return (string.gsub(
               str,
               "({([^}]+)})",
               function(whole, i) return vars[tonumber(i) or i] or whole end
           ))
end

function RemixCogwheel:OnInitialize()
   self.db = LibStub("AceDB-3.0"):New(APPNAME .. "DB", defaults)

   -- I'm too lazy to figure out whats going on with tracking this on changes
   -- so I'm just tracking with a version and doing a full reset if I rev it.
   -- lame user experience, as I should "migrate"
   if not self.db.char.GEMS or self.db.char.GEMS_VERSION ~= GEMS_VERSION then
      self.db.char.GEMS = GEMS
      self.db.char.GEMS_VERSION = GEMS_VERSION
   end

   LibStub("AceConfig-3.0"):RegisterOptionsTable(APPNAME, options)
   self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(APPNAME, "Remix Cogwheel")   

   self:RegisterChatCommand("rc", "SlashCommand")
   self:RegisterChatCommand("remixcogwheel", "SlashCommand")
   
   self.GEM_LOOKUP = {}
   self:BuildGemLookup()

   self:CreateButton()
   self:SettingsChanged()
   
   -- TODO: REMOVE: USED TO OPEN OPTIONS ON LAUNCH
   -- C_Timer.After(2, function() 
   --    InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)  
   --    InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
   -- end)  
end

function RemixCogwheel:OnEnable()
   self:RegisterEvent("BAG_UPDATE_DELAYED")
   self:RegisterEvent("SPELL_UPDATE_COOLDOWN")   
end

function RemixCogwheel:BAG_UPDATE_DELAYED()
   -- print("##BAG_UPDATE. isRunning:" .. tostring(isRunning))
   local equippedChanged = false
   if not isRunning then
      equippedChanged = self:GetAndSetEquippedGem()
   end

   self:FindGemsInBags()

   if not isRunning and equippedChanged then
      self:UpdateButton()
   end
end

function RemixCogwheel:SPELL_UPDATE_COOLDOWN()
   if not self.equippedCD then return end   

   local start, duration = GetSpellCooldown(self.equippedCD)
   self.cd:SetCooldown(start, duration)
end

function RemixCogwheel:OnDisable()
end

function RemixCogwheel:SettingsChanged()
   self.f:SetShown(self.db.char.btnVisible)
end

local function onDragStart(self)
   if not RemixCogwheel.db.char.btnLocked then
       self:StartMoving()
   end
end

local function onDragStop(self)
   self:StopMovingOrSizing()
   local point, relativeTo, relativePoint, offsetX, offsetY = self:GetPoint()
   RemixCogwheel.db.char.btnX = offsetX
   RemixCogwheel.db.char.btnY = offsetY
end

function RemixCogwheel:CreateButton()
   self.f = CreateFrame("Button", "RemixCogwheelButton", UIParent, "SecureActionButtonTemplate")
   self.f:SetPoint("CENTER", RemixCogwheel.db.char.btnX, RemixCogwheel.db.char.btnY)
   self.f:SetMovable(true)
   self.f:EnableMouse(true)
   self.f:RegisterForDrag("LeftButton")
   self.f:RegisterForClicks("AnyUp")
   self.f:SetAttribute("type1", "macro")   
   self.f:SetSize(45, 45)
   self.f:SetScale(self.db.char.scale)

   self.t = self.f:CreateTexture(nil, "BACKGROUND")
   self.t:SetAllPoints()
   self.t:SetTexCoord(0.07, .93, 0.07, .93) --zoom

   self.fs1 = self.f:CreateFontString(nil, "OVERLAY", "GameTooltipText")
   self.fs1:SetPoint("CENTER", 0, 6)
   self.fs1:SetShadowColor(0,0,0)
   self.fs1:SetShadowOffset(1,-1)

   self.fs2 = self.f:CreateFontString(nil, "OVERLAY", "GameTooltipText")
   self.fs2:SetPoint("CENTER", 0, -5)
   self.fs2:SetShadowColor(0,0,0)
   self.fs2:SetShadowOffset(1,-1)

   self.cd = CreateFrame("Cooldown", "RemixCogwheelCooldown", self.f, "CooldownFrameTemplate")
   self.cd:SetAllPoints()
   self.cd:SetDrawEdge(false)

   self.f:SetScript("OnDragStart", onDragStart)
   self.f:SetScript("OnDragStop", onDragStop)
   self.f:SetScript('PreClick', function (btn, button)
      if button == "RightButton" then     
         EasyMenu(contextMenu, contextMenuFrame, "cursor", 0 , 0, "MENU");
      else 
         isRunning = true
      end
   end)
   
   self.f:SetScript('PostClick', function (btn, button)
      
      if button == "RightButton" then return end

      if IsModifierKeyDown() then
         self:PrintWarning("modifier key is pressed. cannot swap gem.")
         isRunning = false
         return
      end

      -- not printing warning here, the main part of macro will show the error, 'you are in combat'
      if InCombatLockdown() then
         isRunning = false
         return
      end

      local b = self.next.bag 
      local s = self.next.slot

      C_Timer.After(1, function() 
         SocketInventoryItem(8)
         
         -- check for error state and bail
         if GetExistingSocketLink(8) then
            self:PrintWarning("already a gem in socket, not swapping.")
            isRunning = false
            return
         end
         
         C_Container.PickupContainerItem(b,s)
         ClickSocketButton(1)
         ClearCursor()
         AcceptSockets()
         CloseSocketInfo()

         isRunning = false
         local moveGem = self.equipped
         self.equipped.isEquipped = false
         self.next.isEquipped = true
         self.equipped = self.next
         self.next = nil

         self:UpdateButton()
         self:MoveGem(moveGem)

         -- after move, clear the bag and slot info
         self.equipped.bag = nil
         self.equipped.slot = nil         
      end)
   end)
end

function RemixCogwheel:MoveGem(move)     
   C_Container.PickupContainerItem(move.bag, move.slot)
   C_Container.PickupContainerItem(self.equipped.bag, self.equipped.slot)   
end

function RemixCogwheel:BuildGemLookup()    
   for i = 1, #self.db.char.GEMS do
      local gem = self.db.char.GEMS[i]
      local gemId = tostring(gem.gemId)

      -- default to enabled
      if gem.isEnabled == nil then
         gem.isEnabled = true
      end

      self.GEM_LOOKUP[gemId] = self.db.char.GEMS[i]
   end
end

function RemixCogwheel:FindGemsInBags()
   -- print("##FindGemsInBags")
   for b = 0, NUM_BAG_SLOTS do
      for s = 1, C_Container.GetContainerNumSlots(b) do
         local itemID = C_Container.GetContainerItemID(b, s)
         if itemID then
            local gem = self.GEM_LOOKUP[tostring(itemID)]
            if gem then
               gem.bag = b
               gem.slot = s
               gem.isOwned = true
               gem.isEquipped = false
            end
         end
      end
   end

   -- move any not found or disabled cogs to end of list
   local invalid, i = {}, 1
   while i <= #self.db.char.GEMS do
      local gem = self.db.char.GEMS[i]

      if not gem.isOwned or not gem.isEnabled then          
         table.insert(invalid, table.remove(self.db.char.GEMS, i))
      else
         i = i + 1
      end
   end

   for i = 1, #invalid do
      local gem = invalid[i]
      table.insert(self.db.char.GEMS, gem)
   end   
end

-- Looks for equipped gem and sets in local object.  returns true if it changed
function RemixCogwheel:GetAndSetEquippedGem()
   local gem = nil
   local cur = self.equipped

   -- check for having boots first
   local boots = GetInventoryItemLink("player", 8)
   if boots then
      -- then find out what gem is in the boots, and find its object
      local _, _, _, gemID, _ = strsplit(":", boots, 5)
      for i = 1, #self.db.char.GEMS do
         local g = self.db.char.GEMS[i]
         if tostring(g.gemId) == tostring(gemID) then
            gem = g
            gem.isEquipped = true
            gem.isOwned = true
            gem.bag = nil
            gem.slot = nil
            break
         end
      end
   else
      gem = false
   end

   -- if no equipped gem, then should also clear next
   if not gem then
      self.next = nil
   end
      
   self.equipped = gem
   return self.equipped ~= cur
end

function RemixCogwheel:GetNextGem()
   if not self.equipped then return nil end
   
   local next = nil   
   for i = 1, #self.db.char.GEMS do
      if self.db.char.GEMS[i].isEquipped then
         -- if were at the end, select the 1st, or if all thats left is disabled
         if i == #self.db.char.GEMS or not self.db.char.GEMS[i+1].isEnabled or not self.db.char.GEMS[i+1].isOwned then 
            next = self.db.char.GEMS[1]
         else
            next = self.db.char.GEMS[i+1]
         end
      end
   end

   return next
end

function RemixCogwheel:UpdateButton()
   -- print("##UpdateButton")
  
   -- verify boots and gem equipped
   if not self.equipped then
      self.fs1:SetText("NO")

      if self.equipped == false then
         self.t:SetTexture("interface\\icons\\INV_Boots_Plate_01")                   
         self.fs2:SetText("BOOTS")
      elseif self.equipped == nil then
         self.t:SetTexture("interface\\icons\\INV_Misc_Gear_01")
         self.fs2:SetText("GEM")
      end

      -- fade, desaturate and disable the button
      self.t:SetDesaturated(true)
      self.t:SetAlpha(.7)
      self.f:Disable()
      return
   end   

   -- find next gem   
   self.next = self:GetNextGem()

   -- update cooldown 
   self.equippedCD = self.equipped.spellId   
   self.cd:SetCooldown(0, 0)

   -- update the button to match current gem
   self.t:SetTexture("interface\\icons\\" .. self.equipped.texture)
   self.t:SetDesaturated(false)
   self.t:SetAlpha(1)
   self.fs1:SetText("")
   self.fs2:SetText("")
   
   -- enable the button
   self.f:Enable()

   -- update the macro
   -- TODO: need combat protection again
   self.f:SetAttribute("macrotext1", strtemplate(CAST_MACRO, self.equipped.name))
end

-- Expose for macros/opie     
function RemixCogwheel:SwapInGem(gemId)
   self.f:SetAttribute("macrotext", NOOP_MACRO)
   self.next = self.GEM_LOOKUP[tostring(gemId)]
end

function RemixCogwheel:SlashCommand(msg)
   if not msg or msg:trim() == "" then
      InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
      InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
   end
end

function RemixCogwheel:PrintWarning(msg)
   UIErrorsFrame:AddMessage(ORANGE_FONT_COLOR:WrapTextInColorCode(APPNAME .. ": " .. msg))
end

function RemixCogwheel:DumpGemInfo()
   local gems = self.db.char.GEMS
   
   print("===== GEM INFO ======")
   for i = 1, #gems do
      local gem = gems[i]

      local isEquipped = gem.isEquipped and " EQUIPPED" or ""
      local isEnabled = gem.isEnabled and " ENABLED " or ""
      local isOwned = gem.isOwned and " OWNED" or ""
      
      print(string.format("%s: (%s,%s)%s%s%s", gem.name, tostring(gem.bag), tostring(gem.slot), isEquipped, isEnabled, isOwned))
   end

   print()
   if (self.equipped) then
      print(string.format("equipped: %s", self.equipped.name))
   else
      print("WARN: no equipped gem")
   end
   if (self.next) then
      print(string.format("next: %s", self.next.name))
   else
      print("WARN: no next gem")
   end
   
end