-- EzAccent static data. The accent rules themselves are in Rules.lua (generated, see tools/gen_rules.py).
local _, ns = ...

ns.ERA = select(4, GetBuildInfo()) < 16000

-- UnitRace's file name -> the accent a new character starts with (EzAccentCharDB.accent).
ns.RACE_ACCENT = { Orc = "orc", Troll = "troll", Dwarf = "dwarf", Scourge = "undead", Undead = "undead" }

-- Accent choices, in the order /acc accent lists them. "race" is not stored: it picks the race's accent.
ns.ACCENTS = {
    { key = "orc", label = "Orc" },
    { key = "troll", label = "Troll" },
    { key = "dwarf", label = "Dwarf" },
    { key = "undead", label = "Undead", thick = "jawless" },
    { key = "none", label = "None" },
}

-- What --thick does to each accent, for /acc accent and the box title.
ns.THICK_LABEL = { orc = "thick", troll = "thick", dwarf = "thick, Gaelic", undead = "jawless" }

-- /acc <letter> <text>: the letters that pick a channel. Lowercase only, so a line starting "E" or "I" is said.
ns.SHORT_CHANNELS = { s = "SAY", y = "YELL", p = "PARTY", g = "GUILD", o = "OFFICER", r = "RAID", e = "EMOTE",
                      w = "WHISPER" }

-- In the box, a line can start like a chat command: /y Hello!
ns.BOX_CHANNELS = {
    s = "SAY", say = "SAY", y = "YELL", yell = "YELL", p = "PARTY", party = "PARTY", g = "GUILD", guild = "GUILD",
    o = "OFFICER", officer = "OFFICER", r = "RAID", raid = "RAID", e = "EMOTE", em = "EMOTE", me = "EMOTE",
    emote = "EMOTE", w = "WHISPER", whisper = "WHISPER", t = "WHISPER", tell = "WHISPER",
}

ns.CHANNEL_LABEL = { SAY = "say", YELL = "yell", PARTY = "party", GUILD = "guild", OFFICER = "officer",
                     RAID = "raid", EMOTE = "emote", WHISPER = "whisper" }

-- How many versions /acc test prints.
ns.TEST_VERSIONS = 3
