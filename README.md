# EzAccent

Type a line and your character says it in their accent. A WoW Forever and Classic Era addon for roleplayers.

> /acc Thank you, that's a fine blessing. I'll buy you a drink later.
>
> **Troll:** Tank ya, dat be a fine blessin'. I buy ya a drink later, mon.
> **Dwarf:** Thank ye, that's a fine blessin'. I'll buy ye a pint later.
> **Orc:** Aka'Magosh, that is fine blessing. I buy you drink later.
> **Undead:** Thenk yuu, thet's e fine blessing. I'll buy yuu e drink leter. Nngh.

## Commands

| Command | Does |
|---|---|
| `/acc <text>` | Say it in your accent (`/ezaccent` works too) |
| `/acc y\|p\|g\|o\|r\|e <text>` | Yell, party, guild, officer, raid or emote it (in an emote with "quoted speech", only the quotes get the accent); `/acc s <text>` says a line that starts with a command word |
| `/acc w <name> <text>` | Whisper it: your target's first name (their surname is filled in), `"First Surname"`, or `%t` |
| `/acc test <text>` | Print a few versions in your own chat, send nothing |
| `/acc accent [orc\|troll\|dwarf\|undead\|none\|race]` | This character's accent (starts as your race's: orcs, trolls, dwarves and Forsaken have one) |
| `/acc thick [on\|off]` | Thicker: more Orcish, heavier troll and Scots, Scottish Gaelic for dwarves; undead lose their jaw |
| `/acc box` | The edit box |

**The box.** Bind a key under Options > Keybindings > EzAccent (or `/acc box`). Type, press Enter to say it; start with `/y`, `/p`, `/g`, `/r`, `/e` or `/w name` for another channel; Up/Down bring back earlier lines; Escape closes. Drag it to move it.

Each line comes out a little different: some words are swapped at random, and a tag (", mon"), an opener ("Och!") or a closer ("Lok'tar!") is added now and then. Chat links, raid marks like `{skull}` and `%t` are left alone. A line longer than the 255-character chat limit loses its extras first, then goes out in pieces.

## Where the accents come from

The rules are those of AccentTranslator's `rules.py`: word and phrase swaps mined from Buff Me Please's accented lines. `Rules.lua` is generated from it:

```
python tools/gen_rules.py
```

The engine that applies them (`Accent.lua`) is a hand port of `rules.accented()`; keep the two in step when the logic changes.

## Install

Copy the `EzAccent` folder into `Interface\AddOns`.
