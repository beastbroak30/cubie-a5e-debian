import ast, pathlib, re, sys
root = pathlib.Path(r"D:\kanre\kicad\test_exp")
local = {p.stem for p in root.glob("*.py")}
for p in sorted(root.glob("*.py")):
    src = p.read_text(encoding="utf-8", errors="replace")
    try:
        tree = ast.parse(src)
    except SyntaxError as e:
        print(p.name, "SYNTAX", e)
        continue
    mods = set()
    for n in ast.walk(tree):
        if isinstance(n, ast.Import):
            for a in n.names:
                mods.add(a.name.split(".")[0])
        elif isinstance(n, ast.ImportFrom) and n.module and n.level == 0:
            mods.add(n.module.split(".")[0])
    loc = sorted(m for m in mods if m in local)
    paths = sorted(set(re.findall(r"results[/\\][A-Za-z0-9_./\\{}-]+|streams[/\\][A-Za-z0-9_.{}-]+|nist_out[/\\][A-Za-z0-9_.{}-]+|figures[/\\][A-Za-z0-9_.{}-]+|data[/\\][A-Za-z0-9_./{}-]+", src)))
    exp = sorted(set(re.findall(r'EXP\s*=\s*"([^"]+)"', src)))
    print(f"{p.name}: local={loc} EXP={exp} paths={paths[:12]}")
