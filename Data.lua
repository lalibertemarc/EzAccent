-- EzAccent static data. The accent rules themselves are in Rules.lua (generated, see tools/gen_rules.py).
local _, ns = ...

ns.ERA = select(4, GetBuildInfo()) < 16000

-- UnitRace's file name -> the accent a new character starts with (EzAccentCharDB.accent).
ns.RACE_ACCENT = { Orc = "orc", Troll = "troll", Dwarf = "dwarf", Scourge = "undead", Undead = "undead" }

-- Accent choices, in the order /acc accent lists them. "race" is not stored: it picks the race's accent.
ns.ACCENTS = {
    { key = "orc", label = "Orc", desc = "Short and blunt, with a bit of Orcish." },
    { key = "troll", label = "Troll", desc = "Da Darkspear way, mon." },
    { key = "dwarf", label = "Dwarf", desc = "Ye'll be wantin' a pint, lad." },
    { key = "undead", label = "Undead", desc = "A locked jaw: the vowels come out squeezed.", thick = "jawless" },
    { key = "none", label = "None", desc = "Lines go out as you type them." },
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

-- The box's channel list (a click on the channel), in order, with the command that picks it from a line.
-- need: greyed unless you're in a group, a raid or a guild.
ns.BOX_MENU = {
    { chatType = "SAY", label = "Say", cmd = "/s" },
    { chatType = "YELL", label = "Yell", cmd = "/y" },
    { chatType = "EMOTE", label = "Emote", cmd = "/e" },
    { chatType = "PARTY", label = "Party", cmd = "/p", need = "group" },
    { chatType = "RAID", label = "Raid", cmd = "/r", need = "raid" },
    { chatType = "GUILD", label = "Guild", cmd = "/g", need = "guild" },
    { chatType = "OFFICER", label = "Officer", cmd = "/o", need = "guild" },
    { chatType = "WHISPER", label = "Whisper", cmd = "/w name" },
}

-- How many people you whispered with (either way) are kept for the box's names, per character.
ns.RECENT_MAX = 10

-- Words the accents call whoever you talk to, and what a woman hears instead (whole words, swapped after the
-- accent): the dwarf tag ", lad" and the troll "bruddah" (from friend or brother). Only words the accent put in: a
-- line you typed with one of typed in it keeps them. A line that already says "lass" (yours, or dwarf "girl") loses
-- the ", lad" tag instead of saying it twice.
ns.TO_HER = {
    { he = "lad", she = "lass", typed = { "lad" } },
    { he = "bruddah", she = "sistah", typed = { "brother", "bruddah" } },
}

-- The options page's Preview button prints this line in your accent.
ns.SAMPLE = "Thank you, that's a fine blessing. I'll buy you a drink later."

-- How many versions /acc test prints.
ns.TEST_VERSIONS = 3

-- Jawless to jawless (Translate.lua): what a jawless line meant goes out as an addon message on the line's channel
-- (emotes have none: /say reaches as far).
ns.MEANING_PREFIX = "EzAccent"
ns.MEANING_CHANNELS = { SAY = "SAY", YELL = "YELL", EMOTE = "SAY", PARTY = "PARTY", RAID = "RAID", GUILD = "GUILD",
                        OFFICER = "OFFICER", WHISPER = "WHISPER" }
ns.MEANING_EVENTS = { "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_EMOTE", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER",
                      "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER",
                      "CHAT_MSG_WHISPER" }
-- Seconds a meaning waits for its line before it shows on a line of its own.
ns.MEANING_WAIT = 1.5
ns.MEANING_COLOR = "|cffa0a0a0"
