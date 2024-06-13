
print(string.format("moving %s: %s%s%s", 
   gem.name, 
   gem.isEquipped and " EQUIPPED" or " NOT EQUIPPED",
   gem.isOwned and " OWNED" or " NOT OWNED",
   gem.isEnabled and " ENABLED" or " NOT ENABLED"))

print(format("post click move.  equip: %s next: %s", self.equipped and self.equipped.name or "nil", self.next and self.next.name or "nil"))
print(format("post click move 2.  equip: %s next: %s", RemixCogwheel.equipped and RemixCogwheel.equipped.name or "nil", RemixCogwheel.next and RemixCogwheel.next.name or "nil"))
print(format("cog %s: isEnabled:%s isOwned:%s", cog.name, cog.isEnabled and "ENABLED" or "DISABLED", cog.isOwned and "OWNED" or "NOT OWNED"))

print(format("movegem.  move: %s (%s,%s) equip: %s (%s,%s)", 
      move and move.name or "nil",
      move and move.bag or "nil", 
      move and move.slot or "nil", 
      self.equipped and self.equipped.name or "nil", 
      self.equipped and self.equipped.bag or "nil", 
      self.equipped and self.equipped.slot or "nil"))
      
   -- TODO: TMP
   -- self.t:SetTexture("interface\\icons\\INV_Boots_Plate_01")
   -- self.f:SetAttribute("macrotext",
   --    "/script print('frame button clicked')\n"
   -- )

   
      -- TODO: TMP #################################################
      -- local tmpGem = {
      --    name = "Pursuit of Justice",
      --    texture = "ability_paladin_veneration",
      --    spellId = 441564,
      --    gemId = 218044,
      --    bag = nil,
      --    slot = nil,
      --    isEquipped = false, 
      --    needsMove = false,
      --    isEnabled = true,
      --    isOwned = true
      -- }

      -- local dest = 1
	   -- for i = 1, #GEMS do
   	-- 	if GEMS[i].isEnabled then
	   -- 		dest = i
		--    end
	   -- end	   
      -- table.insert(GEMS, dest + 1, tmpGem)
      -- reg:NotifyChange(APPNAME)
      -- ###########################################################


-- ## SOCKET FRAME PROTECTION ################################################
-- // in case we need more socket frame protection, here are some of the learnings
-- function RemixCogwheel:SupressSocketFrameStuff()
--    if not self.suppressed then
--          self.suppressed = true;
--          UIParent:UnregisterEvent("SOCKET_INFO_UPDATE");
--          UIParent:UnregisterEvent("ADDON_ACTION_FORBIDDEN");
--          if ItemSocketingFrame then
--             ItemSocketingFrame:UnregisterEvent("SOCKET_INFO_UPDATE");
--          end
--    end 
-- end
-- function RemixCogwheel:UnsuppressSocketFrameStuff()
--    if self.suppressed then
--        self.suppressed = nil;
--        UIParent:RegisterEvent("SOCKET_INFO_UPDATE");
--        UIParent:RegisterEvent("ADDON_ACTION_FORBIDDEN");
--        if ItemSocketingFrame then
--            ItemSocketingFrame:RegisterEvent("SOCKET_INFO_UPDATE");
--        end
--    end
-- end
-- ###########################################################################

-- if InCombatLockdown() then
--    self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateMacro")
--    return
-- else      
--    self:UnregisterMessage("PLAYER_REGEN_ENABLED")         
--    self.f:Enable()
-- end
-- function RemixCogwheel:DumpGemInfo()
--    print("===== GEM INFO ======")
--    for i = 1, #GEMS do
--       local info = GEMS[i]
--       local isEquipped = info.isEquipped and " EQUIPPED" or ""
--       local needsMove = info.needsMove and " MOVE" or ""
--       print(string.format("%s: (%s,%s)%s%s", info.name, tostring(info.bag), tostring(info.slot), isEquipped, needsMove))
--    end
-- end

-- function RemixCogwheel:DumpGemInfoFull()
--    print("===== GEM INFO ======")
--    for i = 1, #GEMS do
--       local info = GEMS[i]
--       print(string.format("%s:", info.name))
--       print(string.format("  id:     %s",   tostring(info.gemId)))
--       print(string.format("  txt:    %s",   tostring(info.texture)))
--       print(string.format("  bag:  %s",   tostring(info.bag)))
--       print(string.format("  slot:  %s",   tostring(info.slot)))
--       print(string.format("  next: %s",   tostring(info.next)))
--       print(string.format("  isEq: %s\n\n", tostring(info.isEquipped)))
--       print(string.format("  move: %s\n\n", tostring(info.needsMove)))
--    end
-- end
-- ================================================================
-- Pauses execution while this is waiting the appropriate amount of seconds.
function Wait(seconds)
    local start = tonumber(date('%S'))
    repeat until tonumber(date('%S')) > start + seconds
 end