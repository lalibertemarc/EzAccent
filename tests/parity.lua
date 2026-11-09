-- Driver for tools/accent_check.py's parity check (Lua 5.1): says every corpus line in every accent with the dice
-- fixed, so the Python engine (AccentTranslator's rules.py) can be asked the same and the two compared.
--   lua tests/parity.lua <roll> <accent>...   roll: what every random() returns (0 = every extra and swap happens,
--                                            0.999 = only the sure swaps); random(n) always picks the first.
-- Prints one line per corpus line, accent and strength: "<accent>\t<thick 0/1>\t<line>\t<said>".
local roll = assert(tonumber(arg[1]), "usage: lua tests/parity.lua <roll> <accent>...")
math.random = function(n) if n then return 1 end return roll end -- before Accent.lua keeps its own copy
local ns = {}
for _, file in ipairs({ "Rules.lua", "Accent.lua" }) do
    assert(loadfile(file))("EzAccent", ns)
end
for line in io.lines("tests/corpus.txt") do
    line = line:gsub("\r$", "")
    -- Links and %t are protected by Accent.lua only (rules.py never sees them), so they're left to tests/accents.lua.
    if line ~= "" and not line:find("^#") and not line:find("[|%%]") then
        for i = 2, #arg do
            for thick = 0, 1 do
                print(arg[i] .. "\t" .. thick .. "\t" .. line .. "\t" .. ns.Speak(arg[i], line, thick == 1))
            end
        end
    end
end
