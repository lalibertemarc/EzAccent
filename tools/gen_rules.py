"""Writes ../Rules.lua from AccentTranslator's rules.py (../../AccentTranslator), so the in-game accents stay in step
with the Python ones. Rerun after editing rules.py:

    python tools/gen_rules.py

What it ports: the word swap tables (TROLL/DWARF/ORC + *_THICK, ORC_VERBS), the undead spelling rules (LOCKED,
JAWLESS), their end sounds and the jawless drools, tags, openers, and the regexes that pick closers. Lua 5.1 has no regex, so every
pattern is expanded into plain phrases ("(?:is|are) going to" -> "is going to", "are going to"); anything this
script doesn't understand stops it with an error instead of porting it wrong.

A few literals live inside rules.accented() rather than at module level; INLINE below copies them, and the script
checks each one still appears in that function's source. The logic itself (rules.accented and its helpers) is
hand-ported in ../Accent.lua.
"""
import inspect
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT.parent / "AccentTranslator"))
import rules  # noqa: E402

# Lookbehinds rules.py puts in front of a phrase -> the condition name Accent.lua checks.
AFTER = {r"(?<=[\w}'] )": "word", r"(?<=, )": "comma"}

# Copied from rules.accented(); each string must still appear in its source.
INLINE = {
    "ORC_PRE": [(r"I'm not going to", "I will not"), (r"(?:is|are|am) not going to", "will not"),
                (r"(?:is|are|am) going to", "will")],
    "ORC_VERB_RULE": "(?:is|are) {v}",
    "TAGGED": r"(?i)\b(?:mon|lad|charaid)\b",
    "MOJO": r"(?i)loa|juju|mojo|spirits|bwonsamdi|voodoo",
    "DRINK": r"(?i:pint|drink|ale)",
    "DABU": r"(?i)dabu",
    "OPENED": r"(?i)(?:och|ach|ey|hey|ooh|hrm|bah|throm)",
    "TROLL_THANKS": ["Good juju.", "Da loa bless ya."],
    "TROLL_GLOOM": ["Bad mojo.", "Da spirits don' like it."],
    "TROLL_ANY": ["Da loa be watchin'.", "Da spirits be tellin' me so.", "Dat be strong juju."],
    "ORC_FIGHT": "Lok'tar ogar!",
    "ORC_ANY": ["Zug zug.", "Lok'tar!"],
    "ORC_THANKS": "Dabu.",
    "DWARF_TAG": ", a charaid",
    "DWARF_CHEERS": "Slàinte mhath!",
    "DWARF_ANY": "Seadh.",
}


def check_inline():
    src = inspect.getsource(rules.accented)
    for key, value in INLINE.items():
        items = value if isinstance(value, list) else [value]
        for item in items:
            for s in (item if isinstance(item, tuple) else (item,)):
                if s not in src:
                    sys.exit(f"INLINE[{key}]: {s!r} is no longer in rules.accented(). Update gen_rules.py.")


def split_top(p, sep="|"):
    """p split on sep outside parentheses and brackets."""
    out, depth, cur, i = [], 0, "", 0
    while i < len(p):
        c = p[i]
        if c == "\\":
            cur += p[i:i + 2]
            i += 2
            continue
        if c in "([":
            depth += 1
        elif c in ")]":
            depth -= 1
        if c == sep and depth == 0:
            out.append(cur)
            cur = ""
        else:
            cur += c
        i += 1
    out.append(cur)
    return out


def closing(p, i):
    depth = 0
    for j in range(i, len(p)):
        if p[j] == "(":
            depth += 1
        elif p[j] == ")":
            depth -= 1
            if depth == 0:
                return j
    sys.exit(f"Unbalanced pattern: {p!r}")


