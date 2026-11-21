import json, io
d = json.load(io.open(r'D:\KANRE\kicad\artifacts\netlist-bare.json', encoding='utf-8-sig'))
refs = set()
for i in range(5, 10):
    refs |= set(d['blocks'][i]['components'])
print("### NO_CONNECT")
for nc in d['no_connect']:
    r = nc['pin'].split('.')[0]
    mark = "**" if r in refs else "  "
    print(mark, nc['pin'], "|", nc.get('reason'))
print()
print("### CALCULATIONS")
for c in d['calculations']:
    print(json.dumps(c, ensure_ascii=False))
print()
print("### HAZARDS")
for h in d['hazards']:
    print(json.dumps(h, ensure_ascii=False))
