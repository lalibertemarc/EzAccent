-- Smoke test for the accents, outside the game (Lua 5.1, also in CI). Run inside EzAccent:
--   lua tests/accents.lua                  every accent in ns.ACCENTS has its tables; every line of tests/corpus.txt,
--                                          said many times in every accent, light and thick, comes out clean; and
--                                          every CASES entry below holds every time
--   lua tests/accents.lua print [accent]   also prints a few versions of every corpus line, to read through
-- When an accent says something wrong, add the line to tests/corpus.txt or a case to CASES, so it stays fixed.
local ns = {}
GetBuildInfo = function() return "1.60.1", "0", "", 16001 end
for _, file in ipairs({ "Data.lua", "Rules.lua", "Accent.lua" }) do
    assert(loadfile(file))("EzAccent", ns)
end
local show, only = arg[1] == "print", arg[2]
math.randomseed(1)

local TRIES = 40     -- versions of each line per accent and thickness
local CASE_TRIES = 60
local MAX = 255

-- Each failure once (the same line can fail the same way in many tries).
local failures, seen = 0, {}
local function Fail(msg, key)
    key = key or msg
    if seen[key] then return end
    seen[key] = true
    failures = failures + 1
    if failures <= 60 then print("FAIL: " .. msg) end
end

-- Words the accents double on purpose ("Heh heh.", "Zug zug.", "Hkk-hkk."): found in Rules.lua's own strings.
local DOUBLED = {}
local function FindDoubles(t)
    for _, v in pairs(t) do
        if type(v) == "table" then
            FindDoubles(v)
        elseif type(v) == "string" then
            for w in v:lower():gmatch("(%a+)[%s%-]+%1%f[^%a]") do DOUBLED[w] = true end
        end
    end
end

