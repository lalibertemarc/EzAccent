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

-- A line past 255 bytes goes out in pieces, but Forever lets a key press say only one message in a public channel
-- (ns.ONE_PER_PRESS): a second SendChatMessage in the same press is blocked. So the first piece goes now and the
-- rest wait here, one per press: Enter in the box (it opens for them) or /acc more. Escape in the box, or a new
-- line, drops them.
local waiting  -- { chatType, target, pieces = { ... } }, nil when nothing waits

local function Waiting()
    return waiting and #waiting.pieces or 0
end
ns.Waiting = Waiting

local function DropWaiting(quiet)
    if waiting and not quiet then Print(("Dropped the rest of your line (%d more)."):format(#waiting.pieces)) end
    waiting = nil
end
ns.DropWaiting = DropWaiting

local function WaitingNote()
    local n = Waiting()
    if n == 0 then return end
    Print(("%d more to say: press Enter in the box (or /acc more) for each, Escape drops %s."):format(n,
        n == 1 and "it" or "them"))
end

local function SendPieces(pieces, chatType, target)
    DropWaiting()
    if not ns.ONE_PER_PRESS[chatType] then
        for _, msg in ipairs(pieces) do Send(msg, chatType, target) end
        return
    end
    Send(pieces[1], chatType, target)
    if #pieces < 2 then return end
    waiting = { chatType = chatType, target = target, pieces = { select(2, unpack(pieces)) } }
    WaitingNote()
    ns.OpenBox()
end

-- The next waiting piece (a key press or slash only). False when nothing waits.
local function SendNext()
    if not waiting then return false end
    if ChatLocked() then
        Print("The game blocks addon chat right now.")
        return true
    end
    Send(table.remove(waiting.pieces, 1), waiting.chatType, waiting.target)
    if #waiting.pieces == 0 then waiting = nil end
    return true
end
ns.SendNext = SendNext

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
-- Other addons' accents (EzAccentAPI). BuffMePlease, CuriousStranger, Bones, FortuneTeller, EzBlessings, EzMinion
-- and DeadButDelicious register at login (where they're active); setting the accent or thick here (slash or
-- options) passes it to each, which sets its own to the nearest one it has. Their own accent commands still set
-- theirs alone, and nothing is passed at login, so those choices stay.
-- EzAccentDB.share (default on) turns it off.
---------------------------------------------------------------------------
local listeners = {}

EzAccentAPI = {
    -- fn(accent, thick) -> what it set, for the chat line ("EzMinion to jawless"), or nil when it had that already.
    OnAccentChanged = function(fn) listeners[#listeners + 1] = fn end,
    GetAccent = function() return Accent(), Thick() end,
    -- Opens the box on a whisper to name ("First Surname"); EzAcquaintances' book uses it.
    Whisper = function(name) ns.OpenWhisper(name) end,
    -- EzLines: the messages for text in this character's accent (for a woman listening: "lass"), none past 255
    -- bytes; only the "quoted" parts of an emote. Sends nothing.
    Lines = function(text, chatType, target) return ns.Lines(text, chatType, target) end,
    -- EzLines, right before the first message goes out: a jawless speaker's plain meaning (Translate.lua).
    Meaning = function(text, chatType, target) ns.SendMeaning(text, chatType, target) end,
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
    Print(EzAccentDB.share and "Changing your accent here also sets it in your other addons that speak in one"
        .. " (Buff Me Please, Curious Stranger, Bones, Fortune Teller, EzBlessings, EzMinion, Dead But Delicious)."
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

-- UnitSex / GetPlayerInfoByGUID's sex: 2 male, 3 female; nil when unknown or secret.
local function KnownSex(sex)
    if issecret(sex) or (sex ~= 2 and sex ~= 3) then return end
    return sex
end

-- A whisper's author as the game gives it: "First-Surname" in Forever, made "First Surname" (what whispers take);
-- "Name-Realm" in Era, kept (it whispers fine). Their sex from the GUID is kept with them (EzAccentCharDB.sexes).
local function Remember(author, guid)
    if not EzAccentCharDB or type(author) ~= "string" or issecret(author) or author == "" then return end
    local name = ns.ERA and author or author:gsub("%-", " ")
    local list = EzAccentCharDB.whispers
    for i = #list, 1, -1 do
        if NameKey(list[i]) == NameKey(name) then table.remove(list, i) end
    end
    table.insert(list, 1, name)
    for i = #list, ns.RECENT_MAX + 1, -1 do list[i] = nil end

    if type(EzAccentCharDB.sexes) ~= "table" then EzAccentCharDB.sexes = {} end
    local sexes, kept = EzAccentCharDB.sexes, {}
    if type(guid) == "string" and not issecret(guid) and guid ~= "" and GetPlayerInfoByGUID then
        local sex = KnownSex((select(5, GetPlayerInfoByGUID(guid))))
        if sex then sexes[NameKey(name)] = sex end
    end
    for _, n in ipairs(list) do kept[NameKey(n)] = true end
    for key in pairs(sexes) do
        if not kept[key] then sexes[key] = nil end
    end
end

---------------------------------------------------------------------------
-- Whom you speak to: a woman hears the accent's "lad" and "bruddah" as "lass" and "sistah" (ns.TO_HER).
---------------------------------------------------------------------------
-- A player unit's sex, never yours.
local function PlayerSex(unit)
    if not UnitFullName(unit) or UnitIsUnit(unit, "player") then return end
    return KnownSex(UnitSex(unit))
end

-- 3 when you're talking to a woman, 2 a man, nil unknown (your words stay as the accent says them). A whisper's
-- name is looked up among the units you can see, then the people who whispered you; say, yell and emotes go to your
-- target, party and raid to your target when it's in your group; guild and officer to nobody in particular.
local function ListenerSex(chatType, target)
    if chatType == "WHISPER" then
        if not target then return end
        local key = NameKey(target)
        local units = GroupUnits()
        table.insert(units, 1, "target")
        units[#units + 1] = "mouseover"
        for _, unit in ipairs(units) do
            local name = UnitFullName(unit)
            if name and NameKey(name) == key then return PlayerSex(unit) end
        end
        return EzAccentCharDB and EzAccentCharDB.sexes and EzAccentCharDB.sexes[key]
    elseif chatType == "SAY" or chatType == "YELL" or chatType == "EMOTE" then
        return PlayerSex("target")
    elseif chatType == "PARTY" or chatType == "RAID" then
        local inGroup = UnitInParty("target") or UnitInRaid("target")
        if not issecret(inGroup) and inGroup then return PlayerSex("target") end
    end
end

local function Cap(s) return (s:gsub("^%l", string.upper)) end

local function HasWord(s, word)
    return s:lower():find("%f[%a]" .. word .. "%f[%A]") ~= nil
end

-- said (text in an accent) as she hears it: only the words the accent put in, never ones you typed.
local function ToHer(said, text)
    for _, w in ipairs(ns.TO_HER) do
        local typed = false
        for _, t in ipairs(w.typed) do typed = typed or HasWord(text, t) end
        if not typed then
            if HasWord(said, w.she) then said = said:gsub(", " .. w.he .. "%f[%A]", "") end
            said = said:gsub("%f[%a]" .. w.he .. "%f[%A]", w.she):gsub("%f[%a]" .. Cap(w.he) .. "%f[%A]", Cap(w.she))
        end
    end
    return said
end

-- text in your accent for that listener (ListenerSex).
local function Speak(accent, text, thick, sex)
    local said = ns.Speak(accent, text, thick, MAX)
    return sex == 3 and ToHer(said, text) or said
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

-- text as your character says it on chatType (to target, for a whisper).
local function Said(text, chatType, target)
    local accent, thick, sex = Accent(), Thick(), ListenerSex(chatType, target)
    if chatType == "EMOTE" and text:find('"[^"]+"') then
        -- /e smiles. "Well met!": only the quoted speech has an accent.
        return (text:gsub('"([^"]+)"', function(q) return '"' .. Speak(accent, q, thick, sex) .. '"' end))
    end
    return Speak(accent, text, thick, sex)
end

-- The messages to send for text: in your accent, none past 255 bytes. EzAccentAPI.Lines.
function ns.Lines(text, chatType, target)
    return ns.Split(Said(text, chatType, target), MAX)
end

local function Say(text, chatType, target)
    text = Trim(text)
    if text == "" then return Print("Nothing to say.") end
    if chatType == "WHISPER" and not target then return Print("Whisper whom? /acc w <name> <text>") end
    if ChatLocked() then return Print("The game blocks addon chat right now.") end
    ns.SendMeaning(text, chatType, target)
    SendPieces(ns.Lines(text, chatType, target), chatType, target)
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
    local sex = ListenerSex("SAY")
    Print(AccentLabel() .. (sex == 3 and ", to your target (a woman)" or sex == 2 and ", to your target (a man)" or "")
        .. ":")
    local seen = {}
    for _ = 1, ns.TEST_VERSIONS * 12 do
        local v = Speak(accent, text, thick, sex)
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
    "/acc more - say the next piece of a line too long for one message (the box's Enter does too)",
    "/acc test <text> - show a few versions in your chat, sends nothing",
    "/acc accent [orc|troll|dwarf|undead|none|race] - this character's accent",
    "/acc thick [on|off] - lay it on thick (dwarf adds Gaelic, undead loses its jaw: only other jawless EzAccent users understand you)",
    "/acc share [on|off] - changing your accent here also sets it in your other addons that speak in one (on by default)",
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
    more = function()
        if not SendNext() then return Print("Nothing waits to be said.") end
        WaitingNote()
    end,
    box = function() ns.FocusBox() end,
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
    if event ~= "PLAYER_LOGIN" then return Remember((select(2, ...)), (select(12, ...))) end  -- author, guid
    EzAccentDB = EzAccentDB or {}
    if EzAccentDB.share == nil then EzAccentDB.share = true end
    EzAccentCharDB = EzAccentCharDB or {}
    if EzAccentCharDB.accent == nil then EzAccentCharDB.accent = RaceAccent() end
    if EzAccentCharDB.thick == nil then EzAccentCharDB.thick = false end
    if type(EzAccentCharDB.whispers) ~= "table" then EzAccentCharDB.whispers = {} end
    if type(EzAccentCharDB.sexes) ~= "table" then EzAccentCharDB.sexes = {} end
    ns.BuildSettings(RaceAccent())
end)
