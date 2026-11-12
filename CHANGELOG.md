# EzAccent

## v1.0.5

- **Fixed:** thick dwarves no longer tack a remark onto a question ("Would ye like some pie? So it is."), say "Tapadh leat!" twice, or add Gaelic to a line that already greets, thanks or says goodbye in Gaelic. Dropped a few openers and closers that clashed with most lines ("Wheesht!", "Haud on!", "Nae bother.", "Mark ma words.").

## v1.0.4

- **Changed:** thick dwarf no longer opens and closes so many lines the same way: fewer "lad" tags, openers and closers, and a wider choice of them.

## v1.0.3

- **Fixed:** a key that opens the box, its keybind or an action bar macro running `/acc box`, no longer types its letter into it.

## v1.0.2

- **Fixed:** the box's keybind no longer types its own letter into the box when it opens it.

## v1.0.1

- **Orcs still offer.** "Would you like some pie?" no longer turns into an order ("Like some roast boar."): it's "You want some roast boar?" now, and "would you care for", "prefer" and "rather" stay questions too. Real requests still get the orc treatment ("Would you cast Fortitude on me?" → "Cast Fortitude on me.").

## v1.0.0

First release. Type a line, and your character says it in their accent.

- **Four accents.** `/acc <text>` says your line as an orc, a troll, a dwarf or an undead with a locked jaw ("Thenk yuu, thet's e fine blessing. Nngh."). Orcs, trolls, dwarves and Forsaken start in their own; anyone can pick one with `/acc accent`. Every line comes out a little different: some words swap at random, and an opener, a tag or a closer that fits the line ("Lok'tar ogar!" for a fight, "Aka'Magosh" for a thanks, "Dabu?" for a question) is added now and then.
- **Lay it on thick.** `/acc thick on`: orcs talk like grunts ("You ready? Me hungry."), trolls go full Darkspear ("Ya wanna come wit' us ta da dungeon?"), dwarves speak broad Scots with some Gaelic ("D'ye want tae come? Mìle taing."), and undead lose their jaw altogether: lip sounds gone, th and s gone slushy, and a wet sound slipping out mid-line ("Hhleashe, shlrk, ghe quiet.").
- **Jawless to jawless.** Two jawless undead understand each other: another EzAccent user who is undead thick reads what you meant after your slush, in grey ("Yusht shtay shtill. Ghk. (Just stay still.)"). Everyone else only hears the slush.
- **Any channel.** `/acc y`, `p`, `g`, `o`, `r` and `e` yell, party, guild, officer, raid or emote the line (an emote with "quoted speech" only accents the quotes); `/acc w <name> <text>` whispers it, and a first name is enough for your target, someone you whispered with or someone in your group.
- **A box of your own.** A key binding (Options > Keybindings > EzAccent) or `/acc box` opens a small chat-style box. Enter says the line, Escape closes it. The channel shows at the start of the line (`Say:`, `Tell Jaina Proudmoore:`) and stays there: start a line with `/y `, `/p `, `/e `... or `/w bob ` to switch. Tab whispers the next person it knows, a click on the channel lists every channel and person, and Up brings back earlier lines.
- **Lad or lass.** A woman you talk to is a "lass", and a thick troll calls her "sistah", not "bruddah": your target in say, yell and emotes, or whoever you whisper. Words you typed yourself are never changed.
- **One accent for all your addons.** Changing your accent here also sets it in Buff Me Please, Curious Stranger, Bones, Fortune Teller, EzBlessings, EzMinion and Dead But Delicious when they're loaded, to the nearest one each has. Their own accent settings still change theirs alone, and `/acc share off` keeps them apart.
- **Whisper from EzAcquaintances.** Its book's Whisper button can open this box on a whisper to that person (right-click the button and pick "In your accent").
- **Try before you speak.** `/acc test <text>` prints a few versions in your own chat and sends nothing. The options page (Esc > Options > AddOns > EzAccent, or `/acc config`) has the accent, thick, a preview and the box.
- **Long lines.** Chat links, raid marks like `{skull}` and `%t` come through untouched. A line past the 255-character limit loses its extras first, then goes in pieces: in say, yell and emotes the game allows one message per key press, so the box waits with the rest and Enter says each (or `/acc more`).
- **WoW Forever and Classic Era**, from one download.
