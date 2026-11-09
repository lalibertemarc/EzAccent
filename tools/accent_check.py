"""Checks the accents end to end after any change to AccentTranslator's rules.py or EzAccent's Accent.lua:

    python tools/accent_check.py           # all four checks
    python tools/accent_check.py --fix     # first regenerate every generated file and copy Accent.lua's body

1. Generated: Rules.lua and every addon's AccentRules.lua are what gen_rules.py writes from rules.py now.
2. Copies: every Accent.lua copy is byte-identical to EzAccent's below its header (EzMinion's and Dead But
   Delicious's trimmed copies to each other).
3. Parity: the Lua port says every line of tests/corpus.txt exactly as rules.py does, with the dice fixed both ways
   (every chance off, then every chance on), in every accent, light and thick.
4. Smoke: lua tests/accents.lua (corpus + cases).

Exits 1 if any check fails. The copies and generated targets are CLAUDE.md's "Shared code" table.
"""
import argparse
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent          # EzAccent
WORKSPACE = ROOT.parent
sys.path.insert(0, str(ROOT / "tools"))
import gen_rules  # noqa: E402  (puts AccentTranslator on the path too)
rules = gen_rules.rules

FULL_COPIES = ["BuffMePlease", "CuriousStranger", "Bones", "FortuneTeller", "EzBlessings"]
UNDEAD_COPIES = ["EzMinion", "DeadButDelicious"]
MARK = "local _, ns = ..."
ROLLS = (0.999, 0.0)
LUA = shutil.which("lua") or r"C:\wingm\bin\lua.exe"


def read(path):
    return path.read_text(encoding="utf-8").replace("\r\n", "\n")


def body(path):
    text = read(path)
    return text[text.index(MARK):]


def generated():
    """{path: what gen_rules.py writes there now}."""
    every, undead = "".join(gen_rules.all_accents()), "".join(gen_rules.undead_only())
    out = {ROOT / "Rules.lua": every}
    out.update({WORKSPACE / a / "AccentRules.lua": every for a in FULL_COPIES})
    out.update({WORKSPACE / a / "AccentRules.lua": undead for a in UNDEAD_COPIES})
    return out


def write_keeping_endings(path, text):
    old = path.read_bytes() if path.exists() else b""
    data = text.encode("utf-8")
    if b"\r\n" in old:
        data = data.replace(b"\n", b"\r\n")
    path.write_bytes(data)


def fix():
    for path, text in generated().items():
        if read(path) != text:
            write_keeping_endings(path, text)
            print(f"  regenerated {path.relative_to(WORKSPACE)}")
    src = body(ROOT / "Accent.lua")
    for a in FULL_COPIES:
        path = WORKSPACE / a / "Accent.lua"
        text = read(path)
        if text[text.index(MARK):] != src:
            write_keeping_endings(path, text[:text.index(MARK)] + src)
            print(f"  copied Accent.lua into {a}")


def check_generated():
    bad = [str(p.relative_to(WORKSPACE)) for p, text in generated().items() if read(p) != text]
    return [f"out of date (rerun gen_rules.py, or --fix): {p}" for p in bad]


def check_copies():
    src, problems = body(ROOT / "Accent.lua"), []
    for a in FULL_COPIES:
        if body(WORKSPACE / a / "Accent.lua") != src:
            problems.append(f"{a}/Accent.lua differs from EzAccent's below its header (--fix copies it)")
    a, b = (body(WORKSPACE / x / "Accent.lua") for x in UNDEAD_COPIES)
    if a != b:
        problems.append("EzMinion/Accent.lua and DeadButDelicious/Accent.lua differ below their headers "
                        "(port the change by hand)")
    return problems


class Fixed:
    """An rng whose dice always come up the same: random() = roll, choice() = the first."""
    def __init__(self, roll):
        self.roll = roll

    def random(self):
        return self.roll

    def choice(self, seq):
        return seq[0]


def accents():
    return [a for a in ("orc", "troll", "dwarf", "tauren", "undead") if a == "undead" or a in rules.TAGS]


def check_parity():
    problems = []
    for roll in ROLLS:
        run = subprocess.run([LUA, "tests/parity.lua", str(roll), *accents()], cwd=ROOT, capture_output=True,
                             text=True, encoding="utf-8")
        if run.returncode:
            return [f"tests/parity.lua failed:\n{run.stderr}"]
        for row in run.stdout.splitlines():
            accent, thick, line, lua_said = row.split("\t")
            py_said = rules.accented(accent, line, thick == "1", Fixed(roll))
            if py_said != lua_said:
                problems.append(f"{accent}{' thick' if thick == '1' else ''}, dice {roll}: {line}\n"
                                f"      rules.py:   {py_said}\n      Accent.lua: {lua_said}")
    return problems


def check_smoke():
    run = subprocess.run([LUA, "tests/accents.lua"], cwd=ROOT, capture_output=True, text=True, encoding="utf-8")
    print("  " + (run.stdout.strip().splitlines() or ["(no output)"])[-1])
    return [] if run.returncode == 0 else [run.stdout + run.stderr]


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--fix", action="store_true", help="regenerate and copy first")
    args = ap.parse_args()
    if args.fix:
        fix()
    failed = False
    for name, check in (("generated", check_generated), ("copies", check_copies), ("parity", check_parity),
                        ("smoke", check_smoke)):
        problems = check()
        print(f"{name}: {'OK' if not problems else f'{len(problems)} problem(s)'}")
        for p in problems[:30]:
            print("  " + p)
        failed = failed or bool(problems)
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
