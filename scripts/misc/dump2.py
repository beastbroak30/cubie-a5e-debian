import json, io
d = json.load(io.open(r'D:\KANRE\kicad\artifacts\netlist-bare.json', encoding='utf-8-sig'))
refs = set()
for i in range(5, 10):
    refs |= set(d['blocks'][i]['components'])
print("REFS:", sorted(refs))
print()
for n in d['nets']:
    hit = [p for p in n['pins'] if p.split('.')[0] in refs]
    if hit:
        print("NET:", n['name'], "| class:", n.get('class'))
        print("  PINS:", ", ".join(n['pins']))
        print("  REASON:", n.get('reason', ''))
        print()
