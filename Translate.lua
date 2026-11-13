-- Jawless to jawless: a jawless undead's line is slush to everyone around, but EzAccent sends what they meant with it
-- as an addon message, and someone else who is jawless in EzAccent reads it after the line, in grey. Anyone else
-- (no EzAccent, or not jawless) only gets the slush.
local _, ns = ...

local PREFIX = ns.MEANING_PREFIX
local COLOR = ns.MEANING_COLOR
local MAX = 255  -- addon message limit, in bytes

local function issecret(v)
    return issecretvalue and issecretvalue(v)
end

local function IsMe(name)
    local me = UnitName("player")
    return me and not issecret(me) and ns.NameKey(name) == me:lower()
end

---------------------------------------------------------------------------
-- Sending: from Say, before the line itself, so the meaning is usually there first.
---------------------------------------------------------------------------
-- Links become their [text] and other | escapes go (SAY drops some characters); %t is filled in here, since only
-- chat lines get it from the game.
local function Plain(text)
    text = text:gsub("|H.-|h(.-)|h", "%1"):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    text = text:gsub("|T.-|t", ""):gsub("|A.-|a", ""):gsub("|K.-|k", "")
    if text:find("%%t") then
        local target = UnitName("target")
        if not target or issecret(target) then target = "<no target>" end
        text = text:gsub("%%t", function() return target end)
    end
    text = ns.Trim(text)
    if #text > MAX then text = text:sub(1, MAX):match("^(.*)%s") or text:sub(1, MAX) end
    return text
end

-- SendAddonMessage returns an Enum.SendAddonMessageResult (0 = sent) in Forever, a boolean or nothing in older clients.
local function Sent(result)
    return result == nil or result == true or result == 0
end

local function SendTo(text, channel, target)
    return Sent(C_ChatInfo.SendAddonMessage(PREFIX, text, channel, target))
end

-- Your group's addon channel, if you have one.
local function GroupChannel()
    if LE_PARTY_CATEGORY_INSTANCE and IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then return "INSTANCE_CHAT" end
    if IsInRaid() then return "RAID" end
    if IsInGroup() then return "PARTY" end
end

-- Addon messages have no SAY or YELL in Forever (retail API: Classic only), and Era may refuse them too, so a
-- /say, /yell or /e meaning goes to whoever is likely listening: your group, and your target when it's a friendly
-- player outside it (an addon whisper, never seen in chat).
local function SendNearby(text)
    local group = GroupChannel()
    if group then SendTo(text, group) end
    local name = ns.UnitFullName("target")
    if not name or UnitIsUnit("target", "player") then return end
    local coop = UnitCanCooperate("player", "target")
    if issecret(coop) or not coop then return end
    if group then
        local inParty, inRaid = UnitInParty("target"), UnitInRaid("target")
        if (not issecret(inParty) and inParty) or (not issecret(inRaid) and inRaid) then return end
    end
    SendTo(text, "WHISPER", name)
end

function ns.SendMeaning(text, chatType, target)
    local channel = ns.MEANING_CHANNELS[chatType]
    if not channel or not ns.Jawless() then return end
    if chatType == "EMOTE" and text:find('"[^"]+"') then
        local quotes = {}
        for q in text:gmatch('"([^"]+)"') do quotes[#quotes + 1] = q end
        text = table.concat(quotes, " ")
    end
    text = Plain(text)
    if text == "" then return end
    if channel == "SAY" or channel == "YELL" then
        if ns.ERA and SendTo(text, channel) then return end
        return SendNearby(text)
    end
    SendTo(text, channel, channel == "WHISPER" and target or nil)
end

---------------------------------------------------------------------------
-- Hearing: a meaning waits for the sender's next line (by first name, as chat and addon messages may spell the
-- sender differently) and is added to it; if the line doesn't come in time, it shows on a line of its own.
---------------------------------------------------------------------------
local waiting = {}         -- first name -> { from, text }
local heard, heardN = {}, 0  -- author .. line -> meaning, so every chat frame showing the line adds it

local function ShowAlone(meaning)
    local from = ns.ERA and meaning.from:match("^[^%-]+") or meaning.from:gsub("%-", " ")
    DEFAULT_CHAT_FRAME:AddMessage(COLOR .. from .. ": (" .. meaning.text .. ")|r")
end

local function Heard(prefix, text, _, sender)
    if prefix ~= PREFIX or type(text) ~= "string" or type(sender) ~= "string" or issecret(text) or issecret(sender)
            or not ns.Jawless() or IsMe(sender) then
        return
    end
    local key = ns.NameKey(sender)
    if waiting[key] and waiting[key].text == text then return end  -- the same meaning by another way
    local meaning = { from = sender, text = text }
    waiting[key] = meaning
    C_Timer.After(ns.MEANING_WAIT, function()
        if waiting[key] ~= meaning then return end
        waiting[key] = nil
        ShowAlone(meaning)
    end)
end

local function Filter(_, _, msg, author, ...)
    if type(msg) ~= "string" or type(author) ~= "string" or issecret(msg) or issecret(author) then return false end
    local line = author .. "\n" .. msg
    local text = heard[line]
    if not text then
        local key = ns.NameKey(author)
        local meaning = waiting[key]
        if not meaning then return false end
        waiting[key] = nil
        text = meaning.text
        if heardN >= 20 then heard, heardN = {}, 0 end
        heard[line], heardN = text, heardN + 1
    end
    return false, msg .. " " .. COLOR .. "(" .. text .. ")|r", author, ...
end

C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)

local AddFilter = (ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter) or ChatFrame_AddMessageEventFilter
for _, event in ipairs(ns.MEANING_EVENTS) do
    AddFilter(event, Filter)
end

local ev = CreateFrame("Frame")
ev:RegisterEvent("CHAT_MSG_ADDON")
ev:SetScript("OnEvent", function(_, _, ...) Heard(...) end)
