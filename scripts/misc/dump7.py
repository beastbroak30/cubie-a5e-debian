import json, io, csv, re
d = json.load(io.open(r'D:\KANRE\kicad\artifacts\netlist-bare.json', encoding='utf-8-sig'))
refs = set()
for i in range(5, 10):
    refs |= set(d['blocks'][i]['components'])

bom = {}
with io.open(r'D:\KANRE\kicad\artifacts\bom.csv', encoding='utf-8-sig') as f:
    for row in csv.DictReader(f):
        for r in re.split(r'[,\s]+', row['Ref'].strip('"')):
            r = r.strip()
            if r:
                bom[r] = row
print("### NOT IN BOM")
for r in sorted(refs):
    if r not in bom:
        print(" ", r)
print()
print("### IN BOM")
for r in sorted(refs):
    if r in bom:
        row = bom[r]
        print(f"  {r:5s} {row['Value']:28s} {row['MPN']:26s} {row['Package']:16s} qty={row['Qty']}")
