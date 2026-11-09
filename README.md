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
| `/acc w <name> <text>` | Whisper it: `"First Surname"`, `%t`, or just the first name of your target, someone you whispered with lately or someone in your group (their surname is filled in) |
| `/acc more` | Say the next piece of a line too long for one message |
| `/acc test <text>` | Print a few versions in your own chat, send nothing |
| `/acc accent [orc\|troll\|dwarf\|tauren\|undead\|none\|race]` | This character's accent (starts as your race's: orcs, trolls, dwarves, tauren and Forsaken have one) |
| `/acc thick [on\|off]` | Thicker: more Orcish, heavier troll and Scots, Scottish Gaelic for dwarves, Taur-ahe and days told in suns for tauren; undead lose their jaw (see below) |
| `/acc share [on\|off]` | Changing your accent here also sets it in your other addons that speak in one: Buff Me Please, Curious Stranger, Bones, Fortune Teller, EzBlessings, EzMinion and Dead But Delicious (on by default) |
| `/acc box` | The edit box |
| `/acc config` | The options page (Options > AddOns > EzAccent): accent, thick, a sample line, the box and its key binding |

**The box.** Bind a key under Options > Keybindings > EzAccent (or `/acc box`). Type, press Enter to say it. The channel shows at the start of the line, as in chat (`Say:`, `Tell Jaina Proudmoore:`), and the box stays on it. To switch, start a line the way chat does: `/y`, `/p`, `/g`, `/o`, `/r`, `/e` or `/w name` and a space. `/w jaina ` fills in the surname of someone the box knows: your target, the people you whispered with (either way, the last 10 per character) and your group. A first name it doesn't know waits for its surname (`/w Bob Smith `), since Forever whispers need both; `/w "First Surname" ` works too. Tab whispers the next of those people, and clicking the channel lists every channel and person. Up/Down bring back earlier lines with their channel; Escape (or its ×) closes. Click anywhere else and it lets go of the keyboard so you can walk, but stays open: click it or press its key to type again. Drag it to move it.

**Lad or lass.** The accents call whoever you talk to "lad" (dwarf) or "bruddah" (thick troll, for friend or brother). Talking to a woman, she hears "lass" and "sistah" instead: in say, yell and emotes that's your target, in party and raid your target when it's in your group, and in whispers the person you whisper (when they're your target, in your group, or whispered with you before). Guild and officer chat, or no one known, keep "lad". Words you typed yourself are never changed, and a line that already says "lass" doesn't add one.

**Jawless to jawless.** A jawless undead's lines are slush to everyone around, except another jawless undead: EzAccent sends what you meant along with the line, hidden, and anyone with EzAccent set to undead thick reads it after your line, in grey: `Yusht shtay shtill. Ghk. (Just stay still.)`. Without EzAccent, or in any other accent, people only get the slush. It works in say, yell, emotes (the quotes), party, raid, guild, officer and whispers. Your own lines don't get it: you know what you said.

Each line comes out a little different: some words are swapped at random, and a tag (", mon"), an opener ("Och!") or a closer ("Lok'tar!") is added now and then. Chat links, raid marks like `{skull}` and `%t` are left alone. A line longer than the 255-character chat limit loses its extras first, then goes out in pieces. In say, yell, emotes and channels the game allows one message per key press, so only the first piece goes at once: the box opens with the rest waiting, Enter says each one (or `/acc more`), Escape drops them.

## Where the accents come from

The rules are those of AccentTranslator's `rules.py`: word and phrase swaps mined from Buff Me Please's accented lines. `Rules.lua` is generated from it:

```
python tools/gen_rules.py
python tools/gen_rules.py --accents undead --out ../EzMinion/AccentRules.lua
python tools/gen_rules.py --accents undead --out ../DeadButDelicious/AccentRules.lua
python tools/gen_rules.py --out ../EzBlessings/AccentRules.lua
python tools/gen_rules.py --out ../BuffMePlease/AccentRules.lua
python tools/gen_rules.py --out ../CuriousStranger/AccentRules.lua
python tools/gen_rules.py --out ../Bones/AccentRules.lua
python tools/gen_rules.py --out ../FortuneTeller/AccentRules.lua
```

The two `--accents undead` lines write only the undead tables for EzMinion and Dead But Delicious, which speak their lines in a locked jaw or jawless; the others write every accent. Rerun them all after editing `rules.py`.

The engine that applies them (`Accent.lua`) is a hand port of `rules.accented()`; keep the two in step when the logic changes. EzMinion's and Dead But Delicious's `Accent.lua` are trimmed copies of its undead path; EzBlessings', Buff Me Please's, Curious Stranger's, Bones' and Fortune Teller's are whole copies.

### Checking a change

```
python tools/accent_check.py --fix       # regenerate all of the above, copy Accent.lua, then check everything
lua tests/accents.lua print [accent]     # read a few versions of every line in tests/corpus.txt
```

`accent_check.py` checks that every generated file and copy is current, that the Lua port says every line of `tests/corpus.txt` exactly as `rules.py` does (dice fixed both ways), and runs `lua tests/accents.lua` (also in CI): the corpus said thousands of times in every accent, light and thick, plus regression `CASES`. When an accent says something wrong, add the line to the corpus or a case, so it stays fixed.

## Install

Copy the `EzAccent` folder into `Interface\AddOns`.
