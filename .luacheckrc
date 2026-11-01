std = "lua51"
max_line_length = false
self = false

globals = {
    "EzAccentDB",
    "EzAccentCharDB",
    "EzAccent_ToggleBox",
    "SLASH_EZACCENT1",
    "SLASH_EZACCENT2",
    "SlashCmdList",
    "BINDING_HEADER_EZACCENT",
    "BINDING_NAME_EZACCENT_BOX",
}

read_globals = {
    -- Frames & UI
    "CreateFrame", "UIParent", "DEFAULT_CHAT_FRAME", "ChatFontNormal",
    -- Namespaced APIs
    "C_ChatInfo", "issecretvalue",
    -- Global APIs
    "GetBuildInfo", "UnitRace", "UnitName", "UnitExists", "UnitIsPlayer", "SendChatMessage",
}
