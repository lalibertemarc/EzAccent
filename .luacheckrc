std = "lua51"
max_line_length = false
self = false
exclude_files = { "tests/" }

globals = {
    "EzAccentDB",
    "EzAccentCharDB",
    "EzAccent_ToggleBox",
    "EzAccentAPI",
    "SLASH_EZACCENT1",
    "SLASH_EZACCENT2",
    "SlashCmdList",
    "BINDING_HEADER_EZACCENT",
    "BINDING_NAME_EZACCENT_BOX",
}

read_globals = {
    -- Frames & UI
    "CreateFrame", "UIParent", "DEFAULT_CHAT_FRAME", "ChatFontNormal",
    -- Settings panel
    "Settings", "CreateSettingsListSectionHeaderInitializer", "CreateSettingsButtonInitializer",
    -- Chat filters (ChatFrameUtil on newer clients)
    "ChatFrameUtil", "ChatFrame_AddMessageEventFilter",
    -- Namespaced APIs
    "C_ChatInfo", "C_Timer", "issecretvalue",
    -- Global APIs
    "GetBuildInfo", "UnitRace", "UnitName", "UnitExists", "UnitIsPlayer", "SendChatMessage", "InCombatLockdown",
    "IsInGroup", "IsInRaid", "IsInGuild", "GetNumGroupMembers", "ChatTypeInfo",
    "UnitSex", "UnitIsUnit", "UnitInParty", "UnitInRaid", "GetPlayerInfoByGUID",
}
