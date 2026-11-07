# EzAccent

*Your orc shouldn't sound like a bank clerk.*

You rolled a troll. You picked the hair, the tusks, the slouch. And then you open your mouth in /say and out comes "Hello, would you like to group for this quest?" Writing every line in an accent by hand is slow, and by the time you've typed "da" for the fifth time the moment has passed.

**EzAccent** does it for you. Type your line the normal way, press Enter, and your character says it in their own voice.

> **You type:** Thank you, that's a fine blessing. I'll buy you a drink later.
>
> **Troll:** Tank ya, dat be a fine blessin'. I buy ya a drink later, mon.
> **Dwarf:** Thank ye, that's a fine blessin'. I'll buy ye a pint later.
> **Orc:** Aka'Magosh, that is fine blessing. I buy you drink later.
> **Undead:** Thenk yuu, thet's e fine blessing. I'll buy yuu e drink leter. Nngh.

Nobody else needs the addon. To them, you just have a very consistent accent.

## Four accents, two strengths

Orcs, trolls, dwarves and Forsaken start in their own accent. Anyone else can pick one with `/acc accent` (a human raised in Ironforge? Sure.).

Turn on **thick** (`/acc thick on`) and it gets heavier:

- **Orcs** talk like grunts: "You ready? We must go now. Me hungry."
- **Trolls** go full Darkspear: "Ya wanna come wit' us ta da dungeon?"
- **Dwarves** speak broad Scots with some Gaelic: "D'ye want tae come? Mìle taing, that wis awfy kind o' ye."
- **Undead** lose their jaw altogether. Lip sounds are gone, every s comes out slushy, and now and then something wet slips out mid-line: "Hhleashe, shlrk, ghe quiet."

Every line comes out a little different. Some words swap at random, and now and then an opener, a tag or a closer that fits the line gets added: *Lok'tar ogar!* for a fight, *Aka'Magosh* for a thanks, *Dabu?* for a question.

## Jawless to jawless

A jawless undead is slush to everyone around... except another jawless undead. If they have EzAccent set to undead thick, they read what you meant after your line, in grey:

> **Bob says:** Yusht shtay shtill. Ghk. *(Just stay still.)*

Everyone else only gets the slush. Lean into it.

## The box

Bind a key under **Options > Keybindings > EzAccent** (or type `/acc box`). A small chat-style box opens: type, press Enter, and it goes out in your accent.

- **The channel sits at the start of the line**, like in chat: `Say:`, `Party:`, `Tell Jaina Proudmoore:`. It stays there until you change it.
- **Switch the way you already do in chat**: start the line with `/p `, `/g `, `/y `, `/r `, `/e ` or `/w name `.
- **No surnames to remember.** `/w jaina ` fills in "Proudmoore" if she's your target, whispered with you, or is in your group. Tab cycles through those people.
- **Click the channel** for a list of every channel and everyone you can whisper.
- **Up and Down** bring back your earlier lines, channel and all.

## Small things

- **Lad or lass.** Talking to a woman, she's a "lass", not a "lad", and a thick troll calls her "sistah". Words you typed yourself are never changed.
- **Emotes** only accent the "quoted speech": `/acc e grins. "Ready when you are."`
- **Chat links, raid marks** like `{skull}` and `%t` come through untouched.
- **Long lines** lose their extras first, then go out in pieces. In say, yell and emotes the game lets an addon send one message per key press, so the box waits with the rest: press Enter for each (or `/acc more`).
- **Try before you speak.** `/acc test <text>` prints a few versions in your own chat and sends nothing.
- It only ever sends something when you press a key or type a command. It never speaks by itself.
- **WoW Forever and Classic Era**, from one download.

## Commands

`/acc` or `/ezaccent`

| Command | Does |
|---|---|
| `/acc <text>` | Say it in your accent |
| `/acc y` / `p` / `g` / `o` / `r` / `e` `<text>` | Yell, party, guild, officer, raid or emote it |
| `/acc w <name> <text>` | Whisper it (a first name is enough for people the box knows) |
| `/acc more` | Say the next piece of a long line |
| `/acc test <text>` | Print a few versions, send nothing |
| `/acc accent [orc/troll/dwarf/undead/none/race]` | This character's accent |
| `/acc thick [on/off]` | Lay it on thick |
| `/acc share [on/off]` | Set your other addons' accents too |
| `/acc box` | Open the box |
| `/acc config` | The options (Esc > Options > AddOns > EzAccent) |

## Better with friends: the EzAddons family

EzAccent is the voice of a whole set of roleplay addons. Pick your accent once and every one of them talks the same way: change it in EzAccent and it changes in the others too, to the nearest voice each has (`/acc share off` if you'd rather keep them apart).

**They speak in your accent:**

- **Buff Me Please**: asks the right player for the right buff, in your character's personality.
- **EzBlessings**: the paladin's blessing button, with a line for every blessing you hand out.
- **Dead But Delicious**: the Forsaken food critic, with a remark about every corpse you Cannibalize (locked jaw or jawless).

**They work hand in hand with it:**

- **EzOOC**: out-of-character lines in `(( ))`, with the same kind of box. Your accent for the scene, EzOOC for the asides.
- **EzReflex**: your character answers emotes aimed at it, and cheers, mourns and duels with your group.
- **EzEmote**: an emote palette and wheels for everything your character does while they talk.
- **EzAcquaintances**: a contact book of the people you've met. Its Whisper button can open the EzAccent box already on a whisper to them.
- **EzTongues** *(coming soon)*: speak Orcish, Thalassian, Gutterspeak and more, understood only by those who know the tongue.

Every one of them is free, stands on its own, and needs nothing from the people you talk to.

## Join us on Discord

Come say hi: **[join the EzAddons Discord](https://discord.com/invite/bZrAYqbsD8)**.

- Hear about new versions first (pick the addons you care about and get pinged when they update).
- Suggest a word your accent gets wrong, a line your orc would never say, or a whole new accent.
- Report bugs, and help test what's coming next.

## Tell us what you think!

Is there a word your accent keeps getting wrong? A phrase your orc would never say? **Drop it in the [Discord](https://discord.com/invite/bZrAYqbsD8), leave a comment, or open an issue on [GitHub](https://github.com/lalibertemarc/EzAccent/issues)** and it might be in the next update.