---------------------------------------------------------------------------
-- Things that must hold for one line, every time. has = text it always says, never = text it never says, ends =
-- what the line always ends with. thick = true/false for one strength only, nil for both.
---------------------------------------------------------------------------
local CASES = {
    -- tauren
    { "tauren", nil, "My horse died, so I'm walking back home.", has = { "walking back to Mulgore" },
      never = { "back in Mulgore" } },
    { "tauren", nil, "I'm back home now.", has = { "back in Mulgore" } },
    { "tauren", nil, "Hello, {name}! It's been years.", never = { "friend, {name}" } },
    { "tauren", true, "Goodbye, friend.", never = { "little one" } },
    { "tauren", nil, "Wait, are you going to the inn tonight?", ends = "?", never = { "Patience" } },
    { "tauren", true, "Thanks, see you tomorrow!", has = { "until the next sun" } },
    { "tauren", nil, "I'm sure it's fine, don't you think?", never = { "'m ", "'s ", "n't" } },
    -- orc
    { "orc", nil, "Cold out tonight, ain't it?", has = { "es?" }, never = { "ain't" } },
    { "orc", false, "Hold still, this won't hurt a bit.", has = { "hurt a bit" } },
    { "orc", false, "I'll buy you a drink later.", has = { "some grog" } },
    { "orc", nil, "Would you like some pie?", ends = "?", never = { "Like some" } },
    { "orc", nil, "Would you cast {buff} on me, please?", never = { "?", "Would you" } },
    { "orc", true, "You should have told me sooner.", has = { "should have" }, never = { "must have" } },
    { "orc", true, "Yes, I'll be there in an hour.", has = { "an hour" } },
    -- A thanks inside a sentence stays a verb; a closing "Aka'Magosh." after it is fine.
    { "orc", nil, "My family thanks you for your help.", has = { "thanks you" }, never = { "Aka'Magosh you" } },
    { "orc", false, "He is going to the market, I'm going to Orgrimmar.", has = { "goes to", "go to Orgrimmar" },
      never = { "will the", "will market", "I Orgrimmar" } },
    -- "going to" + a place is going there, not "gonna"; before a verb it still is.
    { "troll", nil, "Wait, are you going to the inn tonight?", has = { "goin' t" }, never = { "gonna" } },
    { "troll", nil, "I'm going to Orgrimmar, he's going to kill it.", has = { "goin' t", "gonna kill" } },
    { "dwarf", nil, "Wait, are you going to the inn tonight?", has = { " tae the inn" }, never = { "gonnae" } },
    { "dwarf", nil, "It's going to rain.", has = { "gonnae rain" } },
    { "dwarf", nil, "Cold out tonight, ain't it?", has = { "isnae it" } },
    { "dwarf", true, "Listen, my friend, there's something you should know.", never = { "a charaid" } },
    { "dwarf", true, "My family thanks you for your help.", has = { "thanks ye" },
      never = { "tapadh", "Tapadh", "taing", "Taing" } },
    { "dwarf", true, "Thanks, {name}!", never = { "{name}! Tapadh", "lad! Tapadh", "charaid! Tapadh" } },
    { "dwarf", true, "Would you like some pie?", ends = "?" },
    { "dwarf", true, "Is anyone selling a horse in town?", ends = "?" },
    { "dwarf", true, "Hello, want to group up for this quest?", never = { "Seadh", "So it is", "fash" } },
    { "dwarf", true, "Thanks, {name}!", never = { "Thanks" } },
    { "tauren", false, "Lovely day, isn't it?", has = { "is it not" }, never = { "is not it" } },
    { "tauren", true, "Lovely day, isn't it?", ends = "?", never = { "is not it", "isn't" } },
    { "tauren", true, "Isn't it lovely here?", never = { "enit", "Enit" } },
    { "tauren", true, "Let's go to the inn.", has = { "et us go to the inn" }, never = { "koden" } },
    { "tauren", false, "Let's go!", never = { "koden" } },
    { "tauren", false, "Let's do this!", never = { "toodis" } },
    { "tauren", true, "Okay, thanks!", never = { "Aho. Aho", "Aho Aho" } },
    { "tauren", true, "Come on, let's go then!", never = { "us go!" } },
    { "tauren", nil, "Cold out tonight, ain't it?", never = { "is not it", "ain't" } },
    { "troll", nil, "I'm told the king is coming.", has = { "ey tell me" }, never = { "e told" } },
    { "troll", true, "I'm not going to lie.", has = { "e not gonna lie" }, never = { "be not" } },
    { "orc", true, "Lovely day, isn't it?", never = { "Yes? Yes?" } },
    -- A shouted word stays shouted.
    { "undead", true, "FOR THE HORDE!", has = { "HHOR HHE HORDE" } },
    { "undead", false, "FOR THE HORDE!", has = { "FUR " }, never = { "F-f", "T-t", "H-h" } },
    -- A tucked strain keeps the line's own mark after it: "Ere yuu reedy, mmf?", never "reedy?, mmf" or "?..".
    { "undead", false, "Are you ready?", has = { "reedy" }, never = { "?,", "?.", ",?", ".?" } },
    { "undead", false, "I am tired.", never = { "..,", "....", ". ..." } },
}

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------
local function Count(s, sub)
    local n, at = 0, 1
    while true do
        local s1, e1 = s:find(sub, at, true)
        if not s1 then return n end
        n, at = n + 1, e1 + 1
    end
end

