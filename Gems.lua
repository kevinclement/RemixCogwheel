local AceEvent = LibStub("AceEvent-3.0")

NOTIFY_GEMS = {}
AceEvent:Embed(NOTIFY_GEMS) 

GEMS = {
   {
      name = "Sprint",
      texture = "ability_rogue_sprint",
      spellId = 427030,
      gemId = 216632
   },
   {
      name = "Roll",
      texture = "ability_monk_roll",
      spellId = 427026,
      gemId = 216631
   },
   {
      name = "Blink",
      texture = "spell_arcane_blink",
      spellId = 427053,
      gemId = 216629      
   },
   {
      name = "Heroic Leap",
      texture = "ability_heroicleap",
      spellId = 427031,
      gemId = 216630
   },
   {
      name = "Stampeding Roar",
      texture = "spell_druid_stamedingroar",
      spellId = 441493,
      gemId = 218005
   },
   {
      name = "Spirit Walk",
      texture = "ability_tracking",
      spellId = 441576,
      gemId = 218046
   },
   {
      name = "Death's Advance",
      texture = "spell_shadow_demonicempathy",
      spellId = 441749,
      gemId = 218109
   }
   
   

   -- TODO: soulshape test
   -- ["218110"]
   --    name = "Soulshape",
   --    spellId = 441759,
   --    texture = "ability_nightfae_flicker"
  
   -- 30% movement increase when out of combat 3s
   -- {
   --    name = "Trailblazer",
   --    texture = "ability_hunter_aspectmastery",
   --    spellId = 441348,
   --    gemId = 217989
   -- },
   

   }

   -- Not really movement gems, should they be in the loop but disabled?
   -- maybe for macros?
   -- #####################################################################

   -- ["218045"]
   --    name = "Door of Shadows",
   --    spellId = 441569,
   --    texture = "ability_venthyr_doorofshadows"

   -- Pull party member, 40% increase (borderline)
   -- ["218003"]
   --    name = "Leap of Faith",
   --    spellId = 441471,
   --    texture = "priest_spell_leapoffaith_a"
   
   -- Leep backwards, then 25% (borderline)
   -- ["217983"]
   --    name = "Disengage",
   --    spellId = 441299,
   --    texture = "ability_rogue_feint"

   -- Fly to a nearby ally's position
   -- ["218043"]
   --    name = "Wild Charge",
   --    spellId = 441559,
   --    texture = "spell_druid_wildcharge"
   
   -- Flat 8% movement speed increase
   -- ["218044"]
   --    name = "Pursuit of Justice",
   --    spellId = 441564,
   --    texture = "ability_paladin_veneration"

   -- Enter stealth
   -- ["218004"]
   --    name = "Vanish",
   --    spellId = 441479,
   --    texture = "ability_vanish"
   
   -- Sac 20% of current health to shield 200% sac'd health
   --  ["218108"]
   --    name = "Dark Pact",
   --    spellId = 441741,
   --    texture = "spell_shadow_deathpact"
   
   -- 15s ability to cast while moving
   -- ["218082"]
   --    name = "Spiritwalker's Grace",
   --    spellId = 441617,
   --    texture = "spell_shaman_spiritwalkersgrace"
     
   
    