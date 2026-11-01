-- EzAccent: type a line and your character says it in their accent (/acc, or the key binding's edit box).
local _, ns = ...

BINDING_HEADER_EZACCENT = "EzAccent"
BINDING_NAME_EZACCENT_BOX = "Open the accent box"

local MAX = 255  -- chat message limit, in bytes

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffc79c6eEzAccent|r: " .. msg)
end

local function Trim(s)
    return (s or ""):match("^%s*(.-)%s*$")
end

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

local function AccentKeys()
    local keys = {}
    for _, a in ipairs(ns.ACCENTS) do keys[#keys + 1] = a.key end
    keys[#keys + 1] = "race"
    return table.concat(keys, ", ")
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
end

---------------------------------------------------------------------------
-- Saying it
---------------------------------------------------------------------------
-- A whisper's name and the text after it. Forever names have surnames and whispers need "First Surname": when
-- the name is your target's first name, the full name comes from the target (and a typed surname is skipped).
-- "First Surname" in quotes works too, and so does %t for your target.
local function TargetFullName()
    if not (UnitExists("target") and UnitIsPlayer("target")) then return end
    local first, surname = UnitName("target")
    if not first or issecret(first) then return end
    if surname and not issecret(surname) and surname ~= "" then
        return first .. (ns.ERA and "-" or " ") .. surname, first, surname
    end
    return first, first
end

local function WhisperTarget(rest)
    local quoted, text = rest:match('^"([^"]+)"%s+(.+)$')
    if quoted then return quoted, text end
    local name
    name, text = rest:match("^(%S+)%s+(.+)$")
    if not name then return end
    local full, first, surname = TargetFullName()
    if name == "%t" then return full, text end
    if full and first:lower() == name:lower() then
        local typed, after = text:match("^(%S+)%s+(.+)$")
        if surname and typed and typed:lower() == surname:lower() then text = after end
        return full, text
    end
    return name, text
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
    for _, msg in ipairs(ns.Split(said, MAX)) do
        Send(msg, chatType, target)
    end
end

-- rest of a /acc <letter> or box /<channel> line
local function SayTo(chatType, rest)
    if chatType == "WHISPER" then
        local target, text = WhisperTarget(Trim(rest))
        if not target then return Print("Whisper whom? /acc w <name> <text> (or %t for your target)") end
        return Say(text, chatType, target)
    end
    Say(rest, chatType)
end

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

---------------------------------------------------------------------------
-- The box: a small edit box of its own. Enter says the line (in /say, or the channel of a leading /y, /p, /w name
-- ...), Escape closes it, Up/Down go through this session's lines.
---------------------------------------------------------------------------
local box
local history, historyAt = {}, 0

local function SaveBoxPoint(f)
    local point, _, relPoint, x, y = f:GetPoint()
    EzAccentDB.box = { point, relPoint, x, y }
end

local function BoxLine(text)
    text = Trim(text)
    local cmd, rest = text:match("^/(%S+)%s*(.*)$")
    local chatType = cmd and ns.BOX_CHANNELS[cmd:lower()]
    if chatType then return SayTo(chatType, rest) end
    Say(text, "SAY")
end

local function MakeBox()
    local f = CreateFrame("Frame", "EzAccentBox", UIParent, "BackdropTemplate")
    f:SetSize(440, 56)
    local p = EzAccentDB.box
    if p then
        f:SetPoint(p[1], UIParent, p[2], p[3], p[4])
    else
        f:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 240)
    end
    f:SetFrameStrata("DIALOG")
    f:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 14,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    f:SetBackdropColor(0, 0, 0, 0.85)
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SaveBoxPoint(self)
    end)
    f:Hide()

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    title:SetPoint("TOPLEFT", 10, -8)
    local hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("TOPRIGHT", -10, -8)
    hint:SetText("Enter: say  /y /p /g /r /e /w name  Esc: close")

    local e = CreateFrame("EditBox", nil, f)
    e:SetFontObject(ChatFontNormal)
    e:SetPoint("TOPLEFT", 10, -22)
    e:SetPoint("BOTTOMRIGHT", -10, 6)
    e:SetAutoFocus(false)
    e:SetMaxLetters(MAX)
    e:SetScript("OnEnterPressed", function(self)
        local text = self:GetText()
        self:SetText("")
        f:Hide()
        if Trim(text) ~= "" then
            if history[#history] ~= text then history[#history + 1] = text end
            if #history > 20 then table.remove(history, 1) end
            BoxLine(text)
        end
    end)
    e:SetScript("OnEscapePressed", function() f:Hide() end)
    e:SetScript("OnArrowPressed", function(self, key)
        if #history == 0 or (key ~= "UP" and key ~= "DOWN") then return end
        historyAt = math.max(1, math.min(#history + 1, historyAt + (key == "UP" and -1 or 1)))
        self:SetText(history[historyAt] or "")
        self:SetCursorPosition(#self:GetText())
    end)

    f:SetScript("OnShow", function()
        title:SetText("EzAccent: " .. AccentLabel())
        historyAt = #history + 1
        e:SetFocus()
    end)
    f:SetScript("OnHide", function() e:ClearFocus() end)
    return f
end

local function OpenBox()
    box = box or MakeBox()
    box:Show()
end

-- Bindings.xml (runOnUp): opens on key release, so the key's own letter never lands in the box.
function EzAccent_ToggleBox(keystate)
    if keystate ~= "up" then return end
    if box and box:IsShown() then
        box:Hide()
    else
        OpenBox()
    end
end

---------------------------------------------------------------------------
-- Slash command
---------------------------------------------------------------------------
local HELP = {
    "/acc <text> - say <text> in your accent",
    "/acc y|p|g|o|r|e <text> - yell, party, guild, officer, raid or emote it (/acc s <text> to say a line that starts with a command word)",
    "/acc w <name> <text> - whisper it (your target's first name, \"First Surname\", or %t)",
    "/acc test <text> - show a few versions in your chat, sends nothing",
    "/acc accent [orc|troll|dwarf|undead|none|race] - this character's accent",
    "/acc thick [on|off] - lay it on thick (dwarf adds Gaelic, undead loses its jaw)",
    "/acc box - the edit box (also a key binding: Options > Keybindings > EzAccent)",
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
    test = Test,
    box = OpenBox,
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
ev:SetScript("OnEvent", function()
    EzAccentDB = EzAccentDB or {}
    EzAccentCharDB = EzAccentCharDB or {}
    if EzAccentCharDB.accent == nil then EzAccentCharDB.accent = RaceAccent() end
    if EzAccentCharDB.thick == nil then EzAccentCharDB.thick = false end
end)