def expand(p):
    """Every plain phrase a pattern of literals, | and (?:...) groups matches, in the order the regex tries them."""
    out = []
    for alt in split_top(p):
        seqs, i = [""], 0
        while i < len(alt):
            if alt.startswith("(?:", i):
                j = closing(alt, i)
                inner = expand(alt[i + 3:j])
                seqs = [s + x for s in seqs for x in inner]
                i = j + 1
            elif alt[i] in "\\()[]{}?*+.^$":
                sys.exit(f"Can't port {alt[i]!r} in pattern {p!r}. Teach gen_rules.py, or reword the rule.")
            else:
                seqs = [s + alt[i] for s in seqs]
                i += 1
        out += seqs
    return out


def word_rule(rule):
    pattern, out, *rest = rule
    after = None
    for rx, name in AFTER.items():
        if pattern.startswith(rx):
            pattern, after = pattern[len(rx):], name
    if pattern.startswith("(?<"):
        sys.exit(f"Unknown lookbehind in {pattern!r}. Add it to AFTER and to Accent.lua.")
    phrases = [s.lower() for s in expand(pattern)]
    entry = {"phrases": phrases, "out": out}
    if rest and rest[0] != 1:
        entry["chance"] = rest[0]
    if after:
        entry["after"] = after
    return entry


def spell_rule(rule):
    """(regex, out) from LOCKED/JAWLESS -> {from, to[, ahead]}: a literal, then optionally \\b or (?=[class])."""
    pattern, out = rule
    m = re.fullmatch(r"([a-z]+)(\\b|\(\?=\[([a-z]+)\]\))?", pattern)
    if not m:
        sys.exit(f"Can't port spelling rule {pattern!r}.")
    entry = {"from": m.group(1), "to": out}
    if m.group(2) == r"\b":
        entry["ahead"] = "boundary"
    elif m.group(3):
        entry["ahead"] = m.group(3)
    return entry


def detector(rx):
    """A regex used only to test a line -> {words = {...}} (whole words; "fad*" = any word starting fad) or
    {subs = {...}} (anywhere, ignoring case)."""
    rx = re.sub(r"^\(\?i\)", "", rx)
    rx = re.sub(r"^\(\?i:(.*)\)$", r"\1", rx)
    m = re.fullmatch(r"\\b\(\?:(.*)\)\\b", rx)
    if m:
        words = []
        for w in split_top(m.group(1)):
            if w.endswith(r"\w*"):
                words.append(w[:-3] + "*")
            elif re.fullmatch(r"[\w' ]+", w):
                words.append(w)
            else:
                sys.exit(f"Can't port {w!r} in {rx!r}.")
        return {"words": [w.lower() for w in words]}
    m = re.fullmatch(r"\(\?:(.*)\)", rx)
    if m:  # anchored at the start of the line: Accent.lua decides that, this just lists them
        rx = m.group(1)
    subs = []
    for s in split_top(rx):
        cls = re.fullmatch(r"\[(.*)\]", s)
        if cls:
            subs += list(cls.group(1))
        elif re.fullmatch(r"[\w' -]+", s):
            subs.append(s)
        else:
            sys.exit(f"Can't port {s!r} in {rx!r}.")
    # Lua's lower() leaves non-ASCII bytes alone, so those keep both cases.
    seen = []
    for s in subs:
        s = s.lower() if s.isascii() else s
        if s not in seen:
            seen.append(s)
    return {"subs": seen}


# --- Lua output ------------------------------------------------------------------------------------------------------

