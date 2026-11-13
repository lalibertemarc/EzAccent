# EzAccent

## Unreleased

- With EzCaret installed, the box tidies your line as you send it: common typos fixed, a capital at the start of sentences and a period at the end, before the accent is put on.
- **Undead (locked jaw)** ends its lines more ways: more strained sounds ("Tss.", "Hmmf.", "Grrk.", "Nngh-nngh."...), sometimes tucked in before the last mark ("Ere yuu reedy, mmf?", "I em tired... nngh."), and sometimes none at all, so long chats don't all end the same.
- **Fixed:** the undead hiss no longer lands on a word that already has "ss" ("blesssing").

## v1.1.0-beta.3

- **Thick dwarves** have more ways to open and close a line ("Hoots!", "Weel now.", "Dinnae fash.", "For Ironforge!", "Dour times.") and use each one less often, so long chats repeat less.
- **Fixed:** thick dwarves no longer tack a remark onto a question ("Would ye like some pie? So it is."), nor add Gaelic to a line that already greets, thanks or says goodbye in Gaelic.

## v1.1.0-beta.2

- **Fixed: going somewhere isn't "gonna".** "Are you going to the inn?" no longer comes out as "are ya gonna da inn" (troll) or "are ye gonnae the inn" (dwarf), and orcs no longer say "He will the market". Before a place ("the inn", "Orgrimmar") it's "goin' to"; before a verb it's still "gonna kill it".
- **Fixed:** thick dwarves only say "Tapadh leat" for a thanks of its own ("Thanks, Bob!"), not in "My family thanks you for your help".
- **Fixed:** tauren ask "Lovely day, is it not?" instead of "is not it?" (also for "ain't it?").
- **Thick tauren** now use a little rez slang, suggested by one of our testers: "skoden" (let's go then), "stoodis" (let's do this), "enit?" (isn't it?) and "aho" for agreement and thanks: "Aho, skoden, An'she is going down."
- **Fixed:** shouting stays shouting in undead: "FOR THE HORDE!" is "HHOR HHE HORDE!" (jawless), not "HhOR HhE".
- Trolls: "I'm told..." is "Dey tell me...", and "I'm not gonna lie" is "I ain't gonna lie" (thick: "Me not gonna lie").
- Orcs no longer end "Good day. Yes?" with a second "Yes?".
- Orcs and dwarves answer "ain't it?" as they do "isn't it?" ("Cold out tonight, yes?", "isnae it?"), orcs keep "a bit" ("this will not hurt a bit") and buy "some grog" instead of "a drink".
- Thick dwarves no longer say "a charaid" twice in one line ("Listen, mo charaid, ... a charaid").

## v1.1.0-beta.1

- **New: a tauren accent.** Calm and unhurried, never broken English: tauren speak in full ("I will", "do not"), count years in winters and months in moons, ride kodos home to Mulgore, and bid farewell with "Walk with the Earth Mother." Now and then a line ends in a blessing that fits it ("The Earth Mother smiles on you." for a thanks, "May the ancestors guide your hand." for a fight). New tauren characters start in it; anyone can pick it with `/acc accent tauren`.
- **Thick tauren** speak some Taur-ahe ("Nechi owachi" for thanks, "Theia-shoush ahmen" for so be it, "Ish-ne-alo por-ah" for farewell), call the sun An'she and the moon Mu'sha, tell days in suns, and pause to think now and then: "I do not know... I believe we should wait until the next sun."
- **Beta:** Buff Me Please and EzBlessings don't speak tauren yet. With accent sharing on, picking tauren here sets them to plain until they do.

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
