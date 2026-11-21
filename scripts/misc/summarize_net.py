import re

text = open(r"D:\kanre\kicad\netlists\kanre_m1_sheet2_carrier.net", encoding="utf-8").read()

print("PARTS")
for block in re.split(r"\(comp\s", text)[1:]:
    ref = re.search(r'\(ref "([^"]+)"\)', block)
    value = re.search(r'\(value "([^"]*)"\)', block)
    fp = re.search(r'\(footprint "([^"]*)"\)', block)
    if ref and not ref.group(1).startswith("#"):
        print(f"{ref.group(1)} | {value.group(1) if value else ''} | {fp.group(1) if fp else ''}")

print("NETS")
for block in re.split(r"\(net\s", text)[1:]:
    name = re.search(r'\(name "([^"]+)"\)', block)
    nodes = re.findall(r'\(ref "([^"]+)"\)\s*\(pin "([^"]+)"\)', block)
    if name and nodes:
        print(f"{name.group(1)}: " + " ".join(f"{r}.{p}" for r, p in nodes))
