-- EzAccent: type a line and your character says it in their accent (/acc, or the key binding's edit box).
local _, ns = ...

BINDING_HEADER_EZACCENT = "EzAccent"
BINDING_NAME_EZACCENT_BOX = "Open the accent box"

local MAX = 255  -- chat message limit, in bytes

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffc79c6eEzAccent|r: " .. msg)
end
ns.Print = Print

local function Trim(s)
    return (s or ""):match("^%s*(.-)%s*$")
end
ns.Trim = Trim

local function issecret(v)
    return issecretvalue and issecretvalue(v)
end

---------------------------------------------------------------------------
-- Chat. Only ever called from a slash command or a key press in the box, which give the send its hardware event;
-- never from a timer or an event (Forever blocks those).
---------------------------------------------------------------------------
local function Send(msg, chatType, target)
    if C_ChatInfo and C_ChatInfo.SendChatMessage then
        C_ChatInfo.SendChatMessage(msg, chatType, nil, target)
    else
        SendChatMessage(msg, chatType, nil, target)
    end
end

-- Encounters and similar lock addon chat (C_ChatInfo.InChatMessagingLockdown). A real game block:
-- SendChatMessage then raises ADDON_ACTION_BLOCKED.
local function ChatLocked()
    return C_ChatInfo and C_ChatInfo.InChatMessagingLockdown and C_ChatInfo.InChatMessagingLockdown()
end

---------------------------------------------------------------------------
-- Settings (EzAccentCharDB: accent, thick)
---------------------------------------------------------------------------
local function RaceAccent()
    return ns.RACE_ACCENT[select(2, UnitRace("player"))] or "none"
end

local function Accent()
    return EzAccentCharDB and EzAccentCharDB.accent or RaceAccent()
end

local function Thick()
    return EzAccentCharDB and EzAccentCharDB.thick or false
end

-- Undead with no jaw: only they read each other's meaning (Translate.lua).
function ns.Jawless()
    return Accent() == "undead" and Thick()
end

local function AccentInfo(key)
    for _, a in ipairs(ns.ACCENTS) do
        if a.key == key then return a end
    end
end

-- "Troll (thick)", "Undead (jawless)", "None"
local function AccentLabel()
    local a = Accent()
    local info = AccentInfo(a)
    local label = info and info.label or a
    if a ~= "none" and Thick() then label = label .. " (" .. ns.THICK_LABEL[a] .. ")" end
    return label
end
ns.AccentLabel = AccentLabel

local function AccentKeys()
    local keys = {}
    for _, a in ipairs(ns.ACCENTS) do keys[#keys + 1] = a.key end
    keys[#keys + 1] = "race"
    return table.concat(keys, ", ")
end

---------------------------------------------------------------------------
-- Other addons' accents (EzAccentAPI). EzMinion, DeadButDelicious and BuffMePlease register at login; setting the
-- accent or thick here (slash or options) passes it to each, which sets its own to the nearest one it has. Their
-- own accent commands still set theirs alone, and nothing is passed at login, so those choices stay.
-- EzAccentDB.share (default on) turns it off.
---------------------------------------------------------------------------
local listeners = {}

EzAccentAPI = {
    -- fn(accent, thick) -> what it set, for the chat line ("EzMinion to jawless"), or nil when it had that already.
    OnAccentChanged = function(fn) listeners[#listeners + 1] = fn end,
    GetAccent = function() return Accent(), Thick() end,
}

local function Share()
    if not EzAccentDB.share then return end
    local set = {}
    for _, fn in ipairs(listeners) do
        local said = fn(Accent(), Thick())
        if said then set[#set + 1] = said end
    end
    if #set > 0 then Print("Also set " .. table.concat(set, ", ") .. ".") end
end
ns.Share = Share

local function SetShare(arg)
    arg = Trim(arg):lower()
    if arg == "on" then
        EzAccentDB.share = true
    elseif arg == "off" then
        EzAccentDB.share = false
    elseif arg ~= "" then
        return Print("Use /acc share on, or /acc share off.")
    end
    Print(EzAccentDB.share and "Changing your accent here also sets it in DeadButDelicious and BuffMePlease."
        or "Your accent here is yours alone; the other addons keep theirs.")
end

local function SetAccent(arg)
    arg = Trim(arg):lower()
    if arg == "" then
        return Print("Accent: " .. AccentLabel() .. ". Change it with /acc accent <" .. AccentKeys() .. ">.")
    end
    if arg == "race" then
        EzAccentCharDB.accent = RaceAccent()
    elseif AccentInfo(arg) then
        EzAccentCharDB.accent = arg
    else
        return Print("Unknown accent \"" .. arg .. "\". Choose from: " .. AccentKeys() .. ".")
    end
    Print("Accent: " .. AccentLabel() .. ".")
    Share()
end

local function SetThick(arg)
    arg = Trim(arg):lower()
    if arg == "on" then
        EzAccentCharDB.thick = true
    elseif arg == "off" then
        EzAccentCharDB.thick = false
    elseif arg == "" then
        EzAccentCharDB.thick = not EzAccentCharDB.thick
    else
        return Print("Use /acc thick on, or /acc thick off.")
    end
    Print("Thick accent " .. (EzAccentCharDB.thick and "on" or "off") .. ". Accent: " .. AccentLabel() .. ".")
    Share()
end

---------------------------------------------------------------------------
-- Saying it
---------------------------------------------------------------------------
-- Whispers. Forever names have surnames and whispers need "First Surname", so a typed first name is looked up
-- among the people you'd likely whisper: your target, those you whispered with lately (EzAccentCharDB.whispers,
-- newest first) and your group.
local function UnitFullName(unit)
    local exists, isPlayer = UnitExists(unit), UnitIsPlayer(unit)
    if issecret(exists) or issecret(isPlayer) or not (exists and isPlayer) then return end
    local first, surname = UnitName(unit)
    if not first or issecret(first) then return end
    if surname and not issecret(surname) and surname ~= "" then
        return first .. (ns.ERA and "-" or " ") .. surname
    end
    return first
end

local function NameKey(name)
    return (name:match("^[^%s%-]+") or name):lower()
end
ns.NameKey = NameKey

local function GroupUnits()
    local units, n = {}, GetNumGroupMembers() or 0
    if IsInRaid() then
        for i = 1, n do units[#units + 1] = "raid" .. i end
    else
        for i = 1, n - 1 do units[#units + 1] = "party" .. i end
    end
    return units
end

-- { { name, why }, ... }: each person once, never you.
local function WhisperNames()
    local list, seen = {}, {}
    local me = UnitName("player")
    if me and not issecret(me) then seen[NameKey(me)] = true end
    local function add(name, why)
        if name and not seen[NameKey(name)] then
            seen[NameKey(name)] = true
            list[#list + 1] = { name = name, why = why }
        end
    end
    add(UnitFullName("target"), "target")
    for _, name in ipairs(EzAccentCharDB and EzAccentCharDB.whispers or {}) do add(name, "whispered") end
    for _, unit in ipairs(GroupUnits()) do add(UnitFullName(unit), "group") end
    return list
end
ns.WhisperNames = WhisperNames

-- The name to whisper for one typed: %t is your target, a lone first name someone above has gets their surname,
-- anything else goes out as typed. nil: nobody (%t without a target).
local function ResolveName(name)
    name = Trim(name)
    if name == "%t" then return UnitFullName("target") end
    if name == "" then return end
    if name:find("%s") then return name end
    for _, p in ipairs(WhisperNames()) do
        if NameKey(p.name) == NameKey(name) then return p.name end
    end
    return name
end
ns.ResolveName = ResolveName

-- A whisper's author as the game gives it: "First-Surname" in Forever, made "First Surname" (what whispers take);
-- "Name-Realm" in Era, kept (it whispers fine).
local function Remember(author)
    if not EzAccentCharDB or type(author) ~= "string" or issecret(author) or author == "" then return end
    local name = ns.ERA and author or author:gsub("%-", " ")
    local list = EzAccentCharDB.whispers
    for i = #list, 1, -1 do
        if NameKey(list[i]) == NameKey(name) then table.remove(list, i) end
    end
    table.insert(list, 1, name)
    for i = #list, ns.RECENT_MAX + 1, -1 do list[i] = nil end
end

-- A whisper's name and the text after it: "First Surname" in quotes, or a name as ResolveName takes it (a surname
-- typed after a first name it filled in is skipped).
local function WhisperTarget(rest)
    local quoted, text = rest:match('^"([^"]+)"%s+(.+)$')
    if quoted then return quoted, text end
    local name
    name, text = rest:match("^(%S+)%s+(.+)$")
    if not name then return end
    local full = ResolveName(name)
    if not full then return end
    local surname = full ~= name and full:match("^[^%s%-]+[%s%-](.+)$")
    local typed, after = text:match("^(%S+)%s+(.+)$")
    if surname and typed and typed:lower() == surname:lower() then text = after end
    return full, text
end

local function Say(text, chatType, target)
    text = Trim(text)
    if text == "" then return Print("Nothing to say.") end
    if chatType == "WHISPER" and not target then return Print("Whisper whom? /acc w <name> <text>") end
    if ChatLocked() then return Print("The game blocks addon chat right now.") end
    local accent, thick = Accent(), Thick()
    local said
    if chatType == "EMOTE" and text:find('"[^"]+"') then
        -- /e smiles. "Well met!": only the quoted speech has an accent.
        said = text:gsub('"([^"]+)"', function(q) return '"' .. ns.Speak(accent, q, thick, MAX) .. '"' end)
    else
        said = ns.Speak(accent, text, thick, MAX)
    end
    ns.SendMeaning(text, chatType, target)
    for _, msg in ipairs(ns.Split(said, MAX)) do
        Send(msg, chatType, target)
    end
end
ns.Say = Say

-- rest of a /acc <letter> or box /<channel> line
local function SayTo(chatType, rest)
    if chatType == "WHISPER" then
        local target, text = WhisperTarget(Trim(rest))
        if not target then return Print("Whisper whom? /acc w <name> <text> (or %t for your target)") end
        return Say(text, chatType, target)
    end
    Say(rest, chatType)
end
ns.SayTo = SayTo

local function Test(text)
    text = Trim(text)
    if text == "" then return Print("/acc test <text> shows your line in your accent, without sending it.") end
    local accent, thick = Accent(), Thick()
    if accent == "none" then return Print("Your accent is None, so lines go out as you type them.") end
    Print(AccentLabel() .. ":")
    local seen = {}
    for _ = 1, ns.TEST_VERSIONS * 12 do
        local v = ns.Speak(accent, text, thick, MAX)
        if not seen[v] and v ~= text then
            seen[v] = true
            seen[#seen + 1] = v
            DEFAULT_CHAT_FRAME:AddMessage("  " .. v)
            if #seen >= ns.TEST_VERSIONS then break end
        end
    end
    if #seen == 0 then DEFAULT_CHAT_FRAME:AddMessage("  (no change: " .. text .. ")") end
end
ns.Test = Test

---------------------------------------------------------------------------
-- Slash command
---------------------------------------------------------------------------
local function OpenSettings()
    if InCombatLockdown() then return Print("Options can't open in combat.") end
    if ns.settingsCategory then Settings.OpenToCategory(ns.settingsCategory:GetID()) end
end

local HELP = {
    "/acc <text> - say <text> in your accent",
    "/acc y|p|g|o|r|e <text> - yell, party, guild, officer, raid or emote it (/acc s <text> to say a line that starts with a command word)",
    "/acc w <name> <text> - whisper it (\"First Surname\", %t, or the first name of your target, someone you whispered with or in your group)",
    "/acc test <text> - show a few versions in your chat, sends nothing",
    "/acc accent [orc|troll|dwarf|undead|none|race] - this character's accent",
    "/acc thick [on|off] - lay it on thick (dwarf adds Gaelic, undead loses its jaw: only other jawless EzAccent users understand you)",
    "/acc share [on|off] - changing your accent here also sets DeadButDelicious' and BuffMePlease's (on by default)",
    "/acc box - the edit box: pick the channel on its left, or start a line with /y, /p, /w name... (also a key binding: Options > Keybindings > EzAccent)",
    "/acc config - the options page (Options > AddOns > EzAccent)",
}

local function Help()
    Print("Accent: " .. AccentLabel())
    for _, line in ipairs(HELP) do DEFAULT_CHAT_FRAME:AddMessage("  " .. line) end
end

-- Command words are lowercase only, so a sentence starting "Test" or "Thick" is said.
local COMMANDS = {
    help = Help,
    accent = SetAccent,
    thick = SetThick,
    share = SetShare,
    test = Test,
    box = function() ns.OpenBox() end,
    config = OpenSettings,
}

SLASH_EZACCENT1 = "/acc"
SLASH_EZACCENT2 = "/ezaccent"
SlashCmdList.EZACCENT = function(msg)
    msg = Trim(msg)
    if msg == "" then return Help() end
    local cmd, rest = msg:match("^(%S+)%s*(.*)$")
    if COMMANDS[cmd] then return COMMANDS[cmd](rest) end
    local chatType = ns.SHORT_CHANNELS[cmd]
    if chatType then return SayTo(chatType, rest) end
    Say(msg, "SAY")
end

local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_LOGIN")
ev:RegisterEvent("CHAT_MSG_WHISPER")
ev:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
ev:SetScript("OnEvent", function(_, event, ...)
    if event ~= "PLAYER_LOGIN" then return Remember((select(2, ...))) end  -- text, author
    EzAccentDB = EzAccentDB or {}
    if EzAccentDB.share == nil then EzAccentDB.share = true end
    EzAccentCharDB = EzAccentCharDB or {}
    if EzAccentCharDB.accent == nil then EzAccentCharDB.accent = RaceAccent() end
    if EzAccentCharDB.thick == nil then EzAccentCharDB.thick = false end
    if type(EzAccentCharDB.whispers) ~= "table" then EzAccentCharDB.whispers = {} end
    ns.BuildSettings(RaceAccent())
end)