def lua_str(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def lua(v, indent=""):
    if isinstance(v, str):
        return lua_str(v)
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        return repr(v)
    if isinstance(v, (list, tuple)):
        return "{ " + ", ".join(lua(x, indent) for x in v) + " }"
    if isinstance(v, dict):
        return "{ " + ", ".join(f"{k} = {lua(x, indent)}" for k, x in v.items()) + " }"
    raise TypeError(v)


def lua_list(name, entries):
    return f"{name} = {{\n" + "".join(f"    {lua(e)},\n" for e in entries) + "}\n"


def main():
    check_inline()
    out = ["-- Generated by tools/gen_rules.py from AccentTranslator's rules.py. Don't edit by hand: edit rules.py "
           "and rerun.\n",
           "-- Word rules: { phrases = {...}, out = string or {pick one}, chance?, after? = \"word\" (a word and a "
           "space before)\n",
           "-- or \"comma\" (\", \" before) }. Phrases are lowercase and matched as whole words, first rule wins.\n",
           "local _, ns = ...\n\n"]

    orc_pre = INLINE["ORC_PRE"] + [(INLINE["ORC_VERB_RULE"].format(v=v), s) for v, s in rules.ORC_VERBS.items()]
    tables = {
        "troll": rules.TROLL, "troll_thick": rules.TROLL_THICK,
        "dwarf": rules.DWARF, "dwarf_thick": rules.DWARF_THICK,
        "orc": rules.ORC, "orc_thick": rules.ORC_THICK, "orc_pre": orc_pre,
    }
    out.append("ns.WORDS = {}\n")
    for key, rule_list in tables.items():
        out.append(lua_list(f"ns.WORDS.{key}", [word_rule(r) for r in rule_list]))

    out.append("\n-- Undead spelling swaps, in order: { from, to, ahead? = \"boundary\" or letters one of which must "
               "follow }.\n")
    out.append(lua_list("ns.LOCKED", [spell_rule(r) for r in rules.LOCKED]))
    out.append(lua_list("ns.JAWLESS", [spell_rule(r) for r in rules.JAWLESS]))
    out.append(f"ns.STRAINS = {lua(rules.STRAINS)}\n")
    out.append(f"ns.GURGLES = {lua(rules.GURGLES)}\n")
    out.append("-- Jawless only: sometimes one of these mid-line, at a comma or between sentences.\n")
    out.append(f"ns.DROOLS = {lua(rules.DROOLS)}\n")
    out.append(f"ns.DROOL_CHANCE = {lua(rules.DROOL_CHANCE)}\n\n")

    out.append(f"ns.TAGS = {lua(rules.TAGS)}\n")
    out.append(f"ns.TAG_CHANCE = {lua(rules.TAG_CHANCE)}\n")
    for name, src in (("OPENERS", rules.OPENERS), ("THICK_OPENERS", rules.THICK_OPENERS)):
        out.append(f"ns.{name} = {lua({k: {'list': v[0], 'chance': v[1]} for k, v in src.items()})}\n")

    out.append("\n-- Tests on a line: words = whole words (\"fad*\" = starting with fad), subs = anywhere; both "
               "ignore case.\n")
    detectors = {"THANKS": rules.THANKS, "FIGHT": rules.FIGHT, "GLOOM": rules.GLOOM, "ORCISH": rules.ORCISH,
                 "GAELIC": rules.GAELIC, "TAGGED": INLINE["TAGGED"], "MOJO": INLINE["MOJO"],
                 "DRINK": INLINE["DRINK"], "DABU": INLINE["DABU"], "OPENED": INLINE["OPENED"]}
    out.append("ns.TEST = {\n" + "".join(f"    {k} = {lua(detector(v))},\n" for k, v in detectors.items()) + "}\n\n")

    closers = {k: INLINE[k] for k in ("TROLL_THANKS", "TROLL_GLOOM", "TROLL_ANY", "ORC_FIGHT", "ORC_ANY",
                                      "ORC_THANKS", "DWARF_TAG", "DWARF_CHEERS", "DWARF_ANY")}
    out.append("ns.CLOSERS = {\n" + "".join(f"    {k} = {lua(v)},\n" for k, v in closers.items()) + "}\n")

    path = ROOT / "Rules.lua"
    path.write_text("".join(out), encoding="utf-8", newline="\n")
    print(f"Wrote {path}")


if __name__ == "__main__":
    main()