-- What Accent.lua protects and must give back untouched: links, {tokens}, %t.
local function Tokens(line)
    local out = {}
    for t in line:gmatch("|c%x+|H.-|h.-|h|r") do out[#out + 1] = t end
    for t in line:gmatch("{%w+}") do out[#out + 1] = t end
    for t in line:gmatch("%%%a") do out[#out + 1] = t end
    return out
end

local function Corpus()
    local lines = {}
    for line in io.lines("tests/corpus.txt") do
        line = line:gsub("\r$", "")
        if line ~= "" and not line:find("^#") then lines[#lines + 1] = line end
    end
    return lines
end

-- What's wrong with out (line said in accent), or nil.
local function Problem(accent, line, out)
    if out == "" then return "empty" end
    if #out > MAX then return "past " .. MAX .. " bytes" end
    for _, t in ipairs(Tokens(line)) do
        if Count(out, t) ~= Count(line, t) then return "lost or doubled " .. t end
    end
    local bare = out:gsub("|c%x+|H.-|h.-|h|r", "LINK")
    if bare:find("{%d+}") then return "a {N} sentinel was left in" end
    if bare:find("%s%s") then return "two spaces" end
    if bare:find("%s[,.!?;:]") then return "a space before punctuation" end
    if bare:find("^[%s,.;:!?]") or bare:find("%s$") then return "starts with punctuation or ends in a space" end
    if bare:find("[,;:]%s*[.!?]") or bare:find(",%s*,") then return "punctuation piled up" end
    local low = bare:lower()
    for word in low:gmatch("%f[%a][%a']+%f[^%a']") do
        if #word > 2 and not DOUBLED[word] and low:find("%f[%a]" .. word .. "[%s,]+" .. word .. "%f[^%a']") and
                not line:lower():find(word .. "[%s,]+" .. word) then
            return "\"" .. word .. "\" twice in a row"
        end
    end
    for _, tag in ipairs(ns.TAGS[accent] or {}) do
        if Count(out, tag) > 1 then return "tag \"" .. tag .. "\" twice" end
    end
    if accent ~= "undead" and not bare:find("[.!?]['\"]?$") and not bare:find("}$") then
        return "no closing mark"
    end
end

FindDoubles({ ns.WORDS, ns.TAGS, ns.OPENERS, ns.THICK_OPENERS, ns.ORC_CLOSERS, ns.TROLL_CLOSERS, ns.DWARF_CLOSERS,
              ns.TAUREN_CLOSERS, ns.STRAINS, ns.GURGLES })

---------------------------------------------------------------------------
-- Tables: every accent the player can pick has what Accent.lua reads.
---------------------------------------------------------------------------
local accents = {}
for _, a in ipairs(ns.ACCENTS) do
    if a.key ~= "none" then
        accents[#accents + 1] = a.key
        if a.key ~= "undead" then
            for _, t in ipairs({ a.key, a.key .. "_thick" }) do
                if not ns.WORDS[t] then Fail(a.key .. ": no ns.WORDS." .. t) end
            end
            for _, name in ipairs({ "TAGS", "TAG_CHANCE", "TAG_CHANCE_THICK", "OPENERS", "THICK_OPENERS" }) do
                if ns[name][a.key] == nil then Fail(a.key .. ": no ns." .. name .. "." .. a.key) end
            end
        end
        if not ns.THICK_LABEL[a.key] then Fail(a.key .. ": no ns.THICK_LABEL") end
    end
end
for race, key in pairs(ns.RACE_ACCENT) do
    local known = false
    for _, a in ipairs(accents) do known = known or a == key end
    if not known then Fail("ns.RACE_ACCENT." .. race .. " = " .. key .. ": not an accent") end
end

---------------------------------------------------------------------------
-- The corpus, every accent, light and thick
---------------------------------------------------------------------------
local corpus, said = Corpus(), 0
for _, line in ipairs(corpus) do
    if show then print(line) end
    for _, accent in ipairs(accents) do
        for _, thick in ipairs({ false, true }) do
            local shown = {}
            for _ = 1, TRIES do
                local out = ns.Speak(accent, line, thick, MAX)
                said = said + 1
                local why = Problem(accent, line, out)
                if why then
                    Fail(accent .. (thick and " thick" or "") .. ": " .. why .. "\n      " .. line .. "\n   -> " .. out,
                        accent .. tostring(thick) .. line .. why)
                end
                if show and (not only or only == accent) and #shown < 2 and not shown[out] then
                    shown[out] = true
                    shown[#shown + 1] = out
                end
            end
            for _, out in ipairs(shown) do
                print(("  %-14s %s"):format(accent .. (thick and " thick" or ""), out))
            end
        end
    end
end

---------------------------------------------------------------------------
-- Cases
---------------------------------------------------------------------------
for _, c in ipairs(CASES) do
    local accent, which, line = c[1], c[2], c[3]
    for _, thick in ipairs({ false, true }) do
        if which == nil or which == thick then
            local name = accent .. (thick and " thick" or "") .. ": " .. line
            for _ = 1, CASE_TRIES do
                local out = ns.Speak(accent, line, thick, MAX)
                local why = Problem(accent, line, out)
                for _, s in ipairs(c.has or {}) do
                    if not out:find(s, 1, true) then why = why or ("doesn't say \"" .. s .. "\"") end
                end
                for _, s in ipairs(c.never or {}) do
                    if out:find(s, 1, true) then why = why or ("says \"" .. s .. "\"") end
                end
                if c.ends and out:sub(-#c.ends) ~= c.ends then why = why or ("doesn't end in " .. c.ends) end
                if why then
                    Fail(name .. "\n   -> " .. out .. "\n   (" .. why .. ")")
                    break
                end
            end
        end
    end
end

print(("%d accents, %d corpus lines, %d sayings, %d cases, %d failures"):format(#accents, #corpus, said, #CASES,
    failures))
if failures > 0 then os.exit(1) end
