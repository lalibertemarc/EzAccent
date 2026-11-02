-- Options page: Esc > Options > AddOns > EzAccent. Built at login, once the saved variables exist.
local _, ns = ...

function ns.BuildSettings(raceAccent)
    local category, layout = Settings.RegisterVerticalLayoutCategory("EzAccent")
    ns.settingsCategory = category

    local function Header(text)
        layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(text))
    end

    local function Button(name, text, onClick, tooltip)
        layout:AddInitializer(CreateSettingsButtonInitializer(name, text, onClick, tooltip, false))
    end

    Header("Your character")
    -- Per character, like /acc accent and /acc thick.
    local accent = Settings.RegisterAddOnSetting(category, "EZACCENT_ACCENT", "accent", EzAccentCharDB,
        Settings.VarType.String, "Accent", raceAccent)
    Settings.CreateDropdown(category, accent, function()
        local container = Settings.CreateControlTextContainer()
        for _, a in ipairs(ns.ACCENTS) do container:Add(a.key, a.label, a.desc) end
        return container:GetData()
    end, "The accent this character speaks in. Each character has their own; orcs, trolls, dwarves and Forsaken start in theirs.")
    local thick = Settings.RegisterAddOnSetting(category, "EZACCENT_THICK", "thick", EzAccentCharDB,
        Settings.VarType.Boolean, "Lay it on thick", false)
    Settings.CreateCheckbox(category, thick,
        "Orcs talk like grunts, trolls go full Darkspear, dwarves speak broad Scots with some Gaelic, and undead lose their jaw.")
    Button("Sample line", "Preview", function() ns.Test(ns.SAMPLE) end,
        "Prints a few versions of a sample line in this accent to your chat. Only you see them.")

    Header("The box")
    Button("Accent box", "Open", function() ns.OpenBox() end,
        "A small edit box of its own: Enter says the line, a leading /y, /p, /w name... picks the channel, Escape closes it. Drag it to move it.")
    Button("Box position", "Reset", function() ns.ResetBox() end, "Puts the box back above your action bars.")
    -- No inline binding rows or search tags: they taint the options search in Forever.
    Button("Key binding", "Key Bindings",
        function() Settings.OpenToCategory(Settings.KEYBINDINGS_CATEGORY_ID, "EzAccent") end,
        "Bind a key to open the box in the EzAccent section of the Key Bindings page.")

    Settings.RegisterAddOnCategory(category)
end
