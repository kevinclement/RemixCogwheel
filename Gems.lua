local AceEvent = LibStub("AceEvent-3.0")

NOTIFY_GEMS = {}
AceEvent:Embed(NOTIFY_GEMS) 

GEMS_VERSION = "0.9"
GEMS = {
   {
      name = "Sprint",
      texture = "ability_rogue_sprint",
      spellId = 427030,
      gemId = 216632
   },
   {
      name = "Spirit Walk",
      texture = "ability_tracking",
      spellId = 441576,
      gemId = 218046
   },
   {
      name = "Stampeding Roar",
      texture = "spell_druid_stamedingroar",
      spellId = 441493,
      gemId = 218005
   },   
   {
      name = "Blink",
      texture = "spell_arcane_blink",
      spellId = 427053,
      gemId = 216629
   },

   -- {
   --    name = "Soulshape",
   --    texture = "ability_nightfae_flicker",
   --    spellId = 441759,
   --    gemId = 218110,
   -- },   


   -- DISABLED by default since not really 'sprint'-like but still here for macros
   -- ############################################################################
   {
      name = "Heroic Leap",
      texture = "ability_heroicleap",
      spellId = 427033,
      gemId = 216630,
      isEnabled = false
   },
   {
      name = "Trailblazer",
      texture = "ability_hunter_aspectmastery",
      spellId = 441348,
      gemId = 217989,
      isEnabled = false
   },
   {
      name = "Pursuit of Justice",
      texture = "ability_paladin_veneration",
      spellId = 441564,
      gemId = 218044,
      isEnabled = false
   },
   {
      name = "Door of Shadows",
      texture = "ability_venthyr_doorofshadows",
      spellId = 441569,
      gemId = 218045,
      isEnabled = false
   },
   {
      name = "Death's Advance",
      texture = "spell_shadow_demonicempathy",
      spellId = 441749,
      gemId = 218109,
      isEnabled = false
   },
   {
      name = "Leap of Faith",
      texture = "priest_spell_leapoffaith_a",
      spellId = 441467,
      gemId = 218003,
      isEnabled = false
   },   
   {
      name = "Disengage",
      texture = "ability_rogue_feint",
      spellId = 441299,
      gemId = 217983,
      isEnabled = false
   },
   {
      name = "Wild Charge",
      texture = "spell_druid_wildcharge",
      spellId = 441559,
      gemId = 218043,
      isEnabled = false
   },
   {
      name = "Vanish",
      texture = "ability_vanish",
      spellId = 441479,
      gemId = 218004,
      isEnabled = false
   },
   
   -- BUG: Roll doesn't work with this right now, need to investigate
   -- {
   --    name = "Roll",
   --    texture = "ability_monk_roll",
   --    spellId = 427026,
   --    gemId = 216631,
   --    isEnabled = false,
   -- },

   -- FULLY DISABLED: don't see use for this for now
   -- ############################################################################
   -- {
   --    name = "Dark Pact",
   --    texture = "spell_shadow_deathpact",
   --    spellId = 441741,
   --    gemId = 218108,
   --    isEnabled = false
   -- },
   -- {
   --    name = "Spiritwalker's Grace",
   --    texture = "spell_shaman_spiritwalkersgrace",
   --    spellId = 441617,
   --    gemId = 218082,
   --    isEnabled = false
   -- }
}
